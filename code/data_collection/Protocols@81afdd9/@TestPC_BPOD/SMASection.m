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
        % <~> end adaptation for single-trial use :P
        
        
        % <~> Made changes to trial structure for runrats test as well.
        
        allinput = bSettings('get','INPUTLINES','ALL');
        inputnames = [];
        for i = 1:length(allinput)
            inputnames(end+1) = allinput{i,1};
        end
        
        left1led = bSettings('get','DIOLINES','left1led');
        %center1led = bSettings('get','DIOLINES','center1led');
        right1led = bSettings('get','DIOLINES','right1led');
        xled = bSettings('get','DIOLINES','xled');
        
        %aled = bSettings('get','DIOLINES','aled');
        %bled = bSettings('get','DIOLINES','bled');
        %dled = bSettings('get','DIOLINES','dled');
        %eled = bSettings('get','DIOLINES','eled');
        
        left1water = bSettings('get','DIOLINES','left1water');
        right1water = bSettings('get','DIOLINES','right1water');
        %awater = bSettings('get','DIOLINES','awater');
        %dwater = bSettings('get','DIOLINES','dwater');
        
        %get values for leds in port array
%         PALed1 = bSettings('get','PORTARRAYLEDS','PALED1');
%         PALed2 = bSettings('get','PORTARRAYLEDS','PALED2');
%         PALed3 = bSettings('get','PORTARRAYLEDS','PALED3');
%         PALed4 = bSettings('get','PORTARRAYLEDS','PALED4');
%         
%         %get values for leds in port array
%         PAValve1 = bSettings('get','PORTARRAYVALVES','PAVALVE1');
%         PAValve2 = bSettings('get','PORTARRAYVALVES','PAVALVE2');
%         PAValve3 = bSettings('get','PORTARRAYVALVES','PAVALVE3');
%         PAValve4 = bSettings('get','PORTARRAYVALVES','PAVALVE4');
        
        
        %snd_low = SoundManagerSection(obj,'get_sound_id','snd_low');
        %snd_high = SoundManagerSection(obj,'get_sound_id','snd_high');
        sma = StateMachineAssembler('full_trial_structure',...
            'use_happenings',1, ...
            'n_input_lines',numel(inputnames),'line_names',inputnames);
               

%         prob = rand;
%         if prob < 0.5
%             sound_state = 'emit_sound_low';
%             sound_out = snd_low;
%             right_answer = 'right_correct';
%             left_answer = 'left_wrong';
%         else
%             sound_state = 'emit_sound_high';
%             sound_out = snd_high;
%             right_answer = 'right_wrong';
%             left_answer = 'left_correct';
%         end
%         
%         sma = add_scheduled_wave(sma, 'name', 'timeout_trial', 'preamble', 15);
%         
        sma = add_state(sma, 'name', 'wait1', 'self_timer',25, ...
            'output_actions', {'DOut', xled}, ...
            'input_to_statechange', { 'Tup', 'wait2' });
        
        sma = add_state(sma, 'name', 'wait2', 'self_timer',25, ...
            'output_actions', {}, ...
            'input_to_statechange', { 'Tup', 'final_state' });


        
%% State machine with VirtualPorts         

%         sma = add_state(sma, 'name', sound_state, ...
%             'output_actions', ...
%             {'SoundOut', sound_out, ...
%             'DOut', xled + eled}, ...
%             'input_to_statechange', ...
%             {'Ain',left_answer, ...
%              'Din',right_answer,...
%              'Rin',right_answer,...
%              'timeout_trial_In', 'final_state'});
%         
%         sma = add_state(sma, 'name', 'right_wrong','self_timer',0.5, ...
%             'output_actions', ...
%             {'DOut', right1led + dled}, ...
%             'input_to_statechange', {'Tup','final_state'});
%         
%         sma = add_state(sma, 'name', 'left_wrong','self_timer',0.5, ...
%             'output_actions', ...
%             {'DOut', left1led + aled}, ...
%             'input_to_statechange', {'Tup','final_state'});
% 
%         sma = add_state(sma, 'name', 'right_correct','self_timer',1.5, ...
%             'output_actions', ...
%             {'DOut', xled + eled + right1led + right1water + dled  + dwater}, ...
%             'input_to_statechange', {'Tup','final_state'});
%         
%         sma = add_state(sma, 'name', 'left_correct','self_timer',1.5, ...
%             'output_actions', ...
%             {'DOut', xled + eled + left1led + left1water + aled  + awater}, ...
%             'input_to_statechange', {'Tup','final_state'});
        

%% State machine with PORT ARRAY OUT PA1Out  and PA happenings: PA1_Port2in 
        
%        sma = add_state(sma, 'name', sound_state, ...
%             'output_actions', ...
%             {'SoundOut', sound_out, ...
%             'PA1Out', PALed1}, ...
%             'input_to_statechange', ...
%             {'PA1_Port2in',left_answer, ...
%              'PA1_Port4lo',right_answer,...
%              'Rin',right_answer,...
%              'timeout_trial_In', 'final_state'});
        

%       sma = add_state(sma, 'name', 'right_wrong','self_timer',0.5, ...
%             'output_actions', ...
%             {'DOut', right1led, ...
%             'PA1Out', PALed4}, ...
%             'input_to_statechange', {'Tup','final_state'});
%       
        
%         sma = add_state(sma, 'name', 'left_wrong','self_timer',0.5, ...
%             'output_actions', ...
%             {'DOut', left1led, ...
%             'PA1Out', PALed2}, ...
%             'input_to_statechange', {'Tup','final_state'});

%         sma = add_state(sma, 'name', 'right_correct','self_timer',1.5, ...
%             'output_actions', ...
%             {'DOut', center1led+right1led+right1water, ...
%             'PA1Out', PALed3+PALed4}, ...
%             'input_to_statechange', {'Tup','final_state'});
%         
%         sma = add_state(sma, 'name', 'left_correct','self_timer',1.5, ...
%             'output_actions', ...
%             {'DOut', center1led+left1led+left1water, ...
%             'PA1Out', PALed2+PALed3}, ...
%             'input_to_statechange', {'Tup','final_state'});        
        
        
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

