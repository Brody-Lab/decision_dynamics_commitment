function [x, y] = StimulusSection(obj, action, varargin)

GetSoloFunctionArgs(obj);


switch action
    
    
    case 'init'
        
        x = varargin{1};
        y = varargin{2};
        
        
        % WATER INCREASE  %
        
        DispParam(obj, 'water_increase_multiplier', 1, x, y, 'labelfraction', 0.65, ...
            'TooltipString', 'water increase multiplier as a function of n_done_trials'); next_row(y);
        
        NumeditParam(obj, 'WI_base', .95, x, y, 'labelfraction', 0.2, 'label', 'B', 'position', [x y 66 20], ...
            'TooltipString', 'water increase base');
        
        NumeditParam(obj, 'WI_ratio', .00025, x, y, 'labelfraction', 0.2, 'label', 'R', 'position', [x+66 y 66 20],...
            'TooltipString', 'water increase per trial');
        
        NumeditParam(obj, 'WI_max', 1.2, x, y, 'labelfraction', 0.2, 'label', 'M', 'position', [x+133 y 66 20],...
            'TooltipString','water increase max'); next_row(y);
        
        ToggleParam(obj, 'water_increase_toggle', 1, x, y,...
            'OnString','Water increase ON', 'OffString', 'Water increase OFF', ...
            'TooltipString', sprintf('If on water increase is on')); next_row(y);
        
        
        % TIMING PARAMETERS %
        
        % separate window for stimulus parameters
        ToggleParam(obj, 'TimingShow', 0, x, y, 'OnString', 'Parameters timing',...
            'OffString','Parameters timing', 'TooltipString', 'Show/hide timing panel');
        set_callback(TimingShow, {mfilename, 'show_hide3'});
        next_row(y); oldx = x; oldy = y; parentfig = double(gcf);
        SoloParamHandle(obj, 'myfig3', 'value', figure('Position', [300 100 280 220], 'closerequestfcn',...
            [mfilename '(' class(obj) ', ''hide3''):'], 'MenuBar', 'none', 'Name', mfilename), 'saveable', 0);
        
        set(gcf, 'Visible', 'off');
        x = 10; y = 10;
        
        NumeditParam(obj, 'timeout_delay', 3, x, y, 'label', 'Timeout delay', 'TooltipString', 'Delay after timeout at spokes, follows new trial');
        next_row(y);
        
        NumeditParam(obj, 'reward_delay', 0.001, x, y, 'label', 'Reward Delay','TooltipString','Delay between side poke and reward delivery');
        next_row(y);
        
        NumeditParam(obj, 'wait_for_spoke_timeout', 60, x, y, 'label', 'Timeout for spoke', 'TooltipString', 'Time after NIC to wait for a side poke');
        next_row(y);
        
        NumeditParam(obj, 'nic_delay', 3, x, y, 'label', 'NIC violation delay','TooltipString','Delay after NIC violation, follows new trial');
        next_row(y);
        
        NumeditParam(obj, 'settling_time', 0.001, x, y, 'label', 'Pre-stimulus delay','TooltipString','Time in NIC before starting stimulus');
        next_row(y);
        
        NumeditParam(obj, 'wait_for_cpoke_timeout', 120, x, y, 'label', 'Timeout for cpoke', 'TooltipString', 'Timeout waiting for cpoke');
        next_row(y);
        
        SubheaderParam(obj, 'title', 'Timing', x, y); next_row(y, 1.5);
        
        % back to the main window
        x = oldx; y = oldy;
        figure(parentfig);
        
        
        % SOUND PARAM WINDOW %
        
        % sepatate window for sound parameters
        ToggleParam(obj, 'SoundsShow', 0, x, y, 'OnString', 'Parameters other sounds', ...
            'OffString', 'Parameters other sounds', 'TooltipString','Show/Hide Sounds panel');
        set_callback(SoundsShow, {mfilename, 'show_hide2'}); next_row(y);
        oldx = x; oldy = y; parentfig = double(gcf);
        SoloParamHandle(obj, 'myfig2', 'value', figure('Position', [100 100 560 440],'closerequestfcn',...
            [mfilename '(' class(obj) ', ''hide2'');'], 'MenuBar', 'none','Name', mfilename), 'saveable', 0);
        set(gcf, 'Visible','off');
        x = 10; y = 10;
        
        % sound parameters
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
        
        % back to the main window
        x = oldx; y = oldy;
        figure(parentfig);
        
        
        % STIM PARAMETERS WINDOW %
        
        % Separate window for stimulus parameters
        ToggleParam(obj, 'StimuluShow', 0, x, y, 'OnString', 'Parameters stimulus', ...
            'OffString', 'Parameters stimulus', 'TooltipString', 'Show/Hide Stimulus panel');
        set_callback(StimuluShow, {mfilename, 'show_hide'});
        next_row(y);
        oldx=x; oldy=y;    parentfig=double(gcf);
        SoloParamHandle(obj, 'myfig', 'value', figure('Position', [300 100 280 220], 'closerequestfcn',...
            [mfilename '(' class(obj) ', ''hide'');'], 'MenuBar', 'none','Name', mfilename), 'saveable', 0);
        set(gcf, 'Visible', 'off');
        x=10;y=10;
        
        % stimulus parameters
        NumeditParam(obj, 'bup_width', 5, x, y, 'position', [x y 200 20], ...
            'label', 'bup_width (ms)', 'TooltipString', 'the bup width in units of msec');next_row(y);
        NumeditParam(obj, 'bup_ramp', 2, x, y, 'position', [x y 200 20], ...
            'label', 'bup_ramp (ms)', 'TooltipString', 'the duration in units of msec of the upwards and downwards volume ramps for individual bups');next_row(y);
        NumeditParam(obj, 'total_rate', 40, x, y, 'position', [x y 200 20], ...
            'TooltipString', 'the sum of left and right bup rates');next_row(y);

        %%% overall volume
        NumeditParam(obj, 'vol', 0.15, x, y, 'position', [x y 200 20],'label','Overall volume multiplier', ...
            'labelfraction', 0.7,'TooltipString', 'volume multiplier for all sounds in the protocol');next_row(y);
        
        %%% back to the main window
        x=oldx; y=oldy;
        figure(parentfig);
        
        
        % TASK SWITCHING PARAMETERS %
        
        % minimum performances required
        NumeditParam(obj, 'task_switch_min_perf', .8, x, y, 'position', [x y 200 20], ...
            'label', 'Min perf', 'TooltipString', 'Minimum performance to allow switching');next_row(y);
        
        % minimum number of trials
        NumeditParam(obj, 'task_switch_mintrials', 75, x, y, 'position', [x y 200 20], ...
            'label', 'Min trials', 'TooltipString', 'Minimum number of trials before switching');next_row(y);
        
        % switch on/off
        ToggleParam(obj, 'task_switch_auto', 0, x, y, 'position', [x y 200 20], ...
            'OffString', 'Auto task switch OFF', 'OnString',  'Auto task switch ON', ...
            'TooltipString', 'If on, switches automatically between tasks');next_row(y);
        
        % first task: pro or anti?
        ToggleParam(obj, 'randomize_first_task', 0, x, y, 'position', [x y 200 20], ...
            'OffString', 'Start with pro', 'OnString',  'Randomize first task', ...
            'TooltipString', 'If on, picks randomly the first task');next_row(y,1.5);
        
      
        
        
        % ANTIBIAS %
        
        % Ab_TAU: number of trial back for antibias
        NumeditParam(obj, 'Ab_Tau', 50, x, y,'position', [x y 100 20],  ...
            'TooltipString', 'Number of trials back over which to compute antibias');
        
        % Ab_BETA: strength of antibias
        NumeditParam(obj, 'Ab_Beta', 5, x, y,'position', [x+100 y 100 20], ...
            'TooltipString', 'antibias strength');next_row(y);
        
        % antibias type
        MenuParam(obj, 'antibias_type', {'No antibias'; 'Side antibias'},...
            1, x, y, 'label', 'Type', 'TooltipString',...
            'antibias type', 'labelfraction', 0.3333);next_row(y,1);
        
        % side antibias on/off
        ToggleParam(obj, 'antibias_toggle', 1, x,y,...
            'OnString', 'Antibias ON','OffString', 'Antibias OFF',...
            'TooltipString', sprintf('If on antibias is on'));next_row(y,1.1);
        
        
        % TRAINING PARAMETERS %
        
        % on trials w/ error forgiveness for anti, wait delay
        SliderParam(obj,'wait_delay_anti',0.2,0.01,8,x, y,'label','wait delay', 'position', [x y 200 20]);next_row(y);
        
        % helper lights on/off for anti trials
        ToggleParam(obj, 'helper_lights_anti', 1, x, y, ...
            'OffString', 'Anti lights OFF', ...
            'OnString',  'Anti lights ON', ...
            'TooltipString', 'If on (black), LED lights help indicate what to do; if off (brown), no helper LED lights','position', [x y 100 20]);
        
        % toggle error forgiveness on/off for anti trials
        ToggleParam(obj, 'error_forgiveness_anti', 1, x, y, ...
            'OffString', 'Forgive OFF', ...
            'OnString',  'Forgive ON', ...
            'TooltipString', 'If on (black), start new trial upon wrong side choice; if off (brown), can choose again',...
            'position', [x+100 y 100 20]);next_row(y,1.1);
        
        % required time with nose in center
        SliderParam(obj,'nose_in_center',0.05,0.05,1.3,x, y,'label','min NIC', 'position', [x y 200 20]);next_row(y,1.1);
        
        SubheaderParam(obj,'title','Training parameters',x,y, 'position', [x y 200 18]); next_row(y);
        
      
          
        % all the possible durations and gammas
        NumeditParam(obj, 'durations', [1.3], x, y, 'position', [x y 200 20], ...
            'label', 'Duration values', 'TooltipString', 'possible stimulus durations'); next_row(y);
        NumeditParam(obj, 'gamma_values', [4], x, y, 'position', [x y 200 20],...
            'label', 'Gamma values', 'TooltipString', 'possible gamma values'); next_row(y);
        
        % total number of trials in this block
        DispParam(obj, 'nTrials_task',0, x, y, 'labelfraction', 0.55,'label','nTri block','position', [x y 100 20]);
        
        % overall performance in this block
        DispParam(obj, 'total_correct_task', 0, x, y,'labelfraction', 0.55,'label','%hit block','position', [x+100 y 100 20]);next_row(y);
        
        % current task
        MenuParam(obj, 'ThisTask', {'Pro'; 'Anti'}, 1, x, y, ...
            'TooltipString', 'the task of the present trial'); next_row(y, 1.2);
        
        % stimulus variables: current trial
        DispParam(obj, 'ThisSide','RIGHT', x, y, 'label', 'Side', 'position', [x y 70 20]);
        DispParam(obj, 'ThisDuration', 1.3, x, y, 'label', 'Dur', 'position', [x+72 y 62 20],'labelfraction', 0.6);
        DispParam(obj, 'ThisGamma', 1, x, y, 'label', 'Gam', 'position', [x+136 y 62 20]); next_row(y, 1.1);
        
        SubheaderParam(obj,'title','Current Task | Trial',x,y, 'position', [x y 200 18]); next_row(y,1.5);
        
        
        
        % INTERNAL VARIBLES %

        %stimulus variables
        SoloParamHandle(obj, 'ThisSideAnti', 'value', 'RIGHT');
        SoloParamHandle(obj, 'ThisSidePro', 'value', 'RIGHT');
        

        %variables to send to the state matrix
        SoloParamHandle(obj, 'total_error_delay', 'value', 0);
        SoloParamHandle(obj, 'total_water_multiplier', 'value', 1);

        %information about current stimulus to be saved in the data file
        SoloParamHandle(obj, 'ThisStimulus', 'value', []);
        
        % water increase related
        SoloParamHandle(obj, 'WaterL', 'value', []);
        SoloParamHandle(obj, 'WaterR', 'value', []);
        SoloParamHandle(obj, 'DelayL', 'value', []);
        SoloParamHandle(obj, 'DelayR', 'value',[]);
        SoloParamHandle(obj, 'ProbL', 'value', []);
        SoloParamHandle(obj, 'ProbR', 'value', []);
        SoloParamHandle(obj, 'BiasL', 'value', []);
        SoloParamHandle(obj, 'BiasR', 'value', []);
        

        
        % SEND OUT VARIABLES %
        
        % send to the state matrix section
        SoloFunctionAddVars('SMA1','ro_args',{'ThisTask';'settling_time';...
            'reward_delay';'nose_in_center';'nic_delay';...
            'error_forgiveness_anti'; 'ThisSide';'wait_delay_anti';...
            'wait_for_cpoke_timeout';'wait_for_spoke_timeout';...
            'timeout_delay';'helper_lights_anti';...
            'total_error_delay';'total_water_multiplier'});
        
        % send to the training section
        SoloFunctionAddVars('TrainingSection','rw_args', {...
            'antibias_type';'nose_in_center';'gamma_values';'durations';...
            'error_forgiveness_anti';
            'wait_delay_anti';'helper_lights_anti';'ThisTask';...
            'randomize_first_task';'task_switch_auto';'task_switch_min_perf'});
        
        % send to the history section
        SoloFunctionAddVars('HistorySection','ro_args',{'ThisTask';'ThisSide';...
            'ThisGamma'});
        SoloFunctionAddVars('HistorySection','rw_args',{'nTrials_task';...
            'total_correct_task'});

        
        
    case 'next_trial'
        
        % what task on this trial %
        was_block_switch.value = 0;
        
        % choose task for the first trial in the session
        if (n_done_trials<=1)
            if(value(randomize_first_task)==1)
                if (rand(1)>0.5)
                    ThisTask.value = 'Pro';
                else
                    ThisTask.value = 'Anti';
                end
            else
                ThisTask.value = 'Pro';
            end
            
            % if it is not the first trial, should we switch task
        elseif (value(task_switch_auto) == 1)
            
            % requirement 1: at least N trials in this task
            flag1 = value(nTrials_task)> value(task_switch_mintrials);
            flag2 = value(total_correct_task) > value(task_switch_min_perf);
        
            if (flag1 && flag2)
                was_block_switch.value = 1;
                if (strcmp(value(ThisTask),'Pro'))
                    % from pro to anti
                    ThisTask.value = 'Anti';
                else
                    % from anti to pro
                    ThisTask.value = 'Pro';
                end
            end
        end
        
        % setting up stimlus variables according to current task (actually just the stage)
        gamma = value(gamma_values);
        
        
        %%% choose antibias %%%
        if (value(antibias_toggle) ==1)
            antibias_type.value = 'Side antibias';
        else
            antibias_type.value= 'No antibias';
        end
        
        
        %%% compute side antibias
        vec_hit = value(hit_history);
       
        % kernel function: last few trials are most important, 
        % Ab_Tau decides how many trials back matter
        kernel = exp(-(0:length(vec_hit)-1)/value(Ab_Tau));
        kernel = kernel(end:-1:1);
        
        vec_sides = value(side_history);
        vec_sides = vec_sides(1:length(vec_hit));
        % compute bias
        if( isempty(find(vec_sides == 'l',1)) || isempty(find(vec_sides == 'r',1)))
            fracs = [0.5 0.5];
        else
            bias_left = nansum(vec_hit(vec_sides == 'l') .* kernel(vec_sides == 'l'))/sum(kernel(vec_sides == 'l'));
            bias_right = nansum(vec_hit(vec_sides == 'r') .* kernel(vec_sides == 'r'))/sum(kernel(vec_sides == 'r'));
            fracs = [bias_left bias_right];
        end
        fracs = fracs./sum(fracs);
        if(~isempty(find(isnan(fracs))))
            fracs = [0.5 0.5];
        end
        BiasL.value = round(fracs(1)*100)/100;
        BiasR.value = round(fracs(2)*100)/100;
        
        % compute resulting probabilities, water and delay
        p = exp(-fracs*value(Ab_Beta));
        p = p./sum(p);
        ProbL.value = p(1);
        ProbR.value = p(2);
        WaterL.value = p(1)*2;
        WaterR.value = p(2)*2;
        DelayL.value = max(p(1)*8, 2.5);
        DelayR.value = max(p(2)*8, 2.5);
        
        % select side
        sidevals = {'LEFT','RIGHT'};
        if (strcmp(value(antibias_type),'Side antibias'))
            ind = find(mnrnd(1, [p(1) p(2)]) == 1);
        elseif (strcmp(value(antibias_type),'No antibias'))
            ind = find(mnrnd(1, [0.5 0.5]) == 1);
        else
            error('what antibias???');
        end
        
        % assign the side
        ThisSide.value = sidevals{ind};
        
        
        
        %%%% ASSIGN WATER DELAY %%%%%
        
        % water multiplier
        if (value(water_increase_toggle) == 1)
            water_increase_multiplier.value = value(WI_base) + n_done_trials*value(WI_ratio);
            water_increase_multiplier.value = min([value(WI_max), value(water_increase_multiplier)]);
        else
            water_increase_multiplier.value = 1;
        end
        
        % side antibias
        if (strcmp(value(antibias_type),'Side antibias'))
            if (strcmp(value(ThisSide),'RIGHT'))
                total_water_multiplier.value = value(WaterR)*value(water_increase_multiplier);
                total_error_delay.value = value(DelayR);
            elseif (strcmp(value(ThisSide),'LEFT'))
                total_water_multiplier.value = value(WaterL)*value(water_increase_multiplier);
                total_error_delay.value = value(DelayL);
            else
                error('what side???');
            end
            % no antibias
        elseif (strcmp(value(antibias_type),'No antibias'))
            total_water_multiplier.value = 1;
            total_error_delay.value = 4;
        else
            error('what antibias???')
        end
        
        
        %%%%%%--- Generate stimulus --------%%%%%%%%
        
        % get sample rate
        srate = SoundManagerSection(obj, 'get_sample_rate');
        
        % select duration for the current trial
        vec = value(durations);
        ra = randperm(length(vec));
        ThisDuration.value = vec(ra(1));
        
        % select gamma for the current trial
        vec = gamma;
        ra = randperm(length(vec)); 
        if (strcmp(value(ThisSide),'RIGHT'))
            ThisGamma.value = vec(ra(1));
        elseif (strcmp(value(ThisSide),'LEFT'))
            ThisGamma.value = -vec(ra(1));
        else
            error('what?')
        end
        
        [snd lrate rrate data] = make_pbup(value(total_rate), value(ThisGamma), srate, value(ThisDuration),...
            'bup_width',value(bup_width), 'bup_ramp', value(bup_ramp));
        
        snd = snd*value(vol);
        
        if ~SoundManagerSection(obj, 'sound_exists', 'StimulusSound'),
            SoundManagerSection(obj, 'declare_new_sound', 'StimulusSound');
            SoundManagerSection(obj, 'set_sound', 'StimulusSound', snd);
        else
            snd_prev = SoundManagerSection(obj, 'get_sound', 'StimulusSound');
            if ~isequal(snd, snd_prev),
                SoundManagerSection(obj, 'set_sound', 'StimulusSound', snd);
            end;
        end;

        
        bpt.bup_width = value(bup_width);
        bpt.bup_ramp = value(bup_ramp);
        bpt.vol = value(vol);
        bpt.gamma = value(ThisGamma);
        bpt.duration = value(ThisDuration);
        bpt.left = data.left;
        bpt.right = data.right;
        ThisStimulus.value = bpt;
        push_history(ThisStimulus);
        
        
        
        %---------------------------------------%
    case 'hide'
        StimuluShow.value = 0; set(value(myfig), 'Visible', 'off');
    case 'show'
        StimuluShow.value = 1; set(value(myfig), 'Visible', 'on');
    case 'show_hide'
        if StimuluShow == 1, set(value(myfig), 'Visible', 'on');
        else    set(value(myfig),'Visible', 'off');
        end
        
        
    case 'hide2'
        SoundsShow.value = 0; set(value(myfig2), 'Visible', 'off');
    case 'show2'
        SoundsShow.value = 1; set(value(myfig2), 'Visible', 'on');
    case 'show_hide2'
        if SoundsShow == 1, set(value(myfig2), 'Visible', 'on');
        else        set(value(myfig2), 'Visible', 'off');
        end
        
    case 'hide3',
        TimingShow.value = 0; set(value(myfig3), 'Visible', 'off');
    case 'show3'
        TimingShow.value = 1; set(value(myfig3), 'Visible', 'on');
    case 'show_hide3'
        if TimingShow == 1, set(value(myfig3), 'Visible', 'on');
        else            set(value(myfig3), 'Visible', 'off');
        end
        
        
    case 'close'
        delete(value(myfig));
        delete(value(myfig2));
        delete(value(myfig3));
        
    case 'get'
        val = varargin{1};
        eval(['x = value(' val ');']);
                 
end

       
        
end