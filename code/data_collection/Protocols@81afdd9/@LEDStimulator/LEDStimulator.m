

function [obj] = LEDStimulator(varargin)

obj = class(struct, mfilename, saveload, water, antibias, pokesplot, ...
  soundmanager, soundui ,sessionmodel, distribui, punishui, warnDanger, ...
  comments, softpokestay2, sqlsummary);

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


switch action,

  %---------------------------------------------------------------
  %          CASE INIT
  %---------------------------------------------------------------
%% INIT 
  case 'init'
    dispatcher('set_trialnum_indicator_flag');  
    
    hackvar = 10; SoloFunctionAddVars('SessionModel', 'ro_args', 'hackvar'); %#ok<NASGU>
    
    SoloParamHandle(obj, 'myfig', 'saveable', 0); myfig.value = double(figure);

    % Make the title of the figure be the protocol name, and if someone tries
    % to close this figure, call dispatcher's close_protocol function, so it'll know
    % to take it off the list of open protocols.
    name = mfilename;
    set(value(myfig), 'Name', name, 'Tag', name, ...
      'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');

    % At this point we have one SoloParamHandle, myfig
    % Let's put the figure where we want it and give it a reasonable size:
    set(value(myfig), 'Position', [500 400 350 500]); 

    x = 5; y = 5;
    
    [x, y] = SavingSection(obj,       'init', x, y); 
    
    diolines = bSettings('get','DIOLINES', 'all');
    for i = 1:size(diolines,1); dionames{i} = diolines{i,1}; dionums(i) = diolines{i,2}; end %#ok<AGROW>
    [dionums order] = sort(dionums);
    dionames2 = cell(0);
    for i = 1:length(dionums); if ~isnan(dionums(i)); dionames2{end+1} = dionames{order(i)}; end; end %#ok<AGROW>
    dionames3{1} = 'none';
    dionames3(2:length(dionames2)+1) = dionames2;
    
    MenuParam(   obj, 'Line_1',dionames3,1, x, y, 'labelfraction',0.30); next_row(y); 
    NumeditParam(obj, 'Delay_1',     100,   x, y, 'labelfraction', 0.6); next_row(y);
    NumeditParam(obj, 'NumPulses_1', 1,     x, y, 'labelfraction', 0.6); next_row(y);
    NumeditParam(obj, 'Frequency_1', 1,     x, y, 'labelfraction', 0.6); next_row(y);
    NumeditParam(obj, 'Duration_1',  1000,  x, y, 'labelfraction', 0.6); next_row(y,1.1);
    
    MenuParam(   obj, 'Line_2',dionames3,1, x, y, 'labelfraction',0.30); next_row(y); 
    NumeditParam(obj, 'Delay_2',     400,   x, y, 'labelfraction', 0.6); next_row(y);
    NumeditParam(obj, 'NumPulses_2', 2,     x, y, 'labelfraction', 0.6); next_row(y);
    NumeditParam(obj, 'Frequency_2', 200,   x, y, 'labelfraction', 0.6); next_row(y);
    NumeditParam(obj, 'Duration_2',  1,     x, y, 'labelfraction', 0.6); next_row(y,1.1);
    
    NumeditParam(obj, 'Trial_Length',10, x, y, 'labelfraction', 0.6); next_row(y, 1.1);
    
    MenuParam(obj,'StartTrial', {'Automatic','C_poke'}, 2, x, y); next_row(y);
    MenuParam(obj,'EndTrial',   {'On_Time',  'C_poke'}, 2, x, y); next_row(y);  
    
    
      
    
    [x, y] = PokesPlotSection(obj,  'init', x, y,struct('states',  SMASection(obj, 'get_state_colors')));
        
    SoloFunctionAddVars('SMASection', 'ro_args', {'Line_1';...
                                                  'Delay_1';...
                                                  'NumPulses_1';...
                                                  'Frequency_1';...
                                                  'Duration_1';...
                                                  'Line_2';...
                                                  'Delay_2';...
                                                  'NumPulses_2';...
                                                  'Frequency_2';...
                                                  'Duration_2';...
                                                  'StartTrial';...
                                                  'EndTrial';...
                                                  'Trial_Length'});
    feval(mfilename, obj, 'prepare_next_trial');
        
    
%% prepare_next_trial    
  %---------------------------------------------------------------
  %          CASE PREPARE_NEXT_TRIAL
  %---------------------------------------------------------------
  case 'prepare_next_trial'
    % feval(mfilename, 'update');
    
    [sma, prepare_next_trial_states] = SMASection(obj, 'prepare_next_trial');
    
    dispatcher('send_assembler', sma, prepare_next_trial_states);

    
%% trial_completed    
  %---------------------------------------------------------------
  %          CASE TRIAL_COMPLETED
  %---------------------------------------------------------------
  case 'trial_completed'
    % Do any updates in the protocol that need doing:
    feval(mfilename, 'update');
    
    PokesPlotSection(obj, 'trial_completed');
  
%% update    
  %---------------------------------------------------------------
  %          CASE UPDATE
  %---------------------------------------------------------------
  case 'update'
    
    PokesPlotSection(obj, 'update');

%% end_session    
  %---------------------------------------------------------------
  %          CASE END_SESSION
  %---------------------------------------------------------------
  case 'end_session'
     prot_title.value = [value(prot_title) ', Ended at ' datestr(now, 'HH:MM')]; %#ok<NODEF>
     getSessID(obj);
    
%% pre_saving_settings
  %---------------------------------------------------------------
  %          CASE PRE_SAVING_SETTINGS
  %---------------------------------------------------------------
  case 'pre_saving_settings'

 		
    
%% after_load_callbacks
  %---------------------------------------------------------------
  %          CASE AFTER_LOAD_CALLBACKS
  %---------------------------------------------------------------
  case 'after_load_callbacks'
    

    

%% close    
  %---------------------------------------------------------------
  %          CASE CLOSE
  %---------------------------------------------------------------
  case 'close'
    PokesPlotSection(obj, 'close');

    if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)), %#ok<NODEF>
      delete(value(myfig));
    end;
    delete_sphandle('owner', ['^@' class(obj) '$']);

  otherwise,
    warning('Unknown action! "%s"\n', action); %#ok<WNTAG>
end;

return;

