% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%
%            'prepare_next_trial'   Returns a @StateMachineAssembler
%                        object, ready to be sent to dispatcher, and a cell
%                        of strings containing the 'prepare_next_trial'
%                        states.
%
%            'get_state_colors'     Returns a structure where each
%                        fieldname is a state name, and each field content
%                        is a color for that state.
%
%
% RETURNS:
% --------
%
% [sma, prepstates]      When action == 'prepare_next_trial', sma is a
%                        @StateMachineAssembler object, ready to be sent to
%                        dispatcher, and prepstates is a a cell
%                        of strings containing the 'prepare_next_trial'
%                        states.
%
% state_colors           When action == 'get_state_colors', state_colors is
%                        a structure where each fieldname is a state name,
%                        and each field content is a color for that state.
%
%
%
%
%
function [varargout] = SMASection(obj, action)

GetSoloFunctionArgs(obj);

switch action
    
    %% prepare_next_trial
    % -----------------------------------------------------------------------
    %
    %         PREPARE_NEXT_TRIAL
    %
    % -----------------------------------------------------------------------
    
    case 'prepare_next_trial'
        
        nTrials.value = n_done_trials;
        
        % <~> If we've completed our trial, tell RunRats that we're done.
        if nTrials.value > 0 && runrats('is_running')
            runrats('rigtest_singletrial_is_complete');
            return;
        end
        
        allinput = bSettings('get','INPUTLINES','ALL');
        inputnames = repmat('a',1,length(allinput));
        for i = 1:length(allinput)
            inputnames(i) = allinput{i,1};
        end
        
        xled = bSettings('get','DIOLINES','xled');
        cled = bSettings('get','DIOLINES','center1led');
        
        ac_trial = value(solo_ac_trial);
        vr = value(solo_vr);
        if ac_trial.trialType == Choice.R
            right_answer = 'right_correct';
            left_answer = 'left_wrong';
        else
            right_answer = 'right_wrong';
            left_answer = 'left_correct';
        end
        
        %snd_low = SoundManagerSection(obj,'get_sound_id','snd_low');
        %snd_high = SoundManagerSection(obj,'get_sound_id','snd_high');
        sma = StateMachineAssembler('full_trial_structure',...
            'use_happenings',1, ...
            'n_input_lines',numel(inputnames),'line_names',inputnames);
               

        sma = add_state(sma, 'name', 'wait1', 'self_timer',0.1, ...
            'output_actions', {'DOut', xled+cled}, ...
            'input_to_statechange', { 'Tup', 'in_start' });
        
       sma = add_state(sma, 'name', 'in_start', ...
            'output_actions', {'PCLink1Out', 1}, ...
             'input_to_statechange', { vr.signal_dict.signal_dict_bcontrol('cue_entry'), 'in_cues'});
                                   
%        sma = add_state(sma, 'name', 'in_cues', ...
%              'input_to_statechange', { vr.signal_dict.signal_dict_bcontrol('memory_entry'), 'in_memory'
%                                        vr.signal_dict.signal_dict_bcontrol('right_cue_onset'), 'right_cue_on'
%                                        vr.signal_dict.signal_dict_bcontrol('left_cue_onset'), 'left_cue_on'});
%          
%        sma = add_state(sma, 'name', 'right_cue_on', 'self_timer',0.05, ...
%             'output_actions', {'DOut', xled}, ...
%              'input_to_statechange', { vr.signal_dict.signal_dict_bcontrol('memory_entry'), 'in_memory'
%                                        vr.signal_dict.signal_dict_bcontrol('left_cue_onset'), 'left_cue_on'
%                                        'Tup', 'in_cues' });
%         
%        sma = add_state(sma, 'name', 'left_cue_on', 'self_timer',0.05, ...
%             'output_actions', {'DOut', cled}, ...
%              'input_to_statechange', { vr.signal_dict.signal_dict_bcontrol('memory_entry'), 'in_memory'
%                                        vr.signal_dict.signal_dict_bcontrol('right_cue_onset'), 'right_cue_on'
%                                        'Tup', 'in_cues' });

       sma = add_state(sma, 'name', 'in_cues', ...
             'input_to_statechange', { vr.signal_dict.signal_dict_bcontrol('cueTwo_entry'), 'in_cuesTwo'});
         
       sma = add_state(sma, 'name', 'in_cuesTwo', ...
             'input_to_statechange', { vr.signal_dict.signal_dict_bcontrol('cueThree_entry'), 'in_cuesThree'});
         
       sma = add_state(sma, 'name', 'in_cuesThree', ...
             'input_to_statechange', { vr.signal_dict.signal_dict_bcontrol('memory_entry'), 'in_memory'});
         
       sma = add_state(sma, 'name', 'trial_violation', ...
             'input_to_statechange', { 'PCLink1_2', 'in_cues'});
         
       sma = add_state(sma, 'name', 'in_memory', ...
             'input_to_statechange', { vr.signal_dict.signal_dict_bcontrol('turn_entry'), 'in_turn'});
        
        sma = add_state(sma, 'name', 'in_turn', ...
            'input_to_statechange', {vr.signal_dict.signal_dict_bcontrol('choiceL_entry'), left_answer
                                     vr.signal_dict.signal_dict_bcontrol('choiceR_entry'), right_answer});
                                  
          
        sma = add_state(sma, 'name', 'right_wrong','self_timer',0.2, ...
            'input_to_statechange', {'Tup','final_state'});
        
        sma = add_state(sma, 'name', 'left_wrong','self_timer',0.2, ...
            'input_to_statechange', {'Tup','final_state'});

        sma = add_state(sma, 'name', 'right_correct','self_timer',0.2, ...
            'output_actions', {'DOut', xled+cled}, ...
            'input_to_statechange', {'Tup','final_state'});
        
        sma = add_state(sma, 'name', 'left_correct','self_timer',0.2, ...
            'output_actions', {'DOut', xled}, ...
            'input_to_statechange', {'Tup','final_state'});
        

        sma = add_state(sma, 'name', 'final_state', ...
            'self_timer', 0.2, 'input_to_statechange', {'Tup', 'check_next_trial_ready'});
        dispatcher('send_assembler', sma, 'final_state');
        
        vr.fieldsObj.choice_state_obj.set_state_machine_table(get_labels(sma))
        
        % Defaul behavior of following call is that every 20 trials, the data
        % gets saved, not interactive, no commit to CVS.
        %     SavingSection(obj, 'autosave_data');
        
        %% get_state_colors
        % ----------------------------------------------------------------
        %
        %       CASE GET_STATE_COLORS
        %
        % ----------------------------------------------------------------
        
    case 'get_state_colors'
        
        varargout{1} = struct( ...
            'in_start',               [0.7 0.7 1  ], ...
            'in_cues',                [1   0   0  ], ...
            'in_cuestwo',             [0   0.8 0  ], ...
            'in_cuesthree',           [0   0   1  ], ...
            'in_memory',              [0.3 0.3 0.6], ...
            'in_turn',                [0.1 0.1 0.4], ...
            'right_correct',          [0 0.6 0],   ...
            'left_correct',           [0.2 1 0.2],       ...
            'right_wrong',            [0.6 0 0],     ...
            'left_wrong',             [1 0.2 0.2]);
        
        
        
        %% reinit
        
end
end

