function [x, y] = StimulusSection(obj, action, varargin)

%%% pepper some trials also with only dir or only frequency just to make sure the rat knows what's he is doing

GetSoloFunctionArgs(obj);


switch action,

    % ------------------------------------------------------------------
    %              INIT
    % ------------------------------------------------------------------

    case 'init'
        x=varargin{1};
        y=varargin{2};


        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%% BUTTON 2 WINDOW %%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%% Separate window for stimulus parameters
        ToggleParam(obj, 'Button2Show', 0, x, y, 'OnString', 'Parameters ??? 2', ...
            'OffString', 'Parameters ??? 2', 'TooltipString', 'Show/Hide Button 2');
        set_callback(Button2Show, {mfilename, 'show_hide5'}); 
        next_row(y);        
        oldx=x; oldy=y;    parentfig=double(gcf);
        SoloParamHandle(obj, 'myfig5', 'value', figure('Position', [300 100 280 220], ...
            'closerequestfcn', [mfilename '(' class(obj) ', ''hide5'');'], 'MenuBar', 'none', ...
            'Name', mfilename), 'saveable', 0);
        
        set(gcf, 'Visible', 'off');             
        x=10;y=10;       
        
        %%%% insert stuff here
        
        %%% back to the main window
        x=oldx; y=oldy;
        figure(parentfig);
        
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%% BUTTON 1 WINDOW %%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%% Separate window for stimulus parameters
        ToggleParam(obj, 'Button1Show', 0, x, y, 'OnString', 'Parameters ??? 1', ...
            'OffString', 'Parameters ??? 1', 'TooltipString', 'Show/Hide Button 1');
        set_callback(Button1Show, {mfilename, 'show_hide4'}); 
        next_row(y);        
        oldx=x; oldy=y;    parentfig=double(gcf);
        SoloParamHandle(obj, 'myfig4', 'value', figure('Position', [300 100 280 220], ...
            'closerequestfcn', [mfilename '(' class(obj) ', ''hide4'');'], 'MenuBar', 'none', ...
            'Name', mfilename), 'saveable', 0);
        
        set(gcf, 'Visible', 'off');             
        x=10;y=10;       
        
        %%%% insert stuff here
        
        %%% back to the main window
        x=oldx; y=oldy;
        figure(parentfig);
        
        
        
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%% TIMING PARAMETERS WINDOW %%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        
        %%%% Separate window for stimulus parameters
        ToggleParam(obj, 'TimingShow', 0, x, y, 'OnString', 'Parameters timing', ...
            'OffString', 'Parameters timing', 'TooltipString', 'Show/Hide Timing panel');
        set_callback(TimingShow, {mfilename, 'show_hide3'}); 
        next_row(y);        
        oldx=x; oldy=y;    parentfig=double(gcf);
        SoloParamHandle(obj, 'myfig3', 'value', figure('Position', [300 100 280 220], ...
            'closerequestfcn', [mfilename '(' class(obj) ', ''hide3'');'], 'MenuBar', 'none', ...
            'Name', mfilename), 'saveable', 0);
        
        set(gcf, 'Visible', 'off');             
        x=10;y=10;       
        
        
        NumeditParam(obj, 'timeout_delay', 3, x,y,'label','Timeout delay','TooltipString','Delay after timeout at spoke, follows new trial');
        next_row(y);
        
        
        NumeditParam(obj, 'reward_delay', 0.001, x,y,'label','Reward Delay','TooltipString','Delay between side poke and reward delivery');
        next_row(y);
        
        NumeditParam(obj, 'wait_for_spoke_timeout', 60, x,y,'label','Timeout for spoke','TooltipString','Time after NIC to wait for a side poke');
        next_row(y);
        
        NumeditParam(obj, 'nic_delay', 4, x,y,'label','NIC violation delay','TooltipString','Delay after NIC violation, follows new trial');
        next_row(y);
        
        NumeditParam(obj, 'nose_in_center', 1.3, x, y,'label','NIC min. duration', ...
            'TooltipString', 'Duration (in sec) nose must be kept in center poke before side choice is allowed');
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
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%% SOUND PARAMETERS WINDOW %%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        
        %%%% Separate window for sound parameters
        ToggleParam(obj, 'SoundsShow', 0, x, y, 'OnString', 'Parameters other sounds', ...
            'OffString', 'Parameters other sounds', 'TooltipString', 'Show/Hide Sounds panel');
        set_callback(SoundsShow, {mfilename, 'show_hide2'});next_row(y);
        oldx=x; oldy=y;    parentfig=double(gcf);
        SoloParamHandle(obj, 'myfig2', 'value', figure('Position', [100 100 560 440], ...
            'closerequestfcn', [mfilename '(' class(obj) ', ''hide2'');'], 'MenuBar', 'none', ...
            'Name', mfilename), 'saveable', 0);
        set(gcf, 'Visible', 'off');
        x=10;y=10;
        
        %%%% Sound parameters
        [x,y]=SoundInterface(obj,'add','ViolationSound',x,y,'Style','SpectrumNoise','Volume',0.0015,'Loop',1);
        SoundInterface(obj,'set','ViolationSound','Freq1',8000,'Freq2',2222,'Dur1',1,'Sigma',14,'Cntrst',111,'CRatio',1);
        
        [x,y]=SoundInterface(obj,'add','ErrorSound',x,y,'Style','PClick','Volume',0.0035,'Loop',1);
        SoundInterface(obj,'set','ErrorSound','Freq1',333,'Freq2',333,'Dur1',0.5,'Width',5);
        
%         [x,y]=SoundInterface(obj,'add','Task1Sound',x,y,'Style','Tone','Volume',0.005);
%         SoundInterface(obj,'set','Task1Sound','Dur1',0.15,'Freq1',2000);
        
        [x,y]=SoundInterface(obj,'add','Task1Sound',x,y,'Style','ToneFMWiggle','Volume',0.005);
        SoundInterface(obj,'set','Task1Sound','Dur1',1,'Freq1',4000,'FMAmp',600,'FMFreq',5);
        
        next_column(x);y=10;
        
        [x,y]=SoundInterface(obj,'add','TimeoutSound',x,y,'Style','SpectrumNoise','Volume',0.0025,'Loop',1);
        SoundInterface(obj,'set','TimeoutSound','Freq1',1000,'Freq2',1000,'Dur1',1,'Sigma',100,'Cntrst',500,'CRatio',5);        

        [x,y]=SoundInterface(obj,'add','HitSound',x,y,'Style','ToneSweep','Volume',0.0025);
        SoundInterface(obj,'set','HitSound','Freq1',1000,'Freq2',5000,'Dur1',0.1,'Dur2',0.3,'Tau',0.05);
        
%         [x,y]=SoundInterface(obj,'add','Task2Sound',x,y,'Style','Tone','Volume',0.005);
%         SoundInterface(obj,'set','Task2Sound','Dur1',0.15,'Freq1',5000);

        [x,y]=SoundInterface(obj,'add','Task2Sound',x,y,'Style','ToneFMWiggle','Volume',0.005);
        SoundInterface(obj,'set','Task2Sound','Dur1',1,'Freq1',9000,'FMAmp',1800,'FMFreq',15);

        %%% back to the main window
        x=oldx; y=oldy;
        figure(parentfig);

        
        
                
        
        
        
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%% STIM. PARAMETERS WINDOW %%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        
        %%%% Separate window for stimulus parameters
        ToggleParam(obj, 'StimuluShow', 0, x, y, 'OnString', 'Parameters stimulus', ...
            'OffString', 'Parameters stimulus', 'TooltipString', 'Show/Hide Stimulus panel');
        set_callback(StimuluShow, {mfilename, 'show_hide'}); 
        next_row(y);        
        oldx=x; oldy=y;    parentfig=double(gcf);
%         SoloParamHandle(obj, 'myfig', 'value', figure('Position', [100 100 560 440], ...
        SoloParamHandle(obj, 'myfig', 'value', figure('Position', [300 100 280 220], ...
            'closerequestfcn', [mfilename '(' class(obj) ', ''hide'');'], 'MenuBar', 'none', ...
            'Name', mfilename), 'saveable', 0);
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
%         NumeditParam(obj, 'freq_unique', 9000, x, y, 'position', [x y 200 20], ...
%             'TooltipString', 'unique frequency for pure direction trials (Hz)');next_row(y);        
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

        
        
                
        
        
        next_row(y,.1);
        
        
        DispParam(obj, 'exist_incoherent',0, x, y,...
            'TooltipString', '1 if incoherent trials can be generated under current parameters');
        next_row(y);
 
        
        
        
        
        next_row(y,.1);
        
        
        
        ToggleParam(obj, 'error_forgiveness_freq', 1, x, y, ...
            'OffString', 'Forgive OFF', ...
            'OnString',  'Forgive ON', ...
            'TooltipString', 'If on (black), start new trial upon wrong side choice; if off (brown), can choose again',...
            'position', [x y 100 20]);
        NumeditParam(obj, 'wait_delay_freq', 3, x,y,'label','delay','position', [x+100 y 100 20]);next_row(y);
        
        ToggleParam(obj, 'helper_lights_freq', 1, x, y, ...
            'OffString', 'Helper lights off', ...
            'OnString',  'Helper lights on', ...
            'TooltipString', 'If on (black), LED lights help indicate what to do; if off (brown), no helper LED lights');
        next_row(y);

        
        %%%%%%%%%%% all the possible durations and gammas
        NumeditParam(obj, 'durations_freq', [2], x, y, 'position', [x y 200 20], ...
            'label','Duration values','TooltipString', 'possible stimulus durations');next_row(y);
        NumeditParam(obj, 'gamma_freq_values_freq', [4], x, y, 'position', [x y 200 20], ...
            'label','Gamma_freq values','TooltipString', 'possible gamma_freq values');next_row(y);
        NumeditParam(obj, 'gamma_dir_values_freq', [0], x, y, 'position', [x y 200 20], ...
            'label','Gamma_dir values','TooltipString', 'possible gamma_dir values');next_row(y); 
        SliderParam(obj,'freq_modulation_only',1,0,1,x, y,'label','freq only', 'position', [x y 200 20]);next_row(y);     

        
        SubheaderParam(obj,'title','Frequency Task',x,y); next_row(y,1);

        

        
                
        
        next_row(y,.2);
        
        
        
        

        %%%%%%%%%%% all the possible durations and gammas
        NumeditParam(obj, 'durations_dir', [2], x, y, 'position', [x y 200 20], ...
            'label','Duration values','TooltipString', 'possible stimulus durations');next_row(y);
        NumeditParam(obj, 'gamma_freq_values_dir', [0], x, y, 'position', [x y 200 20], ...
            'label','Gamma_freq values','TooltipString', 'possible gamma_freq values');next_row(y);
        NumeditParam(obj, 'gamma_dir_values_dir', [4], x, y, 'position', [x y 200 20], ...
            'label','Gamma_dir values','TooltipString', 'possible gamma_dir values');next_row(y);        
        SliderParam(obj,'dir_modulation_only',1,0,1,x, y,'label','dir only','position', [x y 200 20]);next_row(y);   

        
        SubheaderParam(obj,'title','Direction Task',x,y); next_row(y, 1);

        

        
        
        
        
        
        
        
        %%%%% this variable will contain all the information about the
        %%%%% current stimulus to be saved in the data file
        SoloParamHandle(obj, 'ThisStimulus', 'value', []);
        
        
        
        %%% MOVE THIS TO PREVIOUS COLUMN
        next_column(x,-1); 
        next_row(y,-2.5);
        
        

%         SoloParamHandle(obj, 'incoherent_trial', 'value', 0);
        
        DispParam(obj, 'incoherent_trial', 0, x, y, 'position', [x y 200 20], 'labelfraction', 0.6);next_row(y,1.1);
        DispParam(obj, 'ThisDuration', 2, x, y, 'position', [x y 200 20], 'labelfraction', 0.6);next_row(y,1.1);
        DispParam(obj, 'ThisGamma_freq', '1', x, y,'label','ThisGammaFrequency','labelfraction', 0.6, 'position', [x y 200 20]);next_row(y);        
        DispParam(obj, 'ThisSideFrequency', 'RIGHT', x, y, 'labelfraction', 0.6, 'position', [x y 200 20]);next_row(y,1.1);        
        DispParam(obj, 'ThisGamma_dir', '1', x, y,'label','ThisGammaDirection','labelfraction', 0.6, 'position', [x y 200 20]);next_row(y);
        DispParam(obj, 'ThisSideDirection', 'RIGHT', x, y, 'labelfraction', 0.6, 'position', [x y 200 20]);next_row(y,1.1);
        DispParam(obj, 'ThisSide', 'RIGHT', x, y, 'labelfraction', 0.6, 'position', [x y 200 20]);next_row(y,1.1);
        
        
        SubheaderParam(obj,'title','StimulusSection',x,y); next_row(y, 1.5);

        
        
        next_column(x); 
        
        
        
        
        
        
        
        
        
        
        %%%%%% COLUMN 4 %%%%%%
        y=5; next_column(x); 
        
        

        
        
        
        
        %%%% WATER INCREASE
         
        
        DispParam(obj, 'water_increase_multiplier',1, x, y, 'labelfraction', 0.65,...
            'TooltipString', 'water increase multiplier as a function of n_done_trials');next_row(y);
 
        
        NumeditParam(obj, 'WI_base', .95, x, y, 'labelfraction', 0.2,'label','B','position', [x y 66 20],  ...
            'TooltipString', 'water increase base');
        
        NumeditParam(obj, 'WI_ratio', .0005, x, y, 'labelfraction', 0.2,'label','R','position', [x+66 y 66 20], ...
            'TooltipString', 'water increase per trial');
        
        NumeditParam(obj, 'WI_max', 1.2, x, y, 'labelfraction', 0.2,'label','M','position', [x+133 y 66 20], ...
            'TooltipString', 'water increase max');next_row(y);
        
        
        ToggleParam(obj, 'water_increase_toggle', 0, x,y,...
            'OnString', 'Water increase ON','OffString', 'Water increase OFF',...
            'TooltipString', sprintf('If on water increase is on'));next_row(y);

        
        
        
        
        
        

        
         %%%% SIDE ANTIBIAS
        NumeditParam(obj, 'LR_Tau', 50, x, y,'position', [x y 100 20],  ...
            'TooltipString', 'Number of trials back over which to compute Left/Right antibias');
        
        NumeditParam(obj, 'LR_Beta', 3, x, y,'position', [x+100 y 100 20], ...
            'TooltipString', 'Antibias weight for Left versus Right trials');next_row(y,1.1);
        
        
        
        
        DispParam(obj, 'left_wtr_mult',1, x, y,'label','leftWat','position', [x y 100 20],...
            'TooltipString', 'all left reward times are multiplied by this number');
        DispParam(obj, 'right_wtr_mult',1, x, y,'label','rightWat','position', [x+100 y 100 20],...
            'TooltipString', 'all left reward times are multiplied by this number');next_row(y);
        
        
        DispParam(obj, 'LeftP',0.5, x, y,'position', [x y 100 20]);
        DispParam(obj, 'RightP',0.5, x, y,'position', [x+100 y 100 20]);next_row(y,1.1);       
        
        
        DispParam(obj, 'BiasL',0.5, x, y,'position', [x y 100 20]);
        DispParam(obj, 'BiasR',0.5, x, y,'position', [x+100 y 100 20]);next_row(y);       
        
        
        ToggleParam(obj, 'side_antibias_toggle', 1, x,y,...
            'OnString', 'Side Antibias ON','OffString', 'Side Antibias OFF',...
            'TooltipString', sprintf('If on side antibias is on'));next_row(y);

        
        
        
        
        
        
        
        
         %%%% TASK ANTIBIAS
         
         
         
        NumeditParam(obj, 'DF_Tau', 50, x, y,'position', [x y 100 20],  ...
            'TooltipString', 'Number of trials back over which to compute dir/freq antibias');
        
        NumeditParam(obj, 'DF_Beta', 1, x, y,'position', [x+100 y 100 20], ...
            'TooltipString', 'Antibias weight for dir versus freq trials');next_row(y,1.1);
        
        
        
        
        DispParam(obj, 'overall_wtr_mult_freq',1, x, y,'label','freqWat','position', [x y 100 20],...
            'TooltipString', 'all freq reward times are multiplied by this number');
        DispParam(obj, 'overall_wtr_mult_dir',1, x, y,'label','dirWat','position', [x+100 y 100 20],...
            'TooltipString', 'all dir reward times are multiplied by this number');next_row(y);
        
        
        DispParam(obj, 'BiasDir',0.5, x, y,'position', [x y 100 20]);
        DispParam(obj, 'BiasFreq',0.5, x, y,'position', [x+100 y 100 20]);next_row(y);       
        
         
        ToggleParam(obj, 'task_antibias_toggle', 1, x,y,...
            'OnString', 'Task Antibias ON','OffString', 'Task Antibias OFF',...
            'TooltipString', sprintf('If on task antibias is on'));next_row(y);

         
         %%%% INCOH ANTIBIAS
         
         
         
        NumeditParam(obj, 'CI_Tau', 100, x, y,'position', [x y 100 20],  ...
            'TooltipString', 'Number of trials back over which to compute coh/incoh antibias');
        
        NumeditParam(obj, 'CI_Beta', 1, x, y,'position', [x+100 y 100 20], ...
            'TooltipString', 'Antibias weight for coh versus incoh trials');next_row(y,1.1);
        
        
        
        
        DispParam(obj, 'CohDelay',4, x, y,'position', [x y 100 20]);
        DispParam(obj, 'IncohDelay',4, x, y,'position', [x+100 y 100 20]);next_row(y);       
        
        
        
        DispParam(obj, 'overall_wtr_mult_coh',1, x, y,'label','cohWat','position', [x y 100 20],...
            'TooltipString', 'all coh reward times are multiplied by this number');
        DispParam(obj, 'overall_wtr_mult_incoh',1, x, y,'label','incohWat','position', [x+100 y 100 20],...
            'TooltipString', 'all incoh reward times are multiplied by this number');next_row(y);
        
        
        DispParam(obj, 'CohP',0.5, x, y,'position', [x y 100 20]);
        DispParam(obj, 'IncohP',0.5, x, y,'position', [x+100 y 100 20]);next_row(y,1.1);       
        
        
        DispParam(obj, 'BiasCoh',0.5, x, y,'position', [x y 100 20]);
        DispParam(obj, 'BiasIncoh',0.5, x, y,'position', [x+100 y 100 20]);next_row(y);       
      
         
        ToggleParam(obj, 'incoh_antibias_toggle', 1, x,y,...
            'OnString', 'Incoh. Antibias ON','OffString', 'Incoh. Antibias OFF',...
            'TooltipString', sprintf('If on incoh. antibias is on'));next_row(y);

        
        
        
        
        PushbuttonParam(obj,'draw', x, y, 'position', [x+170 y 30 20],'label', 'draw');
        set_callback(draw, {mfilename, 'update_plot_button'});
        next_row(y);


        
        
        SoloParamHandle(obj, 'myaxesdir', 'saveable', 0,'value', axes);        
        set(value(myaxesdir),'Position', [.5 .7 .21 .21]);        
        SoloParamHandle(obj, 'matrixdir', 'saveable',0);  
        
        SoloParamHandle(obj, 'myaxesfreq', 'saveable', 0,'value', axes);        
        set(value(myaxesfreq),'Position', [.73 .7 .21 .21]);       
        SoloParamHandle(obj, 'matrixfreq', 'saveable',0);      
        
        
        xvec=value(gamma_dir_values_dir);
        xvec=unique([xvec -xvec]);
        yvec=value(gamma_freq_values_dir);        
        yvec=unique([yvec -yvec]);
        n1=length(xvec);
        n2=length(yvec);

        
        bu=nan(64,3);
        bu(:,1)=[zeros(23,1); linspace(0,1,17)'; ones(15,1); linspace(1,0.5,9)'];
        bu(:,2)=[zeros(7,1); linspace(0,1,17)'; ones(15,1); linspace(1,0,17)'; zeros(8,1)];
        bu(:,3)=[linspace(0.5625,1,8)'; ones(15,1); linspace(1,0,17)'; zeros(24,1)];
        bu=[1 1 1;bu];
        
        axes(value(myaxesdir));
        hdir=imagesc(nan(n2,n1),[-0.0159 1]);
        matrixdir.value=hdir;
        colormap(bu);
        colorbar;
        axis image
        set(value(myaxesdir),'XTick',[],'YTick',[]);
        title('Direction')
        
        
        
        xvec=value(gamma_dir_values_freq);
        xvec=unique([xvec -xvec]);
        yvec=value(gamma_freq_values_freq);        
        yvec=unique([yvec -yvec]);
        n1=length(xvec);
        n2=length(yvec);
        
        axes(value(myaxesfreq));
        hfreq=imagesc(nan(n2,n1),[-0.0159 1]);        
        matrixfreq.value=hfreq;
        colormap(bu);
        colorbar;
        axis image
        set(value(myaxesfreq),'XTick',[],'YTick',[]);
        title('Frequency')
        
        
        
        
%         feval(mfilename, obj, 'update_plot');
        

        
        
      
        
        %%%%% INTERNAL VARIABLES
        
        SoloParamHandle(obj, 'total_error_delay', 'value', 0);
        SoloParamHandle(obj, 'total_water_multiplier', 'value', 1);
        
        
        
        
        
        
        
        
        
        
        
        %%% send variables to other sections
        
        
        SoloFunctionAddVars('SMA1', 'ro_args',{'settling_time';...
            'reward_delay';'nose_in_center';'nic_delay';...
            'error_forgiveness_freq';'wait_delay_freq';...
            'wait_for_cpoke_timeout';'wait_for_spoke_timeout';'timeout_delay';...
            'ThisSide';'helper_lights_freq';'total_error_delay';'total_water_multiplier'});
        

        
        
        
        SoloFunctionAddVars('TrainingSection', 'rw_args', {'side_antibias_toggle';...
            'LR_Beta';'LR_Tau';'DF_Beta';'DF_Tau';'CI_Beta';'CI_Tau';...
            'gamma_dir_values_dir';'gamma_dir_values_freq';...
            'gamma_freq_values_dir';'gamma_freq_values_freq';...
            'durations_dir';'durations_freq';...
            'dir_modulation_only';'freq_modulation_only';...
            'settling_time';'reward_delay';'nose_in_center' ;'nic_delay';...
            'error_forgiveness_freq'; 'wait_delay_freq'; ...
            'wait_for_cpoke_timeout';'wait_for_spoke_timeout';'timeout_delay'; ...
            'helper_lights_freq'});
        
        
        
        SoloFunctionAddVars('HistorySection', 'ro_args', {'ThisSide';'incoherent_trial';...
            'ThisGamma_dir';'ThisGamma_freq'});
         
        
        SoloFunctionAddVars('TaskSection', 'ro_args', {'exist_incoherent'});
         
        
        
        
        

    case 'next_trial',

        
        
        
        
        
        %%% setup variables according to current task
        if(strcmp(value(ThisTask),'Direction'))


            durations=value(durations_dir);
            
            gamma_dir_values=value(gamma_dir_values_dir);
            gamma_freq_values=value(gamma_freq_values_dir);
            
            
            crosstalk_dir=0;
            crosstalk_freq=value(dir_modulation_only);
            
            

        elseif(strcmp(value(ThisTask),'Frequency'))


            durations=value(durations_freq);
            
            gamma_dir_values=value(gamma_dir_values_freq);
            gamma_freq_values=value(gamma_freq_values_freq);

            
            crosstalk_freq=0;
            crosstalk_dir=value(freq_modulation_only);


        else
            error('what task?')
        end



        
        
        
        
        
        %%%% COMPUTE ALL ANTIBIAS %%%%
        
        
        vec_hit=value(hit_history);
        

        
        %%%% SIDE ANTIBIAS %%%%
        
        %%% kernel function: last few trials are the most important,
        %%% LR_Tau decides how many trials back matter
        kernel = exp(-(0:length(vec_hit)-1)/value(LR_Tau));
        kernel = kernel(end:-1:1);
        
        vec_sides = value(side_history);
        % make sure the two vectors have same length
        vec_sides = vec_sides(1:length(vec_hit));

        %%%% COMPUTE BIAS
        if(isempty(find(vec_sides=='l',1)) || isempty(find(vec_sides=='r',1)))
            fracs=[0.5 0.5];
        else
            bias_left = nansum(vec_hit(vec_sides=='l') .* kernel(vec_sides=='l'))/sum(kernel(vec_sides=='l'));        
            bias_right = nansum(vec_hit(vec_sides=='r') .* kernel(vec_sides=='r'))/sum(kernel(vec_sides=='r'));
            fracs=[bias_left bias_right];
        end;
        fracs=fracs./sum(fracs);
        BiasL.value=round(fracs(1)*100)/100;
        BiasR.value=round(fracs(2)*100)/100;
        
        %%%% COMPUTE RESULTING PROBABILITIES AND WATER
        p = exp(-fracs*value(LR_Beta));
        p=p./sum(p);
        p=round(p*1000)/1000;
        if(value(side_antibias_toggle))
            LeftP.value=p(1);
            RightP.value=p(2);
            left_wtr_mult.value=p(1)*2;
            right_wtr_mult.value=p(2)*2;
        else
            LeftP.value=0.5;
            RightP.value=0.5;
            left_wtr_mult.value=1;
            right_wtr_mult.value=1;
        end

        
        %%%%% RANDOMLY COMPUTE CORRECT SIDE
        if(rand(1) > value(LeftP))
            this_side = 'RIGHT';
        else
            this_side = 'LEFT';
        end;
        
        %%% set the side for current trial
        ThisSide.value=this_side;
        
        
        
        
        
        
        %%% BEFORE DOING TASK COMPUTATIONS, CHECK WHETHER WE ARE  
        %%% ACTUALLY GOING TO SWITCH BETWEEN TASKS
        
        if(value(task_switch_auto)==0)
            task_antibias_toggle.value=0;
        end
        
        
        

        %%%% TASK ANTIBIAS %%%%
        
        %%% kernel function: last few trials are the most important,
        %%% DF_Tau decides how many trials back matter
        kernel = exp(-(0:length(vec_hit)-1)/value(DF_Tau));
        kernel = kernel(end:-1:1);
        
        vec_tasks = value(task_history);
        % make sure the two vectors have same length
        vec_tasks = vec_tasks(1:length(vec_hit));

        %%%% COMPUTE BIAS
        if(isempty(find(vec_tasks=='d',1)) || isempty(find(vec_tasks=='f',1)))
            fracs=[0.5 0.5];
        else
            bias_dir = nansum(vec_hit(vec_tasks=='d') .* kernel(vec_tasks=='d'))/sum(kernel(vec_tasks=='d'));        
            bias_freq = nansum(vec_hit(vec_tasks=='f') .* kernel(vec_tasks=='f'))/sum(kernel(vec_tasks=='f'));
            fracs=[bias_dir bias_freq];
        end;
        fracs=fracs./sum(fracs);
        BiasDir.value=round(fracs(1)*100)/100;
        BiasFreq.value=round(fracs(2)*100)/100;
        
        %%%% COMPUTE RESULTING WATER
        p = exp(-fracs*value(DF_Beta));
        p=p./sum(p);
        p=round(p*1000)/1000;
        if(value(task_antibias_toggle))
            overall_wtr_mult_dir.value=max(0.95,p(1)*2);
            overall_wtr_mult_freq.value=max(0.95,p(2)*2);
        else
            overall_wtr_mult_dir.value=1;
            overall_wtr_mult_freq.value=1;
        end

                
        
        %%% BEFORE DOING INCOH COMPUTATIONS, CHECK WHETHER IT IS 
        %%% POSSIBLE TO HAVE INCOHERENT TRIALS UNDER CURRENT PARAMETERS
        
        %stimuli aren't "pure"
        flag1=crosstalk_freq>0.0001;
        flag2=crosstalk_freq>0.0001;
        %one of the dimensions is not modulated
        flag3=(length(gamma_dir_values)==1 && gamma_dir_values(1)==0);
        flag4=(length(gamma_freq_values)==1 && gamma_freq_values(1)==0);
        
        if(flag1 || flag2 || flag3 || flag4)
            exist_incoherent.value=0;
            incoh_antibias_toggle.value=0;
        else
            exist_incoherent.value=1;
        end
        
        
        

        
        
        %%%% INCOH ANTIBIAS %%%%
        
        %%% kernel function: last few trials are the most important,
        %%% CI_Tau decides how many trials back matter
        kernel = exp(-(0:length(vec_hit)-1)/value(CI_Tau));
        kernel = kernel(end:-1:1);
        
        vec_incoh = value(incoh_history);
        % make sure the two vectors have same length
        vec_incoh = vec_incoh(1:length(vec_hit));

        %%%% COMPUTE BIAS
        if(isempty(find(vec_incoh==0,1)) || isempty(find(vec_incoh==1,1)))
            fracs=[0.5 0.5];
        else
            bias_coh = nansum(vec_hit(vec_incoh==0) .* kernel(vec_incoh==0))/sum(kernel(vec_incoh==0));        
            bias_incoh = nansum(vec_hit(vec_incoh==1) .* kernel(vec_incoh==1))/sum(kernel(vec_incoh==1));
            fracs=[bias_coh bias_incoh];
        end;
        fracs=fracs./sum(fracs);
        BiasCoh.value=round(fracs(1)*100)/100;
        BiasIncoh.value=round(fracs(2)*100)/100;
        
        %%%% COMPUTE RESULTING WATER
        p = exp(-fracs*value(CI_Beta));
        p=p./sum(p);
        p=round(p*1000)/1000;
        if(value(incoh_antibias_toggle))
            CohP.value=p(1);
            IncohP.value=p(2);
            overall_wtr_mult_coh.value=max(0.95,p(1)*2);
            overall_wtr_mult_incoh.value=max(0.95,p(2)*2);
            CohDelay.value=max(p(1)*8,3);
            IncohDelay.value=max(p(2)*8,3);
        else
            CohP.value=0.5;
            IncohP.value=0.5;
            overall_wtr_mult_coh.value=1;
            overall_wtr_mult_incoh.value=1;
            CohDelay.value=4;
            IncohDelay.value=4;
        end

                        
        
        
        %%%%% RANDOMLY COMPUTE IF INCOHERENT
        
        if(rand(1) > value(IncohP)) % not incoherent
            incoherent_trial.value=0;
            this_side_other_task = this_side;
        else                        % incoherent
            incoherent_trial.value=1;
            if(strcmp(this_side,'RIGHT'))
                this_side_other_task = 'LEFT';
            else
                this_side_other_task = 'RIGHT';
            end
        end;

        
        if(value(exist_incoherent)==0) %incoherent not defined -> all coherent
            incoherent_trial.value=0;
            this_side_other_task = this_side;
        end
     
        
        
        
        
        %%% set the freq and direction side for the current trial
        if(strcmp(value(ThisTask),'Direction'))
            ThisSideDirection.value=this_side;
            ThisSideFrequency.value=this_side_other_task;
        elseif(strcmp(value(ThisTask),'Frequency'))
            ThisSideFrequency.value=this_side;
            ThisSideDirection.value=this_side_other_task;
        else
            error('what task????')
        end
        
        
                
        %%%% SET UP THE TOTAL DELAY FOR ERRORS AND TOTAL WATER MULTIPLIER
        %%%% ACCORDING TO ANTIBIAS PARAMETERS
        
        if(strcmp(value(ThisTask),'Direction'))
            water_task=value(overall_wtr_mult_dir);
        elseif(strcmp(value(ThisTask),'Frequency'))
            water_task=value(overall_wtr_mult_freq);
        else
            error('what task????')
        end
        
        
        if(strcmp(value(ThisSide),'RIGHT'))
            water_side=value(right_wtr_mult);
        elseif(strcmp(value(ThisSide),'LEFT'))
            water_side=value(left_wtr_mult);
        else
            error('what side????')
        end
        
        
        if(value(incoherent_trial)==1)
            water_incoh=value(overall_wtr_mult_incoh);
            delay_incoh=value(IncohDelay);
        else
            water_incoh=value(overall_wtr_mult_coh);
            delay_incoh=value(CohDelay);
        end
        
        
        if(value(water_increase_toggle)==1)
            water_increase_multiplier.value=value(WI_base)+n_done_trials*value(WI_ratio);
            water_increase_multiplier.value=min([value(WI_max),value(water_increase_multiplier)]);
        else
            water_increase_multiplier.value=1;
        end
        
        
        %%% update variables used by the state machine code
        total_water_multiplier.value=water_task*water_side*water_incoh*value(water_increase_multiplier);
        total_error_delay.value=delay_incoh;
        
        
        
        
        
        
        
        

        %%%% prepare stimulus sound
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
        
        
%         
%         %%% if gamma=0 there is no side -> the trial can't be incoherent
%         if(value(ThisGamma_freq)==0 || value(ThisGamma_dir)==0)            
%             incoherent_trial.value=0;
%         end
%         
        
        
            
        
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
        
        
    case 'update_plot_button',
        
        

        xvec=value(gamma_dir_values_dir);
        xvec=unique([xvec -xvec]);
        yvec=value(gamma_freq_values_dir);        
        yvec=unique([yvec -yvec]);
        n1=length(xvec);
        n2=length(yvec);

        
        bu=nan(64,3);
        bu(:,1)=[zeros(23,1); linspace(0,1,17)'; ones(15,1); linspace(1,0.5,9)'];
        bu(:,2)=[zeros(7,1); linspace(0,1,17)'; ones(15,1); linspace(1,0,17)'; zeros(8,1)];
        bu(:,3)=[linspace(0.5625,1,8)'; ones(15,1); linspace(1,0,17)'; zeros(24,1)];
        bu=[1 1 1;bu];
        
        axes(value(myaxesdir));
        hdir=imagesc(nan(n2,n1),[-0.0159 1]);
        matrixdir.value=hdir;
        colormap(bu);
        colorbar;
        axis image
        set(value(myaxesdir),'XTick',[],'YTick',[]);
        title('Direction')
        
        
        
        xvec=value(gamma_dir_values_freq);
        xvec=unique([xvec -xvec]);
        yvec=value(gamma_freq_values_freq);        
        yvec=unique([yvec -yvec]);
        n1=length(xvec);
        n2=length(yvec);
        
        axes(value(myaxesfreq));
        hfreq=imagesc(nan(n2,n1),[-0.0159 1]);        
        matrixfreq.value=hfreq;
        colormap(bu);
        colorbar;
        axis image
        set(value(myaxesfreq),'XTick',[],'YTick',[]);
        title('Frequency')
                
        
        
        
        feval(mfilename, obj, 'update_plot');

     
        
    case 'update_plot',
        
        
        
        
%         
%         
%          NumeditParam(obj, 'gamma_freq_values_freq', [5], x, y, 'position', [x y 200 20], ...
%             'label','Gamma_freq values','TooltipString', 'possible gamma_freq values');next_row(y);
%         NumeditParam(obj, 'gamma_dir_values_freq', [0], x, y, 'position', [x y 200 20], ...
%             'label','Gamma_dir values','TooltipString', 'possible gamma_dir values');next_row(y); 
%         SubheaderParam(obj,'title','Frequency Task',x,y); next_row(y,1);
% 
%          NumeditParam(obj, 'gamma_freq_values_dir', [0], x, y, 'position', [x y 200 20], ...
%             'label','Gamma_freq values','TooltipString', 'possible gamma_freq values');next_row(y);
%         NumeditParam(obj, 'gamma_dir_values_dir', [5], x, y, 'position', [x y 200 20], ...
%             'label','Gamma_dir values','TooltipString', 'possible gamma_dir values');next_row(y);        
%        SubheaderParam(obj,'title','Direction Task',x,y); next_row(y, 1);

        
        
        
%         
%         xvec=value(gamma_dir_values_dir);
%         xvec=unique([xvec -xvec]);
%         yvec=value(gamma_freq_values_dir);        
%         yvec=unique([yvec -yvec]);
%         n1=length(xvec);
%         n2=length(yvec);
%         
        
%         %%% plot direction task
%         axes(value(myaxesdir));
%         matrice=rand(n2,n1);
%         imagesc(1:n1,1:n2,matrice);
%         colormap(jet);
%         axis image
%         hold on
%         plot(3,3,'.w','MarkerSize',30);
%         set(value(myaxesdir),'XTick',1:n1,'YTick',1:n2,...
%             'XTickLabel',xvec,'YTickLabel',yvec);
%         xlabel('direction gamma')
%         ylabel('frequency gamma')
%         title('Direction')

        
%         vec=[-4 -2.5 -1 0 1 2.5 4];


        

        hits=value(hit_history);
        side=value(side_history);   
        task=value(task_history);        
        task=task(1:length(hits));
        gdir=value(gammadir_history);
        gdir=gdir(1:length(hits));
        gfreq=value(gammafreq_history);
        gfreq=gfreq(1:length(hits));
        
        
        ind=find(~isnan(hits));        
        hits=hits(ind);
        side=side(ind);
        task=task(ind);
        gdir=gdir(ind);
        gfreq=gfreq(ind);
        
        
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

        
        
        
        xvec=value(gamma_dir_values_dir);
        xvec=unique([-xvec xvec]);
        yvec=value(gamma_freq_values_dir);        
        yvec=unique([-yvec yvec]);
        n1=length(xvec);
        n2=length(yvec);

        
        curtask='d';
        ind=find(task==curtask);
        gdir1=gdir(ind);
        gfreq1=gfreq(ind);
        choice1=choice(ind);
        
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

        hdir=value(matrixdir);
        set(hdir,'CData',matrice);
        

        
        
        xvec=value(gamma_dir_values_freq);
        xvec=unique([-xvec xvec]);
        yvec=value(gamma_freq_values_freq);        
        yvec=unique([-yvec yvec]);
        n1=length(xvec);
        n2=length(yvec);

        
        
        curtask='f';
        ind=find(task==curtask);
        gdir1=gdir(ind);
        gfreq1=gfreq(ind);
        choice1=choice(ind);
        
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

        
        hfreq=value(matrixfreq);
        set(hfreq,'CData',matrice);
        

        
        
        
        
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
        
        
    case 'hide4',
        TimingShow.value = 0; set(value(myfig4), 'Visible', 'off');

    case 'show4',
        TimingShow.value = 1; set(value(myfig4), 'Visible', 'on');

    case 'show_hide4',
        if Button1Show == 1, set(value(myfig4), 'Visible', 'on');
        else                   set(value(myfig4), 'Visible', 'off');
        end;
        
                
        
        
    case 'hide5',
        TimingShow.value = 0; set(value(myfig5), 'Visible', 'off');

    case 'show5',
        TimingShow.value = 1; set(value(myfig5), 'Visible', 'on');

    case 'show_hide5',
        if Button2Show == 1, set(value(myfig5), 'Visible', 'on');
        else                   set(value(myfig5), 'Visible', 'off');
        end;
        
                
        
        
    case 'close',
        delete(value(myfig));
        delete(value(myfig2));
        delete(value(myfig3));




        
    case 'get'
        
        val=varargin{1};
        
        eval(['x=value(' val ');']);
        
       
        
end


