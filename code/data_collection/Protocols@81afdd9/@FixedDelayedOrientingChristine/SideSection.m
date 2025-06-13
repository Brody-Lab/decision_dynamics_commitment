

function [x, y] = SideSection(obj, action, x,y)

GetSoloFunctionArgs(obj);

switch action,
	
	% ------------------------------------------------------------------
	%              INIT
	% ------------------------------------------------------------------
	
	case 'init'
		
		SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)], 'saveable', 0);
		y0 = y;
 
        [x, y] = AntibiasSectionAthena(obj,     'init', x, y);
		       
        
        ToggleParam(obj, 'antibias_LRprob', 0, x,y,...
			'OnString', 'AB_Prob ON',...
			'OffString', 'AB_Prob OFF',...
			'TooltipString', sprintf(['If on (Yellow) then it enables the AntiBias algorithm\n'...
			'based on changing the probablity of Left vs Right']));

		next_row(y);
		NumeditParam(obj, 'LeftProb', 0.5, x, y); next_row(y);
		set_callback(LeftProb, {mfilename, 'new_leftprob'});
		MenuParam(obj, 'MaxSame', {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, Inf}, Inf, x, y, ...
			'TooltipString', sprintf(['\nMaximum number of consecutive trials where correct\n' ...
			'response is on the same side. Overrides antibias. Thus, for\n' ...
			'example, if MaxSame=5 and there have been 5 Left trials, the\n' ...
			'next trial is guaranteed to be Right'])); next_row(y);
		
		DispParam(obj, 'ThisTrial', 'LEFT', x, y); next_row(y);
		SoloParamHandle(obj, 'previous_sides', 'value', []);
		DeclareGlobals(obj, 'ro_args', 'previous_sides');       
		SubheaderParam(obj, 'title', 'Sides Section', x, y);
		next_row(y, 1.5);
		next_column(x); y = 5;
		NumeditParam(obj, 'RewardCollection_duration', 10, x,y,'label','RewardCollection_duration','TooltipString','Wait until rat collects the reward');
		next_row(y);
		NumeditParam(obj, 'CenterLed_duration', 20, x,y,'label','Central LED duration','TooltipString','Duration of Center Led');
		next_row(y);
		NumeditParam(obj, 'SideLed_duration', 0.5, x,y,'label','Side LED duration','TooltipString','Duration of SideLed');
		next_row(y);
		NumeditParam(obj, 'legal_cbreak', 0.1, x,y, 'position', [x, y, 175 20], 'TooltipString','Time in sec for which it is ok to be outside the center port before a violation occurs.');
		ToggleParam(obj, 'LED_during_legal_cbreak', 1, x, y, 'OnString', 'LED ON LcB', 'OffString', 'LED off LcB', ...
			'position', [x+180 y 20 20], 'TooltipString', ...
			'If 1 (black), turn center port LED back on during legal_cbreak; if 0 (brown), leave LED off');
         next_row(y);
		NumeditParam(obj, 'SettlingIn_time', 0.2, x,y, 'position', [x, y, 175 20], 'TooltipString','Initial settling period during which "legal cbreak period" can be longer than the usual "legal_cbreak"');
        next_row(y);
		NumeditParam(obj, 'settling_legal_cbreak', 0.1, x,y, 'position', [x, y, 175 20], 'TooltipString','Time in sec for which it is ok during the "SettlingIn_time" to be outside the center port before a violation occurs.');
		ToggleParam(obj, 'LED_during_settling_legal_cbreak', 0, x, y, 'OnString', 'LED ON SetLcB', 'OffString', 'LED OFF setLcB', ...
			'position', [x+180 y 20 20], 'TooltipString', ...
			'If 1 (black), turn center port LED back on during settling_legal_cbreak; if 0 (brown), leave LED off');
		next_row(y);
		MenuParam(obj, 'side_lights' ,{'none','both','correct side','anti side'},1, x,y,'label','Side Lights','TooltipString','Controls the side LEDs during wait_for_spoke');
		next_row(y);

		
        NumeditParam(obj, 'A1_time', 0.3, x,y,'label','AUD1 on Time','TooltipString','Duration of first stimulus');
        next_row(y);
        set_callback(A1_time, {mfilename, 'new_CP_duration'});
        NumeditParam(obj, 'A2_time', 0.3, x,y,'label','AUD2 On Time','TooltipString','Duration of second stimulus');
        next_row(y);
        set_callback(A2_time, {mfilename, 'new_CP_duration'});
        NumeditParam(obj, 'Grow_del_by', .001, x,y,'label','Grow delay by','TooltipString','Grow the delay by this much each trial');
        next_row(y);
        NumeditParam(obj, 'Target_Del_time', 1, x,y,'label','Target Delay Time','TooltipString','Grow the delay until it is this much');
        next_row(y);
        NumeditParam(obj, 'Del_time', 1, x,y,'label','Delay Duration Time','TooltipString','Duration of delay period');
        next_row(y);
        set_callback(Del_time, {mfilename, 'new_CP_duration'});
        NumeditParam(obj, 'Target_PreStim_time', 0.05, x,y,'label','Target PreStim time','TooltipString','Grow the prestim period until it is this much');
        next_row(y);
        NumeditParam(obj, 'PreStim_time', 0.05, x,y,'label','Pre-Stim NIC time','TooltipString','Time in NIC before starting the stimulus');
        next_row(y);
        set_callback(PreStim_time, {mfilename, 'new_CP_duration'});
        NumeditParam(obj, 'Target_time_bet_aud2_gocue', 0.05, x,y,'label','Target_A2-GoCue time','TooltipString','target time between the end of the second stimulus and the go cue ');
        next_row(y);
        NumeditParam(obj, 'time_bet_aud2_gocue', 0.05, x,y,'label','A2-GoCue time','TooltipString','time between the end of the second stimulus and the go cue ');
        next_row(y);
        set_callback(time_bet_aud2_gocue, {mfilename, 'new_CP_duration'});
        NumeditParam(obj, 'warmuptrials', 8, x, y, 'label', 'warmuptrials', 'TooltipString', 'warmup trials to ramp up trial duration');
        next_row(y);
        DispParam(obj, 'init_CP_duration', 0.1, x,y,'label','init_CP duration','TooltipString','Duration of Nose in Central Poke before Go cue starts (see Total_CP_duration)');
    	next_row(y);
        DispParam(obj, 'CP_duration', PreStim_time+A1_time+A2_time+Del_time+time_bet_aud2_gocue, x,y,'label','CP duration','TooltipString','Duration of Nose in Central Poke before Go cue starts (see Total_CP_duration)');
		set_callback(CP_duration, {mfilename, 'new_CP_duration'});
		next_row(y);
		NumeditParam(obj, 'time_go_cue' ,0, x,y,'label','Go Cue Duration','TooltipString','duration of go cue (see Total_CP_duration)');
		set_callback(time_go_cue, {mfilename, 'new_time_go_cue'});
		next_row(y);
		DispParam(obj, 'Total_CP_duration', CP_duration+time_go_cue, x, y, 'TooltipString', 'Total nose in center port time, in secs. Sum of CP_duration and Go Cue duration'); %#ok<*NODEF>
		next_row(y);
        ToggleParam(obj, 'warmup_on', 1, x,y,...
			'OnString', 'Warmup ON',...
			'OffString', 'Warmup OFF',...
			'TooltipString', sprintf(['If on (Yellow) then it applies the initial warming up phase, during which the\n',...
            'CP_duration starts small and gradually grows to last_session_max_cp_duration']));
        next_row(y);
        NumeditParam(obj, 'reward_delay', 0.01, x,y,'label','Reward Delay','TooltipString','Delay between side poke and reward delivery');
		next_row(y);
		NumeditParam(obj, 'reward_duration', 0.1, x,y,'label','Reward Duration','TooltipString','Duration of reward sound');
		next_row(y);
		NumeditParam(obj, 'drink_time', 1, x,y,'label','Drink Time','TooltipString','waits to finish water delivery');
		next_row(y);
		NumeditParam(obj, 'error_iti', 5, x,y,'label','Error Timeout','TooltipString','ITI on error trials');
		next_row(y);
		NumeditParam(obj, 'violation_iti', 1, x,y,'label','Violation Timeout','TooltipString','Center poke violation duration');
        next_row(y);
        MenuParam(obj, 'reward_type', {'Always','DelayedReward', 'NoReward'}, ...
            'Always', x, y, 'labelfraction', 0.35, 'TooltipString', sprintf(['\nThis menu is to determine the Reward delivery on wrong-hit trials\n',...
            '\nIf ''Always'': reward will be available on each trial no matter which side rat goes first\n',...
            '\n If rat pokes first on the wrong side, then reward will be delivered with a delay (if DelayedReward) or not delivered at all (if NoReward)']));
        set_callback(reward_type, {mfilename, 'new_reward_type'});
		next_row(y);
        NumeditParam(obj,'secondhit_delay',0,x,y,'label','SecondHit Delay','TooltipString','Reward will be delayed with this amount if reward_type=DelayedReward');
        DeclareGlobals(obj, 'rw_args', {'reward_type', 'secondhit_delay'});
        
        next_column(x);
		y=5;
		NumeditParam(obj,'trials_in_stage',1,x,y,'label','Trial Counter');
		next_row(y);
		NumeditParam(obj,'training_stage',1,x,y,'label','Training Stage');
		next_row(y);
		ToggleParam(obj,'use_training',0,x,y,'OnString','Using Autotrain','OffString','Manual Settings');
        DeclareGlobals(obj, 'ro_args', {'training_stage'});
        
        next_row(y);
		NumeditParam(obj, 'ntrial_correct_bias', 0, x, y, ...
			'TooltipString', 'antibias starts from trial=ntrial_correct_bias');
		next_row(y);
		NumeditParam(obj, 'right_left_diff', .12, x, y, ...
			'TooltipString', 'antibias applies if difference between right and left sides is bigger than this number');
        next_row(y);
		NumeditParam(obj, 'max_wtr_mult', 4, x, y, ...
			'TooltipString', 'wtr_mult will be min(max_wtr_mult,right_hit/left_hit)');
		next_row(y);
		NumeditParam(obj, 'left_wtr_mult', 1, x, y, ...
			'TooltipString', 'all left reward times are multiplied by this number');
		next_row(y);
		NumeditParam(obj, 'right_wtr_mult', 1, x, y, ...
			'TooltipString', 'all right reward times are multiplied by this number');
		next_row(y);
		ToggleParam(obj, 'antibias_wtr_mult', 0, x,y,...
			'OnString', 'AB ON',...
			'OffString', 'AB OFF',...
			'TooltipString', sprintf(['If on (black) then it disables the wtr_mult entries\n'...
			'and uses hitfrac to adjust the water times']));
		
		next_row(y);
        ToggleParam(obj, 'stimuli_on', 1, x,y,...
			'OnString', 'Stimuli ON',...
			'OffString', 'Stimuli OFF',...
			'TooltipString', sprintf('If on (black) then it disable the presentation of sound stimuli during nose poke'));
        set_callback(stimuli_on, {mfilename, 'new_CP_duration'});

		next_row(y);
		SoloFunctionAddVars('SMASection', 'ro_args', ...
			{'CP_duration';'init_CP_duration';'SideLed_duration';'CenterLed_duration';'side_lights' ; ...
			'RewardCollection_duration';'training_stage';...
			'legal_cbreak' ; 'LED_during_legal_cbreak' ; ...
            'SettlingIn_time';'settling_legal_cbreak' ; 'LED_during_settling_legal_cbreak' ; ...
			'time_go_cue'; ...
            'stimuli_on';'A1_time';'A2_time';'Del_time';'time_bet_aud2_gocue' ; ...
			'PreStim_time';'warmup_on'
			'drink_time';'reward_delay';'reward_duration';'left_wtr_mult';...
			'right_wtr_mult';'antibias_wtr_mult';...
			'reward_type';'secondhit_delay';'error_iti';'violation_iti'});

        SoloFunctionAddVars('StimulusSection', 'ro_args', ...
			{'ThisTrial';'A1_time';'A2_time';'Del_time';'time_bet_aud2_gocue' ; ...
			'PreStim_time'; 'CP_duration'; 'warmuptrials'});

        %   History of hit/miss:
        SoloParamHandle(obj, 'deltaf_history',      'value', []);
      
		SoloFunctionAddVars('OverallPerformanceSection', 'ro_args', ...
			{'training_stage'; 'warmuptrials'});
				
		
		SoloParamHandle(obj, 'previous_parameters', 'value', []);
		
	case 'new_leftprob',
		AntibiasSectionAthena(obj, 'update_biashitfrac', value(LeftProb));
		
		
	case 'new_CP_duration', 
        if stimuli_on == 0
            PreStim_time.value=0;
            A1_time.value=0;
            A2_time.value=0;
            time_bet_aud2_gocue.value=0;
            disable(PreStim_time);
            disable(A1_time);
            disable(A2_time);
            disable(time_bet_aud2_gocue);
        else
            enable(PreStim_time);
            enable(A1_time);
            enable(A2_time);
            enable(time_bet_aud2_gocue);
        end
        CP_duration.value=PreStim_time + A1_time + A2_time + Del_time + time_bet_aud2_gocue;
		Total_CP_duration.value = CP_duration + time_go_cue; %#ok<*NASGU>

	case 'new_time_go_cue',
		Total_CP_duration.value = CP_duration + time_go_cue;
		SoundInterface(obj, 'set', 'GoSound', 'Dur1', value(time_go_cue));
        
    case 'new_reward_type'
        if strcmp(reward_type,'DelayedReward')
            enable(secondhit_delay)
        else
            secondhit_delay=0;
            disable(secondhit_delay)
            
        end
		
        
	case 'prepare_next_trial'
		
		
		switch value(training_stage)
			case 0,                  %% learning the reward sound association -left or right led on -> poke -> sound+reward
				settling_time.value=0.01;
				delay_time.value=0;
				allow_nic_breaks.value=1;
				side_lights.value=3;
				trials_in_stage.value=0;
				reward_delay.value=0.01;
				left_prob.value=0.5;
				right_prob.value=0.5;
				time_go_cue.value=0.200;
				reward_duration=0.200;
				
				
			case 1,                  %%  center led on -> poke in the center -> go cue -> reward light and sound
				settling_time.value=0.25;
				delay_time.value=0;
				allow_nic_breaks.value=1;
				side_lights.value=3;
				training_stage.value=1;
				trials_in_stage.value=0;
				reward_delay.value=0.01;
				left_prob.value=0.5;
				right_prob.value=0.5;
                final = PreStim_time + A1_time + A2_time + Del_time + time_bet_aud2_gocue;
                if n_done_trials < 1 && warmup_on ==1
                    CP_duration.value = value(init_CP_duration);  
                elseif n_done_trials <value(warmuptrials) && warmup_on ==1         
                    CP_duration.value=value(n_done_trials)*(final/value(warmuptrials));
                elseif n_done_trials >= value(warmuptrials);
                    CP_duration.value=PreStim_time + A1_time + A2_time + Del_time + time_bet_aud2_gocue;
                    if value(A1_time)==0
                       if value(CP_duration)> 2.1
                          A1_time.value = 0.4;
                          A2_time.value = 0.4;
                          PreStim_time.value = 0.15;
                          Del_time.value = 1;
                          time_bet_aud2_gocue.value = 0.15;
                       end
                    end
                end
                Total_CP_duration.value = CP_duration + time_go_cue; %#ok<*NASGU>
			case 3, % like stage 2, now passive exposure to the stimuli - reward comes anyway
			case 4 %% now reward comes only if rat goes to the correct side
				
		end
		SoloFunctionAddVars('SMASection', 'ro_args', ...
			{'CP_duration'; 'warmuptrials'});
		

		was_viol=false;
		was_hit=false;
        was_timeout=false;
        was_error=false;
		if n_done_trials>0
			if ~isempty(parsed_events)
				if isfield(parsed_events,'states')
					if isfield(parsed_events.states,'timeout_state')
						was_timeout=rows(parsed_events.states.timeout_state)>0;
                    end
                    if isfield(parsed_events.states,'violation_state')
						was_viol=rows(parsed_events.states.violation_state)>0;
					end
				end
				
			end
			
			violation_history.value=[violation_history(:); was_viol];
			%timeout_history.value=[timeout_history(:); was_timeout];

			SideSection(obj,'update_side_history');
			
			if ~was_viol && ~was_timeout
				%was_hit=rows(parsed_events.states.hit_state)>0;
                was_hit=rows(parsed_events.states.second_hit_state)==0;
				hit_history.value=[hit_history(:); was_hit];
                was_error=rows(parsed_events.states.second_hit_state)==1;
                
                if value(PreStim_time) < value(Target_PreStim_time)
                    PreStim_time.value = value(PreStim_time) + value(Grow_del_by);
                end
                if value(Del_time) < value(Target_Del_time)
                    Del_time.value = value(Del_time) + value(Grow_del_by);
                end
                if value(time_bet_aud2_gocue) < value(Target_time_bet_aud2_gocue)
                    time_bet_aud2_gocue.value = value(time_bet_aud2_gocue) + value(Grow_del_by);
                end
				
			else
				% There was a violation or timeout
				hit_history.value=[hit_history(:); nan];
                error_history.value=[error_history(:); nan];
            end
            
            			
			% Now calculate the deltaF and sides - this maybe interesting
			% even in a violation or timeout case.
			
			fn=fieldnames(parsed_events.states);
			led_states=find(strncmp('led',fn,3));
			deltaF=0;
			n_l=0;
			n_r=0;
			for lx=1:numel(led_states)
				lind=led_states(lx);
				if rows(parsed_events.states.(fn{lind}))>0
					if fn{lind}(end)=='l'
						deltaF=deltaF-1;
						n_l=n_l+1;
					elseif fn{lind}(end)=='r'
						deltaF=deltaF+1;
						n_r=n_r+1;
					elseif fn{lind}(end)=='b'
						n_l=n_l+1;
						n_r=n_r+1;
						
					end
				end
				
			end
			
			% if deltaF>0 then a right poke is a hit
			% if deltaF<0 then a left poke is a hit
			
			deltaf_history.value=[deltaf_history(:); deltaF];
			
        end
        
        if n_done_trials>0;
            was_viol = value(violation_history(n_done_trials));
            was_timeout = value(hit_history(n_done_trials)==0);
        end
        
        if antibias_LRprob ==1
            %if n_done_trials >ntrial_correct_bias && ~was_viol && ~was_timeout
            if n_done_trials > value(ntrial_correct_bias) && was_viol~=1;
            nonan_hit_history=value(hit_history);
            nonan_hit_history(isnan(nonan_hit_history))=[];
            nonan_previous_sides=value(previous_sides);
            nan_history=value(hit_history);
            nonan_previous_sides(isnan(nan_history))=[];
            %AntibiasSectionAthena(obj, 'update', value(LeftProb), nonan_hit_history(:)',nonan_previous_sides(:)); % <~> Transposed hit history so that it is the expected column vector. (Antibias errors out otherwise.) 2007.09.05 01:39
            AntibiasSectionAthena(obj, 'update_biashitfrac', value(LeftProb), nonan_hit_history(:)',nonan_previous_sides(:)); % <~> Transposed hit history so that it is the expected column vector. (Antibias errors out otherwise.) 2007.09.05 01:39
            end
		
		
            if ~isinf(MaxSame) && length(previous_sides) > MaxSame && ...
                    all(previous_sides(n_done_trials-MaxSame+1:n_done_trials) == previous_sides(n_done_trials)), %#ok<NODEF>
                if previous_sides(end)=='l', ThisTrial.value = 'RIGHT';
                else                         ThisTrial.value = 'LEFT';
                end;
            else
                choiceprobs = AntibiasSectionAthena(obj, 'get_posterior_probs');
                if rand(1) <= choiceprobs(1),  ThisTrial.value = 'LEFT';
                else                           ThisTrial.value = 'RIGHT';
                end;
            end;
        
        else
            if (rand(1)<=LeftProb)
                ThisTrial.value='LEFT';
			
            else
                ThisTrial.value='RIGHT';
            end

        end
        
        
		
		
% 		%% Do the anti-bias with changing reward delivery
% 		% reset anti-bias
% 		left_wtr_mult.value=1;
% 		right_wtr_mult.value=1;
% 		if n_done_trials>ntrial_correct_bias && antibias_wtr_mult==1
% 			hh=hit_history(n_done_trials-ntrial_correct_bias:n_done_trials);
% 			ps=previous_sides(n_done_trials-ntrial_correct_bias:n_done_trials);
% 			
% 			right_hit=nanmean(hh(ps=='r'));
% 			left_hit=nanmean(hh(ps=='l'));
% 			
% 			if abs(right_hit-left_hit)<right_left_diff
% 				left_wtr_mult.value=1;
% 				right_wtr_mult.value=1;
% 			else
% 				
% 				left_wtr_mult.value=min(right_hit/left_hit,max_wtr_mult);
% 				right_wtr_mult.value=min(left_hit/right_hit,max_wtr_mult);
% 			end
% 		end
		
		

		
	case 'get_water_mult'
        
        %% Modulating Water Time
%         maxasymp=38;
%         slp=3;
%         inflp=300;
%         minasymp=-20;
%         assym=0.7;
%         left_wtr_mult.value=maxasymp + (minasymp./(1+(n_done_trials/inflp).^slp).^assym);
%         right_wtr_mult.value=maxasymp + (minasymp./(1+(n_done_trials/inflp).^slp).^assym);
		x=left_wtr_mult+0;
		y=right_wtr_mult+0;
		
	case 'get_previous_sides',
		x = value(previous_sides); %#ok<NODEF>
		
	case 'get_left_prob'
		x = value(LeftProb);
		
	case 'get_cp_history'
		x = cell2mat(get_history(CP_duration));
		
	case 'update_side_history'
		if strcmp(ThisTrial, 'LEFT')
			ps=value(previous_sides);
			ps(n_done_trials)='l';
			previous_sides.value=ps;
			
		else
			ps=value(previous_sides);
			ps(n_done_trials)='r';
			previous_sides.value=ps;
		end;
		
	case 'get_current_side'
		if strcmp(ThisTrial, 'LEFT')
			x = 'l'; %#ok<NODEF>
		else
			x = 'r';
		end;
		
		
	case 'close'
		% Delete all SoloParamHandles who belong to this object and whose
		% fullname starts with the name of this mfile:
		delete_sphandle('owner', ['^@' class(obj) '$'], ...
			'fullname', ['^' mfilename]);

	case 'reinit',
		currfig = double(gcf);
		
		% Get the original GUI position and figure:
		x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));
		
		% Delete all SoloParamHandles who belong to this object and whose
		% fullname starts with the name of this mfile:
		delete_sphandle('owner', ['^@' class(obj) '$'], ...
			'fullname', ['^' mfilename]);
		
		% Reinitialise at the original GUI position and figure:
		[x, y] = feval(mfilename, obj, 'init', x, y);
		
		% Restore the current figure:
		figure(currfig);
		
end


