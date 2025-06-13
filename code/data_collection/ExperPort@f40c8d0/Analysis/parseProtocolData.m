function parsedProtocolData = parseProtocolData(protocol_data,varargin)
    % right now this is very PBups centric but could be easily generalized.
    % I just don't know what fields I'd want for other tasks.
    % anyway this takes the raw "protocol data" data structures from bdata
    % and turns them into a parsed data structure with the fields we
    % actually care about.
    p=inputParser;
    p.KeepUnmatched=true;
    p.addParamValue('removeViolations',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParamValue('remove_cpoke_tup',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParamValue('removeUserDefinedBups',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParamValue('onlyUserDefinedBups',false,@(x)validateattributes(x,{'logical'},{'scalar'}));  
    p.addParamValue('requireOptoSession',false,@(x)validateattributes(x,{'logical'},{'scalar'}));  
    p.addParamValue('maxBupDiff',Inf);
    p.addParamValue('maxTotalBups',Inf);    
    p.parse(varargin{:});
    params=p.Results;
    try
        PB_set_constants;
    end
    if isfield(protocol_data,'peh')
        pehSupplied=true;
    else
        pehSupplied=false;
        %error('You must supply parsed events history.');
    end
    parsedProtocolData = struct('sides',[],'hits',[],'violations',[],'cpoke_tups',[],'bupDiffs',[],'totalBups',[],...
        'gammas',[],'choices',[],'stim_duration',[],'bupsdata',[],'leftbups',[],'rightbups',[],...
        'min_ISI_left',[],'min_ISI_right',[],'min_ISI_correct',[],'nleft',[],'nright',[],'is_user_defined_bup',[],...
        'stimdata',[],'ratname','','sessid',[],'sessiondate','','cookingTime',[],'RR_right_reward_prob',[],'RR_left_reward_prob',[],'reward_type',[]);      
    if isempty(protocol_data.pd)
        warning('Empty protocol data.');
        return
    end     
    if pehSupplied && any(size(protocol_data.pd)~=size(protocol_data.peh))
        error('pd and peh must be the same size.');
    end  
    fieldNames=fieldnames(parsedProtocolData);       
    for i=1:length(protocol_data.pd)
        %%
        protocol_data.pd{i} = makeFieldLengthsUniform(protocol_data.pd{i});
        hits = protocol_data.pd{i}.hits;  
        ratname = cell(length(hits),1);
        if isfield(protocol_data,'sessid')
            sessid = repmat(protocol_data.sessid(i),length(hits),1);
        end
        sessiondate = cell(length(hits),1);
        if isfield(protocol_data,'ratname')
            if iscell(protocol_data.ratname)
                ratname = protocol_data.ratname(i);
            else
                ratname = {protocol_data.ratname};            
            end        
        end
        if exist('cerebro_rats','var') && ismember(ratname{1},cerebro_rats)
            implant = cerebro_implants.(ratname{1});            
            cookingTime = repmat(round(days(datetime(datestr(protocol_data.sessiondate{i}))-datetime(datestr(implant.surgery_date)))),length(hits),1);
        else
            cookingTime = repmat(NaN,length(hits),1);
        end
        if isfield(protocol_data,'sessiondate')
            sessiondate(:) = protocol_data.sessiondate(i);
        end
        if isempty(hits)
            parsedProtocolData.violationRate(i)=NaN;
            continue
        end
        
        if isfield(protocol_data.pd{i},'reward_type')
            reward_type=string(categorical(protocol_data.pd{i}.reward_type));
            reward_type(reward_type=="reward_reversal")="r";
        else
            reward_type = repmat(string(""),numel(hits),1);
        end
        
        
        
        
        sides = protocol_data.pd{i}.sides;
        violations = protocol_data.pd{i}.violations;   
        if ~isfield(protocol_data.pd{i},'cpoke1_tups')
            cpoke_tups = false(size(violations));
        else
            cpoke_tups = protocol_data.pd{i}.cpoke1_tups~=0;
        end
        if isfield(protocol_data.pd{i},'stimdata')
            stimdata = protocol_data.pd{i}.stimdata;
            if exist('cerebro_rats','var') && ismember(ratname{1},cerebro_rats)
                opsinname = opsin.(ratname{1});                
                for t=1:length(stimdata) 
                    stimdata{t}.ison=logical(stimdata{t}.ison);
                    if isfield(stimdata{t},'power')
                        if stimdata{t}.power==0
                            stimdata{t}.ison=false;
                        end
                    else
                       stimdata{t}.power = -1; 
                    end
                    stimdata{t}.opsin=opsinname;
                    if stimdata{t}.power>-1
                        stimdata{t}.mW = implant.linearFit(1)*stimdata{t}.power + implant.linearFit(2);
                        stimdata{t}.mW = max(0,stimdata{t}.mW);
                    end
                    stimdata{t}.hemisphere = implant.hemisphere;
                    stimdata{t}.region = implant.region;
                    stimdata{t}.nm = implant.wavelength;
                end
            end   
        else
            stimdata={};
        end
        if params.requireOptoSession
           if isempty(stimdata) || ~any(cellfun(@(x)x.ison,stimdata)) || (isfield(stimdata{1},'mW') && ~any(cellfun(@(x)x.mW,stimdata)>0) && exist('cerebro_rats','var') && ismember(ratname{1},cerebro_rats) )
               continue
           end
        end
        if length(protocol_data.pd{i}.bupsdata)-length(protocol_data.pd{i}.violations) == 1 % there always seems to be an extra bupsdata entry!  
            bupsdata = protocol_data.pd{i}.bupsdata;
        elseif length(protocol_data.pd{i}.bupsdata)-length(protocol_data.pd{i}.violations) == 0
            bupsdata = protocol_data.pd{i}.bupsdata;            
        else
            error('Unusual length of bupsdata field in pd.');
        end
        if isfield(bupsdata{1},'user_defined_bup')
            is_user_defined_bup = cellfun(@(x)x.user_defined_bup,bupsdata);
        else
            is_user_defined_bup = false(size(bupsdata));
        end
        gammas=cellfun(@(x)x.gamma,bupsdata); 
        stim_duration = protocol_data.pd{i}.samples;   
        [protocol_data.pd{i}.n_left,protocol_data.pd{i}.n_right,min_ISI_left,min_ISI_right] = deal(NaN(length(stim_duration),1));
        for x=1:length(stim_duration)
            bupsdata{x}.left = bupsdata{x}.left(bupsdata{x}.left<=stim_duration(x));
            bupsdata{x}.right = bupsdata{x}.right(bupsdata{x}.right<=stim_duration(x));
            protocol_data.pd{i}.n_left(x) = length(bupsdata{x}.left);
            protocol_data.pd{i}.n_right(x) = length(bupsdata{x}.right);   
            if numel(bupsdata{x}.left)>1
                min_ISI_left(x) = min(diff(bupsdata{x}.left));
            end
            if numel(bupsdata{x}.right)>1
                min_ISI_right(x) = min(diff(bupsdata{x}.right));
            end            
        end            
        leftbups=cellfun(@(x)x.left,bupsdata,'UniformOutput',false);
        rightbups=cellfun(@(x)x.right,bupsdata,'UniformOutput',false);               
        nleft = protocol_data.pd{i}.n_left;
        nright = protocol_data.pd{i}.n_right;        
        if isfield(protocol_data.pd{i},'RR_right_reward_prob')
            RR_right_reward_prob = protocol_data.pd{i}.RR_right_reward_prob;
            RR_left_reward_prob = protocol_data.pd{i}.RR_left_reward_prob;      
            RR_right_reward_prob = cat(1,RR_right_reward_prob{:});
            RR_left_reward_prob = cat(1,RR_left_reward_prob{:});
        else
            RR_left_reward_prob=nleft*NaN;
            RR_right_reward_prob=nleft*NaN;            
        end
        totalBups = nright+nleft;   
        bupDiffs = nright-nleft;
        min_ISI_correct = NaN(size(min_ISI_left));
        min_ISI_correct(bupDiffs<0) = min_ISI_left(bupDiffs<0);
        min_ISI_correct(bupDiffs>0) = min_ISI_right(bupDiffs>0);
        choices=hits;                        
        nanInds = isnan(hits);
        choices(nanInds)=NaN;
        choices(~nanInds) = double((hits(~nanInds) & sides(~nanInds)=='r') | (~hits(~nanInds) & sides(~nanInds)=='l'));            
        if pehSupplied
            if isempty(protocol_data.peh{i})
                continue
            end
            states = cat(1,protocol_data.peh{i}.states);
            %% sometimes peh and pd are not the same length, so need to align the matching trials
            % right now just considering the case that there are some
            % extra trials on one side. If this doesn't cover all cases,
            % you could do something more sophisticated.
            sizeDiff = length(protocol_data.peh{i})-length(protocol_data.pd{i}.sides);     
            if sizeDiff~=0
                if ~isfield(states,'violation_state')
                    error('violation_state field required in peh');
                end
                violationsFromPeh = arrayfun(@(x)~isempty(x.violation_state),states);
                hitsFromPeh = arrayfun(@(x)~isempty(x.hit_state),states);     
                if sizeDiff>0     % peh longer than pd    
                    if all( (hitsFromPeh(1:end-sizeDiff)==hits | isnan(hits) ) & violationsFromPeh(1:end-sizeDiff)==violations)
                        states = states(1:end-sizeDiff);
                    elseif all( ( isnan(hits) | hitsFromPeh(1+sizeDiff:end)==hits ) & violationsFromPeh(1+sizeDiff:end)==violations)
                        states = states(1+sizeDiff:end); 
                    else
                        warning('Size mismatch between peh and pd which could not be resolved. Skipping session.'); 
                        continue
                    end
                else     % pd longer than peh     
                    sizeDiff=-sizeDiff;
                    if all( (isnan(hits(1:end-sizeDiff)) | hitsFromPeh==hits(1:end-sizeDiff)) & violationsFromPeh==violations(1:end-sizeDiff)  )
                        pdInds2Keep = 1 : (length(hits)-sizeDiff);
                    elseif all ( (isnan(hits(1+sizeDiff:end)) | hitsFromPeh==hits(1+sizeDiff:end) ) & violationsFromPeh==violations(1+sizeDiff:end) )
                        pdInds2Keep = (1 + sizeDiff) : length(hits);
                    else
                        warning('Size mismatch between peh and pd which could not be resolved. Skipping session.'); 
                        continue
                    end  
                    for f=1:length(fieldNames)
                       if strcmp(fieldNames{f},'stimdata')
                           if isfield(protocol_data.pd{i},'stimdata')
                                eval([fieldNames{f},' = ',fieldNames{f},'(pdInds2Keep);']);
                           end
                       else
                           if ~isscalar(eval(fieldNames{f}))
                            eval([fieldNames{f},' = ',fieldNames{f},'(pdInds2Keep);']);
                           end
                       end                           
                   end  
                   nanInds = nanInds(pdInds2Keep);                    
                end
            end        
            left_rewards = logical(cellfun(@length,{states.left_reward}))';
            right_rewards = logical(cellfun(@length,{states.right_reward}))';            
            if any(left_rewards & right_rewards)
                error('Error in parsed event history: some trials have both left and right rewards.');
            end
            anomalousRewardTrials = false(size(hits));            
            anomalousRewardTrials(~nanInds) = ( (hits(~nanInds) & sides(~nanInds)=='r') & ~right_rewards(~nanInds)) | ( (hits(~nanInds) & sides(~nanInds)=='l') & ~left_rewards(~nanInds)) ;          
            if any ( anomalousRewardTrials )
                %error('Disagreement between pd and peh: some trials have no rewards but hits and sides say there should be.');
            end
            choices(sides=='f') = right_rewards(sides=='f');  
            badTrials=anomalousRewardTrials;                  
        else
            badTrials = false(size(hits));
        end
        if params.removeUserDefinedBups
            badTrials = badTrials | is_user_defined_bup;
        end
        if params.onlyUserDefinedBups
            badTrials = badTrials | ~is_user_defined_bup;            
        end
        if isfinite(params.maxBupDiff)
            badTrials = badTrials | abs(bupDiffs)>params.maxBupDiff;
        end
        if isfinite(params.maxTotalBups)
            badTrials = badTrials | abs(totalBups)>params.maxTotalBups;
        end  
        violations = isnan(hits);
        violationRate = sum(violations)./length(violations);
        percentCorrect = nansum(hits)./length(hits);
        if params.removeViolations
            badTrials = badTrials | violations ;
        end          
        if params.remove_cpoke_tup
            badTrials = badTrials | cpoke_tups;
        end
        if pehSupplied
            left_rewards = left_rewards(~badTrials); right_rewards = right_rewards(~badTrials); 
        end
        if i==1
            fieldNames = fieldnames(parsedProtocolData);
        end
        fieldNames = setdiff(fieldNames,'ratname');
        for f=1:length(fieldNames) 
            if exist(fieldNames{f},'var')
                eval([fieldNames{f},' = ',fieldNames{f},'(~badTrials);']);
                parsedProtocolData.(fieldNames{f}) = cat(1,parsedProtocolData.(fieldNames{f}),eval(fieldNames{f}));
            end
        end   
        if params.removeViolations
            percentCorrect = nansum(hits)./length(hits);
            if isempty(percentCorrect)
                percentCorrect=NaN;
            end
        end
        parsedProtocolData.violationRate(i)=violationRate;
        parsedProtocolData.percentCorrect(i) = percentCorrect;
    end
    if isempty(parsedProtocolData.stimdata)
        parsedProtocolData=rmfield(parsedProtocolData,'stimdata');
    end
    if isfield(parsedProtocolData,'stimdata')
        stimdata = mergestruct(parsedProtocolData.stimdata{:},'fill',NaN,'output','structArray');
        if isfield(stimdata,'power') && numel(stimdata(1).power)>1
            for i=1:length(stimdata)
                stimdata(i).power1 = stimdata(i).power(1);
                stimdata(i).power2 = stimdata(i).power(2);
            end
        end      
        if isfield(stimdata,'power')
            stimdata = rmfield(stimdata,'power');
        end
        if ~isempty(stimdata)
            fields = fieldnames(stimdata);
            for f=1:length(fields)
                if strcmp(fields{f},'analog_output')
                    continue
                end
                if ischar(stimdata(1).(fields{f}))
                    parsedProtocolData.(fields{f}) = {stimdata.(fields{f})};                        
                else
                    parsedProtocolData.(fields{f}) = [stimdata.(fields{f})];
                end
            end
        end
        if isfield(stimdata,'analog_output') 
            for i=1:length(stimdata)
                if isstruct(stimdata(i).analog_output) 
                    fields =fieldnames(stimdata(i).analog_output);
                end
            end
        end
        if isfield(stimdata,'analog_output') 
            for i=1:length(stimdata)
                if isstruct(stimdata(i).analog_output) 
                    fields =fieldnames(stimdata(i).analog_output);
                    for f=1:length(fields)
                        if strcmp(fields{f},'voltage') || strcmp(fields{f},'waveform') || strcmp(fields{f},'time_s')
                            parsedProtocolData.(fields{f}){i} = stimdata(i).analog_output.(fields{f});
                        else
                            parsedProtocolData.(fields{f})(i) = stimdata(i).analog_output.(fields{f});                            
                        end
                    end
                elseif exist('fields','var')
                    for f=1:length(fields)
                        if strcmp(fields{f},'voltage') || strcmp(fields{f},'waveform') || strcmp(fields{f},'time_s')
                            parsedProtocolData.(fields{f}){i} = [];
                        else
                            parsedProtocolData.(fields{f})(i) = NaN;                            
                        end
                    end                    
                end
            end
        end          
    end    
end