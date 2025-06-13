function conditions = getStimConditions(parsedProtocolData,varargin)
    p=inputParser;
    p.addParamValue('splitStimConditions',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParamValue('minTrials',0,@(x)validateattributes(x,{'numeric'},{'scalar','nonnegative'}));
    p.parse(varargin{:});
    params=p.Results;
    stimFields = {'ison','channel','dur','freq','power','pre','pulse','trigger','nm','mW','power1','power2','is_sine_not_square','min_V','max_V','on_ramp_dur_s','off_ramp_dur_s'};
    stimTable = table();
    if ~any(parsedProtocolData.ison)
        conditions=struct([]);
        warning('getStimConditions found no stim trials');
        return
    end
    if isfield(parsedProtocolData,'power1') && isfield(parsedProtocolData,'power')
        parsedProtocolData = rmfield(parsedProtocolData,'power');
    end
    %% set irrelevant fields to NaN if analog stimulation
    if isfield(parsedProtocolData,'max_V')
        is_analog = parsedProtocolData.max_V>0;
    else
        is_analog = false(size(parsedProtocolData.hits));
    end
    analog_irrelevant_fields = {'power','mW','power1','power2'};
    for f=1:length(analog_irrelevant_fields)
        if isfield(parsedProtocolData,analog_irrelevant_fields{f})
            parsedProtocolData.(analog_irrelevant_fields{f})(is_analog) = NaN;
        end
    end
    sine_irrelevant_fields = {'pulse'};
    if isfield(parsedProtocolData,'max_V')
        is_sine = parsedProtocolData.is_sine_not_square==1;    
    else
        is_sine = false(size(parsedProtocolData.hits));
    end    
    for f=1:length(sine_irrelevant_fields)
        if isfield(parsedProtocolData,sine_irrelevant_fields{f})        
            parsedProtocolData.(sine_irrelevant_fields{f})(is_sine) = NaN;
        end
    end    
    %%
    parsedProtocolData.pre(parsedProtocolData.pre<0.5 | parsedProtocolData.dur>1)=0;
    parsedProtocolData.dur(parsedProtocolData.dur>1)=2;
    for i=1:length(stimFields)
        if isfield(parsedProtocolData,(stimFields{i}))
            if ~iscell(parsedProtocolData.(stimFields{i}))
                nans = isnan(parsedProtocolData.(stimFields{i}));
                if any(nans) && ~strcmp(stimFields{i},'power') && ~strcmp(stimFields{i},'mW')
                    %error('unexpected nan stim parameter');
                end
                parsedProtocolData.(stimFields{i})(nans)=0; % should only happen for power
            end
            stimTable.(stimFields{i}) = parsedProtocolData.(stimFields{i})(:);
            if strcmp(stimFields{i},'ison')
                stimTable.ison = logical(stimTable.ison);
            end
        end
    end
    [stimTable,tmp,idx] = unique(stimTable);
    conditions = table2struct(stimTable);
    stim_on_inds=[conditions.ison]>0;
    fields=fieldnames(conditions(stim_on_inds));
    for f=1:length(fields)
        if ischar(conditions(2).(fields{f}))
            is_common(f) = length(unique({conditions(stim_on_inds).(fields{f})}))==1;
        else
            is_common(f) = length(unique([conditions(stim_on_inds).(fields{f})]))==1;            
        end
    end
    not_in_common_fields=fields(~is_common);
    %not_in_common_fields = not_in_common_fields(~ismember(not_in_common_fields,{'freq','pulse'}));
    try
        PB_set_constants;
    end
    for i=1:height(stimTable)
        if ~isfield(conditions,'freq') || isempty(conditions(i).freq)
            conditions(i).freq=0;
        end
        if ~isfield(conditions,'pulse')  || isempty(conditions(i).pulse)
            conditions(i).pulse=0;
        end        
        if conditions(i).freq==0 || conditions(i).pulse==0
            pulse_label = 'continuous';
        else
            pulse_label = sprintf('%gmspulse @%gHz',conditions(i).pulse,conditions(i).freq);                
        end
        conditions(i).idx = find(idx==i);
        conditions(i).label='';
        if ~conditions(i).ison
            conditions(i).label = 'STIM OFF';
        elseif conditions(i).dur==0.5 && ( strcmp(conditions(i).trigger,'cpoke_in') || strcmp(conditions(i).trigger,'cpoke1') )
            if conditions(i).pre==0.5
                conditions(i).label = ['1st half ' pulse_label];
            elseif conditions(i).pre==1
                conditions(i).label = ['2nd half ' pulse_label];
            else
               conditions(i).label='';
            end
        elseif conditions(i).dur==2 && ( strcmp(conditions(i).trigger,'cpoke_in') || strcmp(conditions(i).trigger,'cpoke1') )
            conditions(i).label = ['2s from cpoke ' pulse_label];
        elseif conditions(i).dur==1 && conditions(i).pre==0.5 && ( strcmp(conditions(i).trigger,'cpoke_in') || strcmp(conditions(i).trigger,'cpoke1') )
            conditions(i).label = ['full trial ' pulse_label];        
        end
        if isempty(conditions(i).label)
            conditions(i).label = pulse_label;
        end
        if conditions(i).ison
            for f=1:length(not_in_common_fields) 
                if ~strcmp(not_in_common_fields{f},'pulse') && ~strcmp(not_in_common_fields{f},'freqHz')
                    conditions(i).label = [conditions(i).label sprintf(' %s=%s,',not_in_common_fields{f},num2str(conditions(i).(not_in_common_fields{f})))];
                end
            end
        end
       conditions(i).nTrials = length(conditions(i).idx);
    end
    conditions = conditions(stim_on_inds & [conditions.nTrials]>params.minTrials); % just get stim trials. otherwise you have to deal with multiple non-stim conditions
    if length(conditions)>1 && ~params.splitStimConditions
        conditions=struct();
       for i=1:2
           conditions(i).ison = logical(i-1);
           conditions(i).idx = find(logical(parsedProtocolData.ison)==conditions(i).ison);
           if isfield(parsedProtocolData,'mW')
           mW=unique(parsedProtocolData.mW(conditions(i).idx));
           if length(mW)==1
               conditions(i).mW=mW;
           else
               conditions(i).mW=NaN;
           end
           end
           if isfield(parsedProtocolData,'nm')
           nm=unique(parsedProtocolData.nm(conditions(i).idx));
           if length(nm)==1
               conditions(i).nm=nm;
           else
               conditions(i).nm=NaN;
           end           
           end
           if i==1
                conditions(i).label = 'STIM OFF';
           else 
                conditions(i).label = 'STIM ON';
           end
       end
        conditions = conditions([conditions.ison]>0 ); % just get stim trials. otherwise you have to deal with multiple non-stim conditions       
       return
    end    
end