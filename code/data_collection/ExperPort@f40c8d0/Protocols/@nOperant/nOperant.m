function [obj] = nprotocol(varargin)
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

      SoloParamHandle(obj, 'myfig', 'saveable', 0); myfig.value = figure; %janela

    name = 'nOv1.0';
    set(value(myfig), 'Name', name, 'Tag', name, ...
      'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');

    set(value(myfig), 'Position', [470 50 220 385]);   
  
    x = 10; y = 10;            

    [x, y] = SavingSection(obj, 'init', x, y);  
   
       my_state_colors = struct( ...
      'waiting_4_both', [1 0 1], ... [0.75 0.75 0.75]
      'l_poke_in', [0 0 1], ...
      'r_poke_in', [0 1 0], ... 
      'end_state', [0 0 0]);
  
    my_poke_colors = struct( ...
      'L',                  0.6*[1 0.66 0],    ...
      'C',                      [0 0 0],       ...
      'R',                  0.9*[1 0.66 0]);
    
    [x, y] = PokesPlotSection(obj, 'init', x, y, ... 
      struct('states',  my_state_colors, 'pokes', my_poke_colors)); 
    PokesPlotSection(obj, 'show');
    PokesPlotSection(obj, 'set_alignon', 'c_poke_1(1,1)');
    ThisSPH=get_sphandle('owner', mfilename, 'name','t0'); ThisSPH{1}.value = -5;
    ThisSPH=get_sphandle('owner', mfilename, 'name','t1'); ThisSPH{1}.value = 25;
    ThisSPH=get_sphandle('owner', mfilename, 'name','trial_limits'); ThisSPH{1}.value = 1;
    ThisSPH=get_sphandle('owner', mfilename, 'name','ntrials'); ThisSPH{1}.value = 25;
    ThisSPH=get_sphandle('owner', mfilename, 'name','interactive_by_default'); ThisSPH{1}.value = 0;
    ThisSPH=get_sphandle('owner', mfilename, 'name','ratname'); ThisSPH{1}.value = 'GD0';
    ThisSPH=get_sphandle('owner', mfilename, 'name','experimenter'); ThisSPH{1}.value = 'GNP';

    NumeditParam(obj, 'timeOut', 5, x, y, 'TooltipString', 'Time Out.');next_row(y);
    NumeditParam(obj, 'rValve', 0.15, x, y, 'TooltipString', 'Right Valve Open Time.');next_row(y);
    NumeditParam(obj, 'lValve', 0.15, x, y, 'TooltipString', 'Left Valve Open Time.');next_row(y);
%     NumeditParam(obj, 'rpokeTime', 0.1, x, y, 'TooltipString', 'Latency between right poke and valve open.');next_row(y);
%     NumeditParam(obj, 'lpokeTime', 0.1, x, y, 'TooltipString', 'Latency between left poke and valve open.');next_row(y);
    NumeditParam(obj, 'ratWeight', 0, x, y, 'TooltipString', 'Rat''s weight');next_row(y); 
    MenuParam(obj, 'click_or_sound', {'SOUND', 'CLICK'}, 1, x, y);next_row(y);
    MenuParam(obj, 'click_or_sound_onSidePoke',{'NO', 'YES'}, 1, x, y, 'TooltipString', ...
        'Associate click or sound with side water?',  'labelfraction', 0.65);next_row(y);   
    PushbuttonParam(obj, 'nSwitch', x, y, 'position', [x y 200 45], 'BackgroundColor', [0.75 0.75 0.80]);%
    set_callback(nSwitch, {'nSwitch', 'init'});
% RESET POSITION F DISPATCHER AND POKESPLOT
        a = findobj('type','figure');
        [b c] = sort(a);
        set(a(c(1)), 'position', [50 50 405 550]);
        set(a(c(6)), 'position', [705 50 405 735]); %6 in emulator %3 in rig
  
        DeclareGlobals(obj, 'rw_args', {'timeOut', 'rValve', 'lValve', ...
        'nSwitch', 'ratWeight', 'click_or_sound_onSidePoke', 'click_or_sound'});
        
  SoundSection(obj, 'init');      
  StateMatrixSection(obj, 'init');
  
  
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
%     delete(value(nfig));
    delete(value(myfig));
    PokesPlotSection(obj, 'close');
    
    
  otherwise,
    warning('Unknown action! "%s"\n', action);
    
    
end;

return;