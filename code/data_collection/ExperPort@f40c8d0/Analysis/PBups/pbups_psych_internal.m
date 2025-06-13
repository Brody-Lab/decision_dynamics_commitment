function pbups_psych_data = pbups_psych_internal(protocol_data,varargin)
        %% parse and validate inputs
        p=inputParser;
        p.KeepUnmatched=true;
        p.PartialMatching=false;
        p.addParamValue('sessNumber',NaN,@(x)validateattributes(x,{'numeric'},{}));
        p.addParamValue('subplotNo',[1 1 1],@(x)validateattributes(x,{'numeric'},{'positive','integer'}));
        p.addParamValue('axis',1,@(x)validateattributes(x,{'numeric'},{'scalar','positive','integer'}));        
        p.addParamValue('xval','gamma',@(x)validateattributes(x,{'char'},{'nonempty'}));        
        p.addParamValue('normalization','none',@(x)validateattributes(x,{'char'},{'nonempty'})); 
        p.addParamValue('percentCorrect',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
        p.addParamValue('dispersionPrctileLeft',[0 100],@(x)validateattributes(x,{'numeric'},{'<=',100,'>=',0,'integer','numel',2}));
        p.addParamValue('dispersionPrctileRight',[0 100],@(x)validateattributes(x,{'numeric'},{'<=',100,'>=',0,'integer','numel',2}));        
        p.addParamValue('plotCurves',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
        p.addParamValue('addTitle',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
        p.addParamValue('showStimTrials',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
        p.addParamValue('probeTrialsOnly',false,@(x)validateattributes(x,{'logical'},{'scalar'}));    
        p.addParamValue('nPsychBins',Inf,@(x)validateattributes(x,{'numeric'},{'scalar','positive'}));
        p.addParamValue('plotViolations',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
        p.addParamValue('splitStimConditions',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
        p.addParamValue('plotSpecial',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
        p.addParamValue('positive_choice','right',@(x)validateattributes(x,{'char'},{'nonempty'}));
        p.addParamValue('min_opto_dur',0,@(x)validateattributes(x,{'numeric'},{'scalar','nonnegative'}));
        p.parse(varargin{:});
        params=p.Results;
        try
            PB_set_constants;
        end
        params.positive_choice = validatestring(params.positive_choice,{'right','left','ipsi'},'','positive_choice');        
        params.xval = validatestring(params.xval,{'gamma','bupDiff','log_click_ratio','rl_prob_diff'},'','xval');
        params.normalization = validatestring(params.normalization,{'none','totalBups'},'','normalization');    
        %% get the session(s) asked for, chop the protocol_data structure accordingly, and extract relevant fields        
        if ~ismember('sessNumber',p.UsingDefaults)
            sessNumber = unique(params.sessNumber);
            if length(sessNumber)~=length(params.sessNumber)
                warning('Not all sessNumbers provided are unique.');
            end
            if max(sessNumber) > protocol_data.nSessions
                error('sessNumber greater than number of sessions in protocol_data');
            end
            if any(isnan(sessNumber))
                error('Some sessNumbers supplied are NaNs.');
            end     
            fields = fieldnames(protocol_data);
            for f=1:length(fields)
                if length(protocol_data.(fields{f}))==protocol_data.nSessions && ~ischar(protocol_data.(fields{f}))
                    protocol_data.(fields{f}) = protocol_data.(fields{f})(sessNumber);
                end
            end
            protocol_data.nSessions = length(sessNumber);
            parsedProtocolData = parseProtocolData(protocol_data,varargin{:},'protocol','PBups.*');            
        else
            parsedProtocolData = parseProtocolData(protocol_data,varargin{:},'protocol','PBups.*');            
        end
        %% ideally probe trials only flag should be used in parsedProtocolData but right now there's no general way for it to know. so i have to use a hack here (stimdur==1)
        if isempty(parsedProtocolData.choices)
            warning('No useable trials.');
        end
        if params.showStimTrials && ~isfield(parsedProtocolData,'ison')
            warning('Cannot show stim trials. No stimdata field found in protocol data.');
            params.showStimTrials=false;
        end
        if params.probeTrialsOnly
           probe_trials = parsedProtocolData.stim_duration>0.99 & abs(parsedProtocolData.gammas)<10 ;%& ismember(parsedProtocolData.freq',[0 20]) ; % HACK
            fields = fieldnames(parsedProtocolData);
            nTrials = length(parsedProtocolData.sides);
            for f=1:length(fields)
                if length(parsedProtocolData.(fields{f})) == nTrials
                    parsedProtocolData.(fields{f}) = parsedProtocolData.(fields{f})(probe_trials);
                end
            end
        end       
            %keepTrials = parsedProtocolData.left_dispersion_prctile>=params.dispersionPrctileLeft(1) & ...
         %   parsedProtocolData.left_dispersion_prctile<=params.dispersionPrctileLeft(2) & ...
          %  parsedProtocolData.right_dispersion_prctile>=params.dispersionPrctileRight(1) & ...
           % parsedProtocolData.right_dispersion_prctile<=params.dispersionPrctileRight(2) ; 
%         if any(~keepTrials)
%             fields=fieldnames(parsedProtocolData);
%             for f=1:length(fields)
%                 parsedProtocolData.(fields{f}) = parsedProtocolData.(fields{f})(keepTrials);
%             end
%         end
        %% figure out what the x-value of the psychometric curve is
        switch params.xval
            case 'gamma'
                switch params.positive_choice
                    case 'left'
                        levelname = '\gamma, i.e. log(L/R click rate)';
                    case 'right'
                        levelname = '\gamma, i.e. log(R/L click rate)';                    
                    case 'ipsi'
                        levelname = '\gamma, i.e. log(ipsi/contra click rate)';                    
                end
                signals=parsedProtocolData.gammas;
            case 'bupDiff'
                signals = parsedProtocolData.bupDiffs;
                switch params.normalization
                    case 'none'
                        switch params.positive_choice
                            case 'left'
                                levelname = 'Click Difference (#L-#R)';                        
                            case 'right'
                                levelname = 'Click Difference (#R-#L)';                                                    
                            case 'ipsi'
                                levelname = 'Click Difference (ipsi-contra)';
                        end
                    case 'total'
                        warning('off','MATLAB:divideByZero');
                        signals = signals./parsedProtocolData.totalBups;
                        warning('on','MATLAB:divideByZero');                        
                        signals(~parsedProtocolData.totalBups)=0;
                        switch params.positive_choice
                            case 'left'
                                levelname = 'Normalized Click Difference (L-R)/(L+R)';                        
                            case 'right'
                                levelname = 'Normalized Click Difference (R-L)/(R+L)';                                                    
                            case 'ipsi'
                                levelname = 'Normalized Click Difference (ipsi-contra)/(ipsi+contra)';                                                                                    
                        end
                end
            case 'log_click_ratio'
                switch params.positive_choice
                    case 'right'
                        levelname = 'log ( #R / #L )';
                    case 'left'
                        levelname = 'log ( #L / #R )';                    
                    case 'ipsi'
                        levelname = 'log ( #ipsi / #contra )';       
                end
                signals = log(parsedProtocolData.nright ./ parsedProtocolData.nleft);
                
            case 'rl_prob_diff'
                switch params.positive_choice
                    case 'right'
                        levelname = 'R - L reward prob.';
                    case 'left'
                        levelname = 'L - R reward prob.';                 
                    case 'ipsi'
                        levelname = 'ipsi - contra reward prob';     
                end
                signals = parsedProtocolData.RR_right_reward_prob - parsedProtocolData.RR_left_reward_prob;
        end               
        %% if any FC or side LED trials, add "special values" to plot  
        extraSignal = abs(parsedProtocolData.gammas)>90;
        leftLED = extraSignal & parsedProtocolData.sides=='l';
        rightLED = extraSignal & parsedProtocolData.sides=='r';
        if strcmp(params.positive_choice,'ipsi')
            leftLED = extraSignal & parsedProtocolData.sides=='l' | strcmp(parsedProtocolData.hemisphere,'left');
            rightLED = extraSignal & parsedProtocolData.sides=='r' | strcmp(parsedProtocolData.hemisphere,'left');
        end
        freeChoice = parsedProtocolData.sides=='f' & parsedProtocolData.reward_type~="r"; 
        if ~params.plotSpecial
           freeChoice=false;
           leftLED=false;
           rightLED=false;
           fields=fieldnames(parsedProtocolData);
           nTrials = length(parsedProtocolData.hits);
           for f=1:length(fields)
                if length(parsedProtocolData.(fields{f}))==nTrials
                    parsedProtocolData.(fields{f}) = parsedProtocolData.(fields{f})(~extraSignal);
                end
           end
           signals = signals(~extraSignal);           
        end
        count=0;
        if any(freeChoice)
            count=count+1;
            specialVals(count) = -1003;
            specialLabels{count} = 'Free Choice';
            signals(freeChoice) = specialVals(count);                                        
            specialPos(count) = 0;
            specialRewarded(count) = 2;
        end                     
        if any(leftLED)
            count=count+1;
            specialVals(count) = -1001;
            specialLabels{count} = 'Left LED';
            if strcmp(params.positive_choice,'ipsi')
                specialLabels{count} = 'Contra LED';
            end
            signals(leftLED) = specialVals(count);
            if strcmp(params.positive_choice,'left')
                specialPos(count) = max(signals)+1;       
            else
                specialPos(count) = min(signals(signals>-1000))-1;       
            end
            specialRewarded(count) = 0;
        end
        if any(rightLED)
            count=count+1;
            specialVals(count) = -1002;
            specialLabels{count} = 'Right LED';
            if strcmp(params.positive_choice,'ipsi')
                specialLabels{count} = 'Ipsi LED';
            end            
            signals(rightLED) = specialVals(count);       
            if ~strcmp(params.positive_choice,'left')
                specialPos(count) = max(signals)+1;       
            else
                specialPos(count) = min(signals(signals>-1000))-1;       
            end
            specialRewarded(count) = 1;
        end 
        %%  call psychometrics.m
        if params.addTitle
            if ischar(protocol_data.ratname)
                if protocol_data.nSessions>1
                    titleText = {['Rat ',protocol_data.ratname,' - ',protocol_data.sessiondate{1},' to ',protocol_data.sessiondate{end}],[num2str(protocol_data.nSessions),' sessions',' - ',num2str(length(parsedProtocolData.choices)),' trials']};
                else
                    titleText = {['Rat ',protocol_data.ratname],[protocol_data.sessiondate{1},' - ',num2str(length(parsedProtocolData.choices)),' trials']};                
                end
            else
                dates=unique(protocol_data.sessiondate);
                if length(dates)>1
                    titleText = {['Rats ',strjoin(unique(protocol_data.ratname'),','),' - ',dates{1},' to ',dates{end}],[num2str(protocol_data.nSessions),' sessions',' - ',num2str(length(parsedProtocolData.choices)),' trials']};                    
                else
                    titleText = {['Rats ',strjoin(unique(protocol_data.ratname'),',')],[dates{1},' - ',num2str(length(parsedProtocolData.choices)),' trials']};                                    
                end
            end
        else
            titleText='';
        end
        if ~all(params.subplotNo==1) && params.plotCurves
            subplot(params.subplotNo(1),params.subplotNo(2),params.subplotNo(3));hold on
        end        
        if ~ismember('axis',p.UsingDefaults) && params.plotCurves
           axes(params.axis); 
        end
        if params.plotViolations
            behavioral_param = parsedProtocolData.violations;
            ylabel = 'Fraction Violated';
        else
            behavioral_param = parsedProtocolData.choices;
            ylabel = 'Fraction Chose Right';
        end
        switch params.positive_choice
            case 'left'
                signals = -signals;
                if ~params.plotViolations
                    behavioral_param = ~behavioral_param;
                    ylabel = 'Fraction Chose Left';
                end
            case 'ipsi'
                signals(strcmp(parsedProtocolData.hemisphere,'left'))=-signals(strcmp(parsedProtocolData.hemisphere,'left'));
                if ~params.plotViolations
                    behavioral_param(strcmp(parsedProtocolData.hemisphere,'left')) = ~behavioral_param(strcmp(parsedProtocolData.hemisphere,'left'));
                    ylabel = 'Fraction Chose Ipsi';
                end
        end
        if params.nPsychBins==1
            levelname='';
        end        
        if params.showStimTrials
            conditions = getStimConditions(parsedProtocolData,'splitStimConditions',params.splitStimConditions,'minTrials',1);            
            if isfield(protocol_data,'ratname') && ischar(protocol_data.ratname)
                daysSinceSurgery = minmax(parsedProtocolData.cookingTime);
                if exist('cerebro_rats','var') && ismember(protocol_data.ratname,cerebro_rats)
                    if length(conditions)==1
                        textboxstring = {protocol_data.ratname,[cerebro_implants.(protocol_data.ratname).hemisphere,...
                            ' ',cerebro_implants.(protocol_data.ratname).region],sprintf('%g to %g days since Sx',daysSinceSurgery(1),daysSinceSurgery(2)),...
                            opsin.(protocol_data.ratname),conditions.label,sprintf('%g mW, %g nm laser',conditions.mW,conditions.nm)};
                    else
                        textboxstring = {protocol_data.ratname,[cerebro_implants.(protocol_data.ratname).hemisphere,...
                            ' ',cerebro_implants.(protocol_data.ratname).region],sprintf('%g to %g days since Sx',daysSinceSurgery(1),daysSinceSurgery(2)),...
                            opsin.(protocol_data.ratname)};
                    end
                else
                    warning('non-cerebro text box not yet implemented.');
                end
            else
                textboxstring={};
                warning('non scalar rat text box not yet implemented.');
            end
            if exist('specialVals','var')
                pbups_psych_data = psychometrics(behavioral_param(parsedProtocolData.ison==0),signals(parsedProtocolData.ison==0),'levelname',levelname,...
                    'specialVals',specialVals,'specialLabels',specialLabels,'specialPos',specialPos,varargin{:},...
                    'ylabel',ylabel,'title',titleText,'specialRewarded',specialRewarded,'plot',params.plotCurves);     
            else
                pbups_psych_data(1) = psychometrics(behavioral_param(parsedProtocolData.ison==0),signals(parsedProtocolData.ison==0),'levelname',levelname,varargin{:},...
                    'ylabel',ylabel,'title',titleText,'plot',params.plotCurves);
            end
            set(pbups_psych_data(1).dataHandle,'DisplayName','STIM OFF');  
            if ~isfield(protocol_data,'ratname') && length(conditions)==1 % psychometricsection
                conditions.label = 'STIM ON';
            elseif isfield(protocol_data,'ratname') && ischar(protocol_data.ratname) && length(conditions)==1
                conditions.label = 'STIM ON';
            end
            for i=1:length(conditions)
                if length(conditions)==1
                    if isfield(conditions,'nm')
                        color = spectrumRGB(conditions.nm);
                    else
                        color = [0 0 1];
                    end
                else
                    color = kColor.trubetskoy(i,:);
                end
                if params.nPsychBins<Inf && isempty(pbups_psych_data(1).binEdges)
                    params.nPsychBins=Inf;
                end
                xOffset=max(signals(conditions(i).idx))/50;                  
                varDotSizeNormalization = max(pbups_psych_data(1).nx);
                if isempty(varDotSizeNormalization)
                    varDotSizeNormalization=1;
                end
                if params.nPsychBins<Inf
                    if exist('specialVals','var')
                        pbups_psych_data(i+1) = psychometrics(behavioral_param(conditions(i).idx),signals(conditions(i).idx),'levelname',levelname,...
                            'specialVals',specialVals,'specialLabels',specialLabels,'specialPos',specialPos,varargin{:},...
                            'ylabel',ylabel,'title',titleText,'specialRewarded',specialRewarded,'plot',params.plotCurves,'color',color,...
                            'varDotSizeNormalization',varDotSizeNormalization,'binEdges',pbups_psych_data(1).binEdges,'xOffset',xOffset);     
                    else
                        pbups_psych_data(i+1) = psychometrics(behavioral_param(conditions(i).idx),signals(conditions(i).idx),'levelname',levelname,varargin{:},...
                            'ylabel',ylabel,'title',titleText,'plot',params.plotCurves,'color',color,'varDotSizeNormalization',varDotSizeNormalization,...
                            'binEdges',pbups_psych_data(1).binEdges,'xOffset',xOffset);
                    end
                else
                    if exist('specialVals','var')
                        pbups_psych_data(i+1) = psychometrics(behavioral_param(conditions(i).idx),signals(conditions(i).idx),'levelname',levelname,...
                            'specialVals',specialVals,'specialLabels',specialLabels,'specialPos',specialPos,varargin{:},...
                            'ylabel',ylabel,'title',titleText,'specialRewarded',specialRewarded,'plot',params.plotCurves,'color',color,...
                            'varDotSizeNormalization',varDotSizeNormalization,'xOffset',xOffset);     
                    else
                        pbups_psych_data(i+1) = psychometrics(logical(behavioral_param(conditions(i).idx)),signals(conditions(i).idx),'levelname',levelname,varargin{:},...
                            'ylabel',ylabel,'title',titleText,'plot',params.plotCurves,'color',color,'varDotSizeNormalization',varDotSizeNormalization,...
                            'xOffset',xOffset);
                    end                        
                end                    
                set(pbups_psych_data(i+1).dataHandle,'DisplayName',conditions(i).label);
            end
            gobjs = [[pbups_psych_data.dataHandle] pbups_psych_data(1).specialHandle];
            if exist('gobjects','file')
                legendable = ~strncmp(arrayfun(@class,gobjs,'uniformoutput',false),'matlab.graphics.Gra',17);
            else
                legendable = gobjs>0;
            end
            legend(gobjs(legendable),'location','southeast');   
            legend('boxoff')
            if exist('textboxstring','var') && ~isempty(textboxstring)
                 text(0.1,0.8,textboxstring,'units','normalized','FontSize',15);
            end
        else      
            if exist('specialVals','var')
                pbups_psych_data = psychometrics(behavioral_param,signals,'levelname',levelname,...
                    'specialVals',specialVals,'specialLabels',specialLabels,'specialPos',specialPos,varargin{:},...
                    'ylabel',ylabel,'title',titleText,'specialRewarded',specialRewarded,'plot',params.plotCurves);     
            else
                pbups_psych_data = psychometrics(behavioral_param,signals,'levelname',levelname,varargin{:},...
                    'ylabel',ylabel,'title',titleText,'plot',params.plotCurves);     
            end
        end
        if length(pbups_psych_data)==1
            if ~isfield(parsedProtocolData,'violationRate') || isempty(parsedProtocolData.violationRate)
                pbups_psych_data.violationRate=NaN;
            else
                pbups_psych_data.violationRate=parsedProtocolData.violationRate;
            end
            pbups_psych_data.parsedProtocolData=parsedProtocolData;
            if isfield(parsedProtocolData,'percentCorrect')
                pbups_psych_data.percentCorrect = parsedProtocolData.percentCorrect;                    
            else
                pbups_psych_data.percentCorrect=NaN;
            end
        end
end