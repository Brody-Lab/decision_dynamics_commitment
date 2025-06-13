function [x, y] = StimulusSection(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action,

    % ------------------------------------------------------------------
    %              INIT
    % ------------------------------------------------------------------

    case 'init'
        x=varargin{1};
        y=varargin{2};



        %%%% WATER INCREASE

        DispParam(obj, 'water_increase_multiplier',1, x, y, 'labelfraction', 0.65,...
            'TooltipString', 'water increase multiplier as a function of n_done_trials');next_row(y);

        NumeditParam(obj, 'WI_base', .95, x, y, 'labelfraction', 0.2,'label','B','position', [x y 66 20],  ...
            'TooltipString', 'water increase base');

        NumeditParam(obj, 'WI_ratio', .00025, x, y, 'labelfraction', 0.2,'label','R','position', [x+66 y 66 20], ...
            'TooltipString', 'water increase per trial');

        NumeditParam(obj, 'WI_max', 1.2, x, y, 'labelfraction', 0.2,'label','M','position', [x+133 y 66 20], ...
            'TooltipString', 'water increase max');next_row(y);

        ToggleParam(obj, 'water_increase_toggle', 1, x,y,...
            'OnString', 'Water increase ON','OffString', 'Water increase OFF',...
            'TooltipString', sprintf('If on water increase is on'));next_row(y);




        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%% TIMING PARAMETERS WINDOW %%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%% Separate window for stimulus parameters
        ToggleParam(obj, 'TimingShow', 0, x, y, 'OnString', 'Parameters timing', ...
            'OffString', 'Parameters timing', 'TooltipString', 'Show/Hide Timing panel');
        set_callback(TimingShow, {mfilename, 'show_hide3'});
        next_row(y);oldx=x; oldy=y; parentfig=double(gcf);
        SoloParamHandle(obj, 'myfig3', 'value', double(figure('Position', [300 100 280 220],'closerequestfcn',...
            [mfilename '(' class(obj) ', ''hide3'');'], 'MenuBar', 'none','Name', mfilename)), 'saveable', 0);

        set(gcf, 'Visible', 'off');
        x=10;y=10;

        NumeditParam(obj, 'timeout_delay', 3, x,y,'label','Timeout delay','TooltipString','Delay after timeout at spoke, follows new trial');
        next_row(y);

        NumeditParam(obj, 'reward_delay', 0.001, x,y,'label','Reward Delay','TooltipString','Delay between side poke and reward delivery');
        next_row(y);

        NumeditParam(obj, 'wait_for_spoke_timeout', 60, x,y,'label','Timeout for spoke','TooltipString','Time after NIC to wait for a side poke');
        next_row(y);

        NumeditParam(obj, 'nic_delay', 3, x,y,'label','NIC violation delay','TooltipString','Delay after NIC violation, follows new trial');
        next_row(y);

        NumeditParam(obj, 'settling_time', 0.001, x,y,'label','Pre-stimulus delay','TooltipString','Time in NIC before starting stimulus');
        next_row(y);

        NumeditParam(obj, 'wait_for_cpoke_timeout', 120, x,y,'label','Timeout for cpoke','TooltipString','Timeout waiting for cpoke');
        next_row(y);

        SubheaderParam(obj,'title','Timing',x,y); next_row(y, 1.5);

        %%% back to the main window
        x=oldx; y=oldy;
        figure(parentfig);




        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%% SOUND PARAMETERS WINDOW %%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%% Separate window for sound parameters
        ToggleParam(obj, 'SoundsShow', 0, x, y, 'OnString', 'Parameters other sounds', ...
            'OffString', 'Parameters other sounds', 'TooltipString', 'Show/Hide Sounds panel');
        set_callback(SoundsShow, {mfilename, 'show_hide2'});next_row(y);
        oldx=x; oldy=y;    parentfig=double(gcf);
        SoloParamHandle(obj, 'myfig2', 'value', double(figure('Position', [100 100 560 440],'closerequestfcn',...
            [mfilename '(' class(obj) ', ''hide2'');'], 'MenuBar', 'none','Name', mfilename)), 'saveable', 0);
        set(gcf, 'Visible', 'off');
        x=10;y=10;

        %%%% Sound parameters
        [x,y]=SoundInterface(obj,'add','ViolationSound',x,y,'Style','SpectrumNoise','Volume',0.0015,'Loop',1);
        SoundInterface(obj,'set','ViolationSound','Freq1',8000,'Freq2',2222,'Dur1',1,'Sigma',14,'Cntrst',111,'CRatio',1);

        [x,y]=SoundInterface(obj,'add','ErrorSound',x,y,'Style','PClick','Volume',0.0035,'Loop',1);
        SoundInterface(obj,'set','ErrorSound','Freq1',333,'Freq2',333,'Dur1',0.5,'Width',5);

        [x,y]=SoundInterface(obj,'add','Task1Sound',x,y,'Style','ToneFMWiggle','Volume',0.005);
        SoundInterface(obj,'set','Task1Sound','Dur1',1,'Freq1',4000,'FMAmp',600,'FMFreq',5);

        next_column(x);y=10;

        [x,y]=SoundInterface(obj,'add','TimeoutSound',x,y,'Style','SpectrumNoise','Volume',0.0025,'Loop',1);
        SoundInterface(obj,'set','TimeoutSound','Freq1',1000,'Freq2',1000,'Dur1',1,'Sigma',100,'Cntrst',500,'CRatio',5);

        [x,y]=SoundInterface(obj,'add','HitSound',x,y,'Style','ToneSweep','Volume',0.0025);
        SoundInterface(obj,'set','HitSound','Freq1',1000,'Freq2',5000,'Dur1',0.1,'Dur2',0.3,'Tau',0.05);

        [x,y]=SoundInterface(obj,'add','Task2Sound',x,y,'Style','ToneFMWiggle','Volume',0.005);
        SoundInterface(obj,'set','Task2Sound','Dur1',1,'Freq1',9000,'FMAmp',1800,'FMFreq',15);

        %%% back to the main window
        x=oldx; y=oldy;
        figure(parentfig);





        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%% STIM. PARAMETERS WINDOW %%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%% Separate window for stimulus parameters
        ToggleParam(obj, 'StimuluShow', 0, x, y, 'OnString', 'Parameters stimulus', ...
            'OffString', 'Parameters stimulus', 'TooltipString', 'Show/Hide Stimulus panel');
        set_callback(StimuluShow, {mfilename, 'show_hide'});
        next_row(y);
        oldx=x; oldy=y;    parentfig=double(gcf);
        SoloParamHandle(obj, 'myfig', 'value', double(figure('Position', [300 100 280 220], 'closerequestfcn',...
            [mfilename '(' class(obj) ', ''hide'');'], 'MenuBar', 'none','Name', mfilename)), 'saveable', 0);
        set(gcf, 'Visible', 'off');
        x=10;y=10;

        %%%% Stimulus parameters
        NumeditParam(obj, 'bup_width', 5, x, y, 'position', [x y 200 20], ...
            'label', 'bup_width (ms)', 'TooltipString', 'the bup width in units of msec');next_row(y);
        NumeditParam(obj, 'bup_ramp', 2, x, y, 'position', [x y 200 20], ...
            'label', 'bup_ramp (ms)', 'TooltipString', 'the duration in units of msec of the upwards and downwards volume ramps for individual bups');next_row(y);
        NumeditParam(obj, 'total_rate', 40, x, y, 'position', [x y 200 20], ...
            'TooltipString', 'the sum of left and right bup rates');next_row(y);
        NumeditParam(obj, 'freq_lo', 6500, x, y, 'position', [x y 200 20], ...
            'TooltipString', 'low frequency (Hz)');next_row(y);
        NumeditParam(obj, 'freq_hi', 14200, x, y, 'position', [x y 200 20], ...
            'TooltipString', 'high frequency (Hz)');next_row(y);
        NumeditParam(obj, 'vol_low_freq', 1, x, y, 'position', [x y 200 20], ...
            'TooltipString', 'volume multiplier for clicks at low frequency');next_row(y);
        NumeditParam(obj, 'vol_hi_freq', 1, x, y, 'position', [x y 200 20], ...
            'TooltipString', 'volume multiplier for clicks at high frequency');next_row(y);
        %%% overall volume
        NumeditParam(obj, 'vol', 0.15, x, y, 'position', [x y 200 20],'label','Overall volume multiplier', ...
            'labelfraction', 0.7,'TooltipString', 'volume multiplier for all sounds in the protocol');next_row(y);

        %%% back to the main window
        x=oldx; y=oldy;
        figure(parentfig);






        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%% TASK SWITCHING PARAMETERS %%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%% minimum performances required
        NumeditParam(obj, 'task_switch_min_perf', .8, x, y, 'position', [x y 200 20], ...
            'label', 'Min perf', 'TooltipString', 'Minimum performance to allow switching');next_row(y);

        %%%% minimum number of trials
        NumeditParam(obj, 'task_switch_mintrials', 30, x, y, 'position', [x y 200 20], ...
            'label', 'Min trials', 'TooltipString', 'Minimum number of trials before switching');next_row(y);

        %%%% switch on/off
        ToggleParam(obj, 'task_switch_auto', 0, x, y, 'position', [x y 200 20], ...
            'OffString', 'Auto task switch OFF', 'OnString',  'Auto task switch ON', ...
            'TooltipString', 'If on, switches automatically between tasks');next_row(y);

        %%%% first task: direction or random?
        ToggleParam(obj, 'randomize_first_task', 0, x, y, 'position', [x y 200 20], ...
            'OffString', 'Start with direction', 'OnString',  'Randomize first task', ...
            'TooltipString', 'If on, picks randomly the first task');next_row(y,2);

        %%%% are incongruent stimuli present now?
        DispParam(obj, 'exist_incoherent',0, x, y,...
            'TooltipString', '1 if incoherent trials can be generated under current parameters');
        next_row(y);

        %%%% number of incoherent trials in this block
        DispParam(obj, 'nTrials_incoh_task', 0, x, y,'labelfraction', 0.55,'label','nTri incoh','position', [x y 100 20]);
        %%%% performance on incoherent trials in this block
        DispParam(obj, 'total_correct_incoherent_task',0, x, y, 'labelfraction', 0.55,'label','%hit incoh','position', [x+100 y 100 20]);next_row(y);

        %%%% number of coherent trials in this block
        DispParam(obj, 'nTrials_coh_task',0, x, y, 'labelfraction', 0.55,'label','nTri coh','position', [x y 100 20]);
        %%%% performance on coherent trials in this block
        DispParam(obj, 'total_correct_coherent_task',0, x, y, 'labelfraction', 0.55,'label','%hit coh','position', [x+100 y 100 20]);next_row(y);

        %%%% total number of trials in this block
        DispParam(obj, 'nTrials_task',0, x, y, 'labelfraction', 0.55,'label','nTri all','position', [x y 100 20]);
        %%%% overall performance in this block
        DispParam(obj, 'total_correct_task', 0, x, y,'labelfraction', 0.55,'label','%hit all','position', [x+100 y 100 20]);next_row(y);

        %%%% current task
        MenuParam(obj, 'ThisTask', {'Direction'; 'Frequency'}, 1, x, y, ...
            'TooltipString', 'the task of the present trial'); next_row(y);

        SubheaderParam(obj,'title','Current Task',x,y, 'position', [x y 200 18]); next_row(y,1.5);






        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%% ANTIBIAS %%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%% Ab_TAU: number of trials back for antibias
        NumeditParam(obj, 'Ab_Tau', 50, x, y,'position', [x y 100 20],  ...
            'TooltipString', 'Number of trials back over which to compute antibias');

        %%% Ab_BETA: strenth of antibias
        NumeditParam(obj, 'Ab_Beta', 5, x, y,'position', [x+100 y 100 20], ...
            'TooltipString', 'antibias strength');next_row(y);

        %%% antibias type
        MenuParam(obj, 'antibias_type', {'No antibias'; 'Side antibias';...
            'Quadrant antibias'}, 1, x, y, 'label', 'Type', 'TooltipString',...
            'antibias type (depends on exist_incoherent)', 'labelfraction',...
            0.3333);next_row(y,1);

        %%% side antibias on/off
        ToggleParam(obj, 'antibias_toggle', 1, x,y,...
            'OnString', 'Antibias ON','OffString', 'Antibias OFF',...
            'TooltipString', sprintf('If on antibias is on'));next_row(y,1.1);




        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%% TRAINING PARAMETERS %%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%% mixing of frequency evidence
        SliderParam(obj,'stimulus_mixing_freq',0,0,1,x, y,'label','%mixing freq', 'position', [x y 200 20]);next_row(y);
        %%% mixing of direction evidence
        SliderParam(obj,'stimulus_mixing_dir',0,0,1,x, y,'label','%mixing dir', 'position', [x y 200 20]);next_row(y,1.3);


        %%% on trials w/ error forgiveness for frequency, wait delay
        SliderParam(obj,'wait_delay_freq',0.2,0.2,3,x, y,'label','wait delay', 'position', [x y 200 20]);next_row(y);

        %%% helper lights on/off for frequency trials
        ToggleParam(obj, 'helper_lights_freq', 1, x, y, ...
            'OffString', 'Freq. lights OFF', ...
            'OnString',  'Freq. lights ON', ...
            'TooltipString', 'If on (black), LED lights help indicate what to do; if off (brown), no helper LED lights','position', [x y 100 20]);

        %%% toggle error forgiveness on/off for frequency trials
        ToggleParam(obj, 'error_forgiveness_freq', 1, x, y, ...
            'OffString', 'Forgive OFF', ...
            'OnString',  'Forgive ON', ...
            'TooltipString', 'If on (black), start new trial upon wrong side choice; if off (brown), can choose again',...
            'position', [x+100 y 100 20]);next_row(y,1.1);

        %%% required time with nose in center
        SliderParam(obj,'nose_in_center',0.05,0.05,1.3,x, y,'label','min NIC', 'position', [x y 200 20]);next_row(y,1.1);
        
        SubheaderParam(obj,'title','Training parameters',x,y, 'position', [x y 200 18]); next_row(y);








        %%%%%% COLUMN 3 %%%%%%
        y=5; next_column(x);


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%% DIRECTION TASK %%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%% delay for each quadrant
        DispParam(obj, 'Delay3Dir',4, x, y,'labelfraction',0.6,'position', [x y 100 20]);
        DispParam(obj, 'Delay4Dir',4, x, y,'labelfraction',0.6,'position', [x+100 y 100 20]);next_row(y);
        DispParam(obj, 'Delay2Dir',4, x, y,'labelfraction',0.6,'position', [x y 100 20]);
        DispParam(obj, 'Delay1Dir',4, x, y,'labelfraction',0.6,'position', [x+100 y 100 20]);next_row(y,1.1);

        %%% water for each quadrant
        DispParam(obj, 'Water3Dir',1, x, y,'labelfraction',0.6,'position', [x y 100 20]);
        DispParam(obj, 'Water4Dir',1, x, y,'labelfraction',0.6,'position', [x+100 y 100 20]);next_row(y);
        DispParam(obj, 'Water2Dir',1, x, y,'labelfraction',0.6,'position', [x y 100 20]);
        DispParam(obj, 'Water1Dir',1, x, y,'labelfraction',0.6,'position', [x+100 y 100 20]);next_row(y,1.1);

        %%% probability for each quadrant
        DispParam(obj, 'Prob3Dir',0.25, x, y,'labelfraction',0.6,'position', [x y 100 20]);
        DispParam(obj, 'Prob4Dir',0.25, x, y,'labelfraction',0.6,'position', [x+100 y 100 20]);next_row(y);
        DispParam(obj, 'Prob2Dir',0.25, x, y,'labelfraction',0.6,'position', [x y 100 20]);
        DispParam(obj, 'Prob1Dir',0.25, x, y,'labelfraction',0.6,'position', [x+100 y 100 20]);next_row(y,1.1);

        %%% percent correct for each quadrant
        DispParam(obj, 'Bias3Dir',0.25, x, y,'labelfraction',0.6,'position', [x y 100 20]);
        DispParam(obj, 'Bias4Dir',0.25, x, y,'labelfraction',0.6,'position', [x+100 y 100 20]);next_row(y);
        DispParam(obj, 'Bias2Dir',0.25, x, y,'labelfraction',0.6,'position', [x y 100 20]);
        DispParam(obj, 'Bias1Dir',0.25, x, y,'labelfraction',0.6,'position', [x+100 y 100 20]);next_row(y,1.1);

        SubheaderParam(obj,'title','Quadrant Antibias',x,y, 'position', [x y 407 20]); next_row(y,1);



        DispParam(obj, 'WaterL',1, x, y,'position', [x y 100 20]);
        DispParam(obj, 'WaterR',1, x, y,'position', [x+100 y 100 20]);

        next_column(x);

        DispParam(obj, 'DelayL',4, x, y,'position', [x y 100 20]);
        DispParam(obj, 'DelayR',4, x, y,'position', [x+100 y 100 20]);next_row(y,1.1);

        next_column(x,-1);

        DispParam(obj, 'BiasL',0.5, x, y,'position', [x y 100 20]);
        DispParam(obj, 'BiasR',0.5, x, y,'position', [x+100 y 100 20]);

        next_column(x);

        DispParam(obj, 'ProbL',0.5, x, y,'position', [x y 100 20]);
        DispParam(obj, 'ProbR',0.5, x, y,'position', [x+100 y 100 20]);next_row(y,1.1);

        next_column(x,-1);
        SubheaderParam(obj,'title','Side Antibias',x,y, 'position', [x y 407 20]); next_row(y,1.1);


        %%%%%%%%%%% all the possible durations and gammas
        NumeditParam(obj, 'durations_dir', [1.3], x, y, 'position', [x y 200 20], ...
            'label','Duration values','TooltipString', 'possible stimulus durations');next_row(y);
        NumeditParam(obj, 'gamma_freq_values_dir', [0], x, y, 'position', [x y 200 20], ...
            'label','Gamma_freq values','TooltipString', 'possible gamma_freq values');next_row(y);
        NumeditParam(obj, 'gamma_dir_values_dir', [4], x, y, 'position', [x y 200 20], ...
            'label','Gamma_dir values','TooltipString', 'possible gamma_dir values');next_row(y);





        %%%%%% COLUMN 3 %%%%%%
        y=5; next_column(x);


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%% FREQUENCY TASK %%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        %%% delay for each quadrant
        DispParam(obj, 'Delay3Freq',4, x, y,'labelfraction',0.6,'position', [x y 100 20]);
        DispParam(obj, 'Delay4Freq',4, x, y,'labelfraction',0.6,'position', [x+100 y 100 20]);next_row(y);
        DispParam(obj, 'Delay2Freq',4, x, y,'labelfraction',0.6,'position', [x y 100 20]);
        DispParam(obj, 'Delay1Freq',4, x, y,'labelfraction',0.6,'position', [x+100 y 100 20]);next_row(y,1.1);

        %%% water for each quadrant
        DispParam(obj, 'Water3Freq',1, x, y,'labelfraction',0.6,'position', [x y 100 20]);
        DispParam(obj, 'Water4Freq',1, x, y,'labelfraction',0.6,'position', [x+100 y 100 20]);next_row(y);
        DispParam(obj, 'Water2Freq',1, x, y,'labelfraction',0.6,'position', [x y 100 20]);
        DispParam(obj, 'Water1Freq',1, x, y,'labelfraction',0.6,'position', [x+100 y 100 20]);next_row(y,1.1);

        %%% probability for each quadrant
        DispParam(obj, 'Prob3Freq',0.25, x, y,'labelfraction',0.6,'position', [x y 100 20]);
        DispParam(obj, 'Prob4Freq',0.25, x, y,'labelfraction',0.6,'position', [x+100 y 100 20]);next_row(y);
        DispParam(obj, 'Prob2Freq',0.25, x, y,'labelfraction',0.6,'position', [x y 100 20]);
        DispParam(obj, 'Prob1Freq',0.25, x, y,'labelfraction',0.6,'position', [x+100 y 100 20]);next_row(y,1.1);

        %%% percent correct for each quadrant
        DispParam(obj, 'Bias3Freq',0.25, x, y,'labelfraction',0.6,'position', [x y 100 20]);
        DispParam(obj, 'Bias4Freq',0.25, x, y,'labelfraction',0.6,'position', [x+100 y 100 20]);next_row(y);
        DispParam(obj, 'Bias2Freq',0.25, x, y,'labelfraction',0.6,'position', [x y 100 20]);
        DispParam(obj, 'Bias1Freq',0.25, x, y,'labelfraction',0.6,'position', [x+100 y 100 20]);next_row(y,5.4);




        %%%%%%%%%%% all the possible durations and gammas
        NumeditParam(obj, 'durations_freq', [1.3], x, y, 'position', [x y 200 20], ...
            'label','Duration values','TooltipString', 'possible stimulus durations');next_row(y);
        NumeditParam(obj, 'gamma_freq_values_freq', [4], x, y, 'position', [x y 200 20], ...
            'label','Gamma_freq values','TooltipString', 'possible gamma_freq values');next_row(y);
        NumeditParam(obj, 'gamma_dir_values_freq', [0], x, y, 'position', [x y 200 20], ...
            'label','Gamma_dir values','TooltipString', 'possible gamma_dir values');next_row(y);



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%% IMAGE PLOTS %%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%% button to update all plots
        PushbuttonParam(obj,'draw', x, y, 'position', [x+170 y 30 20],'label', 'draw');
        set_callback(draw, {mfilename, 'update_plot_button'});
        next_row(y);


        %%% direction plot
        newaxes = axes;
        SoloParamHandle(obj, 'myaxesdir', 'saveable', 0,'value', double(newaxes));
        set(value(myaxesdir),'Position', [.52 .58 .21 .21]);
        SoloParamHandle(obj, 'matrixdir', 'saveable',0);


        %%% frequency plot
        newaxes = axes;
        SoloParamHandle(obj, 'myaxesfreq', 'saveable', 0,'value', double(newaxes));
        set(value(myaxesfreq),'Position', [.74 .58 .21 .21]);
        SoloParamHandle(obj, 'matrixfreq', 'saveable',0);


        feval(mfilename, obj, 'initialize_plots');





        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%% STIMULUS VARIABLES %%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        next_row(y,9.3);
        next_column(x,-1);

        SubheaderParam(obj,'title','This',x,y, 'position', [x y 50 20]);        
        %%% current quadrant/side
        DispParam(obj, 'ThisSide','RIGHT', x, y,'label','Side','position', [x+50 y 70 20]);
        DispParam(obj, 'ThisQuadrant',4, x, y,'label','Quad','position', [x+120 y 70 20]);
        %%% current duration
        DispParam(obj, 'ThisDuration', 1.3, x, y,'label','Dur', 'position', [x+190 y 70 20], 'labelfraction', 0.6);
        %%% current gammas
        DispParam(obj, 'ThisGamma_dir',1, x, y,'label','Gdir','position', [x+260 y 70 20]);
        DispParam(obj, 'ThisGamma_freq',1, x, y,'label','Gfreq','position', [x+330 y 70 20]);next_row(y);

        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%% LAST TRIALS PLOT %%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        newaxes = axes;
        SoloParamHandle(obj, 'myaxeshistory0', 'saveable', 0,'value', double(newaxes));
        set(value(myaxeshistory0),'Position', [.87 .83 .08 .08]);
        set(value(myaxeshistory0),'XLim',[0.5 6.5],'YLim',[0.5 6.5]);
        set(value(myaxeshistory0),'XTick',[],'YTick',[]);
        set(value(myaxeshistory0),'Box','off');

        newaxes = axes;
        SoloParamHandle(obj, 'myaxeshistory1', 'saveable', 0,'value', double(newaxes));
        set(value(myaxeshistory1),'Position', [.775 .83 .08 .08]);
        set(value(myaxeshistory0),'XLim',[0.5 6.5],'YLim',[0.5 6.5]);
        set(value(myaxeshistory1),'XTick',[],'YTick',[]);
        set(value(myaxeshistory1),'Box','off');
        
        newaxes = axes;
        SoloParamHandle(obj, 'myaxeshistory2', 'saveable', 0,'value', double(newaxes));
        set(value(myaxeshistory2),'Position', [.68 .83 .08 .08]);
        set(value(myaxeshistory2),'XTick',[],'YTick',[]);
        set(value(myaxeshistory2),'Box','off');
        
        newaxes = axes;
        SoloParamHandle(obj, 'myaxeshistory3', 'saveable', 0,'value', double(newaxes));
        set(value(myaxeshistory3),'Position', [.585 .83 .08 .08]);
        set(value(myaxeshistory3),'XTick',[],'YTick',[]);
        set(value(myaxeshistory3),'Box','off');
        
        newaxes = axes;
        SoloParamHandle(obj, 'myaxeshistory4', 'saveable', 0,'value', double(newaxes));
        set(value(myaxeshistory4),'Position', [.49 .83 .08 .08]);
        set(value(myaxeshistory4),'XTick',[],'YTick',[]);
        set(value(myaxeshistory4),'Box','off');
        
        
        


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%% INTERNAL VARIBLES %%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %stimulus variables
        SoloParamHandle(obj, 'ThisSideFrequency', 'value', 'RIGHT');
        SoloParamHandle(obj, 'ThisSideDirection', 'value', 'RIGHT');
        SoloParamHandle(obj, 'incoherent_trial', 'value', 1);

        %variables to send to the state matrix
        SoloParamHandle(obj, 'total_error_delay', 'value', 0);
        SoloParamHandle(obj, 'total_water_multiplier', 'value', 1);

        %information about current stimulus to be saved in the data file
        SoloParamHandle(obj, 'ThisStimulus', 'value', []);








        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%% SEND OUT VARIBLES %%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%% send to the state matrix section
        SoloFunctionAddVars('SMA1', 'ro_args',{'ThisTask';'settling_time';...
            'reward_delay';'nose_in_center';'nic_delay';...
            'error_forgiveness_freq';'wait_delay_freq';...
            'wait_for_cpoke_timeout';'wait_for_spoke_timeout';
            'timeout_delay';'ThisSide';'helper_lights_freq';...
            'total_error_delay';'total_water_multiplier'});

        %%% send to the training section
        SoloFunctionAddVars('TrainingSection', 'rw_args', {...
            'antibias_type';'gamma_dir_values_dir';'gamma_dir_values_freq';...
            'gamma_freq_values_dir';'gamma_freq_values_freq';...
            'durations_dir';'durations_freq';'stimulus_mixing_dir';...
            'stimulus_mixing_freq';'nose_in_center' ;'error_forgiveness_freq';...
            'wait_delay_freq';'helper_lights_freq';'ThisTask';...
            'randomize_first_task';'task_switch_auto';'task_switch_min_perf'});

        %%% send to the history section
        SoloFunctionAddVars('HistorySection', 'ro_args', {'ThisSide';...
            'ThisQuadrant';'incoherent_trial';...
            'ThisGamma_dir';'ThisGamma_freq';'ThisTask'});

        SoloFunctionAddVars('HistorySection', 'rw_args', {'nTrials_task';...
            'nTrials_coh_task';'nTrials_incoh_task';'total_correct_task';...
            'total_correct_incoherent_task';...
            'total_correct_coherent_task'});






    case 'next_trial',



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%% WHAT TASK ON THIS TRIAL? %%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        was_block_switch.value=0;

        %%% choose task for the first trial in the session
        if(n_done_trials<=1)
            if(value(randomize_first_task)==1)
                if(rand(1)>0.5)
                    ThisTask.value='Direction';
                else
                    ThisTask.value='Frequency';
                end
            else
                ThisTask.value='Direction';
            end

            %%% it's not the first trial: should we switch task?
        elseif(value(task_switch_auto)==1)

            %%% requirement 1: at least N trials in this task
            flag1=value(nTrials_task)>=value(task_switch_mintrials);
            if(value(exist_incoherent))
                %%% requirement 2: performances in the last N trials coherent above min
                flag2a=value(total_correct_coherent_task)>=value(task_switch_min_perf);
                %%% requirement 3: performances in the last N trials incoherent above min
                flag2b=value(total_correct_incoherent_task)>=value(task_switch_min_perf);
                flag2=(flag2a && flag2b);
            else
                %%% requirement 2: performances in the last N trials above min
                flag2=value(total_correct_task)>=value(task_switch_min_perf);
            end

            if(flag1 && flag2) %%% switch task
                was_block_switch.value=1;
                if(strcmp(value(ThisTask),'Direction'))
                    %from direction to frequency
                    ThisTask.value='Frequency';
                else
                    %from frequency to direction
                    ThisTask.value='Direction';
                end
            end
        end

        %%% setup stimulus variables according to current task
        if(strcmp(value(ThisTask),'Direction'))
            durations=value(durations_dir);
            gamma_dir_values=value(gamma_dir_values_dir);
            gamma_freq_values=value(gamma_freq_values_dir);
            crosstalk_dir=0;
            crosstalk_freq=1-value(stimulus_mixing_dir);
        elseif(strcmp(value(ThisTask),'Frequency'))
            durations=value(durations_freq);
            gamma_dir_values=value(gamma_dir_values_freq);
            gamma_freq_values=value(gamma_freq_values_freq);
            crosstalk_freq=0;
            crosstalk_dir=1-value(stimulus_mixing_freq);
        else
            error('what task?')
        end




        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%% CHOOSE ANTIBIAS %%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        %%% is it possible to have incoherent trials?

        %stimuli aren't mixed
        flag1=value(stimulus_mixing_dir)<1;
        flag2=value(stimulus_mixing_freq)<1;
        %one of the dimensions is not modulated
        flag3=(length(gamma_dir_values)==1 && gamma_dir_values(1)==0);
        flag4=(length(gamma_freq_values)==1 && gamma_freq_values(1)==0);

        if(flag1 || flag2 || flag3 || flag4)
            %there is no such thing as an incoherent trial
            exist_incoherent.value=0;
        else
            exist_incoherent.value=1;
        end


        if(value(antibias_toggle)==1)
            if(value(exist_incoherent)==1)
                antibias_type.value='Quadrant antibias';
            else
                antibias_type.value='Side antibias';
            end
        else
            antibias_type.value='No antibias';
        end


        

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%% COMPUTE ANTIBIAS %%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        vec_hit=value(hit_history);
        %%% kernel function: last few trials are the most important,
        %%% Ab_Tau decides how many trials back matter
        kernel = exp(-(0:length(vec_hit)-1)/value(Ab_Tau));
        kernel = kernel(end:-1:1);


        %%% SIDE ANTIBIAS
        vec_sides=value(side_history);
        vec_sides = vec_sides(1:length(vec_hit));
        %%%% compute bias
        if(isempty(find(vec_sides=='l',1)) || isempty(find(vec_sides=='r',1)))
            fracs=[0.5 0.5];
        else
            bias_left = nansum(vec_hit(vec_sides=='l') .* kernel(vec_sides=='l'))/sum(kernel(vec_sides=='l'));
            bias_right = nansum(vec_hit(vec_sides=='r') .* kernel(vec_sides=='r'))/sum(kernel(vec_sides=='r'));
            fracs=[bias_left bias_right];
        end;
        fracs=fracs./sum(fracs);
        if(~isempty(find(isnan(fracs))))
            fracs=[0.5 0.5];
        end
        BiasL.value=round(fracs(1)*100)/100;
        BiasR.value=round(fracs(2)*100)/100;
        %%% compute resulting probabilities, water and delay
        p = exp(-fracs*value(Ab_Beta));
        p=p./sum(p);
        ProbL.value=p(1);
        ProbR.value=p(2);
        WaterL.value=p(1)*2;
        WaterR.value=p(2)*2;
        DelayL.value=max(p(1)*8,2.5);
        DelayR.value=max(p(2)*8,2.5);




        %%% QUADRANT ANTIBIAS
        vec_quad=value(quadrant_history);
        vec_task=value(task_history);
        vec_quad = vec_quad(1:length(vec_hit));
        vec_task = vec_task(1:length(vec_hit));
        vec_quadd=vec_quad(vec_task=='d');
        vec_hitd=vec_hit(vec_task=='d');
        vec_quadf=vec_quad(vec_task=='f');
        vec_hitf=vec_hit(vec_task=='f');
        %%%% compute bias for direction task
        if(isempty(find(vec_quadd==1,1)) || isempty(find(vec_quadd==2,1)) ||...
                isempty(find(vec_quadd==4,1)) || isempty(find(vec_quadd==3,1)))
            fracsd=[0.25 0.25 0.25 0.25];
        else
            fracsd=nan(1,4);
            for i=1:4
                fracsd(i)=nansum(vec_hitd(vec_quadd==i) .* kernel(vec_quadd==i))/sum(kernel(vec_quadd==i));
            end
        end;
        fracsd=fracsd./sum(fracsd);
        if(~isempty(find(isnan(fracsd))))
            fracsd=[0.25 0.25 0.25 0.25];
        end
        Bias1Dir.value=round(fracsd(1)*100)/100;
        Bias2Dir.value=round(fracsd(2)*100)/100;
        Bias3Dir.value=round(fracsd(3)*100)/100;
        Bias4Dir.value=round(fracsd(4)*100)/100;
        %%% compute resulting probabilities, water and delay for direction task
        p = exp(-fracsd*1.5*value(Ab_Beta));
        p=p./sum(p);
        Prob1Dir.value=p(1);
        Prob2Dir.value=p(2);
        Prob3Dir.value=p(3);
        Prob4Dir.value=p(4);
        Water1Dir.value=p(1)*4;
        Water2Dir.value=p(2)*4;
        Water3Dir.value=p(3)*4;
        Water4Dir.value=p(4)*4;
        Delay1Dir.value=max(p(1)*16,2);
        Delay2Dir.value=max(p(2)*16,2);
        Delay3Dir.value=max(p(3)*16,2);
        Delay4Dir.value=max(p(4)*16,2);

        %%%% compute bias for frequency task
        if(isempty(find(vec_quadf==1,1)) || isempty(find(vec_quadf==2,1)) ||...
                isempty(find(vec_quadf==4,1)) || isempty(find(vec_quadf==3,1)))
            fracsf=[0.25 0.25 0.25 0.25];
        else
            fracsf=nan(1,4);
            for i=1:4
                fracsf(i)=nansum(vec_hitf(vec_quadf==i) .* kernel(vec_quadf==i))/sum(kernel(vec_quadf==i));
            end
        end;
        fracsf=fracsf./sum(fracsf);
        if(~isempty(find(isnan(fracsf))))
            fracsf=[0.25 0.25 0.25 0.25];
        end
        Bias1Freq.value=round(fracsf(1)*100)/100;
        Bias2Freq.value=round(fracsf(2)*100)/100;
        Bias3Freq.value=round(fracsf(3)*100)/100;
        Bias4Freq.value=round(fracsf(4)*100)/100;
        %%% compute resulting probabilities, water and delay for frequency task
        p = exp(-fracsf*value(Ab_Beta));
        p=p./sum(p);
        Prob1Freq.value=p(1);
        Prob2Freq.value=p(2);
        Prob3Freq.value=p(3);
        Prob4Freq.value=p(4);
        Water1Freq.value=p(1)*4;
        Water2Freq.value=p(2)*4;
        Water3Freq.value=p(3)*4;
        Water4Freq.value=p(4)*4;
        Delay1Freq.value=max(p(1)*16,2);
        Delay2Freq.value=max(p(2)*16,2);
        Delay3Freq.value=max(p(3)*16,2);
        Delay4Freq.value=max(p(4)*16,2);


        
        
        

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%% SELECT QUADRANT/SIDE %%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        %INCOHERENT IS DEFINED -> CHOOSE QUADRANT
        if(value(exist_incoherent)==1)

            %%%% DIRECTION TASK
            if(strcmp(value(ThisTask),'Direction'))
                %%%% CHOOSE THE QUADRANT
                if(strcmp(value(antibias_type),'Quadrant antibias'))
                    ThisQuadrant.value=find(mnrnd(1,[value(Prob1Dir) value(Prob2Dir)...
                        value(Prob3Dir) value(Prob4Dir)])==1);
                elseif(strcmp(value(antibias_type),'Side antibias'))
                    ThisQuadrant.value=find(mnrnd(1,[value(Prob1Dir) value(Prob2Dir)...
                        value(Prob3Dir) value(Prob4Dir)])==1);
                elseif(strcmp(value(antibias_type),'No antibias'))
                    ThisQuadrant.value=find(mnrnd(1,[0.25 0.25 0.25 0.25])==1);
                else
                    error('what antibias????')
                end
                %%%% ASSIGN THE SIDES
                if(value(ThisQuadrant)==1)
                    ThisSide.value='RIGHT';
                    ThisSideDirection.value='RIGHT';
                    ThisSideFrequency.value='LEFT';
                    incoherent_trial.value=1;
                end
                if(value(ThisQuadrant)==2)
                    ThisSide.value='LEFT';
                    ThisSideDirection.value='LEFT';
                    ThisSideFrequency.value='LEFT';
                    incoherent_trial.value=0;
                end
                if(value(ThisQuadrant)==3)
                    ThisSide.value='LEFT';
                    ThisSideDirection.value='LEFT';
                    ThisSideFrequency.value='RIGHT';
                    incoherent_trial.value=1;
                end
                if(value(ThisQuadrant)==4)
                    ThisSide.value='RIGHT';
                    ThisSideDirection.value='RIGHT';
                    ThisSideFrequency.value='RIGHT';
                    incoherent_trial.value=0;
                end

                %%%% FREQUENCY TASK
            elseif(strcmp(value(ThisTask),'Frequency'))
                %%%% CHOOSE THE QUADRANT
                if(strcmp(value(antibias_type),'Quadrant antibias'))
                    ThisQuadrant.value=find(mnrnd(1,[value(Prob1Freq) value(Prob2Freq)...
                        value(Prob3Freq) value(Prob4Freq)])==1);
                elseif(strcmp(value(antibias_type),'Side antibias'))
                    ThisQuadrant.value=find(mnrnd(1,[0 value(ProbL) 0 value(ProbR)])==1);
                elseif(strcmp(value(antibias_type),'No antibias'))
                    ThisQuadrant.value=find(mnrnd(1,[0.25 0.25 0.25 0.25])==1);
                else
                    error('what antibias????')
                end
                %%%% ASSIGN THE SIDES
                if(value(ThisQuadrant)==1)
                    ThisSide.value='LEFT';
                    ThisSideDirection.value='RIGHT';
                    ThisSideFrequency.value='LEFT';
                    incoherent_trial.value=1;
                end
                if(value(ThisQuadrant)==2)
                    ThisSide.value='LEFT';
                    ThisSideDirection.value='LEFT';
                    ThisSideFrequency.value='LEFT';
                    incoherent_trial.value=0;
                end
                if(value(ThisQuadrant)==3)
                    ThisSide.value='RIGHT';
                    ThisSideDirection.value='LEFT';
                    ThisSideFrequency.value='RIGHT';
                    incoherent_trial.value=1;
                end
                if(value(ThisQuadrant)==4)
                    ThisSide.value='RIGHT';
                    ThisSideDirection.value='RIGHT';
                    ThisSideFrequency.value='RIGHT';
                    incoherent_trial.value=0;
                end
            else
                error('what task????')
            end

            %INCOHERENT NOT DEFINED -> ONLY CHOOSE THE SIDE
        else
            incoherent_trial.value=0;
            ThisQuadrant.value=NaN;
            %CHOOSE SIDE
            sidevals={'LEFT','RIGHT'};
            if(strcmp(value(antibias_type),'Side antibias'))
                ind=find(mnrnd(1,[value(ProbL) value(ProbR)])==1);
            elseif(strcmp(value(antibias_type),'No antibias'))
                ind=find(mnrnd(1,[0.5 0.5])==1);
            else
                error('what antibias???')
            end
            %%% ASSIGN THE SIDE
            ThisSide.value=sidevals{ind};
            ThisSideDirection.value=sidevals{ind};
            ThisSideFrequency.value=sidevals{ind};
        end











        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%% ASSIGN WATER/DELAY %%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %water multiplier
        if(value(water_increase_toggle)==1)
            water_increase_multiplier.value=value(WI_base)+n_done_trials*value(WI_ratio);
            water_increase_multiplier.value=min([value(WI_max),value(water_increase_multiplier)]);
        else
            water_increase_multiplier.value=1;
        end


        %%%% QUADRANT ANTIBIAS
        if(strcmp(value(antibias_type),'Quadrant antibias'))
            %%%% DIRECTION TASK
            if(strcmp(value(ThisTask),'Direction'))
                if(value(ThisQuadrant)==1)
                    total_water_multiplier.value=value(Water1Dir)*value(water_increase_multiplier);
                    total_error_delay.value=value(Delay1Dir);
                end
                if(value(ThisQuadrant)==2)
                    total_water_multiplier.value=value(Water2Dir)*value(water_increase_multiplier);
                    total_error_delay.value=value(Delay2Dir);
                end
                if(value(ThisQuadrant)==3)
                    total_water_multiplier.value=value(Water3Dir)*value(water_increase_multiplier);
                    total_error_delay.value=value(Delay3Dir);
                end
                if(value(ThisQuadrant)==4)
                    total_water_multiplier.value=value(Water4Dir)*value(water_increase_multiplier);
                    total_error_delay.value=value(Delay4Dir);
                end
            %%%% FREQUENCY TASK
            elseif(strcmp(value(ThisTask),'Frequency'))
                if(value(ThisQuadrant)==1)
                    total_water_multiplier.value=value(Water1Freq)*value(water_increase_multiplier);
                    total_error_delay.value=value(Delay1Freq);
                end
                if(value(ThisQuadrant)==2)
                    total_water_multiplier.value=value(Water2Freq)*value(water_increase_multiplier);
                    total_error_delay.value=value(Delay2Freq);
                end
                if(value(ThisQuadrant)==3)
                    total_water_multiplier.value=value(Water3Freq)*value(water_increase_multiplier);
                    total_error_delay.value=value(Delay3Freq);
                end
                if(value(ThisQuadrant)==4)
                    total_water_multiplier.value=value(Water4Freq)*value(water_increase_multiplier);
                    total_error_delay.value=value(Delay4Freq);
                end
            else
                error('what task????')
            end
        %%%% SIDE ANTIBIAS
        elseif(strcmp(value(antibias_type),'Side antibias'))
            if(strcmp(value(ThisSide),'RIGHT'))
                total_water_multiplier.value=value(WaterR)*value(water_increase_multiplier);
                total_error_delay.value=value(DelayR);
            elseif(strcmp(value(ThisSide),'LEFT'))
                total_water_multiplier.value=value(WaterL)*value(water_increase_multiplier);
                total_error_delay.value=value(DelayL);
            else
                error('what side???')
            end
        %%%% NO ANTIBIAS
        elseif(strcmp(value(antibias_type),'No antibias'))
            total_water_multiplier.value=1;
            total_error_delay.value=4;
        else
            error('what antibias???')
        end

        


        


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%% GENERATE STIMULUS %%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        

        %%%% get sample rate
        srate = SoundManagerSection(obj, 'get_sample_rate');


        %%% select duration for the current trial
        vec=durations;
        ra=randperm(length(vec));
        ThisDuration.value=vec(ra(1));


        %%% select gamma frequency for the current trial
        vec=value(gamma_freq_values);
        ra=randperm(length(vec));
        if(strcmp(value(ThisSideFrequency),'RIGHT'))
            ThisGamma_freq.value=vec(ra(1));
        elseif(strcmp(value(ThisSideFrequency),'LEFT'))
            ThisGamma_freq.value=-vec(ra(1));
        else
            error('what?')
        end


        %%% select gamma direction for the current trial
        vec=value(gamma_dir_values);
        ra=randperm(length(vec));
        if(strcmp(value(ThisSideDirection),'RIGHT'))
            ThisGamma_dir.value=vec(ra(1));
        elseif(strcmp(value(ThisSideDirection),'LEFT'))
            ThisGamma_dir.value=-vec(ra(1));
        else
            error('whattt?')
        end


        freq_vec=[value(freq_lo) value(freq_hi)];


        [snd data] = make_pbup_mixed3(value(total_rate),...
            value(ThisGamma_dir),value(ThisGamma_freq), srate, value(ThisDuration), ...
            'bup_width',value(bup_width),'crosstalk_dir', crosstalk_dir,...
            'crosstalk_freq', crosstalk_freq,'freq_vec',freq_vec,'bup_ramp',...
            value(bup_ramp),'vol_low',value(vol_low_freq),'vol_hi',value(vol_hi_freq));


        snd=snd*value(vol);


        if ~SoundManagerSection(obj, 'sound_exists', 'StimulusSound'),
            SoundManagerSection(obj, 'declare_new_sound', 'StimulusSound');
            SoundManagerSection(obj, 'set_sound', 'StimulusSound', snd);
        else
            snd_prev = SoundManagerSection(obj, 'get_sound', 'StimulusSound');
            if ~isequal(snd, snd_prev),
                SoundManagerSection(obj, 'set_sound', 'StimulusSound', snd);
            end;
        end;

        bpt.freqs=freq_vec;
        bpt.crosstalk_dir=crosstalk_dir;
        bpt.crosstalk_freq=crosstalk_freq;
        bpt.bup_width=value(bup_width);
        bpt.bup_ramp=value(bup_ramp);
        bpt.vol_low=value(vol_low_freq);
        bpt.vol_hi=value(vol_hi_freq);
        bpt.vol=value(vol);
        bpt.gamma_dir = value(ThisGamma_dir);
        bpt.gamma_freq = value(ThisGamma_freq);
        bpt.duration = value(ThisDuration);
        bpt.left_hi = data.left_hi;
        bpt.right_hi = data.right_hi;
        bpt.left_lo = data.left_lo;
        bpt.right_lo = data.right_lo;
        ThisStimulus.value = bpt;
        push_history(ThisStimulus);




        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%% UPDATE PLOT BUTTON %%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    case 'update_plot_button',

        %%% re-initialize the plots regardless of n_done_trials
        feval(mfilename, obj, 'initialize_plots');

        %populate the images
        feval(mfilename, obj, 'update_plot');

        
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%% UPDATE PLOT %%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    case 'update_plot',

        if(n_done_trials==1)
            %if it's the first trial, re-initialize plots
            feval(mfilename, obj, 'initialize_plots');
        end

        %%% GET THE DATA
        hits=value(hit_history);
        side=value(side_history);
        task=value(task_history);
        task=task(1:length(hits));
        gdir=value(gammadir_history);
        gdir=gdir(1:length(hits));
        gfreq=value(gammafreq_history);
        gfreq=gfreq(1:length(hits));
        %remove violation trials
        ind=find(~isnan(hits));
        hits=hits(ind);
        side=side(ind);
        task=task(ind);
        gdir=gdir(ind);
        gfreq=gfreq(ind);
        %save choice (where the rat went)
        choice=nan(1,length(side));
        for i=1:length(side)
            if(hits(i)==1)
                if(side(i)=='r')
                    choice(i)=1;
                else
                    choice(i)=0;
                end
            else
                if(side(i)=='r')
                    choice(i)=0;
                else
                    choice(i)=1;
                end
            end
        end

        
        %%% POPULATE DIRECTION TASK 
        
        %unique values of direction during direction trials
        xvec=value(gamma_dir_values_dir);
        xvec=unique([-xvec xvec]);
        %unique values of frequency during direction trials
        yvec=value(gamma_freq_values_dir);
        yvec=unique([-yvec yvec]);
        n1=length(xvec);
        n2=length(yvec);
        %subselect direction trials
        curtask='d';
        ind=find(task==curtask);
        gdir1=gdir(ind);
        gfreq1=gfreq(ind);
        choice1=choice(ind);
        %populate matrix
        matrice=nan(n2,n1);
        for i=1:n2
            for j=1:n1
                indz=find(gfreq1==yvec(i) & gdir1==xvec(j));
                if(~isempty(indz))
                    matrice(i,j)=mean(choice1(indz));
                else
                    matrice(i,j)=NaN;
                end
            end
        end
        %retrieve image handle
        hdir=value(matrixdir);
        %populate image
        set(hdir,'CData',matrice);


        %%% POPULATE FREQUENCY TASK 
        
        %unique values of direction during frequency trials
        xvec=value(gamma_dir_values_freq);
        xvec=unique([-xvec xvec]);
        %unique values of frequency during frequency trials
        yvec=value(gamma_freq_values_freq);
        yvec=unique([-yvec yvec]);
        n1=length(xvec);
        n2=length(yvec);
        %subselect frequency trials
        curtask='f';
        ind=find(task==curtask);
        gdir1=gdir(ind);
        gfreq1=gfreq(ind);
        choice1=choice(ind);
        %populate matrix
        matrice=nan(n2,n1);
        for i=1:n2
            for j=1:n1
                indz=find(gfreq1==yvec(i) & gdir1==xvec(j));
                if(~isempty(indz))
                    matrice(i,j)=mean(choice1(indz));
                else
                    matrice(i,j)=NaN;
                end
            end
        end
        %retrieve image handle
        hfreq=value(matrixfreq);
        %populate image
        set(hfreq,'CData',matrice);


        
        %%% POPULATE LAST TRIAL PLOT
        
        
        hits=value(hit_history);
        task=value(task_history);
        task=task(1:length(hits));
        gdir=value(gammadir_history);
        gdir=gdir(1:length(hits));
        gfreq=value(gammafreq_history);
        gfreq=gfreq(1:length(hits));
        
        if(~isempty(hits) && ~isnan(hits(end)))
            
            %%% copy over old plots
            cla(value(myaxeshistory4));
            copyobj(get(value(myaxeshistory3),'Children'),value(myaxeshistory4));
            set(value(myaxeshistory4),'XLim',get(value(myaxeshistory3),'XLim'));
            set(value(myaxeshistory4),'YLim',get(value(myaxeshistory3),'YLim'));
            set(value(myaxeshistory4),'XTick',[],'YTick',[]);
            set(value(myaxeshistory4),'Box','off');
            cla(value(myaxeshistory3));
            copyobj(get(value(myaxeshistory2),'Children'),value(myaxeshistory3));
            set(value(myaxeshistory3),'XLim',get(value(myaxeshistory2),'XLim'));
            set(value(myaxeshistory3),'YLim',get(value(myaxeshistory2),'YLim'));
            set(value(myaxeshistory3),'XTick',[],'YTick',[]);
            set(value(myaxeshistory3),'Box','off');
            cla(value(myaxeshistory2));
            copyobj(get(value(myaxeshistory1),'Children'),value(myaxeshistory2));
            set(value(myaxeshistory2),'XLim',get(value(myaxeshistory1),'XLim'));
            set(value(myaxeshistory2),'YLim',get(value(myaxeshistory1),'YLim'));
            set(value(myaxeshistory2),'XTick',[],'YTick',[]);
            set(value(myaxeshistory2),'Box','off');            
            cla(value(myaxeshistory1));
            copyobj(get(value(myaxeshistory0),'Children'),value(myaxeshistory1));
            set(value(myaxeshistory1),'XLim',get(value(myaxeshistory0),'XLim'));
            set(value(myaxeshistory1),'YLim',get(value(myaxeshistory0),'YLim'));
            set(value(myaxeshistory1),'XTick',[],'YTick',[]);
            set(value(myaxeshistory1),'Box','off');
            
            %%% populate new plot
            lasthit=hits(end);
            lasttask=task(end);
            lastgdir=gdir(end);
            lastgfreq=gfreq(end);
            cla(value(myaxeshistory0));
            hold(value(myaxeshistory0),'off');
            if(lasttask=='d')
                xvec=value(gamma_dir_values_dir);
                xvec=unique([-xvec xvec]);
                yvec=value(gamma_freq_values_dir);
                yvec=unique([-yvec yvec]);
                yvec=yvec(end:-1:1);
                n1=length(xvec);
                n2=length(yvec);
                plot(value(myaxeshistory0),mean(1:n1),mean(1:n2),'xb');
            elseif(lasttask=='f')
                xvec=value(gamma_dir_values_freq);
                xvec=unique([-xvec xvec]);
                yvec=value(gamma_freq_values_freq);
                yvec=unique([-yvec yvec]);
                yvec=yvec(end:-1:1);
                n1=length(xvec);
                n2=length(yvec);
                plot(value(myaxeshistory0),mean(1:n1),mean(1:n2),'or');
            end
            hold(value(myaxeshistory0),'on');
            mat=repmat(1:n1,n2,1)';
            vec1=mat(:);
            mat=repmat(1:n2,n1,1);
            vec2=mat(:);
            plot(value(myaxeshistory0),vec1,vec2,'.k')
            xval=find(lastgdir==xvec);
            yval=find(lastgfreq==yvec);
            if(~isempty(xval) && ~isempty(yval))
                if(lasthit==1)
                    plot(value(myaxeshistory0),xval,yval,'.g','MarkerSize',20)
                else
                    plot(value(myaxeshistory0),xval,yval,'.r','MarkerSize',20)
                end
            end
            set(value(myaxeshistory0),'XLim',[0.5 n1+.5],'YLim',[.5 n2+.5]);
            hold(value(myaxeshistory0),'off');
            set(value(myaxeshistory0),'XTick',[],'YTick',[]);
            set(value(myaxeshistory0),'Box','off');

        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%% INITIALIZE PLOTS %%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    case 'initialize_plots',

        %%% generate colormap for imagesc plots
        bu=nan(64,3);
        bu(:,1)=[zeros(23,1); linspace(0,1,17)'; ones(15,1); linspace(1,0.5,9)'];
        bu(:,2)=[zeros(7,1); linspace(0,1,17)'; ones(15,1); linspace(1,0,17)'; zeros(8,1)];
        bu(:,3)=[linspace(0.5625,1,8)'; ones(15,1); linspace(1,0,17)'; zeros(24,1)];
        bu=[1 1 1;bu];

        %%% DIRECTION PLOT 
        
        %unique values of direction during direction trials
        xvec=value(gamma_dir_values_dir);
        xvec=unique([xvec -xvec]);
        %unique values of frequency during direction trials
        yvec=value(gamma_freq_values_dir);
        yvec=unique([yvec -yvec]);
        n1=length(xvec);
        n2=length(yvec);
        %initialize image and save handle
        axes(value(myaxesdir));
        hdir=imagesc(nan(n2,n1),[-0.0159 1]);
        matrixdir.value=hdir;
        colormap(bu);
        colorbar;
        axis image
        set(value(myaxesdir),'XTick',[],'YTick',[]);
        title('Direction')
        
        
        %%% FREQUENCY PLOT
        
        %unique values of direction during frequency trials
        xvec=value(gamma_dir_values_freq);
        xvec=unique([xvec -xvec]);
        %unique values of frequency during frequency trials
        yvec=value(gamma_freq_values_freq);
        yvec=unique([yvec -yvec]);
        n1=length(xvec);
        n2=length(yvec);
        %initialize image and save handle
        axes(value(myaxesfreq));
        hfreq=imagesc(nan(n2,n1),[-0.0159 1]);
        matrixfreq.value=hfreq;
        colormap(bu);
        colorbar;
        axis image
        set(value(myaxesfreq),'XTick',[],'YTick',[]);
        title('Frequency')





    case 'hide',
        StimuluShow.value = 0; set(value(myfig), 'Visible', 'off');
    case 'show',
        StimuluShow.value = 1; set(value(myfig), 'Visible', 'on');
    case 'show_hide',
        if StimuluShow == 1, set(value(myfig), 'Visible', 'on');
        else                   set(value(myfig), 'Visible', 'off');
        end;


    case 'hide2',
        SoundsShow.value = 0; set(value(myfig2), 'Visible', 'off');
    case 'show2',
        SoundsShow.value = 1; set(value(myfig2), 'Visible', 'on');
    case 'show_hide2',
        if SoundsShow == 1, set(value(myfig2), 'Visible', 'on');
        else                   set(value(myfig2), 'Visible', 'off');
        end;


    case 'hide3',
        TimingShow.value = 0; set(value(myfig3), 'Visible', 'off');
    case 'show3',
        TimingShow.value = 1; set(value(myfig3), 'Visible', 'on');
    case 'show_hide3',
        if TimingShow == 1, set(value(myfig3), 'Visible', 'on');
        else                   set(value(myfig3), 'Visible', 'off');
        end;


    case 'close',
        delete(value(myfig));
        delete(value(myfig2));
        delete(value(myfig3));


    case 'get'
        val=varargin{1};
        eval(['x=value(' val ');']);

end


