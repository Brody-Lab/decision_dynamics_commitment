

function [obj] = CerebroLaserControl(varargin)

obj = class(struct, mfilename, pokesplot2, saveload);

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
    disp('Setting rand seed to sum(1e3*clock)');  
    rand('twister',sum(1e3*clock));
    
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
    set(value(myfig), 'Position', [303 60 200 400]);

    % ----------
    
    % We use the following to generate a call that will occur after
    % any loading of data. We can use that to do any updates we may want.
    SoloParamHandle(obj, 'after_load_callbacks', 'value', []);
    set_callback(after_load_callbacks, {mfilename, 'after_load_callbacks'});
    set_callback_on_load(after_load_callbacks, 1);

    
    x = 5; y = 5;             % Initial position on main GUI window
    
    [x, y] = SavingSection(obj,       'init', x, y);
    
    NumeditParam(obj, 'Laser_Duration',   .002,  x, y,  'labelfraction', 0.8); next_row(y);
    NumeditParam(obj, 'Taper_Duration',   0,  x, y,  'labelfraction', 0.8); next_row(y);
    NumeditParam(obj, 'Cycle_Duration',   20,  x, y,  'labelfraction', 0.8); next_row(y);
    NumeditParam(obj, 'Number_Replicates',10, x, y,  'labelfraction', 0.8); next_row(y);   
    NumeditParam(obj, 'Power',            25, x, y,  'labelfraction', 0.8); next_row(y); 
    
    SoloParamHandle(obj,'STATE_COLORS','value',struct( ...
      'laser_stim',             [0 1 1],...
      'reset',                  [1 0 0],...
      'wait',                   [0 1 0],...
      'check_next_trial_ready', [0.7 0.7 0.7]));
 
    SoloParamHandle(obj,'WAVE_COLORS','value',struct( ...
      'laser_digital_wave',[1 1 0],...
      'neuralynx_wave',    [1 1 0],...
      'laser_analog_wave', [1 1 0]));  
  
    SoloParamHandle(obj,'Cerebro1Line','value',bSettings('get','DIOLINES','cerebro1'));
    SoloParamHandle(obj,'Cerebro2Line',   'value',bSettings('get','DIOLINES','cerebro2'));
   
    SoloParamHandle(obj,'NeuralynxLine',   'value',bSettings('get','DIOLINES','stim2'));
        
    
    DeclareGlobals(obj,'ro_args',{'STATE_COLORS','WAVE_COLORS'});
    
    [x, y] = PokesPlotSection(obj,    'init', x, y);
      
    feval(mfilename, obj, 'prepare_next_trial');
    
   

%% prepare_next_trial    
  %---------------------------------------------------------------
  %          CASE PREPARE_NEXT_TRIAL
  %---------------------------------------------------------------
  case 'prepare_next_trial'
    
    sma = StateMachineAssembler('full_trial_structure','use_happenings', 1);
    
    LinuxClock = 2000;
    cd = round(value(Cycle_Duration) * LinuxClock);
    ld = round(value(Laser_Duration) * LinuxClock);
    td = round(value(Taper_Duration) * LinuxClock);
    
    AWF = zeros(1,ld);
    AWF(1:ld-td) = 1;
    AWF((ld-td)+1:end) = 1:-1/(td-1):0;
    
    scale = 0.47 * (value(Power) / 64);
    
    AWF = AWF * scale;
    
    
    sma = add_scheduled_wave(sma, 'name', 'cerebro_wave',...
                                  'preamble',12,...
                                  'sustain', 0.002,...
                                  'refraction',8-0.002,...
                                  'DOut',    value(Cerebro1Line),...
                                  'loop',    value(Number_Replicates));

    sma = add_scheduled_wave(sma, 'name', 'neuralynx_wave',...
                                  'preamble',12,...
                                  'sustain', 8,...
                                  'DOut',    value(NeuralynxLine),...
                                  'loop',    value(Number_Replicates));
                              
                             
    
    %sma = add_state(sma,'name','prepare_next_trial','self_timer',0.01,...
    %          'input_to_statechange',{'Tup','current_state+1'});
          
    if rem(n_done_trials,2)==1                          
        sma = add_state(sma, 'name', 'laser_stim', 'self_timer', (value(Cycle_Duration) * value(Number_Replicates))+0.1,...
              'output_actions', {'SchedWaveTrig', '+cerebro_wave+neuralynx_wave'},...
              'input_to_statechange', {'Tup', 'reset';'Cout','reset'});
          
        sma = add_state(sma,'name','reset','self_timer',0.01,...
              'output_actions', {'SchedWaveTrig', '-cerebro_wave-neuralynx_wave'},...
              'input_to_statechange', {'Tup', 'check_next_trial_ready'});
    else
        sma = add_state(sma,'name','wait','self_timer',1e6,...
              'input_to_statechange', {'Tup', 'check_next_trial_ready';'Cout', 'check_next_trial_ready'});
    end
          
    dispatcher('send_assembler', sma, {'check_next_trial_ready'});
    
%% trial_completed    
  %---------------------------------------------------------------
  %          CASE TRIAL_COMPLETED
  %---------------------------------------------------------------
  case 'trial_completed'
    % Do any updates in the protocol that need doing:
    feval(mfilename, 'update');
    % And PokesPlot needs completing the trial:
    PokesPlotSection(obj, 'trial_completed');
  
    
%% update    
  %---------------------------------------------------------------
  %          CASE UPDATE
  %---------------------------------------------------------------
  case 'update'
    PokesPlotSection(obj, 'update');
    
    
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

