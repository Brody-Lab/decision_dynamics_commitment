
% Make sure you ran newstartup, then dispatcher('init'), and you're good to
% go!
%

function [obj] = VirmenBPOD1(varargin)

% Default object is of our own class (mfilename); in this simplest of
% protocols, we inherit only from Plugins/@pokesplot

obj = class(struct, mfilename, pokesplot, saveload, soundmanager, soundui);

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
    else action = varargin{2}; varargin = varargin(3:end);
    end;
else % Ok, regular call with first param being the action string.
    action = varargin{1}; varargin = varargin(2:end);
end;
if ~ischar(action), error('The action parameter must be a string'); end;

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
%   'prepare_next_trial'  Called when a trial has ended and your protocol
%              is expected to produce the StateMachine diagram for the next
%              trial; i.e., somewhere in your protocol's response to this
%              call, it should call "dispatcher('send_assembler', sma,
%              prepare_next_trial_set);" where sma is the
%              StateMachineAssembler object that you have prepared and
%              prepare_next_trial_set is either a single string or a cell
%              with elements that are all strings. These strings should
%              correspond to names of states in sma.
%                 Note that after the 'prepare_next_trial' call, further
%              events may still occur in the RTLSM while your protocol is thinking,
%              before the new StateMachine diagram gets sent. These events
%              will be available to you when 'trial_completed' is called on your
%              protocol (see below).
%
%   'trial_completed'   Called when 'state_0' is reached in the RTLSM,
%              marking final completion of a trial (and the start of
%              the next).
%
%   'close'    Called when the protocol is to be closed.
%
%
% VARIABLES THAT DISPATCHER WILL ALWAYS INSTANTIATE FOR YOU IN YOUR
% PROTOCOL:
%
% (These variables will be instantiated as regular Matlab variables,
% not SoloParamHandles. For any method in your protocol (i.e., an m-file
% within the @your_protocol directory) that takes "obj" as its first argument,
% calling "GetSoloFunctionArgs(obj)" will instantiate all the variables below.)
%
%
% n_done_trials     How many trials have been finished; when a trial reaches
%                   one of the prepare_next_trial states for the first
%                   time, this variable is incremented by 1.
%
% n_started trials  How many trials have been started. This variable gets
%                   incremented by 1 every time the state machine goes
%                   through state 0.
%
% parsed_events     The result of running disassemble.m, with the
%                   parsed_structure flag set to 1, on all events from the
%                   start of the current trial to now.
%
% latest_events     The result of running disassemble.m, with the
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
% dispatcher.m. See the wiki documentation for information on how to access
% those histories from within your protocol and for information.
%
%


switch action
    
    %---------------------------------------------------------------
    %          CASE INIT
    %---------------------------------------------------------------
    
    case 'init'
        
        %Communicate all virmen setup variables
        [virmen_structure, codes_files] = virmen_utils.generate_all_Virmen_vars();
        
        %Initialize tcp client
        tcp_client = comm.tcp.initialize_tcp( ...
            BControlCommParameters.ipAddressBControl, ...
            BControlCommParameters.tcpClientPort, ...
            BControlCommParameters.networkRole, ...
            BControlCommParameters.outputBufferSize);
        
        comm.virmen_specific.send_all_virmen_vars(tcp_client, codes_files, virmen_structure);


        % Get example session
        path_session = 'C:\ratter\Protocols\@VirmenBPOD1\virmen_test_session.mat';
        virmen_test_session = load(path_session);
        trial_idx = 1;
        
        
        
        FigureSection(obj, 'declare_new_figures')

        SoloParamHandle(obj, 'hit_history',   'value', [0, 0]);
        SoloParamHandle(obj, 'freqs_sound',   'value', [500, 2000]);
        
        SoloParamHandle(obj, 'solo_virmenSession',   'value', virmen_test_session);
        SoloParamHandle(obj, 'solo_tcpclient',   'value', tcp_client);
        SoloParamHandle(obj, 'solo_trial_idx',   'value', trial_idx);
        
        % Initialize Virmen %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        DeclareGlobals(obj, 'ro_args', {'hit_history', ...
                                        'freqs_sound', ...
                                        'solo_virmenSession',    ...
                                        'solo_trial_idx',
                                        'tcp_client'});
        
        SoloFunctionAddVars('HitSection',   'rw_args', 'hit_history');
        %SoloFunctionAddVars('HitSection',   'rw_args', 'solo_trialsTable');
        SoloFunctionAddVars('HitSection',   'rw_args', 'solo_trial_idx');
        
        SoloFunctionAddVars('SoundSection',   'rw_args', 'freqs_sound');
        
        %SoundSection(obj, 'declare_new_sounds')
        
        
        
        
        VirmenBPOD1(obj, 'prepare_next_trial');
        
        %---------------------------------------------------------------
        %          CASE PREPARE_NEXT_TRIAL
        %---------------------------------------------------------------
    case 'prepare_next_trial'
        
        HitSection(obj,  'prepare_next_trial');
        
        SMASection(obj, 'prepare_next_trial');
        
        
        
        %---------------------------------------------------------------
        %          CASE TRIAL_COMPLETED
        %---------------------------------------------------------------
    case 'trial_completed'
        % Do any updates in the protocol that need doing:
        %feval(mfilename, 'update');
        % And PokesPlot needs completing the trial:
        %PokesPlotSection(obj, 'trial_completed');
        
        %---------------------------------------------------------------
        %          CASE UPDATE
        %---------------------------------------------------------------
    case 'update'
        %PokesPlotSection(obj, 'update');
        
        
        %---------------------------------------------------------------
        %          CASE CLOSE
        %---------------------------------------------------------------
    case 'close'
        
        disp('Esto se ejecuta cuando cierran ...............')
        
        %PokesPlotSection(obj, 'close');
        if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)), %#ok<NODEF>
            delete(value(myfig));
        end
        delete_sphandle('owner', ['^@' class(obj) '$']);
        
    otherwise
        warning('Unknown action! "%s"\n', action); %#ok<WNTAG>
end

return;

