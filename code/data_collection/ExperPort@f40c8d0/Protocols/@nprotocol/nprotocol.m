function [obj] = nprotocol(varargin)
    obj = class(struct, mfilename, pokesplot, saveload); 
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


switch action,

    
  case 'init'

    SoloParamHandle(obj, 'nfig', 'saveable', 0); nfig.value = figure;
     name = 'nWSL';
        set(value(nfig), 'Name', name, 'Tag', name, ...
          'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');
        set(value(nfig), 'Position', [520 370 240 400]);%[775 100 220 400]

    SubheaderParam(obj, 'valveMenu', 'Solenoid Times', 20, 370);
    NumeditParam(obj, 'centerLed', 0.3, 20, 350, 'TooltipString', 'Time of center led cue.');
    NumeditParam(obj, 'leftValve', 0.3, 20, 330, 'TooltipString', 'Opening time of left solenoid.');
    NumeditParam(obj, 'rightValve', 0.3, 20, 310, 'TooltipString', 'Opening time of right solenoid.');

    SubheaderParam(obj, 'latencyMenu', 'Poke-Valve Latency', 20, 280);
    NumeditParam(obj, 'cpokeTime', 0.3, 20, 260, 'TooltipString', 'Latency between center poke and valve open.');
    NumeditParam(obj, 'lpokeTime', 0.3, 20, 240, 'TooltipString', 'Latency between left poke and valve open.');
    NumeditParam(obj, 'rpokeTime', 0.3, 20, 220, 'TooltipString', 'Latency between right poke and valve open.');

    SubheaderParam(obj, 'shockMenu', 'Shock', 20, 190);
    NumeditParam(obj, 'shockProp', 0.0, 20, 170, 'TooltipString', 'Proportion of SHOCKS/trials.');
    MenuParam(obj, 'LRshock', {'null' 'Left' 'Right'}, 1, 20, 150, 'TooltipString', 'Side of SHOCK delivery.');
    NumeditParam(obj, 'shockStart_after', 0, 20, 130, 'TooltipString', 'Start Shock Trials after...');
    
    SubheaderParam(obj, 'laserMenu', 'LASER', 20, 100);
    NumeditParam(obj, 'laserProp', 0.0, 20, 80, 'TooltipString', 'Proportion of LASER/trials.');
%     NumeditParam(obj, 'laserTime', 0.3, 20, 80, 'TooltipString', 'duration of LASER pulse.');
    MenuParam(obj, 'LRlaser', {'null' 'Left' 'Right'}, 1, 20, 60, 'TooltipString', 'Side of LASER pulse delivery.');

    PushbuttonParam(obj, 'submit', 20, 10, 'position', [20 10 200 45],'BackgroundColor', [0 0 1]);
    set_callback(submit, {'StateMatrixSection', 'init'}); %i, sprintf('\n')});
%     get_PushButtonParam.submit.value('position')=[20 20 20 100];
% set(value(submit), 'position', [20 20 20 300]);
    DeclareGlobals(obj, 'rw_args', {'centerLed', 'leftValve', 'rightValve', 'cpokeTime', 'lpokeTime', ...
        'rpokeTime', 'shockProp', 'LRshock', 'laserProp', 'LRlaser', 'submit', 'shockStart_after'});%, 'laserTime'

    % DeclareGlobals(obj, {'rw_args','leftValve'}, {'ro_args', 'rightValve'},{'owner', class(obj)});

    SoloParamHandle(obj, 'myfig', 'saveable', 0); myfig.value = figure; %janela

    name = 'Saving Section Figure';
    set(value(myfig), 'Name', name, 'Tag', name, ...
      'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');

    set(value(myfig), 'Position', [520 100 240 235]);   
  
    x = 20; y = 20;            

    [x, y] = SavingSection(obj, 'init', x, y);  
   
       my_state_colors = struct( ...
      'waiting_4_cin', [0.75 0.75 0.75], ...
      'waiting_4_cout', [0.5 0.5 0.5], ...
      'center_valve_click', [0.75 0.25 0.25], ...
      'waiting_4_both', [0.75 0 0], ... 
      'wait_4_leftvalveon', [0.25 0.5 1], ...
      'wait_4_rightvalveon', [0.5 1 0.75], ...
      'deliver_water_shock_left', [0 0 0.5], ...
      'deliver_water_left', [0 0 1], ...
      'deliver_water_shock_right', [0 0.5 0], ...
      'deliver_water_right', [0 1 0]);
%      'waiting_4_cin', [0.5 0.5 1], ...
%      'waiting_4_cout', [0.5 1 0.5], ...
%      'center_valve_click', [1 0.5 0.5], ...
%      'waiting_4_both', [0.5 0.5 0.5], ... 
%      'wait_4_leftvalveon', [0.5 0.5 0], ...
%      'wait_4_rightvalveon', [0.5 0 0.5], ...
%      'deliver_water_left', [0 0.5 0.5], ...
%      'deliver_water_right', [0 0 0]);
%      'state_0', [1 1 1], ...
%      'final_state', [0.5 0 0], ...
%      'check_next_trial_ready', [0.7 0.7 0.7]);
  
    my_poke_colors = struct( ...
      'L',                  0.6*[1 0.66 0],    ...
      'C',                      [0 0 0],       ...
      'R',                  0.9*[1 0.66 0]);
    
    [x, y] = PokesPlotSection(obj, 'init', x, y, ... 
      struct('states',  my_state_colors, 'pokes', my_poke_colors)); 
%    set(value(PokesPlotSection.myfig), 'Position', [520 100 240 235]);
    PokesPlotSection(obj, 'hide');
    PokesPlotSection(obj, 'set_alignon', 'center_valve_click(1,2)');
    ThisSPH=get_sphandle('owner', mfilename, 'name','t0'); ThisSPH{1}.value = -10;
    ThisSPH=get_sphandle('owner', mfilename, 'name','t1'); ThisSPH{1}.value = 10;
%     PokesPlotSection(obj, 'time_axes', '-10 +10');
%     set(value(axpokesplot), 'XLim', [value(t0) value(t1)]);
%     set(value(PokesPlotSection(obj, 't0', 'value', -10)));
%     SoloParamHandle(obj, 't0', 'value', -10);

%   % Left edge of pokes plot:
%     SoloParamHandle(obj, 't0', 'label', 't0', 'type', 'numedit', 'value', -4, ...
%       'position', [165 1 60 20], 'TooltipString', 'time axis left edge');
%     % Right edge of pokes plot:
%     SoloParamHandle(obj, 't1', 'label', 't1', 'type', 'numedit', 'value', 15, ...
%       'position', [230 1 60 20], 'TooltipString', 'time axis right edge');
%     set_callback({t0;t1}, {mfilename, 'time_axis'});
next_row(y);

    
  case 'prepare_next_trial'
    fprintf(1, 'Got to a prepare_next_trial state -- making the next state matrix\n');
    StateMatrixSection(obj, 'next_trial');
    
 
  case 'trial_completed'
    fprintf(1, ['\nFrom the beginning of this trial #%d to the\n' ...
      'start of the next, %g seconds elapsed.\n\n'], n_done_trials, ...
      parsed_events.states.state_0(2,1) - parsed_events.states.state_0(1,2));

  PokesPlotSection(obj, 'trial_completed'); 
    
 
  case 'update'
%     if ~isempty(latest_parsed_events.states.starting_state),
%       fprintf(1, 'Somep''n happened! Since the last update, we''ve moved from state "%s" to state "%s"\n', ...
%         latest_parsed_events.states.starting_state, latest_parsed_events.states.ending_state);
%     end;
      
  PokesPlotSection(obj, 'update');
 
  
  case 'close'
    delete(value(nfig));
    delete(value(myfig));
    PokesPlotSection(obj, 'close');
    
  otherwise,
    warning('Unknown action! "%s"\n', action);
end;

return;