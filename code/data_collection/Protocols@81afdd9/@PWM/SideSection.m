% Typical section code-- this file may be used as a template to be added 
% on to. The code below stores the current figure and initial position when
% the action is 'init'; and, upon 'reinit', deletes all SoloParamHandles 
% belonging to this section, then calls 'init' at the proper GUI position 
% again.


% [x, y] = YOUR_SECTION_NAME(obj, action, x, y)
%
% Section that takes care of YOUR HELP DESCRIPTION
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%            'init'      To initialise the section and set up the GUI
%                        for it
%
%            'reinit'    Delete all of this section's GUIs and data,
%                        and reinit, at the same position on the same
%                        figure as the original section GUI was placed.
%
% x, y     Relevant to action = 'init'; they indicate the initial
%          position to place the GUI at, in the current figure window
%
% RETURNS:
% --------
%
% [x, y]   When action == 'init', returns x and y, pixel positions on
%          the current figure, updated after placing of this section's GUI. 
%


function [x, y] = SideSection(obj, action, x,y)

GetSoloFunctionArgs(obj);

switch action,
    
    %---------------------------------------------------------------%
    %          init                                                 %
    %---------------------------------------------------------------%
    case 'init'
   
        SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)], 'saveable', 0);
        y0 = y;
 
        [x, y] = AntibiasSectionPWM(obj,     'init', x, y);
               
        % add AB on/off button to PWM window
        ToggleParam(obj, 'antibias_LRprob', 1, x,y,...
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
            'next trial is guaranteed to be Right'])); 
        next_row(y);

        DispParam(obj, 'ThisTrial', 'LEFT', x, y); 
        next_row(y,2);
        SoloParamHandle(obj, 'previous_sides', 'value', []);
        DeclareGlobals(obj, 'ro_args', 'previous_sides');
        
        
        next_column(x);
        y=5;
        NumeditParam(obj, 'RewardCollection_duration', 10, x,y,'label','RewardCollection_duration','TooltipString','Wait until rat collects the reward');
        next_row(y);
        NumeditParam(obj, 'CenterLed_duration', 120000, x,y,'label','Central LED duration','TooltipString','Duration of Center Led');
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
  
        % TODO change NumeditParam here to DispParam, then make PWMsection generate
        % AUD1_time, Del_time and set callbacks
        NumeditParam(obj, 'AUD1_time', 0.4, x,y,'label','AUD1 on Time','TooltipString','Duration of first stimulus');
        next_row(y);
        set_callback(AUD1_time, {mfilename, 'new_CP_duration'});
        NumeditParam(obj, 'AUD2_time', 0.4, x,y,'label','AUD2 On Time','TooltipString','Duration of second stimulus');
        next_row(y);
        set_callback(AUD2_time, {mfilename, 'new_CP_duration'});
        NumeditParam(obj, 'target_aud_duration', 0.4, x,y,'label','target AUD','TooltipString','Training: target time for both AUD on cues');
        next_row(y);        
        NumeditParam(obj, 'Del_time', 1, x,y,'label','Delay Duration Time','TooltipString','Duration of delay period');
        next_row(y);
        set_callback(Del_time, {mfilename, 'new_CP_duration'});
        NumeditParam(obj, 'target_del_time', 1, x,y,'label','target delay','TooltipString','Training: target delay duration time');
        next_row(y);
        NumeditParam(obj, 'PreStim_time', 0.05, x,y,'label','Pre-Stim NIC time','TooltipString','Time in NIC before starting the stimulus');
        next_row(y);
        set_callback(PreStim_time, {mfilename, 'new_CP_duration'});
        NumeditParam(obj, 'time_bet_AUD2_gocue', 0.05, x,y,'label','AUD2-GoCue time','TooltipString','time between the end of the second stimulus and the go cue ');
        next_row(y);
        set_callback(time_bet_AUD2_gocue, {mfilename, 'new_CP_duration'});
        DispParam(obj, 'init_CP_duration', 0.01, x,y,'label','init_CP duration','TooltipString','Duration of Nose in Central Poke before Go cue starts (see Total_CP_duration)');
        next_row(y);
        DispParam(obj, 'CP_duration', PreStim_time+AUD1_time+AUD2_time+Del_time+time_bet_AUD2_gocue, x,y,'label','CP duration','TooltipString','Duration of Nose in Central Poke before Go cue starts (see Total_CP_duration)');
        set_callback(CP_duration, {mfilename, 'new_CP_duration'});
        next_row(y);
        NumeditParam(obj, 'time_go_cue' ,0.2, x,y,'label','Go Cue Duration','TooltipString','duration of go cue (see Total_CP_duration)');
        set_callback(time_go_cue, {mfilename, 'new_time_go_cue'});
        next_row(y);        
        NumeditParam(obj, 'target_go_cue_duration', 0.2, x,y,'label','target GO','TooltipString','For training: target length of the go cue');
        next_row(y);
        NumeditParam(obj, 'max_total_cp',5.5,x,y,'label','goal fixation','TooltipString','For training: target fixation length');
            next_row(y);
        next_column(x);
        y=5;
        DispParam(obj, 'Total_CP_duration', CP_duration+time_go_cue, x, y, 'TooltipString', 'Total nose in center port time, in secs. Sum of CP_duration and Go Cue duration'); %#ok<*NODEF>
        SubheaderParam(obj, 'title', 'SideSection', x, y);
        next_row(y, 1.5);
        NumeditParam(obj, 'reward_delay', 0.01, x,y,'label','Reward Delay','TooltipString','Delay between side poke and reward delivery');
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
        next_row(y);
        
        ToggleParam(obj, 'warmup_on', 0, x,y,...
            'OnString', 'Warmup ON',...
            'OffString', 'Warmup OFF',...
            'TooltipString', sprintf(['If on, CP_duration starts small and gradually grows to last_session_max_cp_duration']));
        next_row(y);
        
        NumeditParam(obj, 'cp_minimum_increment', 0.001, x, y, ...
            'TooltipString', 'minimum cp increment');
        next_row(y);
        NumeditParam(obj, 'cp_fraction', 0.001, x, y, ...
            'TooltipString', 'fraction for cp increment');
        next_row(y);
        
        NumeditParam(obj, 'cp_duration_threshold_for_initial_trials', 0.2, x, y, ...
            'TooltipString', 'warmup minimum');
        next_row(y);
        NumeditParam(obj, 'n_initial_trials', 20, x, y, ...
            'TooltipString', 'length of warmup');
        next_row(y);
        NumeditParam(obj, 'last_session_aud_time', 0.03, x, y, ...
            'TooltipString', 'auditory duration from yesterday to warm up to');
        next_row(y);
        NumeditParam(obj, 'starting_aud_time', 0.03, x, y, ...
            'TooltipString', 'starting auditory duration for warm up');
        next_row(y);
        NumeditParam(obj, 'aud_increment', 0.002, x, y, ...
            'TooltipString', 'increment used for sound growth');
        next_row(y);
        NumeditParam(obj, 'last_session_del_time', 0.1, x, y, ...
            'TooltipString', 'del duration from yesterday to warm up to');
        next_row(y);
        NumeditParam(obj, 'starting_del_time', 0.1, x, y, ...
            'TooltipString', 'starting delay duration for warm up');
        next_row(y);
        NumeditParam(obj, 'starting_total_cp', 0.01, x, y, ...
            'TooltipString', 'starting poke length');
        next_row(y);
        NumeditParam(obj, 'start_settling_in_at', 1000, x, y, ...
            'TooltipString', 'how long until settling in');
        next_row(y);
        NumeditParam(obj, 'settling_in_time', 0, x, y, ...
            'TooltipString', 'how long is settling in');
        next_row(y);
        NumeditParam(obj, 'settling_in_legal_cbreak', 0.1, x, y, ...
            'TooltipString', '0.1');
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
        ToggleParam(obj, 'imaging', 0, x,y,...
            'OnString', 'cScope ON',...
            'OffString', 'cScope OFF',...
            'TooltipString', sprintf(['If ON - syncs with cScope imaging']));
        next_row(y);
        ToggleParam(obj, 'stimuli_on', 1, x,y,...
            'OnString', 'Stimuli ON',...
            'OffString', 'Stimuli OFF',...
            'TooltipString', sprintf('If on (black) then it disable the presentation of sound stimuli during nose poke'));
        set_callback(stimuli_on, {mfilename, 'new_CP_duration'});

        next_row(y);

        SoloFunctionAddVars('SoundSection','ro_args', 'time_go_cue');
        
        SoloFunctionAddVars('PWMsma', 'ro_args', ...
            {'CP_duration';'SideLed_duration';'CenterLed_duration';'side_lights' ; ...
            'RewardCollection_duration'; ...
            'legal_cbreak' ; 'LED_during_legal_cbreak' ; ...
            'SettlingIn_time';'settling_legal_cbreak' ; 'LED_during_settling_legal_cbreak' ; ...
            'time_go_cue'; ...
            'stimuli_on';'AUD1_time';'AUD2_time';'Del_time';'time_bet_AUD2_gocue' ; ...
            'PreStim_time';'warmup_on'
            'drink_time';'reward_delay';...
            % 'left_wtr_mult';'right_wtr_mult';'antibias_wtr_mult';...
            'reward_type';'secondhit_delay';'error_iti';'violation_iti';'imaging'});
            
        SoloFunctionAddVars('PWMSection', 'ro_args', ...
            {'ThisTrial';'AUD1_time';'AUD2_time';'Del_time';'time_bet_AUD2_gocue' ; ...
            'stimuli_on';'PreStim_time'});
        
        SoloFunctionAddVars('SoundSection','ro_args',...
        {'time_go_cue';'AUD1_time';'AUD2_time';'stimuli_on'})

        % SoloFunctionAddVars('StimulatorSection', 'ro_args', ...
        %   {'AUD1_time';'AUD2_time';'Del_time';'time_bet_AUD2_gocue';'time_go_cue'; ...
        %   'PreStim_time';'CP_duration';'Total_CP_duration'});
        
        %   History of hit/miss:
        SoloParamHandle(obj, 'deltaf_history',      'value', []);
      
        % SoloFunctionAddVars('OverallPerformanceSection', 'ro_args', ...
        %     {'stimuli_on'});
        SoloFunctionAddVars('RewardsSection', 'ro_args', ...
            {'stimuli_on','ThisTrial'});
        
                SoloFunctionAddVars('AdLibGUISection', 'ro_args', ...
            {'stimuli_on','ThisTrial'});
        SoloParamHandle(obj, 'previous_parameters', 'value', []);
        

    %---------------------------------------------------------------%
    %          new_leftprob                                         %
    %---------------------------------------------------------------%
    case 'new_leftprob',
        AntibiasSectionPWM(obj, 'update_biashitfrac', value(LeftProb));
        

    %---------------------------------------------------------------%
    %          new_CP_duration                                      %
    %---------------------------------------------------------------%
    case 'new_CP_duration', 
        % TODO change this to actually call PWMSection/PWMSection new_duration
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

    %---------------------------------------------------------------%
    %          new_time_go_cue                                      %
    %---------------------------------------------------------------%
    case 'new_time_go_cue',
        Total_CP_duration.value = CP_duration + time_go_cue;
        SoundInterface(obj, 'set', 'GoSound', 'Dur1', value(time_go_cue));

    %---------------------------------------------------------------%
    %          new_reward_type                                      %
    %---------------------------------------------------------------%
    case 'new_reward_type'
        if strcmp(reward_type,'DelayedReward')
            enable(secondhit_delay)
        else
            secondhit_delay=0;
            disable(secondhit_delay)
        end
        
    %---------------------------------------------------------------%
    %          prepare_next_trial                                   %
    %---------------------------------------------------------------%
    case 'prepare_next_trial'   

% if I want to add randomness into the trials, good to do that by setting a seed. Marino uses a rand value generated in his main file
%  if rand(1)<value(LightProb); ThisTrial_Stim.value = 'LIGHT'; else ThisTrial_Stim.value = 'SOUND'; end
%     if rand(1)<value(MemProb);   ThisTrial_Mem.value  = 'MEM';   else ThisTrial_Mem.value  = 'NoMEM'; end
%     if rand(1)<value(FreeProb);  ThisTrial_Free.value = 'FREE';  else ThisTrial_Free.value = 'REG';   end 
        
        % update hit_history, previous_sides, etc
        was_viol=false;
        was_hit=false;
        was_timeout=false;
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
            timeout_history.value=[timeout_history(:); was_timeout];
            SideSection(obj,'update_side_history');
            
            
            if ~was_viol && ~was_timeout
                if strcmp(RewardFromPoke, 'cpoke');
                    was_hit=rows(parsed_events.states.second_hit_state)==0;
                    hit_history.value=[hit_history(:); was_hit];
                else
                was_hit=rows(parsed_events.states.hit_state)>0;
                hit_history.value=[hit_history(:); was_hit];
                end
                
            else
                % There was a violation or timeout
                hit_history.value=[hit_history(:); nan];
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
        
        if value(antibias_LRprob) ==1
            if n_done_trials >ntrial_correct_bias && ~was_viol
                nonan_hit_history=value(hit_history);
                nonan_hit_history(isnan(nonan_hit_history))=[];
                nonan_previous_sides=value(previous_sides);
                nan_history=value(hit_history);
                nonan_previous_sides(isnan(nan_history))=[];
                AntibiasSectionPWM(obj, 'update', value(LeftProb), nonan_hit_history(:)',nonan_previous_sides(:));
            end
        
            if ~isinf(MaxSame) && length(previous_sides) > MaxSame && ...
                    all(previous_sides(n_done_trials-MaxSame+1:n_done_trials) == previous_sides(n_done_trials)), %#ok<NODEF>
                if previous_sides(end)=='l', ThisTrial.value = 'RIGHT';
                else                         ThisTrial.value = 'LEFT';
                end;
            else
                choiceprobs = AntibiasSectionPWM(obj, 'get_posterior_probs');
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
       
        
    %---------------------------------------------------------------%
    %          get_water_mult                                       %
    %---------------------------------------------------------------%
    case 'get_water_mult'
        % Modulating Water Time       
        x=left_wtr_mult+0;
        y=right_wtr_mult+0;

    %---------------------------------------------------------------%
    %          get_previous_sides                                   %
    %---------------------------------------------------------------%
    case 'get_previous_sides',
        x = value(previous_sides); %#ok<NODEF>

    %---------------------------------------------------------------%
    %          get_left_prob                                        %
    %---------------------------------------------------------------%
    case 'get_left_prob'
        x = value(LeftProb);

    %---------------------------------------------------------------%
    %          get_cp_history                                       %
    %---------------------------------------------------------------%
    case 'get_cp_history'
        x = cell2mat(get_history(CP_duration));

    %---------------------------------------------------------------%
    %          get_stimdur_history                                  %
    %---------------------------------------------------------------%
    case 'get_stimdur_history'
        x = cell2mat(get_history(AUD1_time));
        y = cell2mat(get_history(AUD2_time));

    %---------------------------------------------------------------%
    %          update_side_history                                  %
    %---------------------------------------------------------------%
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

    %---------------------------------------------------------------%
    %          get_current_side                                     %
    %---------------------------------------------------------------%
    case 'get_current_side'
        if strcmp(ThisTrial, 'LEFT')
            x = 'l'; %#ok<NODEF>
        else
            x = 'r';
        end;
        
    %---------------------------------------------------------------%
    %          get_sidelights                                       %
    %---------------------------------------------------------------%
    case 'get_sidelights'
        
        if nargout>0
            x=[value(side_lights)];
        end
        
    %---------------------------------------------------------------%
    %          get_sidelights                                       %
    %---------------------------------------------------------------%
    case 'get_warmup'
        if nargout>0
            x=[value(warmup_on)];
        end
        
    %---------------------------------------------------------------%
    %          get_reward                                           %
    %---------------------------------------------------------------%
    case 'get_reward'
        if nargout >0 
            x=[value(reward_type)];
        end

        
    %---------------------------------------------------------------%
    %          close                                                %
    %---------------------------------------------------------------%
    case 'close'
        % Delete all SoloParamHandles who belong to this object and whose
        % fullname starts with the name of this mfile:
        delete_sphandle('owner', ['^@' class(obj) '$'], ...
            'fullname', ['^' mfilename]);


    %---------------------------------------------------------------%
    %          reinit                                               %
    %---------------------------------------------------------------%
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


