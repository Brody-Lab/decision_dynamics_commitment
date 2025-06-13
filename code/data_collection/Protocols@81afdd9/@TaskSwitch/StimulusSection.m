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


        
        
        
        NumeditParam(obj, 'overall_wtr_mult_freq', 1, x,y,'label','Overall water mult');
        next_row(y);
        
        ToggleParam(obj, 'error_forgiveness_freq', 1, x, y, ...
            'OffString', 'Error forgiveness OFF', ...
            'OnString',  'Error forgiveness ON', ...
            'TooltipString', 'If on (black), start new trial upon wrong side choice; if off (brown), can choose again');
        next_row(y);
        
        ToggleParam(obj, 'helper_lights_freq', 1, x, y, ...
            'OffString', 'Helper lights off', ...
            'OnString',  'Helper lights on', ...
            'TooltipString', 'If on (black), LED lights help indicate what to do; if off (brown), no helper LED lights');
        next_row(y);

        %%%%%%%%%%% all the possible durations and gammas
        NumeditParam(obj, 'durations_freq', [1 2], x, y, 'position', [x y 200 20], ...
            'label','Duration values','TooltipString', 'possible stimulus durations');next_row(y);
        NumeditParam(obj, 'gamma_freq_values_freq', [1 2], x, y, 'position', [x y 200 20], ...
            'label','Gamma_freq values','TooltipString', 'possible gamma_freq values');next_row(y);
        NumeditParam(obj, 'gamma_dir_values_freq', [1 2], x, y, 'position', [x y 200 20], ...
            'label','Gamma_dir values','TooltipString', 'possible gamma_dir values');next_row(y);        
        MenuParam(obj, 'stim_type_freq', {'Frequency only';'Direction + Frequency'}, 1, x, y, ...
            'labelfraction', 0.35,'label', 'Stimulus type', 'TooltipString', 'Dir. and Freq: hi and low freq. from both sides. Dir. only: one frequency. Freq. only: stereo clicks');next_row(y,1);
        
        SubheaderParam(obj,'title','Frequency Task',x,y); next_row(y, 1);

        

        
        
        
        
        
        
        
        
        NumeditParam(obj, 'overall_wtr_mult_dir', 1, x,y,'label','Overall water mult');
        next_row(y);
        
        ToggleParam(obj, 'error_forgiveness_dir', 1, x, y, ...
            'OffString', 'Error forgiveness OFF', ...
            'OnString',  'Error forgiveness ON', ...
            'TooltipString', 'If on (black), start new trial upon wrong side choice; if off (brown), can choose again');
        next_row(y);
        
        ToggleParam(obj, 'helper_lights_dir', 1, x, y, ...
            'OffString', 'Helper lights off', ...
            'OnString',  'Helper lights on', ...
            'TooltipString', 'If on (black), LED lights help indicate what to do; if off (brown), no helper LED lights');
        next_row(y);

        %%%%%%%%%%% all the possible durations and gammas
        NumeditParam(obj, 'durations_dir', [1 2], x, y, 'position', [x y 200 20], ...
            'label','Duration values','TooltipString', 'possible stimulus durations');next_row(y);
        NumeditParam(obj, 'gamma_freq_values_dir', [1 2], x, y, 'position', [x y 200 20], ...
            'label','Gamma_freq values','TooltipString', 'possible gamma_freq values');next_row(y);
        NumeditParam(obj, 'gamma_dir_values_dir', [1 2], x, y, 'position', [x y 200 20], ...
            'label','Gamma_dir values','TooltipString', 'possible gamma_dir values');next_row(y);        
        MenuParam(obj, 'stim_type_dir', {'Direction only'; 'Direction + Frequency'}, 1, x, y, ...
            'labelfraction', 0.35,'label', 'Stimulus type', 'TooltipString', 'Dir. and Freq: hi and low freq. from both sides. Dir. only: one frequency. Freq. only: stereo clicks');next_row(y,1);
        
        SubheaderParam(obj,'title','Direction Task',x,y); next_row(y, 1);

        

        
        
        
        
        
        
        
        %%%%% this variable will contain all the information about the
        %%%%% current stimulus to be saved in the data file
        SoloParamHandle(obj, 'ThisStimulus', 'value', []);
        
        
        
        SoloParamHandle(obj, 'incoherent_trial', 'value', 0);
        
        DispParam(obj, 'ThisDuration', 2, x, y, 'position', [x y 200 20], 'labelfraction', 0.6);next_row(y,1.1);
        DispParam(obj, 'ThisGamma_freq', '1', x, y,'label','ThisGammaFrequency','labelfraction', 0.6, 'position', [x y 200 20]);next_row(y);        
        DispParam(obj, 'ThisSideFrequency', 'RIGHT', x, y, 'labelfraction', 0.6, 'position', [x y 200 20]);next_row(y,1.1);        
        DispParam(obj, 'ThisGamma_dir', '1', x, y,'label','ThisGammaDirection','labelfraction', 0.6, 'position', [x y 200 20]);next_row(y);
        DispParam(obj, 'ThisSideDirection', 'RIGHT', x, y, 'labelfraction', 0.6, 'position', [x y 200 20]);next_row(y,1.1);
        DispParam(obj, 'ThisStimulusType', 'Direction only', x, y, 'labelfraction', 0.6, 'position', [x y 200 20]);next_row(y,1.1);
        DispParam(obj, 'ThisSide', 'RIGHT', x, y, 'labelfraction', 0.6, 'position', [x y 200 20]);next_row(y,1.1);
        
        
        SubheaderParam(obj,'title','StimulusSection',x,y); next_row(y, 1.5);

        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        %%%%%% COLUMN 4 %%%%%%
        y=5; next_column(x); 
        
        
        
        
        %%% overall volume
        NumeditParam(obj, 'vol', 0.15, x, y, 'position', [x y 200 20],'label','Overall volume multiplier', ...
            'labelfraction', 0.7,'TooltipString', 'volume multiplier for all sounds in the protocol');next_row(y);
        
        
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
        
        [x,y]=SoundInterface(obj,'add','Task1Sound',x,y,'Style','Tone','Volume',0.005);
        SoundInterface(obj,'set','Task1Sound','Dur1',0.15,'Freq1',2000);
        
        next_column(x);y=10;
        
        [x,y]=SoundInterface(obj,'add','TimeoutSound',x,y,'Style','SpectrumNoise','Volume',0.0025,'Loop',1);
        SoundInterface(obj,'set','TimeoutSound','Freq1',1000,'Freq2',1000,'Dur1',1,'Sigma',100,'Cntrst',500,'CRatio',5);        

        [x,y]=SoundInterface(obj,'add','HitSound',x,y,'Style','ToneSweep','Volume',0.0025);
        SoundInterface(obj,'set','HitSound','Freq1',1000,'Freq2',5000,'Dur1',0.1,'Dur2',0.3,'Tau',0.05);
        
        [x,y]=SoundInterface(obj,'add','Task2Sound',x,y,'Style','Tone','Volume',0.005);
        SoundInterface(obj,'set','Task2Sound','Dur1',0.15,'Freq1',5000);

        %%% back to the main window
        x=oldx; y=oldy;
        figure(parentfig);

        
        
        
        
        
        
        %%%% Separate window for stimulus parameters
        ToggleParam(obj, 'StimuluShow', 0, x, y, 'OnString', 'Parameters stimulus', ...
            'OffString', 'Parameters stimulus', 'TooltipString', 'Show/Hide Stimulus panel');
        set_callback(StimuluShow, {mfilename, 'show_hide'}); 
        next_row(y,1.3);        
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
        NumeditParam(obj, 'freq_unique', 9000, x, y, 'position', [x y 200 20], ...
            'TooltipString', 'unique frequency for pure direction trials (Hz)');next_row(y);        
        NumeditParam(obj, 'vol_low_freq', 1, x, y, 'position', [x y 200 20], ...
            'TooltipString', 'volume multiplier for clicks at low frequency');next_row(y);
        NumeditParam(obj, 'vol_hi_freq', 1, x, y, 'position', [x y 200 20], ...
            'TooltipString', 'volume multiplier for clicks at high frequency');next_row(y);
        
        
        %%% back to the main window
        x=oldx; y=oldy;
        figure(parentfig);

        
        
        
        
        
        
        
        
        

        
        

        %%%% ANTIBIAS PARAMETERS
        LogsliderParam(obj, 'LR_BiasTau', 30, 10, 400, x, y,'label','LR bias tau',...
            'TooltipString', 'Number of trials back over which to compute Left/Right antibias');next_row(y);
        
        MenuParam(obj, 'MaxSame', {'1', '2', '3', '4', '5', '6', '7', '14', 'Inf'}, 7, ...
            x, y,'position', [x y 100 20], 'TooltipString', 'Maximum number of times the same side (L or R) can appear');       
        NumeditParam(obj, 'LR_Beta', 3, x, y,'position', [x+100 y 100 20], ...
            'TooltipString', 'Antibias weight for Left versus Right trials');next_row(y,1.1);
        
        
%         NumeditParam(obj, 'LR_Beta', 0, x, y, ...
%             'TooltipString', 'Antibias weight for Left versus Right trials; trumps the antibias beta in soundtable');next_row(y);
%         MenuParam(obj, 'MaxSame', {'1', '2', '3', '4', '5', '6', '7', '14', 'Inf'}, 3, ...
%             x, y, 'TooltipString', 'Maximum number of times the same side (L or R) can appear');next_row(y);       

        
        %%%% WATER ANTIBIAS
        DispParam(obj, 'left_wtr_mult',1, x, y,'label','leftWat','position', [x y 100 20],...
            'TooltipString', 'all left reward times are multiplied by this number');
        DispParam(obj, 'right_wtr_mult',1, x, y,'label','rightWat','position', [x+100 y 100 20],...
            'TooltipString', 'all left reward times are multiplied by this number');next_row(y);
        ToggleParam(obj, 'water_antibias_toggle', 1, x,y,...
            'OnString', 'Water Antibias ON','OffString', 'Water Antibias OFF',...
            'TooltipString', sprintf(['If on (black) then it disables the wtr_mult entries\n'...
            'and uses hitfrac to adjust the water times']));next_row(y);

        
        
         %%%% SIDE ANTIBIAS
        DispParam(obj, 'LeftP',0.5, x, y, 'labelfraction', 0.4,'position', [x y 100 20]);
        DispParam(obj, 'RightP',0.5, x, y, 'labelfraction', 0.4,'position', [x+100 y 100 20]);next_row(y);       
        ToggleParam(obj, 'side_antibias_toggle', 1, x,y,...
            'OnString', 'Side Antibias ON','OffString', 'Side Antibias OFF',...
            'TooltipString', sprintf('If on side antibias is on'));next_row(y);

        
        DispParam(obj, 'BiasL',0.5, x, y, 'labelfraction', 0.4,'position', [x y 100 20]);
        DispParam(obj, 'BiasR',0.5, x, y, 'labelfraction', 0.4,'position', [x+100 y 100 20]);next_row(y,1.1);       
        
        
        SubheaderParam(obj,'title','Antibias',x,y); next_row(y, 1);


        
        
        
        NumeditParam(obj, 'incoherent_delay',1, x,y,'label','Incoherent delay','TooltipString','Delay for errors on incoherent trials');
        next_row(y);
        
        ToggleParam(obj, 'longer_punish_incoh_trials', 0, x, y, ...
            'OffString', 'Same punish if incoherent', ...
            'OnString',  'Long punish if incoherent', ...
            'TooltipString', 'If on (black), error state lasts longer on incoherent trials; if off (brown), error state lasts the same on incoherent trials');
        next_row(y);
        
        
        NumeditParam(obj, 'incoherent_reward', 1, x,y,'label','Incoherent reward','TooltipString','Reward multiplier on incoherent trials');
        next_row(y);
        
        ToggleParam(obj, 'higher_reward_incoh_trials', 0, x, y, ...
            'OffString', 'Same reward if incoherent', ...
            'OnString',  'Higher reward if incoherent', ...
            'TooltipString', 'If on (black), larger reward on incoherent trials; if off (brown), same reward on incoherent trials');
        next_row(y);
        
        
        
        
        
        NumeditParam(obj, 'timeout_delay', 3, x,y,'label','Timeout delay','TooltipString','Delay after timeout at spoke, follows new trial');
        next_row(y);
        
        NumeditParam(obj, 'error_delay', 3, x,y,'label','Error delay','TooltipString','Delay after poking on wrong side');
        next_row(y);
        
        NumeditParam(obj, 'reward_delay', 0.001, x,y,'label','Reward Delay','TooltipString','Delay between side poke and reward delivery');
        next_row(y);
        
        NumeditParam(obj, 'wait_for_spoke_timeout', 60, x,y,'label','Timeout for spoke','TooltipString','Time after NIC to wait for a side poke');
        next_row(y);
        
        NumeditParam(obj, 'nic_delay', 3, x,y,'label','NIC violation delay','TooltipString','Delay after NIC violation, follows new trial');
        next_row(y);
        
        NumeditParam(obj, 'nose_in_center', 1, x, y,'label','NIC min. duration', ...
            'TooltipString', 'Duration (in sec) nose must be kept in center poke before side choice is allowed');
        next_row(y);
        
        NumeditParam(obj, 'settling_time', 0.1, x,y,'label','Pre-stimulus delay','TooltipString','Time in NIC before starting stimulus');
        next_row(y);
        
        NumeditParam(obj, 'wait_for_cpoke_timeout', 120, x,y,'label','Timeout for cpoke','TooltipString','Timeout waiting for cpoke');
        next_row(y);
        
        SubheaderParam(obj,'title','Timing',x,y); next_row(y, 1.5);

        
        
        
        next_row(y);

       
        
        
        
        
        
        
        
        
        
        
        
        %%% send variables to other sections
        
        
        SoloFunctionAddVars('SMA1', 'ro_args',{'settling_time';...
            'reward_delay';'nose_in_center';'nic_delay';...
            'error_forgiveness_dir';'error_forgiveness_freq';'error_delay';...
            'wait_for_cpoke_timeout';'wait_for_spoke_timeout';'timeout_delay';...
            'ThisSide';'helper_lights_dir';'helper_lights_freq'});
        

        
        SoloFunctionAddVars('SoundWindow', 'ro_args',{'vol'});
         
        
        
        
        SoloFunctionAddVars('TrainingSection', 'rw_args', {'side_antibias_toggle';...
            'LR_Beta';'MaxSame';'LR_BiasTau';'water_antibias_toggle';...
            'stim_type_dir';'stim_type_freq';...
            'gamma_dir_values_dir';'gamma_dir_values_freq';...
            'gamma_freq_values_dir';'gamma_freq_values_freq';...
            'durations_dir';'durations_freq';...
            'settling_time';'reward_delay';'nose_in_center' ;'nic_delay';...
            'error_forgiveness_dir';'error_forgiveness_freq';'error_delay';...
            'wait_for_cpoke_timeout';'wait_for_spoke_timeout';'timeout_delay'; ...
            'longer_punish_incoh_trials'; 'incoherent_delay';'higher_reward_incoh_trials';...
            'incoherent_reward';'helper_lights_dir';'helper_lights_freq'});
        
        
        
        SoloFunctionAddVars('HistorySection', 'ro_args', {'ThisSide';'incoherent_trial'});
         
        
        
        
        
        
                
        
        
        
        
        
        
        
        

    case 'next_trial',

        
        
        
        
        
        %%% setup variables according to current task
        if(strcmp(value(ThisTask),'Direction'))


            durations=value(durations_dir);
            
            gamma_dir_values=value(gamma_dir_values_dir);
            gamma_freq_values=value(gamma_freq_values_dir);
            
            stim_type=value(stim_type_dir);

        elseif(strcmp(value(ThisTask),'Frequency'))


            durations=value(durations_freq);
            
            gamma_dir_values=value(gamma_dir_values_freq);
            gamma_freq_values=value(gamma_freq_values_freq);
            
            stim_type=value(stim_type_freq);


        else
            error('what task?')
        end




        %%%% ANTIBIAS %%%% (adapted from PBups protocol)
        
        %%% compute bias
        
        vec_sides = value(side_history);
        vec_hit=value(hit_history);
        % make sure the two vectors have same length
        vec_sides = vec_sides(1:length(vec_hit));


        %%% the kernel function decides how to weigh correct responses:
        %%% the last few trials are the most important
        %%% LR_BiasTau decides how many trials back matter
        kernel = exp(-(0:length(vec_hit)-1)/value(LR_BiasTau));
        kernel = kernel(end:-1:1);


        %%%% calculate an average of percent correct for left and right trials,
        %%%% weighted so that the last trials count more
        ul = find(vec_sides=='l');
        rl = find(vec_sides=='r');
        if(isempty(ul) || isempty(rl))
            fracs=[0.5 0.5];
        else
            bias_left = nansum(vec_hit(ul) .* kernel(ul))/sum(kernel(ul));        
            bias_right = nansum(vec_hit(rl) .* kernel(rl))/sum(kernel(rl));
            fracs=[bias_left bias_right];
        end;
        fracs=fracs./sum(fracs);
        
        
        val=fracs(1);
        val=round(val*100)/100;
        BiasL.value=val;
        
        val=fracs(2);
        val=round(val*100)/100;
        BiasR.value=val;
                
        if(value(LR_Beta) > 0)
            p = exp(-fracs*value(LR_Beta));
            p=p./sum(p);
            
            %%% round to the third decimal
            p=round(p*1000)/1000;
            
            if(value(side_antibias_toggle))
                choices=p;
                LeftP.value=p(1);
                RightP.value=p(2);
            else
                choices=[0.5 0.5];
                LeftP.value=0.5;
                RightP.value=0.5;
            end
            
            
            if(value(water_antibias_toggle))
                left_wtr_mult.value=p(1)*2;
                right_wtr_mult.value=p(2)*2;
            else
                left_wtr_mult.value=1;
                right_wtr_mult.value=1;
            end
            
        else
            choices=[0.5 0.5];
            LeftP.value=0.5;
            RightP.value=0.5;
            left_wtr_mult.value=1;
            right_wtr_mult.value=1;
        end
             
            

        this_side = '';
        %%% MaxSame rule applies
        if(~strcmpi(value(MaxSame), 'Inf') && value(MaxSame)<=n_started_trials)
            
            % if there's been a string of MaxSame guys all the same, force change
            if(all(vec_sides(end-value(MaxSame)+1:end) == vec_sides(end)))
                if(vec_sides(end) == 'l')
                    this_side = 'RIGHT';
                else
                    this_side = 'LEFT';
                end;
            elseif(~isempty(choices)) % if there is a trump LR_Beta, pick next side here
                if(rand(1) > value(LeftP))
                    this_side = 'RIGHT';
                else
                    this_side = 'LEFT';
                end;
            end;
        else
            %%% MaxSame rule does not apply
            if(rand(1) > value(LeftP))
                this_side = 'RIGHT';
            else
                this_side = 'LEFT';
            end;
        end
        
        
        %%%% Pick randomly side for the other task
        if(rand(1) > 0.5)
            this_side_other_task = 'RIGHT';
        else
            this_side_other_task = 'LEFT';
        end;
        
        
        %%% decide whether the current trial is incoherent
        if(strcmp(stim_type,'Direction + Frequency'))
            if(~strcmp(this_side,this_side_other_task))
                incoherent_trial.value=1;
            else
                incoherent_trial.value=0;
            end
        else
            incoherent_trial.value=NaN;
        end
        
        
        %%% set the side for current trial
        ThisSide.value=this_side;
        
        
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
        
        
                
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
%         
%         %%% randomize freq_unique each day at the beginning of the session
%         if(n_done_trials==1)
%             if(rand(1)>0.5)
%                 freq_unique.value=value(freq_lo);
%             else
%                 freq_unique.value=value(freq_hi);
%             end
%         end
        

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
            
        
        %%% select current stim type
        if(strcmp(stim_type,'Direction + Frequency'))
            freq_vec=[value(freq_lo) value(freq_hi)];
            crosstalk=0;
        elseif(strcmp(stim_type,'Direction only'))
            freq_vec=[value(freq_unique) value(freq_unique)];
            crosstalk=0;
        elseif(strcmp(stim_type,'Frequency only'))
            freq_vec=[value(freq_lo) value(freq_hi)];
            crosstalk=1;
        else
            error('WTF???!!!')
        end
        
        
        [snd data] = make_pbup_mixed(value(total_rate),...
            value(ThisGamma_dir),value(ThisGamma_freq), srate, value(ThisDuration), ...
            'bup_width', value(bup_width), 'crosstalk', crosstalk, 'freq_vec',freq_vec, ...
            'bup_ramp', value(bup_ramp),'vol_low',value(vol_low_freq),'vol_hi',value(vol_hi_freq));


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
        
        bpt.stim_type=stim_type;
        bpt.freqs=freq_vec;
        bpt.crosstalk=crosstalk;
        bpt.bup_width=value(bup_width);
        bpt.bup_ramp=value(bup_ramp);
        bpt.vol_low=value(vol_low_freq);
        bpt.vol_hi=value(vol_hi_freq);
        bpt.vol=value(vol);
        bpt.gamma_dir = value(ThisGamma_dir);
        bpt.gamma_freq = value(ThisGamma_freq);
        bpt.duration = value(ThisDuration);
        bpt.left = data.left;
        bpt.right = data.right;
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
        
        
    case 'close',
        delete(value(myfig));
        delete(value(myfig2));



    case 'get_delay_incoh'
        
        %%% setup variables according to current task
        if(strcmp(value(ThisTask),'Direction'))
            stim_type=value(stim_type_dir);
        elseif(strcmp(value(ThisTask),'Frequency'))
            stim_type=value(stim_type_freq);
        else
            error('what task?')
        end


        
        flag1=value(longer_punish_incoh_trials)==1;
        flag2=strcmp(stim_type,'Direction + Frequency');
        
        
        val1=value(ThisSideDirection);
        val2=value(ThisSideFrequency);    
        flag3=~strcmp(val1,val2);
        
        if(flag1 && flag2 && flag3)
            x=value(incoherent_delay);
        else
            x=0;
        end
        
        


    case 'get_water_incoh'
        
        
        %%% setup variables according to current task
        if(strcmp(value(ThisTask),'Direction'))
            stim_type=value(stim_type_dir);
        elseif(strcmp(value(ThisTask),'Frequency'))
            stim_type=value(stim_type_freq);
        else
            error('what task?')
        end


        
        
        flag1=value(higher_reward_incoh_trials)==1;
        flag2=strcmp(stim_type,'Direction + Frequency');
        
        
        val1=value(ThisSideDirection);
        val2=value(ThisSideFrequency);    
        flag3=~strcmp(val1,val2);
        
        if(flag1 && flag2 && flag3)
            x=value(incoherent_reward);
        else
            x=1;
        end
        

        
        
    case 'get_overall_water_mult'


        
        
        if(strcmp(value(ThisTask),'Direction'))
            x=value(overall_wtr_mult_dir);
        elseif(strcmp(value(ThisTask),'Frequency'))
            x=value(overall_wtr_mult_freq);
        else
            error('what task?')
        end


        
        
        
    case 'get_water_mult'

        x=value(left_wtr_mult);
        y=value(right_wtr_mult);

        
        
    case 'get'
        
        val=varargin{1};
        
        eval(['x=value(' val ');']);
        
       
        
end


