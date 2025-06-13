% [x, y] = PWMSection(obj, action, tname, varargin)
% major overhaul, modified from PbupsSection and AthenaDelayComp
% Emily Jane Dennis Nov 2018
% major update for Automation/restructuring Feb 2019
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%
%   'init'     Initializes the plugin. Sets up internal variables
%               and the GUI window.
%
% ABBREVIATIONS:
% -------------
%
% ADC: AthenaDelayComp (previous iteration of this protocol)
% PWM: Parametric Working Memory
% SPH: SoloParamHandle
%
%

function [x, y] = PWMSection(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action
    
    %---------------------------------------------------------------%
    %          init                                                 %
    %---------------------------------------------------------------%
    case 'init'
    if length(varargin) < 2
        error('Need at least two arguments, x and y position, to initialize %s', mfilename);
    end
    x = varargin{1}; 
    y = varargin{2};

    SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);

    %adds a button and a soloparam PWMshow which opens and closes the
    %New stimulus window
    ToggleParam(obj, 'PWMshow', 0, x, y, ...
        'OnString', 'PWM window Showing', ...
        'OffString', 'PWM window Hidden', ...
        'TooltipString', 'Show/Hide PWM window'); 
    set_callback(PWMshow, {mfilename, 'show_hide';});
    next_row(y);
 
    %this saves the position on the main PWM screen so we can return there
    %if the screen is closed/to add other buttons, etc.
    fig = double(gcf);
    oldx = x;
    oldy = y;
    
    % add a SPH called myfig that includes this window
    SoloParamHandle(obj, 'myfig', ...
        'value', double(figure('Position', [10 20 800 700], ...
        'closerequestfcn', [mfilename '(' class(obj) ', ''hide''' ');'], 'MenuBar', 'none', ...
        'NumberTitle', 'off', 'Name', mfilename)), 'saveable', 0);

    x = 10; 
    y = 10;     
    
    %  define axes for the performance and pairs plots
    %  test label axes get replaced later
    yaxislabel = 'testy';
    xaxislabel = 'testx';
    SoloParamHandle(obj, 'PWMax', 'saveable', 0, ...
                    'value', double(axes('Position', [0.1 0.55 0.4 0.4])));
    ylabel(yaxislabel,'FontSize',16);  
    set(value(PWMax),'Fontsize',15)
    xlabel(xaxislabel,'FontSize',16)

    SoloParamHandle(obj, 'PWMaxperf', 'saveable', 0, ...
                   'value', double(axes('Position', [0.5 0.5 0.4 0.4])));
    ylabel(yaxislabel,'FontSize',16);  
    set(value(PWMaxperf),'Fontsize',15)
    xlabel(xaxislabel,'FontSize',16)

    comparison_list = {'loudness', 'pitch', 'duration'};
    MenuParam(obj, 'comparison_type', comparison_list, 1, x, y, ...
        'labelfraction', 0.3, ...
        'TooltipString', 'The list of major task types');
    next_row(y)    
    
    sound_list = {'pink','tone'};
    % TODO add clicks as an option
    MenuParam(obj, 'sound_type', sound_list,1, x, y, ...
        'labelfraction', 0.3, ...
        'TooltipString', 'The list of major sound types');
    set_callback(sound_type, {mfilename, 'plot_pairs'});
    next_row(y)
    
    %% from ADC
    SoundManagerSection(obj, 'declare_new_sound', 'StimAUD1');
    SoundManagerSection(obj, 'declare_new_sound', 'StimAUD2');
    SoloParamHandle(obj, 'thesepairs', 'value', []);
    SoloParamHandle(obj, 'pairs_d', 'value', []);
    SoloParamHandle(obj, 'pairs_u', 'value', []);
    SoloParamHandle(obj, 'pairs_d_psych', 'value', []);
    SoloParamHandle(obj, 'pairs_u_psych', 'value', []);
    SoloParamHandle(obj, 'h1', 'value', []); 
    SoloParamHandle(obj, 'thisclass', 'value', []);
    SoloParamHandle(obj, 'control_history',   'value', []);

    %% sound_type specifications section:

    % TODO gray out (disable) depending on sound_type selection
    % PINK NOISE SECTION
    MenuParam(obj, 'StimulusType', {'library', 'new'}, ...
      'new', x, y, 'labelfraction', 0.35, 'TooltipString', sprintf(['\nnew means at each trial, a new noise pattern will be generated,\n' ...
      '"library" means for each trial stimulus is loaded from a library with limited number of noise patterns'])); next_row(y, 1.3)
    set_callback(StimulusType, {mfilename, 'StimulusType'});
    next_row(y);
    NumeditParam(obj,'nPatt',50,x,y,'label','Num Nois Patt','TooltipString','Number of Noise Patters for the library');
    next_row(y);
    MenuParam(obj, 'filter_type', {'GAUS','LPFIR', 'FIRLS','BUTTER','MOVAVRG','KAISER','EQUIRIP','HAMMING'}, ...
      'GAUS', x, y, 'labelfraction', 0.35, 'TooltipString', sprintf(['\nDifferent filters. ''LPFIR'': lowpass FIR ''FIRLS'': Least square linear-phase FIR filter design\n', ...
      '\n''BUTTER'': IIR Butterworth lowpass filter ''GAUS'': Gaussian filter (window)\n', ...
      '\n''MOVAVRG'': Moving average FIR filter ''KAISER'': Kaiser-window FIR filtering\n', ...
      '\n''EQUIRIP'':Eqiripple FIR filter ''HAMMING'': Hamming-window based FIR'])); 
    next_row(y);
    NumeditParam(obj,'fcut',110,x,y,'label','fcut','TooltipString','Cut off frequency on the original white noise');
    next_row(y);
    NumeditParam(obj,'lfreq',2000,x,y,'label','Modulator_LowFreq','TooltipString','Lower bound for the frequency modulator');
    next_row(y);
    NumeditParam(obj,'hfreq',20000,x,y,'label','Modulator_HighFreq','TooltipString','Upper bound for the frequency modulator'); 
    next_row(y);    

    for i = 1:40
        SoloParamHandle(obj, ['probClass',num2str(i)],'value',0);
        SoloParamHandle(obj, ['perfClass',num2str(i)],'value',0);
        SoloParamHandle(obj, ['nTrialsClass',num2str(i)],'value',0);
        SoloParamHandle(obj, ['hperf',num2str(i)], 'value', 0);
    end
         
    % SHARED soundtype info section
    DispParam(obj, 'AUD1_sigma', 0.01, x,y,'label','AUD1_sigma','TooltipString','Sigma value for AUD1 of the first stimulus');
    next_row(y);
    DispParam(obj, 'AUD2_sigma', 0.01, x,y,'label','AUD2_sigma','TooltipString','Sigma value for AUD2 of the first stimulus');
    next_row(y);
    DispParam(obj,'minS1',0.001,x,y,'label','minS1','TooltipString','min sigma value for AUD1');
    next_row(y);
    DispParam(obj,'maxS',40,x,y,'label','maxS','TooltipString','max sigma value for AUD1');
    NumeditParam(obj,'S2_S1_ratio',2.6,x,y,'label','S2_S1_ratio','TooltipString','Intensity index i.e. Ind=(S1-S2)/(S1+S2)');
    next_row(y);

    %% PLOTTING SECTION
    next_row(y);
    PushbuttonParam(obj, 'refresh_pairs', x,y , 'TooltipString', 'Instantiates the pairs given the new set of parameters');
    set_callback(refresh_pairs, {mfilename, 'plot_pairs'});
    next_row(y);
    PushbuttonParam(obj, 'plot_performance', x,y , 'TooltipString', 'Plots the class design with mean performance for each class');
    set_callback(plot_performance, {mfilename, 'plot_perf'});
    next_row(y);
    ToggleParam(obj, 'midclass_pairs', 0, x,y,...
            'OnString', 'Mid Class Pairs ON',...
            'OffString', 'Mid Class Pairs OFF',...
            'TooltipString', sprintf('If on (Yellow) then stimulus pairs between the main class pairs will be included'));
    next_row(y);   
    ToggleParam(obj, 'psych_pairs', 1, x,y,...
        'OnString', 'Psych Pairs ON',...
        'OffString', 'Psych Pairs OFF',...
        'TooltipString', sprintf('If on (black) then it disable the presentation of psychometric pairs'));
    next_column(x);
    y=5;
    NumeditParam(obj,'nPsych',6,x,y,'label','Num Psych Pairs','TooltipString','Number of psychometric pairs');
    next_row(y);
    NumeditParam(obj,'from',0.0073,x,y,'label','lowest pair','TooltipString','Psychometric pairs will be put between this pair, and an upper pair based on Ratio');
    next_row(y);
    MenuParam(obj, 'psych_type', {'horizpairs', 'vertpairs'}, ...
      'horizpairs', x, y, 'labelfraction', 0.35, 'TooltipString', sprintf(['\nhorizpairs means psychometric pairs will be built with "from" as their fixed S2 while S1 will increase,\n' ...
      '"vertpairs" means psychometric pairs will be built with "from" as their fixed S1 while S2 will increase'])); 
    next_row(y);
    NumeditParam(obj,'probpsych',0,x,y,'label','probpsych','TooltipString','probability of having a psychometric pair as the stimulus pair at each trial');
    disable(nPatt);
    next_row(y,1.3);
    MenuParam(obj, 'Rule', {'S2>S1 Left','S2>S1 Right'}, ...
      'S2>S1 Left', x, y, 'labelfraction', 0.35, 'TooltipString', sprintf(['\nThis bottom determines the rule\n', ...
      '\n''S2>S1 Left'' means if Aud2 > Aud1 then reward will be delivered from the left water spout and if Aud2 < Aud1 then water comes form right\n',...
      '\n''S2>S1 Right'' means if Aud2 < Aud1 then reward will be delivered from the left water spout and if Aud2 > Aud1 then water comes from right\n'])); 
    next_row(y);
    %%    
    SoloParamHandle(obj, 'existing_numClassPsych', 'value', 0, 'saveable', 0);
    SoloParamHandle(obj, 'existing_numClass', 'value', 0, 'saveable', 0);
    SoloParamHandle(obj, 'my_window_info', 'value', [x, y, value(myfig)], 'saveable', 0);
    
    NumeditParam(obj,'numClass',4,x,y,'label','numClass','TooltipString','Number of stimulus pairs');
    set_callback_on_load(numClass, 4); %#ok<NODEF>
    set_callback(numClass, {mfilename, 'numClass'});
    numClass.value = 4; callback(numClass);
    PWMSection(obj,'plot_pairs');
    %     set_callback(psych_pairs, {mfilename, 'PsychPairs'});
        
    % return to PWM window
    x=oldx;
    y=oldy;
    figure(fig);

    %

    %---------------------------------------------------------------%
    %          prepare_next_trial                                   %
    %---------------------------------------------------------------%
    case 'prepare_next_trial' 
        % which port should the rat report its choice to?
        % this does NOT make the pairs, just chooses from them based on
        % user-defined probabilities
        SideSection(obj,'get_current_side');

        %-----ABBREVIATIONS FOR FOLLOWING SECTION
        % cc =  the number of pairs that need to be generated default is 
        %       midclass_pairs = OFF & numClass==4, make 4 pairs
        % pr =  probability of a class
        %       for S2>S1 Left, pr(cc+numClass), S2>S1 Right, pr(cc)
        % bag = a vector containing pair reference numbers, according to their
        % likelihood (set manally by probpsych and probClass) e.g. if classprob is
        % 4 for pair #4,and 1 for all others  bag=[1 2 3 4 4 4 4 5 6 7 8]
        % 
        %-----

        % this section uses the same pairs as either upwards pairs(pairs_u, S2>S1)
        % or downwards pairs (pairs_d, S2<S1). Depending on the rule, these should
        % be rewarded differently, therefore this section uses ThisTrial to tell us
        % whether we should use an upward or downward set, and also randomly
        % chooses the pair to use.

        %% determine if this is a control trial or not
        if value(ControlTaskFreq) == 0    
        %if it's not a control trial because controls are off, use the normal rule
            ctrl='n';
            if strcmp(ThisTrial, 'LEFT') % for LEFT trial  use pairs_u
                sideuse = 1; %left trial sounds
            else sideuse = 2; %right trial sounds
            end
        else % if it's sometimes a control trial use the freq of control to determine if this is a same or diff stimuli trial
            if rand < value(ControlTaskFreq); %if yes, this is a control trial
        %       if strcmp(ControlTask,'light chasing')
                    if rand > 0.5 %if yes, sounds concur
                        ctrl='s';
                        if strcmp(ThisTrial,'LEFT')
                            sideuse =1;
                        else
                            sideuse = 2;
                        end
                    else %sounds are opposite
                        ctrl='d';
                        if strcmp(ThisTrial,'RIGHT')
                            sideuse =1;
                        else
                            sideuse = 2;
                        end
                    end
                    
            else
                ctrl='n';
                %if it's not control trial, use the normal rule
                if strcmp(ThisTrial, 'LEFT') % for LEFT trial  use pairs_u
                    sideuse = 1;
                else
                    sideuse = 2;
                end
            end
        end
        try
            ch = value(control_history);
        catch
            ch = [];
        end
    
        control_history.value=[ch,ctrl];
%%
        if strcmp(ControlTask,'no 1st sound')
            numclass = value(numClass)-1;
        elseif strcmp(ControlTask,'fixed 1st sound')
            numclass = value(numClass)-1;
        else
            numclass = value(numClass);
        end
        
        if strcmp(Rule,'S2>S1 Left') 

            if sideuse == 1 % for LEFT sounds use pairs_u
                bag=[];

                for cc=1:numclass+numclass*value(midclass_pairs)
                    eval(sprintf('pr=value(probClass%d);',cc+numclass)); 
                    bag=[bag ones(1,(10-10*probpsych)*pr)*value(cc)];
                end

                if psych_pairs ==1
                    for cc=numclass+1:numclass+value(nPsych)/2
                        bag = [bag ones(1,(floor(probpsych*10)))*value(cc)];
                    end 
                end
                % reorder bag pseudorandomly
                pp=randsample(bag,length(bag));
                % retrieve pair values for this pair (1st entry in pp)
                thispair=[pairs_u(pp(1),1) pairs_u(pp(1),2)];
                % tell thisclass if it's a numClass or not/what pair it is
                if pp(1) > numclass
                    thisclass(n_done_trials+1)=pp(1)+numclass+nPsych/2;   
                else 
                    thisclass(n_done_trials+1)=pp(1)+numclass;
                end


            else %for RIGHT sounds, use pairs_d
                bag=[];

                for cc=1:numclass+(numclass-1)*value(midclass_pairs)
                    eval(sprintf('pr=value(probClass%d);',cc+numclass)); 
                    bag=[bag ones(1,(10-10*probpsych)*pr)*value(cc)];
                end

                if psych_pairs ==1
                    for cc=numclass+1:numclass+value(nPsych)/2
                        bag = [bag ones(1,(floor(probpsych*10)))*(value(cc))];
                    end 
                end
                pp=randsample(bag,length(bag));
                thispair=[pairs_d(pp(1),1) pairs_d(pp(1),2)];
                if pp(1) > numclass
                    thisclass(n_done_trials+1)=pp(1)+numclass;   
                else
                thisclass(n_done_trials+1)=pp(1);
                end            
            end;
         %end
        elseif strcmp(Rule,'S2>S1 Right')
            % if strcmp(ControlTask,'no 1st sound')
            % elseif strcmp(ControlTask,'fixed 1st sound')
            %   else
            if sideuse == 2 %for RIGHT sounds use pairs_u
                bag=[];
                for cc=1:numclass+(numclass-1)*value(midclass_pairs)
                eval(sprintf('pr=value(probClass%d);',cc+numclass)); 
                bag=[bag ones(1,(10-10*probpsych)*pr)*value(cc)];
                end
        
                if psych_pairs ==1
                    for cc=numclass+1:numclass+value(nPsych)/2
                        bag = [bag ones(1,(floor(probpsych*10)))*(value(cc)+numclass*2)];
                    end 
                end
                
                pp=randsample(bag,length(bag));
                thispair=[pairs_u(pp(1),1) pairs_u(pp(1),2)];
                if pp(1) > numclass*2
                    thisclass(n_done_trials+1)=pp(1)+numclass*2;   
                else
                    thisclass(n_done_trials+1)=pp(1)+numclass;
                end
            
            else %for LEFT sounds use pairs_d
                bag=[];
                for cc=1:numclass+(numclass-1)*value(midclass_pairs)
                eval(sprintf('pr=value(probClass%d);',cc));
                bag=[bag ones(1,(10-10*probpsych)*pr)*value(cc)];
                end
                
                if psych_pairs ==1
                    for cc=numclass+1:numclass+value(nPsych)/2
                        bag = [bag ones(1,(floor(probpsych*10)))*(value(cc)+numclass)];
                    end 
                end
                
                pp=randsample(bag,length(bag));
                thispair=[pairs_d(pp(1),1) pairs_d(pp(1),2)];
                
                if pp(1) > numclass
                    thisclass(n_done_trials+1)=pp(1)+numclass;   
                else
                thisclass(n_done_trials+1)=pp(1);
                end
            end;
        end
      
        AUD1_sigma.value=thispair(1);
        AUD2_sigma.value=thispair(2);

 
        set(value(h1), 'XData', log(value(AUD1_sigma)), 'Ydata', log(value(AUD2_sigma)));


%------ MAKE STIM1 AND STIM2 NOISES
    
        srate=SoundManagerSection(obj,'get_sample_rate');
        Fs=srate;    
        T=max(value(AUD2_time),value(AUD1_time));
        sigma_1=1;
        sigma_2=1;
        if strcmp(comparison_type, 'duration');
            % S2>S1 means S2 LONGER than S1
            AUD1_length=value(AUD1_sigma);
            AUD2_length=value(AUD2_sigma);
            T1=value(AUD1_length);
            T2=value(AUD2_length);
            AUD1_pitch= 8788; %in freq (Hz) units
            AUD2_pitch= 8788; %in freq (Hz) units
            AUD1_loudness= 0.001; %in "sigma" units, ~60dB BUT UNTESTED
            AUD2_loudness= 0.001; %in "sigma" units, ~60dB BUT UNTESTED
        elseif strcmp(comparison_type, 'pitch');
            % S2>S1 means S2 HIGHER than S1
            AUD1_length=value(AUD1_time);
            AUD2_length=value(AUD2_time);
            T1=T;
            T2=T;
            AUD1_pitch= value(AUD1_sigma); %in freq (Hz) units
            AUD2_pitch= value(AUD2_sigma); %in freq (Hz) units
            AUD1_loudness= 0.001; %in "sigma" units, ~60dB BUT UNTESTED
            AUD2_loudness= 0.001; %in "sigma" units, ~60dB BUT UNTESTED
           % TODO gray out pink noise as an option
            
% later add a condition to include clickfreq as a parameter
        %   elseif strcmp(comparison_type, 'clickfreq');
        elseif strcmp(comparison_type,'loudness');
            % S2>S1 means S2 LOUDER than S1 (historical from AthenaDelayComp)
            AUD1_length=value(AUD1_time);
            AUD2_length=value(AUD2_time);
            T1=T;
            T2=T;
            AUD1_pitch= 8788; %in freq (Hz) units
            AUD2_pitch= 8788; %in freq (Hz) units
            AUD1_loudness= value(AUD1_sigma); 
            AUD2_loudness= value(AUD2_sigma); 
        end
        
        [AUD1,AUD2] = make_sounds(sigma_1,sigma_2,lfreq,hfreq,T1,T2,AUD1_length,AUD2_length,AUD1_pitch,AUD2_pitch,AUD1_loudness,AUD2_loudness,fcut,Fs,comparison_type,sound_type,filter_type);
% TODO Chuck recommends adding pink noise to the sound ui instead of this
% solution

        if ~isempty(AUD1)
            SoundManagerSection(obj, 'set_sound', 'StimAUD1', [AUD1';  AUD1'])
        end
        if ~isempty(AUD2)
        SoundManagerSection(obj, 'set_sound', 'StimAUD2', [AUD2';  AUD2'])
        end

        SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
        SoloFunctionAddVars('PWMsma', 'ro_args', ...
                {'AUD1_length';'AUD2_length'});
        if n_done_trials >0
            if ~violation_history(n_done_trials) && ~timeout_history(n_done_trials) 
                eval(sprintf('nTrialsClass%d.value=nTrialsClass%d+1;',thisclass(n_done_trials),thisclass(n_done_trials)));
                eval(sprintf('nt = value(nTrialsClass%d);',thisclass(n_done_trials)));
                if nt == 1
                    eval(sprintf('perfClass%d.value = 0;',thisclass(n_done_trials)))
                end
                eval(sprintf('perfClass%d.value=(perfClass%d * (nTrialsClass%d - 1) +%d)/nTrialsClass%d;',thisclass(n_done_trials),thisclass(n_done_trials),thisclass(n_done_trials),hit_history(n_done_trials),thisclass(n_done_trials)));
            end
            PWMSection(obj,'update_pair_history');
        end


    %---------------------------------------------------------------%
    %          comparison_type                                      %
    %---------------------------------------------------------------%
    case 'comparison_type'
        if strcmp(comparison_type, 'duration');
            xaxislabel= 'Duration AUD1';
            yaxislabel= 'Duration AUD2';
        elseif strcmp(comparison_type, 'pitch');
            xaxislabel= 'Frequency AUD1';
            yaxislabel= 'Frequency AUD2';
        else
            xaxislabel= 'sigma AUD1';
            yaxislabel= 'sigma AUD2';
        end    
        ylabel(yaxislabel,'FontSize',16);  
        xlabel(xaxislabel,'FontSize',16);
        %TODO add disable parameters
        %   check this example from new_numClass:
        %     for cc=1:20    
        %         eval(sprintf('disable(probClass%d)',cc)) 
        %     end
    

    %---------------------------------------------------------------%
    %          get_comparison_type                                  %
    %---------------------------------------------------------------%
    case 'get_comparison_type'
        if nargout > 0,
            x=[value(comparison_type)];
        end


    %---------------------------------------------------------------%
    %          get_psych_info_for_summary                           %
    %---------------------------------------------------------------%
    case 'get_psych_info_for_summary'
        if nargout >0,
            x = [value(probpsych)];
        end


    %---------------------------------------------------------------%
    %          get_sound_type                                       %
    %---------------------------------------------------------------%
    case 'get_sound_type'
        if nargout > 0,
            x=[value(sound_type)];
        end


    %---------------------------------------------------------------%
    %          new_numClass                                         %
    %---------------------------------------------------------------%
    case 'new_numClass'
        for cc=1:40    
            eval(sprintf('disable(probClass%d)',cc)) 
        end
        for cc=1:2*value(numClass)
            eval(sprintf('enable(probClass%d)',cc)) 
        end


    %---------------------------------------------------------------%
    %          get_class_perform                                    %
    %---------------------------------------------------------------%
    case 'get_class_perform'
        if nargout > 0,
            for ii=1:numClass*2+(numClass-1)*midclass_pairs+(nPsych)*psych_pairs
            eval(sprintf('final_perf(ii)=value(perfClass%d);',ii));
            end
            eval(sprintf('x=[value(perfClass%d) value(perfClass%d) value(perfClass%d) value(perfClass%d);]',1,value(numClass), value(numClass)+1,value(numClass)*2));
            y=final_perf;
        end    


    %---------------------------------------------------------------%
    %          numClass                                             %
    %---------------------------------------------------------------%
    case 'numClass',
        if numClass > existing_numClass,        %#ok<NODEF>
            orig_fig = double(gcf);
            my_window_visibility = get(my_window_info(3), 'Visible');
            x = my_window_info(1); y = my_window_info(2); figure(my_window_info(3));
            set(my_window_info(3), 'Visible', my_window_visibility);

            next_row(y, 1+ value(existing_numClass*2));
            new_class = (existing_numClass*2 + 1):value(numClass*2);
         
            
            for newnum = new_class,

                %% TODO this is a place to fix prob/perf/ntrials     
                NumeditParam(obj,['probClass',num2str(newnum)],1,x,y,'label',['probClass ',num2str(newnum)],'TooltipString','Probability of this pair');
                next_column(x); 
                DispParam(obj,['perfClass',num2str(newnum)],nan,x,y,'label',['perfClass ',num2str(newnum)],'TooltipString','Performance on this pair');
                next_column(x); 
                DispParam(obj,['nTrialsClass',num2str(newnum)],0,x,y,'label',['nTrialsClass ',num2str(newnum)],'TooltipString','Number of trials on this pair');
                next_row(y);  x = my_window_info(1);

            end;
         
            existing_numClass.value = value(numClass);
            figure(orig_fig);
         
            elseif numClass < existing_numClass,
                % If asking for fewer vars than exist, delete excess:
                for oldnum = (numClass*2+1):value(existing_numClass*2);
                    sphname = ['probClass' num2str(oldnum)];
                    delete(eval(sphname));
                    sphname = ['perfClass' num2str(oldnum)];
                    delete(eval(sphname));
                    sphname = ['nTrialsClass' num2str(oldnum)];
                    delete(eval(sphname));
                end;
                existing_numClass.value = value(numClass);
                else
                    x = my_window_info(1); y = my_window_info(2);
                    new_class = (1):value(numClass*2);
                    for newnum = new_class,
                        next_row(y);
                    end;
                end

                if value(psych_pairs) ==1
                    SoloParamHandle(obj, 'my_window_info', 'value', [x, y, value(myfig)], 'saveable', 0);
                    PWMSection(obj,'PsychClass');
                end

                PWMSection(obj,'plot_pairs');


    %---------------------------------------------------------------%
    %          PsychClass                                           %
    %---------------------------------------------------------------%
    case 'PsychClass' 
         orig_fig = double(gcf);
         my_window_visibility = get(my_window_info(3), 'Visible');
         x = my_window_info(1); y = my_window_info(2); figure(my_window_info(3));
         set(my_window_info(3), 'Visible', my_window_visibility);
         
      if nPsych > existing_numClassPsych,        %#ok<NODEF>

         next_row(y, 1+ value(existing_numClassPsych));
         new_class = (existing_numClassPsych + 1):value(nPsych);
         for newnum = new_class,
            DispParam(obj,['perfClass',num2str(newnum+numClass*2)],nan,x,y,'label',['perfClass ',num2str(newnum+numClass*2)],'TooltipString','Performance on this pair');
            next_column(x); 
            DispParam(obj,['nTrialsClass',num2str(newnum+numClass*2)],0,x,y,'label',['nTrialsClass ',num2str(newnum+numClass*2)],'TooltipString','Number of trials on this pair');
            next_row(y);  x = my_window_info(1);
            SoloParamHandle(obj, ['hperf',num2str(newnum+numClass*2)], 'value', 0);
         end;
         
         existing_numClassPsych.value = value(nPsych);
         figure(orig_fig);
         
      elseif nPsych < existing_numClassPsych,
         % If asking for fewer vars than exist, delete excess:
         for oldnum = (nPsych+1):value(existing_numClassPsych);
            sphname = ['perfClass' num2str(oldnum+numClass*2)];
            delete(eval(sphname));
            sphname = ['nTrialsClass' num2str(oldnum+numClass*2)];
            delete(eval(sphname));
         end;
         existing_numClassPsych.value = value(nPsych);
     
      end;
   

    %---------------------------------------------------------------%
    %          StimulusType                                         %
    %---------------------------------------------------------------%
    case 'StimulusType'
        if strcmp(StimulusType, 'library');
            enable((nPatt));
        else
            disable(nPatt);
        end

    %---------------------------------------------------------------%
    %          make_pairs                                           %
    %---------------------------------------------------------------%
    case 'make_pairs'
    % makes numClass pairs of sigma values -pairs are high to low (d) and low to high (u)   
    %     
    % TODO figure out ideal S2_S1_ratio for pitch, duration, keeping 2.6 for now
    % 2018-11-12 EJD
    if strcmp(comparison_type,'loudness');
        % TODO make this flexible later
        minS1=0.001;
        S2_S1_ratio=2.7;
    elseif strcmp(comparison_type,'pitch');
        % TODO make this flexible later
        minS1=500;
        S2_S1_ratio=2.6;
    elseif strcmp(comparison_type,'duration');
        % TODO make this flexible later
        minS1=0.2; % in seconds
        S2_S1_ratio=2;
    else
        error('unknown comparison_type in %s', mfilename);
    end
    
    Ind=(value(S2_S1_ratio-1))/(1+value(S2_S1_ratio));
    S1_d(1)=value(minS1);
    S2_d(1)=S1_d(1)*(1-Ind)/(1+Ind);
    S1_u(1)=S1_d;
    S2_u(1)=S1_u(1)*(1+Ind)/(1-(Ind));
    
    for ii=2:value(numClass+1)
    S1_d(ii)=S2_u(ii-1);    
    S2_d(ii)=S1_d(ii)*(1-Ind)/(1+Ind);
    S1_u(ii)=S1_d(ii);    
    S2_u(ii)=S1_u(ii)*(1+Ind)/(1-Ind);
    end
    pairs=[];
    pairs(:,1)=[S1_d S1_u];
    pairs(:,2)=[S2_d S2_u];
    
    % excludes first (lowest to lower) and last (higest to higher) pairs
    mainpairs=pairs(2:end-1,:);

    % add midclass pairs if needed
    if midclass_pairs

        for ii=1:length(S1_u)-1
            mS1_d(ii)=0.5*(log(S1_d(ii)*S1_d(ii+1)));
            mS2_d(ii)=0.5*(log(S2_d(ii)*S2_d(ii+1)));
            mS1_u(ii)=0.5*(log(S1_u(ii)*S1_u(ii+1)));
            mS2_u(ii)=0.5*(log(S2_u(ii)*S2_u(ii+1)));
        end
        mS1_d(ii+1)=mS1_d(ii);
        mS2_d(ii+1)=mS2_d(ii);
        mS1_u(ii+1)=mS1_u(ii);
        mS2_u(ii+1)=mS2_u(ii);

        mpairs(:,1)=exp([mS1_d mS1_u]);
        mpairs(:,2)=exp([mS2_d mS2_u]);
        midpairs=mpairs(2:end-1,:);

        [m,n]=size(midpairs');
        thesepairs.value=reshape(permute(cat(3,mainpairs',midpairs'), [1 3 2]), [m 2*n]);
        thesepairs.value=value(thesepairs)';
        pairs_d.value=thesepairs(1:value(numClass)*2-1,:);
        pairs_u.value=thesepairs(value(numClass)*2+1:value(numClass)*4-1,:);

        thesepairs.value=[value(pairs_d);value(pairs_u)];
        
        if psych_pairs
            PWMSection(obj,'PsychPairs'); 
            thesepairs.value=[value(thesepairs);value(pairs_d_psych);value(pairs_u_psych)];
        end

    else
            
        thesepairs.value=pairs(2:end-1,:);                
        % vols = sort(unique(thesepairs(:,1)));
        %         midval = round(length(vols)/2);
        %         d = vols(1:midval-1);
        %         u = vols(midval+1:end);
        %         if strcmp(ControlTask,'no 1st sound')
        %             pairs_d.value=[zeros(length(d),1),d];
        %             pairs_u.value=[zeros(length(u),1),u];
        %             thesepairs.value=[value(pairs_d);value(pairs_u)];
        %         elseif strcmp(ControlTask,'fixed 1st sound')
        %             pairs_d.value = [repmat(vols(midval),length(d),1),d];
        %             pairs_u.value = [repmat(vols(midval),length(d),1),d];
        %             thesepairs.value=[value(pairs_d);value(pairs_u)];
        %         end
        %TODO this doesn't make sense yet - re-orders, making psychpairs hard to
        %find - makes more sense to change thesepairs, and change pairs_d/u_psych      
        if strcmp(ControlTask,'no 1st sound')
            nopairs = [zeros(length(unique(roundn(pairs(:,2),-5))),1),unique(roundn(pairs(:,2),-5))];
            pairs_d.value = nopairs(nopairs(:,2)>median(nopairs(:,2)),:);
            pairs_u.value = nopairs(nopairs(:,2)<median(nopairs(:,2)),:);
        elseif strcmp(ControlTask, 'fixed 1st sound')
            fixedpairs = [repmat(median(unique(roundn(pairs(:,2),-5))),length(unique(roundn(pairs(:,2),-5))),1),unique(roundn(pairs(:,2),-5))];
            pairs_d.value = fixedpairs(fixedpairs(:,2)>median(fixedpairs(:,2)),:);
            pairs_u.value = fixedpairs(fixedpairs(:,2)<median(fixedpairs(:,2)),:);
            %make changing Rewards dropdown call makepairs
            %make changes to psychpairs
            %add this to midclasspairs if statement.
        else
            pairs_d.value=thesepairs(1:value(numClass),:);
            pairs_u.value=thesepairs(value(numClass)+1:value(numClass)*2,:);
        end
            thesepairs.value=[value(pairs_d);value(pairs_u)];
            if psych_pairs
                PWMSection(obj,'PsychPairs'); 
                thesepairs.value=[value(thesepairs);value(pairs_d_psych);value(pairs_u_psych)];
            end
        end
       
        %% 20210902 ejd moving sounds to sound ui
        % first get a list of unique sounds with precision to the 4th
        % decimal place
        % sound_list = unique(floor(value(thesepairs)*10^4)/10^4);
        
        % % now make each sound a variable
        % for sound_n = 1:length(sound_list)
        %     eval(sprintf("sound%d = %d",sound_n,sound_list(sound_n)));
        %     SoundManagerSection(obj, 'declare_new_sound', sprintf("sound%d",n))
        % end
        
        % SoloParamHandle(obj, 'thesepairs', 'value', []);
        % if ~isempty(AUD1)
        %     SoundManagerSection(obj, 'set_sound', 'StimAUD1', [AUD1';  AUD1'])
        % end


    %---------------------------------------------------------------%
    %          plot_pairs                                           %
    %---------------------------------------------------------------%
    case 'plot_pairs'  
        PWMSection(obj,'make_pairs');     
        maxS.value=max(thesepairs(:));

        % plot the pair set
        cla(value(PWMax))
        xd=log(thesepairs(:,1));
        yd=log(thesepairs(:,2));
        for ii=1:length(xd)
            axes(value(PWMax));
            plot(xd(ii),yd(ii),'s','MarkerSize',15,'MarkerEdgeColor',[0 0 0],'LineWidth',2)
            hold on
            eval(sprintf('hperf%d=text(xd(ii),yd(ii),num2str(ii));',ii));
            hold on
        end
        axis square

        yaxislabel='neweryaxis';
        xaxislabel='newerxaxis';

        if strcmp(comparison_type, 'duration');
            xaxislabel= 'Duration AUD1';
            yaxislabel= 'Duration AUD2';
        elseif strcmp(comparison_type, 'pitch');
            xaxislabel= 'Frequency AUD1';
            yaxislabel= 'Frequency AUD2';
        else
            xaxislabel= 'sigma AUD1';
            yaxislabel= 'sigma AUD2';
        end    
        ylabel(yaxislabel,'FontSize',16);  
        xlabel(xaxislabel,'FontSize',16);
    
        if strcmp(sound_type,'pink');
            title('pink noise stimuli');
        elseif strcmp(sound_type,'tone');
            title('tone frequency stimuli');
        % elseif strcmp(sound_type,'clicks');
        %     title('click stimuli');
        else
            title('not sure what stimuli');
        end

        % set(value(PWMax),'ytick',((yd(1:1+value(midclass_pairs):(end-nPsych*psych_pairs)/2))),'xtick',((xd(1:1+value(midclass_pairs):(end-nPsych*psych_pairs)/2))));
        %     set(value(PWMax),'yticklabel',num2str(exp(yd(1:1+value(midclass_pairs):(end-nPsych*psych_pairs)/2)),2),'xticklabel',num2str(exp(xd(1:1+value(midclass_pairs):(end-nPsych*psych_pairs)/2)),2));
        %     ylabel(yaxislabel,'FontSize',16);  
        %     set(value(PWMax),'Fontsize',15)
        %     xlabel(xaxislabel,'FontSize',16)
    
        % plot the current pair
        h1.value=plot(log(value(AUD1_sigma)),log(value(AUD2_sigma)),'s','color',[.96 .37 .65],'markerfacecolor',[.96 .37 .65],'MarkerSize',15,'LineWidth',3);
        %LOGplotPairs(thesepairs(:,1),thesepairs(:,2),'s',15,'k',1,16,thispair(1),thispair(2),value(PWMax),'init')


    %---------------------------------------------------------------%
    %          get_pairs                                            %
    %---------------------------------------------------------------%
    case 'get_pairs'
        if nargout>0
            x=value(pairs_u);
            y=value(pairs_d);
        end
    

    %---------------------------------------------------------------%
    %          new_duration                                         %
    %---------------------------------------------------------------%
    case 'new_duration', 
        if stimuli_on == 0
            PreStim_time.value=0;
            AUD1_time.value=0;
            AUD2_time.value=0;
            time_bet_AUD2_gocue.value=0;
            disable(PreStim_time);
            disable(AUD1_time);
            disable(AUD2_time);
            disable(time_bet_AUD2_gocue);
        else
            enable(PreStim_time);
            enable(AUD1_time);
            enable(AUD2_time);
            enable(time_bet_AUD2_gocue);
        end
        CP_duration.value=PreStim_time + AUD1_time + AUD2_time + Del_time + time_bet_AUD2_gocue;
        Total_CP_duration.value = CP_duration + time_go_cue; %#ok<*NASGU>
        % plot the pair
        h1.value=plot(log(value(AUD1_sigma)),log(value(AUD2_sigma)),'s','color',[0.8 0.4 0.1],'markerfacecolor',[0.8 0.4 0.1],'MarkerSize',15,'LineWidth',3);
        %LOGplotPairs(thesepairs(:,1),thesepairs(:,2),'s',15,'k',1,16,thispair(1),thispair(2),value(PWMax),'init')


    %---------------------------------------------------------------%
    %          plot_perf                                            %
    %---------------------------------------------------------------%
    case 'plot_perf'
        % plot the pair set
        cla(value(PWMaxperf))
        xd=log(thesepairs(:,1));
        yd=log(thesepairs(:,2));
        for ii=1:length(xd)
            axes(value(PWMaxperf));
            plot(xd(ii),yd(ii),'s','MarkerSize',31,'MarkerEdgeColor',[0 0 0],'LineWidth',1.5)
            hold on
            eval(sprintf('perf=value(perfClass%d);',ii))
            text(xd(ii)-0.14,yd(ii),num2str(round(perf*1000)/10));
            hold on
        end
        axis square
        % set(value(PWMax),'ytick',((yd(1:1+value(midclass_pairs):(end-nPsych*psych_pairs)/2))),'xtick',((xd(1:1+value(midclass_pairs):(end-nPsych*psych_pairs)/2))));
        % set(value(PWMax),'yticklabel',num2str(exp(yd(1:1+value(midclass_pairs):(end-nPsych*psych_pairs)/2)),2),'xticklabel',num2str(exp(xd(1:1+value(midclass_pairs):(end-nPsych*psych_pairs)/2)),2));
        % set(value(PWMaxperf),'Fontsize',15)
       

    %---------------------------------------------------------------%
    %          PsychPairs                                           %
    %---------------------------------------------------------------%
    case 'PsychPairs'
        % change FROM to be editable/dropdown based on pairs and default to middle
        %   PWMSection(obj,'make_pairs');  
        if psych_pairs == 1
            enable(nPsych);
            enable(from);
            enable(psych_type);     
        if strcmp(comparison_type,'loudness');
            % TODO make this flexible later
            minS1=0.007;
            S2_S1_ratio=2.7;
        elseif strcmp(comparison_type,'pitch');
            % TODO make this flexible later
            minS1=500;
            S2_S1_ratio=2.6;
        elseif strcmp(comparison_type,'duration');
            % TODO make this flexible later
            minS1=0.2; % in seconds
            S2_S1_ratio=2;
        else
            error('unknown comparison_type in %s', mfilename);
        end
    
        % Emily added this - always chooses middle pair for psychometrics
        % TODO add options/drop down for "from" rather than manual entry
        % from = mainpairs(floor(numClass/2),1);
        % Ind=(value(S2_S1_ratio-1))/(1+value(S2_S1_ratio));   

        Ind=(value(S2_S1_ratio-1))/(1+value(S2_S1_ratio));
        if strcmp(psych_type,'horizpairs')
            s2=value(from);
            s1_first=s2*(1-Ind)/(1+Ind);
            s1_last=s2*(1+Ind)/(1-Ind);
            s1_first=log(s1_first);
            s1_last=log(s1_last);
            s2=log(s2);
            psych_diff=(s1_last-s1_first)/(value(nPsych)-1);
            s1_psych(1)=s1_first;
            s2_psych(1)=s2;
            for nn = 1:value(nPsych)-1
                s1_psych(nn+1)=s1_psych(nn)+psych_diff;
                s2_psych(nn+1)=s2_psych(1);
            end
            
            pairs_u_psych.value = [s1_psych(1:value(nPsych)/2);s2_psych(1:value(nPsych)/2)];
            pairs_d_psych.value = [s1_psych(value(nPsych)/2+1:end);s2_psych(value(nPsych)/2+1:end)];
                                
               
        else
            s1=value(from);
            s2_first=s1*(1-Ind)/(1+Ind);
            s2_last=s1*(1+Ind)/(1-Ind);
            s2_first=log(s2_first);
            s2_last=log(s2_last);
            s1=log(s1);
            psych_diff=(s2_last-s2_first)/(value(nPsych)-1);
            s2_psych(1)=s2_first;
            s1_psych(1)=s1;
            for nn = 1:value(nPsych)-1
                s2_psych(nn+1)=s2_psych(nn)+psych_diff;
                s1_psych(nn+1)=s1_psych(1);
            end
            pairs_d_psych.value = [s1_psych(1:value(nPsych)/2);s2_psych(1:value(nPsych)/2)];
            pairs_u_psych.value = [s1_psych(value(nPsych)/2+1:end);s2_psych(value(nPsych)/2+1:end)];
        end
        pairs_d_psych.value=exp(value(pairs_d_psych))';
        pairs_u_psych.value=exp(value(pairs_u_psych))';
        pairs_d.value=[value(pairs_d); value(pairs_d_psych)];
        pairs_u.value=[value(pairs_u); value(pairs_u_psych)];
        %PWMSection(obj,'plot_pairs');
        else
            disable(nPsych);
            disable(from);
            disable(psych_type);
    end
      
%TODO this doesn't make sense yet - re-orders, making psychpairs hard to
%find - makes more sense to change thesepairs, and change pairs_d/u_psych 
        

    %---------------------------------------------------------------%
    %          hide / show_hide                                     %
    %---------------------------------------------------------------%
    case 'hide',
        PWMshow.value = 0;
        set(value(myfig), 'Visible', 'off');
    case 'show_hide',
        if value(PWMshow) == 1, set(value(myfig), 'Visible', 'on');  %#ok<NODEF>
        else                      set(value(myfig), 'Visible', 'off');
        end;


    %---------------------------------------------------------------%
    %          update_pairs                                         %
    %---------------------------------------------------------------%
    case 'update_pairs'
        PWMSection(obj,'plot_pairs');
    
    case 'update_pair_history'
        ps=value(pair_history);
        ps(n_done_trials)=value(thisclass(n_done_trials));
        pair_history.value=ps;


    %---------------------------------------------------------------%
    %          get_control_history                                  %
    %---------------------------------------------------------------%
    case 'get_control_history'
        x = [value(control_history)];
 

    %---------------------------------------------------------------%
    %          close                                                %
    %---------------------------------------------------------------%
    case 'close'   
        try %#ok<TRYNC>
            if ishandle(value(myfig)), delete(value(myfig)); end;
            delete_sphandle('owner', ['^@' class(obj) '$'], 'fullname', [mfilename '_' tname]);
        end;
    

    %---------------------------------------------------------------%
    %          reinit                                               %
    %---------------------------------------------------------------%
    case 'reinit'
        % Get the original GUI position and figure:
        my_gui_info = value(my_gui_info);
        x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));
        
        % close everything involved with the plugin
        feval(mfilename, obj, 'close');

        % Reinitialise at the original GUI position and figure:
        feval(mfilename, obj, 'init', x, y);
            

    %---------------------------------------------------------------%
    %          otherwise                                            %
    %---------------------------------------------------------------%
    otherwise
        warning('%s : action "%s" is unknown!', mfilename, action); %#ok<WNTAG> (This line OK.)

end

