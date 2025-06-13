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
        SoloParamHandle(obj, 'myfig3', 'value', figure('Position', [300 100 280 220],'closerequestfcn',...
            [mfilename '(' class(obj) ', ''hide3'');'], 'MenuBar', 'none','Name', mfilename), 'saveable', 0);
        
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
        SoloParamHandle(obj, 'myfig2', 'value', figure('Position', [100 100 560 440],'closerequestfcn',...
            [mfilename '(' class(obj) ', ''hide2'');'], 'MenuBar', 'none','Name', mfilename), 'saveable', 0);
        set(gcf, 'Visible', 'off');
        x=10;y=10;
        
        %%%% Sound parameters
        [x,y]=SoundInterface(obj,'add','ViolationSound',x,y,'Style','SpectrumNoise','Volume',0.0015,'Loop',1);
        SoundInterface(obj,'set','ViolationSound','Freq1',8000,'Freq2',2222,'Dur1',1,'Sigma',14,'Cntrst',111,'CRatio',1);
        
        [x,y]=SoundInterface(obj,'add','ErrorSound',x,y,'Style','PClick','Volume',0.0035,'Loop',1);
        SoundInterface(obj,'set','ErrorSound','Freq1',333,'Freq2',333,'Dur1',0.5,'Width',5);
        
        
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
        SoloParamHandle(obj, 'myfig', 'value', figure('Position', [300 100 280 220], 'closerequestfcn',...
            [mfilename '(' class(obj) ', ''hide'');'], 'MenuBar', 'none','Name', mfilename), 'saveable', 0);
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
        
        
        
        
        %%%% current task
        next_row(y);
        
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%% ANTIBIAS %%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        
        
        
        
        DispParam(obj, 'WaterL',1, x, y,'position', [x y 100 20]);
        DispParam(obj, 'WaterR',1, x, y,'position', [x+100 y 100 20]);
        next_row(y,1.1);
%         next_column(x);
        
        DispParam(obj, 'DelayL',4, x, y,'position', [x y 100 20]);
        DispParam(obj, 'DelayR',4, x, y,'position', [x+100 y 100 20]);
        next_row(y,1.1);
%         next_column(x,-1);
        
        DispParam(obj, 'BiasL',0.5, x, y,'position', [x y 100 20]);
        DispParam(obj, 'BiasR',0.5, x, y,'position', [x+100 y 100 20]);
        next_row(y,1.1);
%         next_column(x);
        
        DispParam(obj, 'ProbL',0.5, x, y,'position', [x y 100 20]);
        DispParam(obj, 'ProbR',0.5, x, y,'position', [x+100 y 100 20]);
        
        next_row(y,1.1);
%         next_column(x,-1);

        
        
        
        
        
        %%% Ab_TAU: number of trials back for antibias
        NumeditParam(obj, 'Ab_Tau', 50, x, y,'position', [x y 100 20],  ...
            'TooltipString', 'Number of trials back over which to compute antibias');
        
        %%% Ab_BETA: strenth of antibias
        NumeditParam(obj, 'Ab_Beta', 5, x, y,'position', [x+100 y 100 20], ...
            'TooltipString', 'antibias strength');next_row(y);
        
        
        %%% side antibias on/off
        ToggleParam(obj, 'antibias_toggle', 1, x,y,...
            'OnString', 'Antibias ON','OffString', 'Antibias OFF',...
            'TooltipString', sprintf('If on antibias is on'));next_row(y,1.1);
        
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%% TRAINING PARAMETERS %%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         
%         %%% mixing of frequency evidence
%         SliderParam(obj,'stimulus_mixing_freq',0,0,1,x, y,'label','%mixing freq', 'position', [x y 200 20]);next_row(y);
%         %%% mixing of direction evidence
%         SliderParam(obj,'stimulus_mixing_dir',0,0,1,x, y,'label','%mixing dir', 'position', [x y 200 20]);next_row(y,1.3);
%         
        
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
        
        next_row(y);
        
        
        
        
        
        
        
        %%%%%%%%%%% all the possible durations and gammas
        NumeditParam(obj, 'durations_freq', [1.3], x, y, 'position', [x y 200 20], ...
            'label','Duration values','TooltipString', 'possible stimulus durations');next_row(y);
        NumeditParam(obj, 'gamma_freq_values', [4], x, y, 'position', [x y 200 20], ...
            'label','Gamma values','TooltipString', 'possible gamma values');next_row(y);
%        

        
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%% STIMULUS VARIABLES %%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        next_row(y,1.1);
%         next_row(y,9.3);
%         next_column(x,-1);
        
%         SubheaderParam(obj,'title','This',x,y, 'position', [x y 50 20]);
        %%% current quadrant/side
        DispParam(obj, 'ThisSide','RIGHT', x, y,'label','This Side','position', [x y 200 20]);next_row(y);
%         
        %%% current duration
        DispParam(obj, 'ThisDuration', 1.3, x, y,'label','This Duration', 'position', [x y 200 20]);next_row(y);
        %%% current gammas
        DispParam(obj, 'ThisGamma_freq',1, x, y,'label','This Gamma','position', [x y 200 20]);next_row(y);
        
        
        
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%% INTERNAL VARIBLES %%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %stimulus variables
        SoloParamHandle(obj, 'ThisSideFrequency', 'value', 'RIGHT');
        
        %variables to send to the state matrix
        SoloParamHandle(obj, 'total_error_delay', 'value', 0);
        SoloParamHandle(obj, 'total_water_multiplier', 'value', 1);
        
        %information about current stimulus to be saved in the data file
        SoloParamHandle(obj, 'ThisStimulus', 'value', []);
        
        
        
        
        
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%% SEND OUT VARIBLES %%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%% send to the state matrix section
        SoloFunctionAddVars('SMA1', 'ro_args',{'settling_time';...
            'reward_delay';'nose_in_center';'nic_delay';...
            'error_forgiveness_freq';'wait_delay_freq';...
            'wait_for_cpoke_timeout';'wait_for_spoke_timeout';
            'timeout_delay';'ThisSide';'helper_lights_freq';...
            'total_error_delay';'total_water_multiplier'});
        
        %%% send to the training section
        SoloFunctionAddVars('TrainingSection', 'rw_args', {...
            'gamma_freq_values';'durations_freq';...
            'nose_in_center' ;'error_forgiveness_freq';...
            'wait_delay_freq';'helper_lights_freq'});
        
        %%% send to the history section
        SoloFunctionAddVars('HistorySection', 'ro_args', {'ThisSide';'ThisGamma_freq'});
        
%         SoloFunctionAddVars('HistorySection', 'rw_args', {'nTrials_task';'total_correct_task'});
        
        
        
        
    case 'next_trial',
        
        
        
        
        
        
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
        
        
        
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%% SELECT SIDE %%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        
        
        %CHOOSE SIDE
        sidevals={'LEFT','RIGHT'};
        if(value(antibias_toggle)==1)
            ind=find(mnrnd(1,[value(ProbL) value(ProbR)])==1);
        else
            ind=find(mnrnd(1,[0.5 0.5])==1);
        end
        %%% ASSIGN THE SIDE
        ThisSide.value=sidevals{ind};
        ThisSideFrequency.value=sidevals{ind};
        
        
        
        
        
        
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
        
        
        
        %%%% SIDE ANTIBIAS
        if(value(antibias_toggle)==1)
            if(strcmp(value(ThisSide),'RIGHT'))
                total_water_multiplier.value=value(WaterR)*value(water_increase_multiplier);
                total_error_delay.value=value(DelayR);
            elseif(strcmp(value(ThisSide),'LEFT'))
                total_water_multiplier.value=value(WaterL)*value(water_increase_multiplier);
                total_error_delay.value=value(DelayL);
            else
                error('what side???')
            end
            
        else    %%%% NO ANTIBIAS
            total_water_multiplier.value=1;
            total_error_delay.value=4;
        end
        
        
        
        
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%% GENERATE STIMULUS %%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        %%%% get sample rate
        srate = SoundManagerSection(obj, 'get_sample_rate');
        
        
        %%% select duration for the current trial
        vec=value(durations_freq);
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
        
        
        
        freq_vec=[value(freq_lo) value(freq_hi)];
        
        
        [snd data] = make_pbup_mixed3(value(total_rate),...
            0,value(ThisGamma_freq), srate, value(ThisDuration), ...
            'bup_width',value(bup_width),'crosstalk_dir', 1,...
            'crosstalk_freq', 0,'freq_vec',freq_vec,'bup_ramp',...
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
        bpt.bup_width=value(bup_width);
        bpt.bup_ramp=value(bup_ramp);
        bpt.vol_low=value(vol_low_freq);
        bpt.vol_hi=value(vol_hi_freq);
        bpt.vol=value(vol);
        bpt.gamma_freq = value(ThisGamma_freq);
        bpt.duration = value(ThisDuration);
        bpt.left_hi = data.left_hi;
        bpt.right_hi = data.right_hi;
        bpt.left_lo = data.left_lo;
        bpt.right_lo = data.right_lo;
        ThisStimulus.value = bpt;
        push_history(ThisStimulus);
        
        
        
        
        
        
        
        
        
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


