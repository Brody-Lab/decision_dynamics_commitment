% @DynamicForaging/SmaSection
% KJM 6/2012

% [x, y] = StateMatrixSection(obj, action, x, y)
%
% HELP HERE
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%            'init'         To initialise the section
%
%            'next_trial'   To set up the state matrix for the next trial
%
%            'reinit'       Delete all of this section's GUIs and data,
%                           and reinit, at the same position on the same
%                           figure as the original section GUI was placed.
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


function  [] =  SmaSection(obj, action)

GetSoloFunctionArgs;


switch action
    case 'init',
        
        feval(mfilename, obj, 'next_trial');
        
        %% next_trial
    case 'next_trial',
        
        sma = StateMachineAssembler('full_trial_structure', 'use_happenings', 1);
        min_time= 2.5E-4;  % This is less than the minumum time allowed for a state transition.
        
        left1led           = bSettings('get', 'DIOLINES', 'left1led');
        center1led         = bSettings('get', 'DIOLINES', 'center1led');
        right1led          = bSettings('get', 'DIOLINES', 'right1led');
        left1water         = bSettings('get', 'DIOLINES', 'left1water');
        right1water        = bSettings('get', 'DIOLINES', 'right1water');
        
        baiting = BanditsSection(obj,'get_baiting');
        timing = ParamsSection(obj,'get_timing');
        
        [LeftWValveTime RightWValveTime] = WaterValvesSection(obj, 'get_water_times');
        
        LeftWValveTime = LeftWValveTime * baiting.left_wtr_mult;
        RightWValveTime = RightWValveTime * baiting.right_wtr_mult;
        
        if baiting.context
            context_sound = 'Context2';
        else
            context_sound = 'Context1';
        end
        
        
        %% Initial states
        center_light_behavior = ParamsSection(obj,'get_center_led');
        switch value(center_light_behavior),
            case 'off',
                pre_cpoke_led = 0;
                cpoke_led= 0;
                
            case 'on',
                pre_cpoke_led = center1led;
                cpoke_led= center1led;
                
            case 'off_at_cpoke',
                pre_cpoke_led = center1led;
                cpoke_led = 0;
                
            case 'on_at_cpoke',
                pre_cpoke_led = 0;
                cpoke_led = center1led;
        end
        
        
        sma = add_state(sma,'name','state_zero','self_timer',min_time,'input_to_statechange',{'Tup','trial_ready'});
        
        if timing.sound_timing % Sound starts on poke, don't start it yet
            sma = add_state(sma,'name','trial_ready','output_actions', {'DOut', pre_cpoke_led},'input_to_statechange',{'Chi','nose_in_center'});
        else % Sound starts at the beginning of the trial, start it now
            sma = add_state(sma,'name','trial_ready','output_actions', {'DOut', pre_cpoke_led,'SoundOut', SoundManagerSection(obj, 'get_sound_id', context_sound)},'input_to_statechange',{'Chi','nose_in_center'});
        end
        
        %% Nose-in-center states
        
        sma = add_scheduled_wave(sma, 'name', 'nic_timer',  'preamble', timing.nose_in_center);
        
        if timing.sound_timing % sound starts on poke,
            sma = add_state(sma,'name','nose_in_center','output_actions',{'DOut',cpoke_led,'SchedWaveTrig','nic_timer','SoundOut', SoundManagerSection(obj, 'get_sound_id', context_sound)},'input_to_statechange',{'nic_timer_In','choice_state','Cout','legal_cbreak_state','Rhi','early_sidepokes_penalty','Lhi','early_sidepokes_penalty'});
        else
            sma = add_state(sma,'name','nose_in_center','output_actions',{'DOut',cpoke_led,'SchedWaveTrig','nic_timer'},'input_to_statechange',{'nic_timer_In','choice_state','Cout','legal_cbreak_state','Rhi','early_sidepokes_penalty','Lhi','early_sidepokes_penalty'});
        end
        
        sma = add_state(sma,'name','legal_cbreak_state','self_timer',timing.legal_cbreak,'output_actions',{'DOut',cpoke_led},'input_to_statechange',{'Cin','nose_in_center','nic_timer_In','choice_state','Tup','cpoke_violation'});
        
        sma = add_state(sma,'name','cpoke_violation','self_timer',timing.cpoke_violation_timeout,'output_actions',{'SchedWaveTrig','-nic_timer'},'input_to_statechange',{'Tup','trial_ready'});
        
        % Early sidepokes penalty states
        sma = PunishInterface(obj, 'add_sma_states', 'early_sidepokes_penalty', sma, 'exitstate', 'trial_ready');
        
        %% Choice States
        

        % Choose which states to use based on the trial type
        switch baiting.trial_type
            case 'Free Trial'
                choice_leds = left1led+right1led;
                if baiting.left_baited
                    left_state = 'left_reward_state';
                else
                    if ~timing.forgiveness
                        left_state = 'left_unreward_state';
                    else
                        left_state = 'forgiveness_delay_right';
                    end
                end
                
                if baiting.right_baited
                    right_state = 'right_reward_state';
                else
                    if ~timing.forgiveness
                        right_state = 'right_unreward_state';
                    else
                        right_state = 'forgiveness_delay_left';
                    end
                end
                
            case 'Forced: Right'
                choice_leds = right1led;
                if baiting.right_baited
                    right_state = 'right_reward_state';
                else
                    right_state = 'right_unreward_state';
                end
                left_state = 'violation_penalty';
                
            case 'Forced: Left'
                choice_leds = left1led;
                if baiting.left_baited
                    left_state = 'left_reward_state';
                else
                    left_state = 'left_unreward_state';
                end
                right_state = 'violation_penalty';
        end
        
        sma = add_state(sma,'name','choice_state','output_actions',{'DOut',choice_leds},'input_to_statechange',{'Lhi',left_state,'Rhi',right_state});
        
        %% Post-choice states: reward, unreward, and violation
        
        sma = add_scheduled_wave(sma,'name','left_reward_wav','preamble',timing.reward_delay,'sustain',LeftWValveTime,'DOut',left1water,'refraction',timing.drink_time);
        sma = add_scheduled_wave(sma,'name','right_reward_wav','preamble',timing.reward_delay,'sustain',RightWValveTime,'DOut',right1water,'refraction',timing.drink_time);
        sma = add_scheduled_wave(sma,'name','drink_timer','preamble',timing.drink_time);
        
        if timing.softdrink_enabled
            left_noseout_state = 'left_softdrink_state';
            right_noseout_state = 'right_softdrink_state';
        else
            left_noseout_state = 'left_reward_state';
            right_noseout_state = 'right_reward_state';
        end
        
        if timing.unreward_punish
            post_unreward_state = 'unreward_penalty';
        else
            post_unreward_state = 'sound_off';
        end
        
        % Forgiveness states
%         sma = add_state(sma,'name','forgiveness_wait_for_left','self_timer',timing.forgiveness_available,'input_to_statechange',{'Lhi','forgiveness_delay_left','Tup','sound_off'});
%         sma = add_state(sma,'name','forgiveness_wait_for_right','self_timer',timing.forgiveness_available,'input_to_statechange',{'Rhi','forgiveness_delay_right','Tup','sound_off'});
        
        sma = add_state(sma,'name','forgiveness_delay_left','self_timer',timing.forgiveness_delay,'input_to_statechange',{'Tup','forgiveness_left'});
        sma = add_state(sma,'name','forgiveness_delay_right','self_timer',timing.forgiveness_delay,'input_to_statechange',{'Tup','forgiveness_right'});
        
        sma = add_state(sma,'name','forgiveness_left','self_timer',timing.forgiveness_delay,'input_to_statechange',{'Lhi','left_reward_state','Tup','sound_off'});
        sma = add_state(sma,'name','forgiveness_right','self_timer',timing.forgiveness_delay,'input_to_statechange',{'Rhi','right_reward_state','Tup','sound_off'});
        
        
        % Reward states, including soft-drink
        sma = add_state(sma,'name','left_reward_state','output_actions',{'SchedWaveTrig','left_reward_wav+drink_timer'},'input_to_statechange',{'Llo',left_noseout_state,'drink_timer_In','sound_off'});
        sma = add_state(sma,'name','right_reward_state','output_actions',{'SchedWaveTrig','right_reward_wav+drink_timer'},'input_to_statechange',{'Rlo',right_noseout_state,'drink_timer_In','sound_off'});
        
        sma = add_state(sma,'name','left_softdrink_state','self_timer',timing.softdrink_time,'input_to_statechange',{'Tup','sound_off','Lhi','left_reward_state','drink_timer_In','sound_off'});
        sma = add_state(sma,'name','right_softdrink_state','self_timer',timing.softdrink_time,'input_to_statechange',{'Tup','sound_off','Rhi','right_reward_state','drink_timer_In','sound_off'});
        
        % Unrewarded states
        sma = add_state(sma,'name','left_unreward_state','self_timer',timing.unreward_time,'input_to_statechange',{'Tup',post_unreward_state});
        sma = add_state(sma,'name','right_unreward_state','self_timer',timing.unreward_time,'input_to_statechange',{'Tup',post_unreward_state});
        sma = PunishInterface(obj,'add_sma_states','unreward_penalty',sma,'exitstate','sound_off');
        
        % Violation states
        sma = PunishInterface(obj, 'add_sma_states', 'violation_penalty', sma, 'exitstate', 'sound_off');
        
        
        %% Cleanup States
        sma = add_state(sma,'name','sound_off','self_timer',min_time,'output_actions',{'SoundOut', -SoundManagerSection(obj, 'get_sound_id', context_sound)},'input_to_statechange',{'Tup','wd'});
        sma = WarnDangerInterface(obj,'add_sma_states','wd',sma,'exitstate','cleanup_state','on_poke_when_danger_state','dangerpokes_penalty');
        
        %sma = add_state(sma,'name','warning_state','self_timer',warn_time,'input_to_statechange',{'Tup',post_warning_state},'output_actions',{'SoundOut', -SoundManagerSection(obj, 'get_sound_id', context_sound)});
        %sma = add_state(sma,'name','danger_state','self_timer',danger_time,'input_to_statechange',{'Tup','cleanup_state','Lhi','dangerpokes_penalty','Rhi','dangerpokes_penalty'},'output_actions',{'SoundOut', -SoundManagerSection(obj, 'get_sound_id', context_sound)});
        sma = PunishInterface(obj, 'add_sma_states', 'dangerpokes_penalty', sma, 'exitstate', 'wd');
        
        
    sma = add_state(sma, 'name', 'cleanup_state', 'self_timer', min_time, 'input_to_statechange', {'Tup', 'check_next_trial_ready'});
    dispatcher('send_assembler', sma, {'check_next_trial_ready','trial_ready'});

        
       
             
        
        %% reinit
    case 'reinit',
        
        % Delete all SoloParamHandles who belong to this object and whose
        % fullname starts with the name of this mfile:
        delete_sphandle('owner', ['^@' class(obj) '$'], ...
            'fullname', ['^' mfilename]);
        
        % Reinitialise at the original GUI position and figure:
        feval(mfilename, obj, 'init');
        
end;