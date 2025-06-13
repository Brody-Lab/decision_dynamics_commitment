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
        % <~> end adaptation for single-trial use :P
        
        %snd_low = SoundManagerSection(obj,'get_sound_id','snd_low');
        %snd_high = SoundManagerSection(obj,'get_sound_id','snd_high');
        sma = StateMachineAssembler('full_trial_structure',...
            'use_happenings',1, ...
            'n_input_lines',numel(inputnames),'line_names',inputnames);
               

        sma = add_state(sma, 'name', 'wait1', 'self_timer',0.3, ...
            'output_actions', {'DOut', xled}, ...
            'input_to_statechange', { 'Tup', 'cue_in' });
        
        sma = add_state(sma, 'name', 'cue_in', ...
            'input_to_statechange', { 'PCLink1_3', 'send_back1'});
        
         sma = add_state(sma, 'name', 'send_back1', ...
            'output_actions', {'PCLink1Out', 1}, ...
            'input_to_statechange', { 'PCLink1_1', 'send_back2'
                                      'PCLink1_7', 'final_state'
                                      'PCLink1_8', 'final_state'});
                                  
         sma = add_state(sma, 'name', 'send_back2', ....
            'output_actions', {'PCLink1Out', 1}, ...
            'input_to_statechange', { 'PCLink1_1', 'send_back1'
                                      'PCLink1_7', 'final_state'
                                      'PCLink1_8', 'final_state'});
             

        sma = add_state(sma, 'name', 'final_state', ...
            'self_timer', 0.2, 'input_to_statechange', {'Tup', 'check_next_trial_ready'});
        dispatcher('send_assembler', sma, 'final_state');
        
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
            'wait_for_centernose',    [0.2 0.5 0.2], ...
            'emit_sound',          [0.5 0.5 1],   ...
            'wait_for_response',        [0.5 1 0.5],   ...
            'right_correct',         [1 0.5 0.5],   ...
            'left_correct',                [1 1 1],       ...
            'right_wrong',            [0.5 0 0],     ...
            'left_wrong', [0.7 0.7 0.7]);
        
        
        
        %% reinit
        
end
end

