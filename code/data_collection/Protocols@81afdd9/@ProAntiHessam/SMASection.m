function  [varargout] =  SMASection(obj, action)


GetSoloFunctionArgs(obj);


switch action
    
    
    case 'prepare_next_trial',
        %% prepare_next_trial
        sma = StateMachineAssembler('full_trial_structure', 'use_happenings', 1);
        
        min_time= 1E-4;  % This is close to the minumum time allowed for a state transition.
        
        left1led           = bSettings('get', 'DIOLINES', 'left1led');
        center1led         = bSettings('get', 'DIOLINES', 'center1led');
        right1led          = bSettings('get', 'DIOLINES', 'right1led');
        left1water         = bSettings('get', 'DIOLINES', 'left1water');
        right1water        = bSettings('get', 'DIOLINES', 'right1water');
        
        target_side = TrialSection(obj, 'get_side'); %TODO randomize this
        
        %% set up reward quantity and timing
        hit_streak = 3; % TODO: what's this?
        [LeftWValveTime RightWValveTime] = WaterValvesSection(obj, 'get_water_times', hit_streak);
        
        
        warning_sound   = SoundManagerSection(obj, 'get_sound_id', 'WarningSound');
        danger_sound = SoundManagerSection(obj, 'get_sound_id', 'DangerSound');
        
        % TODO Solo parameters
        % TODO start with short fixations
        % TODO blocks
        
        cviolation_time = 0.05;
        cfix_time = TimeVarsSection(obj, 'get_cfix_time');
        fprintf('cfix_time = %.2f\n', value(cfix_time));
        delay_time = 0.1;
        drinking_time = 1;
        
        bad_job_sound_time = 1;
        success_wait_time = 1;
        penalty_wait_time = 5;
        
%         que_time = 0;
%         water_delivery_time = 0;

        if(target_side == 'l')
            wrong_side = 'r';
            target1water = left1water;
            que_time = SoundInterface(obj, 'get', 'LeftClicks', 'Dur1');
            que_sound = SoundManagerSection(obj, 'get_sound_id', 'LeftClicks');
            water_delivery_time = LeftWValveTime;
        elseif(target_side == 'r')
            wrong_side = 'l';
            target1water = right1water;
            que_time = SoundInterface(obj, 'get', 'RightClicks', 'Dur1');
            que_sound = SoundManagerSection(obj, 'get_sound_id', 'RightClicks');
            water_delivery_time = RightWValveTime;
        else
            assert(false);
        end
        
        
        
        sma = add_scheduled_wave(sma, 'name', 'cfix_timer', 'preamble', cfix_time);
        sma = add_scheduled_wave(sma, 'name', 'drink_timer', 'preamble', drinking_time);
        
        max_danger_sound_duration = 5;
        warning_sound_duration = SoundInterface(obj, 'get', 'WarningSound', 'Dur1');
        
        %% clean up sounds
        snd_list=SoundManagerSection(obj, 'get_sound_id','all');
        sma = add_multi_sounds_state(sma, -1*snd_list,'state_name','clean_sound_state','return_state','wait_for_cpoke');
        % TODO make a sound to signal trial start
        sma = add_state(sma, 'name', 'wait_for_cpoke', ...
            'input_to_statechange', {'Chi', 'cfix_pro', 'Lhi', 'current_state+1', 'Rhi', 'current_state+1'});
        
        %TODO: how to say stop playing sounds? say you want to stop playing
        %danger and start playing warning for the next state:
        
        sma = AddGetOutSidepokeState(sma, [warning_sound, danger_sound], [warning_sound_duration, max_danger_sound_duration]);
        
        sma = add_state(sma, 'name', 'cfix_pro', ...
            'output_actions', {'SchedWaveTrig', 'cfix_timer', 'DOut', left1led+right1led}, ...
            'input_to_statechange', {'cfix_timer_In', 'current_state+2', 'Clo', 'current_state+1', ...
                'Lhi', 'double_poke', 'Rhi', 'double_poke'});
        
        sma = AddCfixViolationState(sma, cviolation_time, {'DOut', left1led+right1led}, 'cfix_timer');
        
        sma = add_state(sma, 'name', 'delay_period', ...
            'self_timer', delay_time, ...
            'input_to_statechange', {'Tup', ['play_que_', target_side]});

        sma = add_state(sma, 'name', ['play_que_', target_side], ...
            'output_actions', {'SoundOut', que_sound}, ...
            'input_to_statechange', {[upper(wrong_side), 'hi'], 'wrong_spoke', ...
                                     [upper(target_side), 'hi'], 'correct_spoke'} ...
                                     );
        
        sma = add_state(sma, 'name', 'correct_spoke', ...
            'self_timer', min_time, ...
            'input_to_statechange', {'Tup', ['deliver_water_', target_side], ...
                                     [upper(wrong_side), 'hi'], 'double_poke', ...
                                     'Chi', 'double_poke'});
                                 
        sma = add_state(sma, 'name', ['deliver_water_', target_side], ...
            'self_timer', water_delivery_time, ...
            'output_actions', {'DOut', target1water}, ...
            'input_to_statechange', {'Tup', ['start_drinking_time_', target_side], ...
                                     [upper(wrong_side), 'hi'], 'double_poke', ...
                                     'Chi', 'double_poke'});
        
        
        sma = add_state(sma, 'name', ['start_drinking_time_', target_side], ...
            'self_timer', min_time, ...
            'output_actions', {'SchedWaveTrig', 'drink_timer'}, ...
            'input_to_statechange', {'Tup', ['is_drinking_', target_side]});
        
        
        sma = add_state(sma, 'name', ['is_drinking_', target_side], ...
            'input_to_statechange', {[upper(target_side), 'lo'], ['done_drinking_', target_side], ...
                                     'drink_timer_In', 'drinking_timeover', ...
                                     [upper(wrong_side), 'hi'], 'double_poke', ...
                                     'Chi', 'double_poke'});
                                 
        sma = add_state(sma, 'name', ['done_drinking_', target_side], ...
            'input_to_statechange', {[upper(target_side), 'hi'], ['is_drinking_', target_side], ...
                                     'drink_timer_In', 'drinking_timeover', ...
                                     [upper(wrong_side), 'hi'], 'wrong_spoke'});
                                 
        sma = add_state(sma, 'name', 'drinking_timeover', ...
            'self_timer', success_wait_time, ...
            'input_to_statechange', {'Lhi', 'current_state+1', 'Rhi', 'current_state+1', 'Tup', 'end_trial'});
        
        sma = AddGetOutSidepokeState(sma, [warning_sound, danger_sound], [warning_sound_duration, max_danger_sound_duration]);
                
        
        sma = add_multi_sounds_state(sma, -1*snd_list,'state_name','wrong_spoke','return_state', 'wrong_spoke_post');
        
        sma = add_state(sma, 'name', 'wrong_spoke_post', ...
            'self_timer', bad_job_sound_time, ...
            'output_actions', {'SoundOut', danger_sound}, ...
            'input_to_statechange', {'Tup', 'penalty_wait'}); 
        
        sma = add_multi_sounds_state(sma, -1*snd_list,'state_name','double_poke','return_state', 'double_poke_post');

        sma = add_state(sma, 'name', 'double_poke_post', 'self_timer', max_danger_sound_duration, ...
            'output_actions', {'SoundOut', danger_sound}, ...
            'input_to_statechange', {'Lout', 'penalty_wait', 'Rout', 'penalty_wait', 'Cout', 'penalty_wait', 'Tup', 'penalty_wait'});
        
        sma = add_multi_sounds_state(sma, -1*snd_list,'state_name','penalty_wait','return_state','penalty_wait_post');
        
        sma = add_state(sma, 'name', 'penalty_wait_post', ...
            'self_timer', penalty_wait_time, ...
            'input_to_statechange', {'Tup', 'end_trial'});
        
        sma = add_multi_sounds_state(sma, -1*snd_list,'state_name','cbreak','return_state','cbreak_post');        
        
        sma = add_state(sma, 'name', 'cbreak_post', ...
            'self_timer', bad_job_sound_time, ...
            'output_actions', {'SoundOut', danger_sound}, ...
            'input_to_statechange', {'Tup', 'end_trial'});
        
        sma = add_multi_sounds_state(sma, -1*snd_list,'state_name','end_trial','return_state','check_next_trial_ready');
        
        prepare_next_trial_states = {'end_trial'};
        
        dispatcher('send_assembler', sma, prepare_next_trial_states);
        
        
    
    case 'state_colors'
        %% case state_colors
        varargout{1} = struct( ...
            'wait_for_cpoke',           [0 0 0]/255, ...
            'cfix_pro',          [140 140 140]/255, ...
            'play_que_l',           [150 150 30]/255, ...
            'play_que_r',           [150 30 150]/255, ...
            'deliver_water_l',          [70 230 70]/255, ...
            'deliver_water_r',          [70 70 230]/255, ...
            'is_drinking_l',            [0 255 0]/255, ...
            'is_drinking_r',            [0 0 255]/255, ...
            'done_drinking_l',          [.5 .9 .9], ...
            'done_drinking_r',          [.5 .9 .9], ...
            'drinking_timeover',        [0 0 0]/255, ...
            'double_poke',              [255 0 0]/255, ...
            'double_poke_post',         [255 0 0]/255, ...
            'wrong_spoke',              [255 0 0]/255, ...
            'wrong_spoke_post',         [255 0 0]/255, ...
            'penalty_wait',             [240 140 140]/255, ...
            'penalty_wait_post',        [240 140 140]/255, ...
            'cbreak',                   [255 0 0]/255, ...
            'cbreak_post',              [255 0 0]/255);
        
    case 'poke_colors'
        %% case poke_colors;
        varargout{1} = struct( ...
            'L',                  [1 1 1 ],    ...
            'C',                  [1 1 1],       ...
            'R',                  [1 1 1]);
        
    otherwise
        disp('SMASection ERROR: unknown case');
        
end

end

function [sma] = AddGetOutSidepokeState(sma, sounds, durations)

assert(all(size(sounds) == size(durations)));

for i = 1:numel(sounds)
    home = sprintf('current_state+%d', numel(sounds)+1-i);
    
    if(i == numel(sounds))
        next = 'penalty_wait';
    else
        next = 'current_state+1';
    end
    
    sma = add_state(sma, ...
        'self_timer', durations(i), ...
        'output_actions', {'SoundOut', sounds(i)}, ...
        'input_to_statechange', {'Lout', home, 'Rout', home, 'Tup', next, 'Cin', 'double_poke'});
end

sma = add_multi_sounds_state(sma, -1*sounds,'return_state', sprintf('current_state-%d', numel(sounds)*2));

end

function [sma] = AddCfixViolationState(sma, cviolation_time, output_actions, timer)

sma = add_state(sma, ...
    'self_timer', cviolation_time, ...
    'output_actions', output_actions, ...
    'input_to_statechange', {[timer,'_In'], 'current_state+1', 'Chi', 'current_state-1', 'Tup', 'cbreak'});

end
