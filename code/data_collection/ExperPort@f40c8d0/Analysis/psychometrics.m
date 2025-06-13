function data = psychometrics(varargin)
    %PSYCHOMETRICS Plots and fits psychometric curves for behavioral data
    %from 2AFC tasks.
    %
    %   PSYCHOMETRICS(CHOICES,SIGNALS) plots a psychometric curve given a
    %   vector (of one dimension) SIGNALS that defines the stimulus
    %   variable and a set of binary choices CHOICES. CHOICES must be
    %   logicals.
    %
    %   PSYCHOMETRICS(CHOICES,SIGNALS,SIGNALVALUES) allows the user to
    %   provide a vector of positive signal levels for SIGNALS and a vector
    %   of equal length SIGNALVALUES specifying the stimulus condition (with two unique values).
    %   This is useful for experiments in which the stimulus can come from
    %   one of two categories (up and down, left and right, etc.) and can
    %   also vary in intensity (e.g. motion coherence). For plotting purposes, one stimulus
    %   condition gets signed as "negative" (i.e. its SIGNALS values are
    %   inverted).
    %
    %   PARAMS = PSYCHOMETRICS(CHOICES,SIGNALS) provides an output
    %   structure PARAMS with information about the psychometric curve.
    %   Important fields include: (under construction)
    %
    %   
    %   Adrian Bondy, 2017
    
    %% parse and validate inputs
    p=inputParser;
    p.KeepUnmatched=true;
    p.StructExpand=true;
    p.addOptional('choices',@(x)validateattributes(x,{'logical'},{'vector'}));
    p.addOptional('signals',@(x)validateattributes(x,{'double'},{'vector'}));    
    p.addOptional('signalvalues',[],@(x)validateattributes(x,{'double'},{}));  
    p.addParamValue('plot',true,@(x)validateattributes(x,{'logical'},{'scalar'},'','plot'));   
    p.addParamValue('upvalue',NaN,@(x)validateattributes(x,{'numeric'},{'scalar'},'','upvalue'));        
    p.addParamValue('valuename','',@(x)validateattributes(x,{'char'},{'nonempty'},'','valuename'));     
    p.addParamValue('levelname','Signal Level',@(x)validateattributes(x,{'char'},{},'','levelname'));            
    p.addParamValue('replot',struct([]),@(x)validateattributes(x,{'struct','cell'},{}));
    p.addParamValue('color',[0 0 0],@(x)validateattributes(x,{'numeric','char'},{'nonempty'},'','color'));
    p.addParamValue('fit',true,@(x)validateattributes(x,{'logical'},{'scalar'},'','fit'));    
    p.addParamValue('nmin',0,@(x)validateattributes(x,{'numeric'},{'nonnegative','scalar','integer'},'','nmin'));    
    p.addParamValue('fitType','logit',@(x)validateattributes(x,{'char'},{'nonempty'},'','fitType'));    
    p.addParamValue('fitLapse',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParamValue('fitBias',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParamValue('showN',false,@(x)validateattributes(x,{'logical'},{'scalar'},'','showN'));   
    p.addParamValue('legend',false,@(x)validateattributes(x,{'logical'},{'scalar'},'','legend'));     
    p.addParamValue('errorbar',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParamValue('varDotSize',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParamValue('ylabel','Fraction Positive Choice',@(x)validateattributes(x,{'char'},{}));
    p.addParamValue('specialVals',[],@(x)validateattributes(x,{'numeric'},{}));
    p.addParamValue('specialLabels',{},@(x)validateattributes(x,{'cell'},{}));
    p.addParamValue('specialPos',[],@(x)validateattributes(x,{'numeric'},{}));
    p.addParamValue('specialRewarded',[],@(x)validateattributes(x,{'numeric'},{}));
    p.addParamValue('alpha',0.05,@(x)validateattributes(x,{'numeric'},{'positive','scalar','<',1}));
    p.addParamValue('title','',@(x)validateattributes(x,{'char','cell'},{}));
    p.addParamValue('zeroSignalFree',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParamValue('nPsychBins',Inf,@(x)validateattributes(x,{'numeric'},{'scalar'}));
    p.addParamValue('binEdges',[],@(x)validateattributes(x,{'numeric'},{}));
    p.addParamValue('varDotSizeNormalization',1,@(x)validateattributes(x,{'numeric'},{'positive','scalar','finite'}));
    p.addParamValue('binMode','symmetric');
    p.parse(varargin{:});
    params=p.Results;   
    params.fitType = validatestring(params.fitType,{'probit','logit','cumgauss'},'psychometrics','fitType');
    if strcmp(params.fitType,'cumgauss') % legacy
        warning('fitType "cumgauss" is deprecated. Use "probit" instead.')
        params.fitType='probit';
    end
    data = struct('choices',params.choices(:),'nTrials',0,'signals',params.signals(:),'levelname',params.levelname,'signalvalues',params.signalvalues(:),...
        'valuename',params.valuename,'fitType',params.fitType,'xs',[],'nx',[],'uprate',[],'upchoices',[],'ci',[],...
        'specialUpChoices',[],'specialUpRate',[],'specialNx',[],'dataHandle',[],'specialHandle',[],'fitHandle',[],'dataErrorHandle',[],'originalSignals',[],'originalChoices',[],...
        'binEdges',params.binEdges);
    data.specialVals = params.specialVals;
    data.specialLabels = params.specialLabels;
    data.specialRewarded = params.specialRewarded;
    data = SetFields(data,'specialUpChoice',[],'specialCI',[],'upchoice',[],'percentCorrect',NaN,'specialPercentCorrect',NaN,'bias',[NaN NaN],'criterion',[NaN NaN],'dispersion',[NaN NaN],'lapse',[NaN NaN]);
    data.params = rmfield(params,{'choices','signals','levelname','signalvalues','valuename','specialVals','specialLabels','specialRewarded'});
    goodtrials = ~isnan(data.signals)&~isnan(data.choices);
    data.choices=data.choices(goodtrials);
    data.signals = data.signals(goodtrials);
    if ~isempty(data.params.replot)
        if isstruct(data.params.replot)
            data=data.params.replot;
            data.params.replot=true;
        else
            error('replot must be a structure output by psychometrics.');
        end
        data.params.plot=true;
        fields=fieldnames(p.Results);
        for f=1:length(fields)
            if ~ismember(fields{f},p.UsingDefaults)
                if isfield(data.params,fields{f})
                    data.params.(fields{f})=p.Results.(fields{f});
                else
                    data.(fields{f})=p.Results.(fields{f});                    
                end
            end
        end
    else
        data.params.replot=false;
    end 
    if ~isempty(data.specialVals)
        if numel(data.specialVals)~=numel(data.specialLabels) || (numel(data.specialVals)~=numel(data.specialRewarded) && ~isempty(data.specialRewarded))
            error('specialVals and specialLabels must be the same size.');
        end
    end
    if any(strcmp(varargin,'darker'))
        data.params.color=data.params.color/2;
    end
    if isempty(data.choices)   
        return
    end
    if numel(unique(data.choices))==1
        warning('psychometrics:onlyOneChoice','Only one choice.');
    end
    data.nTrials=length(data.choices);
    if data.nTrials~=length(data.signals)
        error('choices and signals must vectors of equal length.');
    end
    if ~isempty(data.signalvalues)
        data.signalvalues=data.signalvalues(:);
        if length(data.signalvalues)~=data.nTrials
            error('signalvalues must have same length as choices');
        end
        if any(data.signals<0)
            if length(unique(data.signalvalues))>1
                error('With signal values provided, all signals must be positive (signal values already acts like a sign.');
            end
        end
        if all(abs(data.signalvalues)==1)
            data.params.upvalue=1;
        end
        valueTypes=unique(data.signalvalues);
        if length(valueTypes)<2
            mssg(0,'Only one signal value: %g',valueTypes);
        elseif length(valueTypes)>2
            error('There can currently be at most two signal value types.');
        end       
        if ~isnan(data.params.upvalue)
            if ~ismember(data.params.upvalue,data.signalvalues)
                error('up value provided is not on the list of values.');
            end
            data.signals(data.signalvalues~=data.params.upvalue)=-data.signals(data.signalvalues~=data.params.upvalue);        
            if valueTypes(1)==data.params.upvalue
                valueTypes=flipud(valueTypes);
            end
        else
            data.signals(data.signalvalues==valueTypes(1))=-data.signals(data.signalvalues==valueTypes(1));
        end
    else
        valueTypes=[];
    end
    %% find special vals
    for i=1:length(data.specialVals)
        idx = data.signals==data.specialVals(i);
        data.specialNx(i) = sum(idx);    
        data.specialUpChoice(i) = sum(data.choices(idx));
    end
    if ~isempty(data.specialVals)
        data.specialUpRate = data.specialUpChoice ./ data.specialNx;
        data.specialCI = statbinoci(data.specialUpChoice,data.specialNx,data.params.alpha);
    end    
    %% psych bins
    data.originalSignals = data.signals;
    data.originalChoices = data.choices;
    data.choices = data.choices(~ismember(data.originalSignals,data.specialVals));
    data.signals = data.signals(~ismember(data.originalSignals,data.specialVals)); 
    if params.nPsychBins<Inf && isempty(params.binEdges)
        tmp=0;
        if params.nPsychBins==1
            idx=ones(size(data.signals));
            edges=minmax(data.signals);
        elseif params.nPsychBins==2
            edges=[min(data.signals)-eps(min(data.signals)),median(data.signals),max(data.signals)+eps(max(data.signals))];
            [tmp,idx] = histc(data.signals,edges); 
        else
            if length(unique(data.signals)) <= 2*params.nPsychBins
                params.nPsychBins = Inf;
                warning('You asked for more psychbins than half the number of unique signal values.');
            else
                switch params.binMode
                    case 'equal range'
                        edges = (min(data.signals)-eps(min(data.signals))):range(data.signals)/params.nPsychBins:(max(data.signals)+eps(max(data.signals)));
                    case 'equal number'
                        quantiles = (1:params.nPsychBins-1)/params.nPsychBins;
                        edges=[min(data.signals)-eps(min(data.signals)),prctile(data.signals(:)',100*quantiles),max(data.signals)+eps(max(data.signals))];
                    case 'symmetric'
                        mx = max(abs(data.signals));
                        mx=mx+eps(mx);
                        edges = linspace(-mx,mx,params.nPsychBins+1);
                end
                [tmp,idx] = histc(data.signals,edges);
            end
        end
        if tmp(end)>0
            error('Bin edges don''t extend far enough to capture the data.'); %% should never get to this line
        end
        if ~isinf(params.nPsychBins)
            idx = idx(:);            
            binMids = (edges(2:end) + edges(1:end-1) ) / 2;
            data.signals=binMids(idx)';
            data.binEdges = edges;
        else
            data.binEdges=[];
        end
    end
    %% directly giving binedges overrides npsychbins
    if ~isempty(params.binEdges) 
       toolow = data.signals<min(params.binEdges);
       toohigh = data.signals>=max(params.binEdges);
       undiscretizedsignals=data.signals;
       for i=1:(length(params.binEdges)-1)
           inrange(i,:) = isinrange(data.signals,params.binEdges(i-1+[1 2]))';
       end
       [idx,idx2] = find(sparse(inrange));
       data.signals(idx2)=idx;    
       %data.signals =  discretize(data.signals,params.binEdges); %
       %avoiding syntax that older matlab can't handle
       data.signals(toolow) = 1;
       data.signals(toohigh) = length(params.binEdges)-1;
        for i=1:length(params.binEdges)
            binMids(i) = mean(undiscretizedsignals(data.signals==i));
        end
        binMids = binMids(:);
        data.signals=binMids(data.signals);
        data.binEdges = params.binEdges;
    end
    data.originalSignals = data.signals;    
    %% calculate psychometric curve  
    % first for original data, then binned
    [data.originalNx,data.originalXs] = Counts(data.originalSignals);    
    data.originalXs=data.originalXs(data.originalNx>data.params.nmin);    
    data.originalNx=data.originalNx(data.originalNx>params.nmin);
    data.originalUpChoice=zeros(length(data.originalNx),1);
    data.originalNx=data.originalNx(:);
    if ismember('varDotSizeNormalization',p.UsingDefaults)
        params.varDotSizeNormalization=max(data.originalNx);
    end
    for x=1:length(data.originalNx)
        xind=data.originalSignals==data.originalXs(x);
        data.originalUpChoice(x)=sum(data.choices(xind));
    end
    data.originalUprate=data.originalUpChoice ./ data.originalNx;
    data.originalCI=statbinoci(data.originalUpChoice,data.originalNx,data.params.alpha); % get ~95% CI on binomial p  
    data.bias = [sum(data.choices)./length(data.choices) - 0.5 0];
    data.lapse = [min([data.uprate(:); 1-data.uprate(:)]) 0];
    %
    [data.nx,data.xs] = Counts(data.signals);    
    data.xs=data.xs(data.nx>data.params.nmin);    
    data.nx=data.nx(data.nx>params.nmin);
    data.upchoice=zeros(length(data.nx),1);
    data.nx=data.nx(:);
    if ismember('varDotSizeNormalization',p.UsingDefaults)
        params.varDotSizeNormalization=max(data.nx);
    end
    for x=1:length(data.nx)
        xind=data.signals==data.xs(x);
        data.upchoice(x)=sum(data.choices(xind));
    end
    data.uprate=data.upchoice ./ data.nx;
    data.ci=statbinoci(data.upchoice,data.nx,data.params.alpha); % get ~95% CI on binomial p  
    if params.zeroSignalFree % assumes all zero signal trials are rewarded (free choice) -- default
        data.percentCorrect = sum ( ( sign ( data.choices-0.5 ) == sign(data.signals(:)) ) | ~data.signals(:) ) ./ length(data.choices);
    else % assumes zero signal means randomly rewarded
        data.percentCorrect = (sum(sign(data.choices-0.5) == sign(data.signals) ) + sum(data.signals==0)./2 ) ./ length(data.choices);        
    end
    if ~isempty(data.specialRewarded)
        data.specialPercentCorrect = data.specialUpRate ;
        data.specialPercentCorrect(data.specialRewarded==0) = 1 - data.specialPercentCorrect(data.specialRewarded==0);
        for i=1:length(data.specialRewarded)
            if data.specialRewarded(i)>1
                data.specialPercentCorrect(i) = 1;
            end
        end
        data.percentCorrect = wmean([data.percentCorrect data.specialPercentCorrect],[length(data.choices) data.specialNx]);
    end
    %% fit if requested
    if data.params.fit && ~isfield(data.params,'mdl')
        % use iteratively reweighted least squares to converge to MLE solution given binomial observations                   
        if numel(data.originalXs)<4
            warning('psychometrics:lessThanFour','Less than four unique x-values. No point trying to fit a sigmoid.');
        else            
            data.params = makeModelFun(data);     
            data.params.beta0=initializeModelParams(data.originalXs,data.params.fitParams);              
            if hastoolbox('optimization')
                %warning_state=warning('off');
                [data.params.mdl.Coefficients.Estimate,data.params.mdl.logL,data.params.mdl.exitflag,...
                    data.params.mdl.output,data.params.mdl.lambda,data.params.mdl.grad,data.params.mdl.hessian] = ...
                    fmincon(data.params.modelFun,data.params.beta0,data.params.A,data.params.b,[],[],data.params.lb,data.params.ub,[],optimset('display','off'));
                %warning(warning_state);
            else
                [data.params.mdl.Coefficients.Estimate,data.params.mdl.logL,data.params.mdl.exitflag,...
                    data.params.mdl.output] = ...
                    fminsearch(data.params.modelFun,data.params.beta0);
            end
            data.params.mdl.Coefficients.SE = zeros(size(data.params.fitParams));    
        end
        if isfield(data.params,'fitParams')
            for f=1:length(data.params.fitParams)
                data.(data.params.fitParams{f})(1) = data.params.mdl.Coefficients.Estimate(f);
                data.(data.params.fitParams{f})(2) = data.params.mdl.Coefficients.SE(f);            
            end
        end
    end      
    %% plot curve (with error bars and fit if requested)
    if ~isempty(data.specialNx)
        if exist('gobjects','file')
            data.specialHandle = gobjects(1,length(data.specialNx));
        else
            data.specialHandle = zeros(1,length(data.specialNx));
        end
        if data.params.errorbar
            data.specialErrorHandle = data.specialHandle;
        end
    end
    if data.params.plot
        hold on;
        if data.params.varDotSize
            dotSize=data.nx*80./params.varDotSizeNormalization;
            if ~isempty(data.specialVals)
                if isempty(data.nx)
                    specialDotSize = data.specialNx*80;                    
                else
                    specialDotSize = data.specialNx*80./params.varDotSizeNormalization;                    
                end
            end
        else
            dotSize=60;
            specialDotSize=ones(length(data.specialVals),1)*60;
        end
        % scatter plot
        scatterfun = @(xs,uprate,markerSize,color)scatter(xs,uprate,'o','SizeData',markerSize,'MarkerFaceColor',color,'MarkerEdgeColor',[1 1 1],'LineWidth',0.4);
        data.dataHandle = scatterfun(data.xs,data.uprate,dotSize,data.params.color);
        try
            set(data.dataHandle,'MarkerFaceAlpha',0.75);
        end
        if isempty(data.specialVals)
            data.specialHandle=[];
        end
        for i=1:length(data.specialVals)
            if data.specialNx(i)==0
                continue
            end
            colors = distinguishable_colors(length(data.specialVals));                
            data.specialHandle(i) = scatterfun(data.params.specialPos(i),data.specialUpRate(i),specialDotSize(i),colors(i,:));
            set(data.specialHandle(i),'MarkerEdgeColor',params.color);
            set(data.specialHandle(i),'LineWidth',1);
            if isnumeric(data.specialHandle)
                set(data.specialHandle(i),'DisplayName',data.specialLabels{i});
            else
                data.specialHandle(i).DisplayName = data.specialLabels{i};
            end
        end
        set(data.dataHandle,'HandleVisibility','off');
        if data.params.errorbar % error bar
            errorbarfun = @(xs,uprate,ci,color)errorbar(xs,uprate,(uprate-ci(:,1))/2,(ci(:,2)-uprate)/2,'.','LineStyle','none','MarkerSize',0.01,'LineWidth',1.75,'color',color,'CapSize',0);
            data.dataErrorHandle=errorbarfun(data.xs,data.uprate,data.ci,data.params.color);
            for i=1:length(data.specialVals)
                if data.specialNx(i)==0
                    continue
                end
                set(data.specialHandle(i),'HandleVisibility','off');
                colors = distinguishable_colors(length(data.specialVals));
                data.specialErrorHandle(i) = ...
                    errorbarfun(data.params.specialPos(i),data.specialUpRate(i),data.specialCI(i,:),colors(i,:));
            end
        end      
        set(data.dataHandle,'HandleVisibility','off');        
        if data.params.showN % show n trials in text box if requested
            textfun = @(xs,ci,uprate,nx,color)text(xs+0.05, uprate-0.03,num2str(nx),'FontWeight','bold','color',color);
            for i=1:length(data.xs)
                textfun(data.xs(i),data.ci(i,2),data.uprate(i),data.nx(i),params.color);
            end
            for i=1:length(data.specialVals)
                colors = distinguishable_colors(length(data.specialVals));                                
                textfun(data.params.specialPos(i),data.specialCI(i,2),data.specialUpRate(i),data.specialNx(i),colors(i,:));
            end
        end
        ylabel(data.params.ylabel);
        xlabel(data.levelname);
        if data.params.fit && isfield(data.params,'mdl') % plot fit if requested
            hold on;
            dataRange = linspace(min(data.originalSignals),max(data.originalSignals),50);                
            if data.params.fitLapse
                if data.params.fitBias
                    y_hat = data.params.psychoFun(dataRange(:),data.criterion(1),data.dispersion(1),data.lapse(1),data.bias(1));
                else
                    y_hat = data.params.psychoFun(dataRange(:),data.criterion(1),data.dispersion(1),data.lapse(1),0);                    
                end
            else
                y_hat = data.params.psychoFun(dataRange(:),data.criterion(1),data.dispersion(1),0,0);                
            end
            if data.params.errorbar && any(data.params.mdl.Coefficients.SE(:))
                try
                    data.fitHandle = shadedErrorBar(dataRange,y_hat',abs(bsxfun(@minus,y_hat_ci',y_hat')));
                    data.fitHandle.mainLine.Color=data.params.color;
                    if ~isempty(data.fitHandle.patch)
                        data.fitHandle.patch.FaceAlpha=0.2;
                        data.fitHandle.patch.FaceColor=data.params.color;
                        data.fitHandle.patch.HandleVisibility='off';        
                        data.fitHandle.mainLine.DisplayName=sprintf('%s fit w/ %g%% CI',data.params.fitType,100*(1-data.params.alpha));                                    
                    else
                        data.fitHandle.mainLine.DisplayName=sprintf('%s fit',data.params.fitType);                                                        
                    end
                catch
                    data.fitHandle = plot(dataRange,y_hat,'color',data.params.color);
                    set(data.fitHandle,'DisplayName',sprintf('%s fit',data.params.fitType));  
                end
            else
                data.fitHandle = plot(dataRange,y_hat,'color',data.params.color);
                set(data.fitHandle,'DisplayName',sprintf('%s fit',data.params.fitType));                                                        
            end
        else
            data.fitHandle=[];
        end
        % make figure pretty
        if ~isempty(data.signalvalues)
            set(data.dataHandle,'DisplayName',[data.valuename,'=',num2str(valueTypes(:)')]);
        else
            set(data.dataHandle,'DisplayName',data.valuename);
        end
        if data.params.errorbar
            if ~isempty(data.valuename)
                %data.dataHandle.DisplayName = [data.params.legendString,' with 95% CI'];
                data.dataHandle.HandleVisibility = 'on';
            end
           for i=1:length(data.specialVals)
               if ~isa(data.specialHandle(i),'matlab.graphics.GraphicsPlaceholder') && double(data.specialHandle(i))~=0
                set(data.specialHandle(i),'DisplayName',[data.specialLabels{i} ' with 95% CI']);
               end
           end
        end
        if data.params.legend && (~isempty(data.specialVals) || (data.params.fit && numel(data.xs)>=4))
            legend('show');
            legend('Location','southeast');
            legend('boxoff');            
        end
        if ~isempty(data.specialVals)
            data.xs = cat(1,data.xs(:),data.params.specialPos(:));
        end
        if length(data.xs)>1
            %set(gca,'xlim',[min(data.xs)-range(data.xs)/8-eps max(data.xs)+range(data.xs)/8]);
            % with showstimtrials on, and low trial numbers, this can mess
            % up plotting
        end
        set(gca,'ylim',[0 1],'ygrid','on');
        set(gca,'ytick',[0:0.25:1]);
        set(gca,'FontSize',15);        
        title(data.params.title);     
    else
        data.dataHandle=[];
        data.specialHandle=[];
        data.fitHandle=[];
    end
end


function params = makeModelFun(data)
    params=data.params;
    switch params.fitType
        case 'probit' % equation for a probit function with variable lapse rate and criterion
            params.psychoFun = @(x,criterion,dispersion,lapse,bias) ...
                min(1-eps,max(eps,bias + lapse/2 + (1-lapse).*( 1 + erf ( ( x - criterion ) ./ ( sqrt(2) * dispersion ) ) ) ./ 2));
        case 'logit' % equation for a logistic function with variable lapse rate and criterion
            params.psychoFun = @(x,criterion,dispersion,lapse,bias) ...
               min(1-eps,max(eps, bias + lapse/2 + (1-lapse) ./ ( 1 + exp ( - (x - criterion )./dispersion ) )   ));               
    end  
    params.fitParams = {'criterion','dispersion','lapse','bias'};
    params.lb = [-Inf eps 0 -1];
    params.ub = [Inf Inf 1 1];
    params.A = [];
    params.b=[];
    if params.fitBias
        if params.fitLapse
           params.modelFun = @(beta) -sum(log(params.psychoFun(data.originalSignals(data.choices==1),beta(1),beta(2),beta(3),beta(4)))) ...
               - sum( log(1-params.psychoFun(data.originalSignals(data.choices==0),beta(1),beta(2),beta(3),beta(4))));
           params.A = [0 0 -1 2];
           params.b=0;
        else
            params.modelFun = @(beta) -sum(log(params.psychoFun(data.originalSignals(data.choices==1),beta(1),beta(2),0,0))) ...
                -sum( log(1-params.psychoFun(data.originalSignals(data.choices==0),beta(1),beta(2),0,0)));
            params.lb = params.lb([1 2]);
            params.ub = params.ub([1 2]);               
            params.fitParams = params.fitParams(~ismember(params.fitParams,{'bias','lapse'}));  
        end
    elseif params.fitLapse
        params.modelFun = @(beta) -sum(log(params.psychoFun(data.originalSignals(data.choices==1),beta(1),beta(2),beta(3),0))) ...
            -sum( log(1-params.psychoFun(data.originalSignals(data.choices==0),beta(1),beta(2),beta(3),0)));
        params.lb = params.lb([1 2 3]);
        params.ub = params.ub([1 2 3]);               
        params.fitParams = params.fitParams(~ismember(params.fitParams,'bias'));                  
    else
        params.modelFun = @(beta) -sum(log(params.psychoFun(data.originalSignals(data.choices==1),beta(1),beta(2),0,0))) ...
            -sum( log(1-params.psychoFun(data.originalSignals(data.choices==0),beta(1),beta(2),0,0)));
        params.lb = params.lb([1 2]);
        params.ub = params.ub([1 2]);               
        params.fitParams = params.fitParams(~ismember(params.fitParams,{'bias','lapse'}));                       
    end
    data.params=params;
end


function beta0 = initializeModelParams(xs,fitParams)
   for i=1:length(fitParams)
       if strcmp(fitParams{i},'dispersion')
           beta0(i) = range(xs)./10;
       else
           beta0(i) = 0;
       end
   end
end