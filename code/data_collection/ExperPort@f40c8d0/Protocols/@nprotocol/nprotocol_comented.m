% This protocol allows you to control port's valves times shock and LASER
% using TTL pulse...
%
% Based on PokesplotDemo, Minimal, etc, etc...
%
% Niccolò Bonacchi - September 2008


function [obj] = nprotocol(varargin)

% Default object is of our own class (mfilename); in this simplest of
% protocols, we inherit only from Plugins/@pokesplot and Plugins/@saveload

obj = class(struct, mfilename, pokesplot, saveload); %-- If you want to use plugins you have to declare them here

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
if ~isstr(action), error('The action parameter must be a string'); end;

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
  
  case 'init'

      %begin figure for protocol
% open a figure
SoloParamHandle(obj, 'nfig', 'saveable', 0); nfig.value = figure;
 name = 'nWSL'; %name it
    set(value(nfig), 'Name', name, 'Tag', name, ...
      'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');
    set(value(nfig), 'Position', [775 100 220 400]);

    %create the lines for the different sections that will contain the
    %different var's you need to submit to the sma.
%     Syntax goes as follows: call the NumEditParam, SubHeaderParam or
%     MenuParam obj that you want, WhateverParam(obj, 'name it', initial value, position
%     X, position Y, call TooltipString function, 'String of Alt')
%     (the Next_line(y) func probably works here for not having to change
%     all the Y values every time you add a line) Did not use it...
SubheaderParam(obj, 'valveMenu', 'Solenoid Times', 10, 370);
NumeditParam(obj, 'centerValve', 0.3, 10, 350, 'TooltipString', 'Opening time of center solenoid.');
NumeditParam(obj, 'leftValve', 0.3, 10, 330, 'TooltipString', 'Opening time of left solenoid.');
NumeditParam(obj, 'rightValve', 0.3, 10, 310, 'TooltipString', 'Opening time of right solenoid.');

SubheaderParam(obj, 'latencyMenu', 'Poke-Valve Latency', 10, 280);
NumeditParam(obj, 'cpokeTime', 0.3, 10, 260, 'TooltipString', 'Latency between center poke and valve open.');
NumeditParam(obj, 'lpokeTime', 0.3, 10, 240, 'TooltipString', 'Latency between left poke and valve open.');
NumeditParam(obj, 'rpokeTime', 0.3, 10, 220, 'TooltipString', 'Latency between right poke and valve open.');

SubheaderParam(obj, 'shockMenu', 'Shock', 10, 190);
NumeditParam(obj, 'shockProp', 0.0, 10, 170, 'TooltipString', 'Proportion of SHOCKS/trials.');
MenuParam(obj, 'LRshock', {'null' 'Left' 'Right'}, 1, 10, 150, 'TooltipString', 'Side of SHOCK delivery.');

SubheaderParam(obj, 'laserMenu', 'LASER', 10, 120);
NumeditParam(obj, 'laserProp', 0.0, 10, 100, 'TooltipString', 'Proportion of LASER/trials.');
NumeditParam(obj, 'laserTime', 0.3, 10, 80, 'TooltipString', 'duration of LASER pulse.');
MenuParam(obj, 'LRlaser', {'null' 'Left' 'Right'}, 1, 10, 60, 'TooltipString', 'Side of LASER pulse delivery.');

PushbuttonParam(obj, 'submit', 20, 10, 'position', [20 10 200 45]);
%Next we need to set the callback for the action that the button will
%perform: Syntax: set_callback(name_of_obj, {'call_for_other_obj',
%'case_of_%obj called'}) You can set more than one callback  for example to give you an output to confirm the button did something)
% but I did it in a different way (see StateMatrixSection).

set_callback(submit, {'StateMatrixSection', 'init'}); % 'fprintf', 'MARTIX SENT!!'});

%Next we have to declare Globals which means that we have to tell Solo that
%other obj can see or see and change the var's we just created. 'rw_args' is
%read write privileges; 'ro_args' is read only
DeclareGlobals(obj, 'rw_args', {'centerValve', 'leftValve', 'rightValve', 'cpokeTime', 'lpokeTime', ...
    'rpokeTime', 'shockProp', 'LRshock', 'laserProp', 'LRlaser', 'laserTime', 'submit'});
% ex. syntax: DeclareGlobals(obj, {'rw_args','leftValve'}, {'ro_args', 'rightValve'},{'owner', class(obj)});

%finish figure for protocol

    % Make default figure. We remember to make it non-saveable; on next run
    % the handle to this figure might be different, and we don't want to
    % overwrite it when someone does load_data and some old value of the
    % fig handle was stored as SoloParamHandle "myfig"
    SoloParamHandle(obj, 'myfig', 'saveable', 0); myfig.value = figure; %janela

 % Make the title of the figure be the protocol name, and if someone tries
    % to close this figure, call dispatcher's close_protocol function, so it'll know
    % to take it off the list of open protocols.
    name = 'Saving Section Figure';
    set(value(myfig), 'Name', name, 'Tag', name, ...
      'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');


 % At this point we have one SoloParamHandle, myfig
    % Let's put the figure where we want it and give it a reasonable size:
    set(value(myfig), 'Position', [50 50 300 350]);   
    %First 2 values are position (in px i presume)0 0 = inferior left
    %corner. The other 2 values are window size
    
     %-- _____'SavingSection Plugin'_____
     % Save Content Plugin, check docs for settings and definitions? 

%      IMPORTANT: whatever data you want to save should be define as a
%      SoloParam object [whatever(obj, ....);], if you do NOT want to save
%      things you can define it as whateverIdontwanttosave('base', ...);

    x = 50; y = 50;             % Initial position on main GUI window 

%Initiates 'Savig Section' in the window(figure) just created, x e y = position of section in win.
    [x, y] = SavingSection(obj, 'init', x, y);  
                                                
    
    next_row(y); %-- Why it needs a 'y' I dunno... check out ./HandleParam/next_row.m
    
% The next line Displays 'nTrials' in myfig. Syntax: (obj, 'ParamName, beginning n.º, X position, Y position)   
%For default position leave ..., x, y), x & y different from the x&y of the GUI window.  
% If you have no psoition and a lot of additional stuff somthing will probably overlap whith     
%somthing else, better to set position always, or learn to use the next_line(y)...bah    
  
    DispParam(obj, 'nTrials', 0, 50, 225);  
  
 % _____'pokesplot Plugin'_____
 % For plotting with the pokesplot plugin, we need to tell it what
    % colors to plot with:
%  IMPORTANT: States in the StateMatrixSection (sma_states) should NOT have
%  capitalized letters, if they do, the PokesPlot Plugin will not plot
%  them. ex. waiting_4_cout works but Waiting_4_Cout will not...
       my_state_colors = struct( ...
      'waiting_4_cin', [0.5 0.5 1], ...
      'waiting_4_cout', [0.5 1 0.5], ...
      'center_valve_click', [1 0.5 0.5], ...
      'waiting_4_both', [0.5 0.5 0.5], ... 
      'wait_4_leftvalveon', [0.5 0.5 0], ...
      'wait_4_rightvalveon', [0.5 0 0.5], ...
      'deliver_water_left', [0 0.5 0.5], ...
      'deliver_water_right', [0 0 0]);
    % In pokesplot, the poke colors have a default value, so we don't need
    % to specify them, but here they are so you know how to change them.
    %colors vary from 0 to 1 in RGB so [1 0 0] is red, [0 1 0] is green, [0 0 1] is blue and [1 1 1] is
    % white [0 0 0] is black, of course.
    my_poke_colors = struct( ...
      'L',                  0.6*[1 0.66 0],    ...
      'C',                      [0 0 0],       ...
      'R',                  0.9*[1 0.66 0]);
    
    [x, y] = PokesPlotSection(obj, 'init', x, y, ... % Initiates PokesPlotSection
      struct('states',  my_state_colors, 'pokes', my_poke_colors)); 
    %X&Y are the default position of the button that PokesPlot adds to the
    %Saving Section Figure(there is probably a next_line(y) missing somewhere)
    %in this case if the nTrials param position is not set as well 
    %it will overlap and dissapear. P.S. I removed the nTrials from the
    %final GUI.
    PokesPlotSection(obj, 'hide');%this hides pokesplot
    PokesPlotSection(obj, 'set_alignon', 'center_valve_click(1,2)');%this sets the align at the end of center_valve_click
%   Next two lines set the Xaxis limits for the PokesPlot (don't understand them compleatly but thanks to Santiago Jaramillo's protocol)  
    ThisSPH=get_sphandle('owner', mfilename, 'name','t0'); ThisSPH{1}.value = -10;
    ThisSPH=get_sphandle('owner', mfilename, 'name','t1'); ThisSPH{1}.value = 10;
    next_row(y); % I think I could remove this....?
%     SubheaderParam(obj, 'title', 'Poke twice in the ctr to move to next trial', x, y); next_row(y);
    
    % Make the main figure window as wide as it needs to be and as tall as
    % it needs to be; that way, no matter what each plugin requires in terms of
    % space, we always have enough space for it.
%    pos = get(value(myfig), 'Position');                 
%    set(value(myfig), 'Position', [pos(1:2) x+240 y+25]);
%This I removed because it was screwing up my positioning of the fig's and
%do not quite understand why it is set up like this in the original script.

% OK, usually the case 'init' of a protocol ends with the following line,
% but, because we set the callback for the button 'submit' the line is
% commented out. the button will replace this line however you will not be
% able to run the protocol if you don't submit first. This is good so you
% can always double check your settings before starting the session
%     StateMatrixSection(obj, 'init');
    
  %---------------------------------------------------------------
  %          CASE PREPARE_NEXT_TRIAL
  %---------------------------------------------------------------
% The next cases are just set up with outputs so to understand when (during
% the protocol) each case happens. If you want your protocol to do
% something at a particukar moment during each trial you can use these
% cases...
    
  case 'prepare_next_trial'
    fprintf(1, 'Got to a prepare_next_trial state -- making the next state matrix\n');
    StateMatrixSection(obj, 'next_trial');
    
  %---------------------------------------------------------------
  %          CASE TRIAL_COMPLETED
  %---------------------------------------------------------------
  case 'trial_completed'
    fprintf(1, ['\nFrom the beginning of this trial #%d to the\n' ...
      'start of the next, %g seconds elapsed.\n\n'], n_done_trials, ...
      parsed_events.states.state_0(2,1) - parsed_events.states.state_0(1,2));

  %You need to inform the PokesPlot Plugin at what moment of the trial you
  %are so here should go:
  PokesPlotSection(obj, 'trial_completed'); 
    
  %---------------------------------------------------------------
  %          CASE UPDATE
  %---------------------------------------------------------------
  case 'update'

%       I commented this out because it was annoying!!
%     if ~isempty(latest_parsed_events.states.starting_state),
%       fprintf(1, 'Somep''n happened! Since the last update, we''ve moved from state "%s" to state "%s"\n', ...
%         latest_parsed_events.states.starting_state, latest_parsed_events.states.ending_state);
%     end;
      
    %And here should go this otherwise you will not see the plotting as it
    %happens trial by tial.
  PokesPlotSection(obj, 'update');
  %---------------------------------------------------------------
  %          CASE CLOSE
  %---------------------------------------------------------------
  case 'close'
    
%     In the event of a close command this is what will happen:  
    delete(value(nfig));
    delete(value(myfig));
    PokesPlotSection(obj, 'close');
    
  otherwise,
    warning('Unknown action! "%s"\n', action);
end;

return;