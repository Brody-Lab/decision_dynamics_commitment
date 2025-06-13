%TortureTest_Sound: Water Calibration Protocol addressing some of the
%issues with the earlier protocol.
% Sundeep Tuteja, 20th October, 2009

function [obj] = FSMTest_Sound(varargin)

obj = class(struct, mfilename, soundmanager);

%---------------------------------------------------------------
%   BEGIN SECTION COMMON TO ALL PROTOCOLS, DO NOT MODIFY
%---------------------------------------------------------------

% If creating an empty object, return without further ado:
if nargin==0 || (nargin==1 && ischar(varargin{1}) && strcmp(varargin{1}, 'empty')),
    return;
end;

if isa(varargin{1}, mfilename), % If first arg is an object of this class itself, we are
    % Most likely responding to a callback from
    % a SoloParamHandle defined in this mfile.
    if length(varargin) < 2 || ~ischar(varargin{2}),
        error(['If called with a "%s" object as first arg, a second arg, a ' ...
            'string specifying the action, is required\n']);
    else action = varargin{2}; varargin = varargin(3:end); %#ok<NASGU>
    end;
else % Ok, regular call with first param being the action string.
    action = varargin{1}; varargin = varargin(2:end); %#ok<NASGU>
end;

GetSoloFunctionArgs(obj);

%---------------------------------------------------------------
%   END OF SECTION COMMON TO ALL PROTOCOLS, MODIFY AFTER THIS LINE
%---------------------------------------------------------------





% ---- From here on is where you can put the code you like.
%
% Your protocol will be called, at the appropriate times, with the
% following possible actions:
%
%   'init'     To initialize -- make figure windows, variables, etc.
%
%   'update'   Called periodically within a trial
%
%   'prepare_next_trial'  Called when a trial has ended and your protocol is expected
%              to produce the StateMachine diagram for the next trial;
%              i.e., somewhere in your protocol's response to this call, it
%              should call "dispatcher('send_assembler', sma,
%              prepare_next_trial_set);" where sma is the
%              StateMachineAssembler object that you have prepared and
%              prepare_next_trial_set is either a single string or a cell
%              with elements that are all strings. These strings should
%              correspond to names of states in sma.
%                 Note that after the prepare_next_trial call, further
%              events may still occur while your protocol is thinking,
%              before the new StateMachine diagram gets sent. These events
%              will be available to you when 'state0' is called on your
%              protocol (see below).
%
%   'trial_completed'   Called when the any of the prepare_next_trial set
%              of states is reached.
%
%   'close'    Called when the protocol is to be closed.
%
%
% VARIABLES THAT DISPATCHER WILL ALWAYS INSTANTIATE FOR YOU AS READ_ONLY
% GLOBALS IN YOUR PROTOCOL:
%
% n_done_trials     How many trials have been finished; when a trial reaches
%                   one of the prepare_next_trial states for the first
%                   time, this variable is incremented by 1.
%
% n_started_trials  How many trials have been started. This variable gets
%                   incremented by 1 every time the state machine goes
%                   through state 0.
%
% parsed_events     The result of running disassemble.m, with the
%                   parsed_structure flag set to 1, on all events from the
%                   start of the current trial to now.
%
% latest_parsed_events     The result of running disassemble.m, with the
%                   parsed_structure flag set to 1, on all new events from
%                   the last time 'update' was called to now.
%
% raw_events        All the events obtained in the current trial, not parsed
%                   or disassembled, but raw as gotten from the State
%                   Machine object.
%
% current_assembler The StateMachineAssembler object that was used to
%                   generate the State Machine diagram in effect in the
%                   current trial.
%
% Trial-by-trial history of parsed_events, raw_events, and
% current_assembler, are automatically stored for you in your protocol by
% dispatcher.m.
%
%

persistent tStop;
persistent tStart;
persistent counter;
if isempty(tStop)
    tStop = zeros(10000, 1);
end
if isempty(tStart)
    tStart = uint64(0);
end
if isempty(counter)
    counter = 1;
end

switch action
    
    %% init
    case 'init'
       
        tStart = tic;
        
        SoundManagerSection(obj, 'init');
        samplerate = SoundManagerSection(obj, 'get_sample_rate');
        twokhz_vec = 0.3*sin(2*pi*2000*(0:1/samplerate:0.1));
        SoundManagerSection(obj, 'declare_new_sound', 'twokhz', twokhz_vec);
        
        sma = StateMachineAssembler('full_trial_structure');
        
        sma = add_state(sma, ...
            'self_timer', 0.0001, ...
            'input_to_statechange', {'Tup', 'check_next_trial_ready'});
        
        dispatcher('send_assembler', sma, 'check_next_trial_ready');
       
        
        %% prepare next trial
    case 'prepare_next_trial'
        
        tStop(counter) = toc(tStart);
        fprintf([num2str(tStop(counter)), '\n']);
        counter = counter + 1;
        
        if counter <= length(tStop)
            feval(mfilename, 'RESTART');
        else
            dispatcher('close');
        end
        
        %% RESTART
    case 'RESTART'
        
        tStart = tic;
        
        twokhz_soundid = SoundManagerSection(obj, 'get_sound_id', 'twokhz'); 
        
        left1led = bSettings('get', 'DIOLINES', 'left1led');
        
        sma = StateMachineAssembler('full_trial_structure');
        
        %Dummy state
        sma = add_state(sma, ...
            'self_timer', 0.0001, ...
            'input_to_statechange', {'Tup', 'current_state+1'});
        
        sma = add_state(sma, ...
            'name', 'start_state', ...
            'self_timer', 0.0001, ...
            'input_to_statechange', {'Tup', 'current_state+1'});
        
        for ctr = 1:100
            sma = add_state(sma, ...
                'self_timer', 0.1, ...
                'input_to_statechange', {'Tup', 'current_state+1'}, ...
                'output_actions', {'SoundOut', twokhz_soundid; ...
                'DOut', left1led});
            
            sma = add_state(sma, ...
                'self_timer', 0.1, ...
                'input_to_statechange', {'Tup', 'current_state+1'}, ...
                'output_actions', {'SoundOut', -twokhz_soundid});
        end
        
        sma = add_state(sma, ...
            'name', 'trial_complete', ...
            'self_timer', 0.0001, ...
            'input_to_statechange', {'Tup', 'check_next_trial_ready'});
        
        dispatcher('send_assembler', sma, 'check_next_trial_ready');
        
        
        
        
        
    
        %% trial_completed
    case 'trial_completed'
        
        
        
        
        
        %% update
    case 'update'
        
        % msgbox('UPDATE!!!');
        
        
        
        %% close
    case 'close'
        save(['TIMESTAMPS_', mfilename, '.mat'], 'tStop');
        clear('tStart', 'tStop', 'counter');
        waitfor(msgbox('TORTURE TEST COMPLETED!!!', 'Completed Test', 'modal'));
        
        
        
        %% end_session
    case 'end_session'
        
        
        
        
        %% pre_saving_settings
    case 'pre_saving_settings'
        
        
        
        %% otherwise
        
    otherwise
        warning('Unknown action! "%s"\n', action); %#ok<WNTAG>
end

return


