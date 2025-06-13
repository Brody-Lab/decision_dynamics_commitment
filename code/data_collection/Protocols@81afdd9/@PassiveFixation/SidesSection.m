function [x, y] = SidesSection(obj, action, varargin)
%(PassiveFixation) cmc Nov 2015

GetSoloFunctionArgs(obj);

switch action,
    
    % ------------------------------------------------------------------
    %              INIT
    % ------------------------------------------------------------------
    
    case 'init'
        x=varargin{1};
        y=varargin{2};
        
        
        
        % next_row(y);
        NumeditParam(obj, 'wait_for_cpoke_timeout', 60, x,y,'label','Wait for Cpoke Timeout','TooltipString','After this time go to the timeout state');
        next_row(y);
        NumeditParam(obj, 'rewardprob', 1, x,y,'label','rewardprob','TooltipString','Variable reward schedule');
        next_row(y);
        ToggleParam(obj,  'allow_nic_breaks', 0, x,y,'OffString','Punish NIC Viol','OnString','Ignore NIC Viol','TooltipString','After this time go to the timeout state');
        next_row(y);
        MenuParam(obj, 'side_lights' ,{'none','both','correct side','anti side'},1, x,y,'label','Side Lights','TooltipString','Controls the side LEDs during wait_for_spoke');
        next_row(y);
        NumeditParam(obj, 'wait_for_spoke_timeout', 4, x,y,'label','Response Timeout','TooltipString','Time after NIC to wait for a side poke');
        next_row(y);
        NumeditParam(obj, 'reward_delay', 0.5, x,y,'label','Reward Delay','TooltipString','Delay between side poke and reward delivery');
        next_row(y);
        ToggleParam(obj, 'ignore_errors', 0, x,y,'OffString','Errors Punished','OnString','Errors Ignored','TooltipString','If ignore errors, then subject will eventually get the reward at the correct poke');
        next_row(y);
        NumeditParam(obj, 'error_iti', 1.5, x,y,'label','Error Timeout','TooltipString','ITI on error trials');
        next_row(y);
        NumeditParam(obj, 'thisnic', .01, x, y, 'label', 'thisnic');
        next_row(y);
        NumeditParam(obj, 'warmuptrials', 15, x, y, 'label', 'warmuptrials');
        next_row(y);
        NumeditParam(obj, 'nic_time', .01, x,y,'label','NIC Time','TooltipString','Length of NIC');
        next_row(y);
        NumeditParam(obj, 'growNIC_incr', .002, x,y,'label','growNIC_incr','TooltipString','Grow NIC time by this much');
        next_row(y);
        NumeditParam(obj, 'Max_NIC', 3, x,y,'label','Maximum NIC','TooltipString','Max NIC time');
        next_row(y);
        NumeditParam(obj, 'violation_iti', 1, x,y,'label','Violation Timeout','TooltipString','ITI on error trials');
        
        next_column(x);
        y = 5;
        NumeditParam(obj, 'NosPos', 0, x, y, 'label', 'NosPos');
        next_row(y);
        NumeditParam(obj, 'StepSize', 0, x, y, 'label', 'StepSize');
        next_row(y);
        NumeditParam(obj, 'mswitch_counter', 0, x, y, 'label', 'mswitch_counter');
        next_row(y);
        NumeditParam(obj, 'Vacuum_dur', 0, x, y, 'label', 'Vacuum_dur');
        next_row(y);
        NumeditParam(obj, 'ObjWater_dur', 0, x, y, 'label', 'ObjWater_dur');
        next_row(y);
        NumeditParam(obj, 'WaterImmersion', 0, x, y, 'label', 'WaterImmersion');
        next_row(y);
        NumeditParam(obj, 'PistonPressure', 0, x, y, 'label', 'PistonPressure');
        next_row(y);
        NumeditParam(obj, 'Imaging', 0, x, y, 'label', 'Imaging');
        next_row(y);
        
        next_column(x);
        y=5;
        NumeditParam(obj,'trials_in_stage',1,x,y,'label','Trial Counter');
        next_row(y);
        NumeditParam(obj,'training_stage',0,x,y,'label','Training Stage');
        next_row(y);
        ToggleParam(obj,'use_training',1,x,y,'OnString','Using Autotrain','OffString','Manual Settings');
        next_row(y);
        
        
        SoloFunctionAddVars('SMA1', 'ro_args', ...
            {'training_stage';'side_lights' ; 'rewardprob'; 'ignore_errors';...
            'nic_time'; 'growNIC_incr';'wait_for_cpoke_timeout'; 'allow_nic_breaks' ; ...
            'wait_for_spoke_timeout' ; 'reward_delay'; 'thisnic'; 'warmuptrials'; ...
            'error_iti';'violation_iti'; 'NosPos';'StepSize'; 'PistonPressure'; 'Imaging';...
            'WaterImmersion'; 'ObjWater_dur'; 'Vacuum_dur'});
        SoloFunctionAddVars('SMA1', 'rw_args', {'training_stage'; 'mswitch_counter'});
        
        
        %   History of nose_in_center violations:
        SoloParamHandle(obj, 'violation_history', 'value', []);
        SoloParamHandle(obj, 'previous_sides', 'value', []);
        
        
    case 'update_trial_history',
        ps=value(previous_sides);
        ps(n_done_trials+1)=varargin{1};
        
        previous_sides.value=ps;
        
    case 'trial_completed'
        trials_in_stage.value = value(trials_in_stage) + 1;
        
    case 'next_trial',
        
        
        
        %% update hit_history, previous_sides, etc
        was_viol=false;
        was_hit=false;
        if n_done_trials>0
            if ~isempty(parsed_events)
                if isfield(parsed_events,'states')
                    if isfield(parsed_events.states,'violation_state')
                        was_viol=rows(parsed_events.states.violation_state)>0 || rows(parsed_events.states.timeout_state)>0;
                        %was_hit = nan;
                    elseif isfield(parsed_events.states, 'givewater')
                        was_hit = rows(parsed_events.states.givewater);
                        was_viol = 0;
                    end
                end
                
            end
            
            violation_history.value=[violation_history(:); was_viol];
            hit_history.value = [hit_history(:); was_hit];
            
        end
        
        if n_done_trials < value(warmuptrials)
           thisnic.value = value(nic_time)/(value(warmuptrials)-n_done_trials); 
        end
        
        
        %% Now set up next_trial
        
        
        if use_training==1
            if ~was_viol && was_hit
                trials_in_stage.value=trials_in_stage+1;
            end
            
            switch value(training_stage) %#ok<*NODEF>
                case 0,
                    settling_time.value=0.001;
                    allow_nic_breaks.value=1;
                    ignore_errors.value=1;
                    side_lights.value=3;
                    % training_stage.value=1;
                    % trials_in_stage.value=0;
                    wait_for_cpoke_timeout.value=600;
                    wait_for_spoke_timeout.value=600;
                    reward_delay.value=0.01;
                    error_iti.value=1.5;
                   % nic_time.value=0.001;
                    
                    NosPos.value = value(NosPos) + value(StepSize);
                    if isfield(parsed_events, 'states');
                        if isfield(parsed_events.states, 'cpslotonly');
                            if ~isempty(parsed_events.states.cpslotonly);
                                mswitch_counter.value = value(mswitch_counter) + 1;
                            elseif isempty(parsed_events.states.cpslotonly);
                                mswitch_counter.value = 0;
                            end
                        end
                    end
                    
                    if value(mswitch_counter) > 10;
                        training_stage.value = 1;
                        trials_in_stage.value = 0;
                    end
                    
                case 1,  % Light chase and grow nose in center time
                    
                    if ~was_viol  % if last trial was violation don't increment.
                        
                        
                        
                        nic_time.value=value(nic_time)+value(growNIC_incr);
                                               
                        allow_nic_breaks.value=0; %#ok<*STRNU>
                        
                        
                        if value(nic_time)>=value(Max_NIC) % increased this time to make the transition easier
                            training_stage.value=2;
                            trials_in_stage.value=0;
                        end
                    end
                case 2,  %pistons and shutter will be activated, but you can still grow the nic_time if you want.
                    
                    if ~was_viol
                        if value(nic_time)<value(Max_NIC)
                            nic_time.value=value(nic_time)+value(growNIC_incr);
                        end
                    end
                    
                    
                    
            end
        end
        
        
    case 'get_water_mult',
      %  x=left_wtr_mult+0;
    %    y=right_wtr_mult+0;
        
    case 'make_and_send_summary',
        

        
        peh=cell2mat(parsed_events_history);
        ps=value(previous_sides(:));
       
        sides = ps;
        pd.sides = ps;
        %cout=extract_event(peh,'wait_for_cout(1,2)');
        cin=extract_event(peh,'wait_for_cpoke(end,2)');
        viol=extract_event(peh,'violation_state(1,1)');
                
        nic=cell2mat(get_history(nic_time));
        pd.nic=cell2mat(get_history(nic_time));
        pd.training_stage=cell2mat(get_history(training_stage));
        
        hits = ones(length(value(nic)), 1);
        %hits=hit_history(1:n_done_trials);
        pd.hits = hits;
        
        
        sendsummary(obj,'hits',hits,'sides',sides,'protocol_data',pd);
        
end


