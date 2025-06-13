function [obj] = nprotocol2(varargin)
    obj = class(struct, mfilename, pokesplot, saveload, soundmanager); 
    
    GetSoloFunctionArgs;

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
if ~isstr(action), error('The action parameter must be a string'); end; %#ok<FDEPR>

GetSoloFunctionArgs(obj);

%---------------------------------------------------------------
%   END OF SECTION COMMON TO ALL PROTOCOLS, MODIFY AFTER THIS LINE
%---------------------------------------------------------------


switch action,

    
  case 'init'

      SoloParamHandle(obj, 'myfig', 'saveable', 0); myfig.value = figure; %janela

    name = 'nPv2.1';
    set(value(myfig), 'Name', name, 'Tag', name, ...
      'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');

    set(value(myfig), 'Position', [470 50 630 720]);   
  
    x = 10; y = 10;            
% --------------------------
nprotocol2_gui(obj, 'init', x, y);
% --------------------------
    x = 10; y = 430;
    next_row(y);
    next_row(y);
    next_row(y);
    next_row(y);
      [x, y] = SavingSection(obj, 'init', x, y);  
   
       my_state_colors = struct( ...
      'waiting_4_cin', [0.5 0.5 1], ... [0.75 0.75 0.75]
      'l_poke_in_dummy_two', [0.5 0.5 0.5], ... grey 
      'r_poke_in_dummy_two', [0.5 0.5 0.5], ... grey
      'c_poke_1', [0.75 0.5 0.5], ... [0.5 0.5 0.5]
      'c_poke_2', [0.75 0.25 0.25], ...
      'waiting_4_both', [0.75 0 0], ... 
      'l_poke_in_shock_start', [0 1 1], ... [0.25 0.5 1]
      'l_poke_out', [0 1 0], ... [0 0 1]
      'l_poke_in_shock', [0.25 1 0], ... [0.5 1 0.75]
      'l_c_poke_in', [0.25 1 0.25], ... [0 1 0]
      'l_r_poke_in', [0.25 1 0.25], ... [0.5 0.5 1]
      'r_poke_in_shock_start', [0 1 1], ... [0.5 1 0.5]
      'r_poke_out', [0 1 0], ... [1 0.5 0.5]
      'r_poke_in_shock', [0.25 1 0], ... [0.5 0.5 0.5]
      'r_c_poke_in', [0.25 1 0.25], ... [0.5 0.5 0]
      'r_l_poke_in', [0.25 1 0.25], ... [0.5 0 0.5]
      'l_poke_in_dummy', [0.5 0.5 0.5], ... [0 0.5 0.5]
      'c_poke_in_dummy', [0.5 0.5 0.5], ... [0 0 0]
      'r_poke_in_dummy', [0.5 0.5 0.5], ... [1 1 1]
      'idle', [0 0 0], ... [0.5 0 0]
      'check_next_trial_ready', [1 1 1], ...%[0.7 0.7 0.7]
      'state_0', [1 1 1]);
  
    my_poke_colors = struct( ...
      'L',                  0.6*[1 0.66 0],    ...
      'C',                      [0 0 0],       ...
      'R',                  0.9*[1 0.66 0]);
    
    PokesPlotSection(obj, 'init', x, y, ... 
      struct('states',  my_state_colors, 'pokes', my_poke_colors)); 
%    set(value(PokesPlotSection.myfig), 'Position', [520 100 240 235]);
%     PokesPlotSection(obj, 'show');
    PokesPlotSection(obj, 'set_alignon', 'c_poke_1(1,1)');
    ThisSPH=get_sphandle('owner', mfilename, 'name','t0'); ThisSPH{1}.value = -5; %#ok<NASGU>
    ThisSPH=get_sphandle('owner', mfilename, 'name','t1'); ThisSPH{1}.value = 25; %#ok<NASGU>
    ThisSPH=get_sphandle('owner', mfilename, 'name','trial_limits'); ThisSPH{1}.value = 1; %#ok<NASGU>
    ThisSPH=get_sphandle('owner', mfilename, 'name','ntrials'); ThisSPH{1}.value = 25; %#ok<NASGU>
    ThisSPH=get_sphandle('owner', mfilename, 'name','interactive_by_default'); ThisSPH{1}.value = 0; %#ok<NASGU>
    ThisSPH=get_sphandle('owner', mfilename, 'name','ratname'); ThisSPH{1}.value = 'GD0'; %#ok<NASGU>
    ThisSPH=get_sphandle('owner', mfilename, 'name','experimenter'); ThisSPH{1}.value = 'GNP'; %#ok<NASGU>
    
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
% next_row(y);
 
% [x, y] = SidesPlotSection(obj, 'init', x, y);

%     [x, y, submit, timeOut, timeOutMenu, rightValve, leftValve, valveMenu, ...
%     rPokePVO, preambleMenu, cClickTime, cPokeTime, poketimeMenu] = 

% nprotocol2_gui(obj, 'init', x, y);

% RESET POSITION F DISPATCHER AND POKESPLOT
        a = findobj('type','figure');
        [b c] = sort(a);
        set(a(c(1)), 'position', [50 50 405 460]);
        set(a(c(6)), 'position', [1105 50 405 735]); %6 in emulator %3 in rig
        nPlot(obj, 'init');
  case 'prepare_next_trial'
    fprintf(1, 'Got to a prepare_next_trial state -- making the next state matrix\n');
    StateMatrixSection2(obj, 'next_trial');
    
 
  case 'trial_completed'
%     fprintf(1, ['\nFrom the beginning of this trial #%d to the\n' ...
%       'start of the next, %g seconds elapsed.\n\n'], n_done_trials, ...
%       parsed_events.states.state_0(2,1) - parsed_events.states.state_0(1,2));

  PokesPlotSection(obj, 'trial_completed'); 
  nPlot(obj, 'next_trial');  
  paramChange(obj, 'water');
 
  case 'update'
%     if ~isempty(latest_parsed_events.states.starting_state),
%       fprintf(1, 'Somep''n happened! Since the last update, we''ve moved from state "%s" to state "%s"\n', ...
%         latest_parsed_events.states.starting_state, latest_parsed_events.states.ending_state);
%     end;
  PokesPlotSection(obj, 'update');
  nLaser(obj, 'update');
 

  case 'close'
%     delete(value(nfig));
    delete(value(myfig)); %#ok<NODEF>
    PokesPlotSection(obj, 'close');
    
  otherwise,
    warning('Unknown action! "%s"\n', action); %#ok<WNTAG>
end;

return;