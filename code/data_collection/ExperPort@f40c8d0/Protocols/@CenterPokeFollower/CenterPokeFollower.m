function [obj] = CenterPokeFollower(varargin)

% Default object is of our own class (mfilename); in this simplest of
% protocols, we will not inherit any elements from Plugins/

obj = class(struct, mfilename, pokesplot);



% ----------------------- START DO NOT MODIFY SECTION -----
% If creating an empty object, return without further ado:
if nargin==0 || (nargin==1 && ischar(varargin{1}) && strcmp(varargin{1}, 'empty')), 
   return; 
end;

if isa(varargin{1}, mfilename), % Most likely responding to a callback from 
                                % a SoloParamHandle defined in this mfile.
  if length(varargin) < 2, 
    error(['If called with a "%s" object as first arg, a second arg, a ' ...
      'string specifying the action, is required\n']);
  else action = varargin{2}; varargin = varargin(3:end);
  end;
else % Ok, regular call with first param being the action string.
       action = varargin{1}; varargin = varargin(2:end);
end;

GetSoloFunctionArgs(obj);
% ----------------------- END DO NOT MODIFY SECTION -----


switch action,

  %---------------------------------------------------------------
  %          CASE INIT
  %---------------------------------------------------------------
  
  case 'init'

    % Make default figure. We remember to make it non-saveable; on next run
    % the handle to this figure might be different, and we don't want to
    % overwrite it when someone does load_data and some old value of the
    % fig handle was stored as SoloParamHandle "myfig"
    SoloParamHandle(obj, 'myfig', 'saveable', 0); myfig.value = figure;

    % Make the title of the figure be the protocol name, and if someone tries
    % to close this figure, call dispatcher's close_protocol function, so it'll know
    % to take it off the list of open protocols.
    name = mfilename;
    set(value(myfig), 'Name', name, 'Tag', name, ...
      'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');



    % At this point we have one SoloParamHandle, myfig
    % Let's put the figure where we want it and give it a reasonable size:
    set(value(myfig), 'Position', [485   144   300   300]);

    % ----------

    x = 5; y = 5;             % Initial position on main GUI window

    DispParam(obj, 'nTrials', 0, x, y); next_row(y);
    % For plotting with the pokesplot plugin, we need to tell it what
    % colors to plot with:
    my_state_colors = struct( ...
      'wait_for_cpoke1',        [0.5 0.5 1],   ...
      'wait_for_cpoke2',        [0.5 1 0.5],   ...
      'state_0',                [1 1 1],       ...
      'final_state',            [0.5 0 0],     ...
      'check_next_trial_ready', [0.7 0.7 0.7]);
    % In pokesplot, the poke colors have a default value, so we don't need
    % to specify them, but here they are so you know how to change them.
    my_poke_colors = struct( ...
      'L',                  0.6*[1 0.66 0],    ...
      'C',                      [0 0 0],       ...
      'R',                  0.9*[1 0.66 0]);
    
    [x, y] = PokesPlotSection(obj, 'init', x, y, ...
      struct('states',  my_state_colors, 'pokes', my_poke_colors));
        
    SoloParamHandle(obj, 'ax', 'value', axes('Units', 'pixels', 'Position', [x+20 y+20 200 120])); y = y+140;
    SoloParamHandle(obj, 'timepoints', 'value', 0);
    SoloParamHandle(obj, 'Cvalue',     'value', 0);
    SoloParamHandle(obj, 'h', 'value', plot(value(timepoints), value(Cvalue)));
    set(value(ax), 'YLim', [-0.1 1.1], 'XLim', [-0.1 0.1]);
    
    % Make the main figure window as wide as it needs to be and as tall as it
    % needs to be; that way, no matter what each plugin requires in terms of
    % space, we always have enough space for it.
    pos = get(value(myfig), 'Position');
    set(value(myfig), 'Position', [pos(1:2) x+240 y+25]);

    
    sma = StateMachineAssembler('full_trial_structure');
    sma = add_state(sma, 'name', 'wait_for_cpoke1', ...
      'input_to_statechange', {'Cin', 'wait_for_cpoke2'});
    sma = add_state(sma, 'name', 'wait_for_cpoke2', ...
      'input_to_statechange', {'Cin', 'final_state'});
    sma = add_state(sma, 'name', 'final_state', ...
      'self_timer', 2, 'input_to_statechange', {'Tup', 'check_next_trial_ready'});
    dispatcher('send_assembler', sma, 'final_state');
    
    
    
  %---------------------------------------------------------------
  %          CASE PREPARE_NEXT_TRIAL
  %---------------------------------------------------------------
  case 'prepare_next_trial'
    feval(mfilename, 'update');

    nTrials.value = n_done_trials;

    sma = StateMachineAssembler('full_trial_structure');
    sma = add_state(sma, 'name', 'wait_for_cpoke1', ...
      'input_to_statechange', {'Cin', 'wait_for_cpoke2'});
    sma = add_state(sma, 'name', 'wait_for_cpoke2', ...
      'input_to_statechange', {'Cin', 'final_state'});
    sma = add_state(sma, 'name', 'final_state', ...
      'self_timer', 2, 'input_to_statechange', {'Tup', 'check_next_trial_ready'});
    dispatcher('send_assembler', sma, 'final_state');

    
  %---------------------------------------------------------------
  %          CASE TRIAL_COMPLETED
  %---------------------------------------------------------------
  case 'trial_completed'
    feval(mfilename, 'update');
    PokesPlotSection(obj, 'trial_completed');
    
  %---------------------------------------------------------------
  %          CASE UPDATE
  %---------------------------------------------------------------
  case 'update'
    C = latest_parsed_events.pokes.C;
    for i=1:size(C,1),
      if ~isnan(C(i,1)), 
        Cvalue.value     = [value(Cvalue) ; 0 ; 1];
        timepoints.value = [value(timepoints) ; C(i,1) ; C(i,1)];
      end;
      if ~isnan(C(i,2)),
        Cvalue.value     = [value(Cvalue) ; 1 ; 0];
        timepoints.value = [value(timepoints) ; C(i,2) ; C(i,2)];
      end;        
    end;
      
    Cvalue.value     = [value(Cvalue) ; Cvalue(length(Cvalue))];
    timepoints.value = [value(timepoints) ; dispatcher('get_time')];
    
    set(value(h), 'XData', value(timepoints), 'YData', value(Cvalue));
    xlims = get(value(ax), 'Xlim');
    if timepoints(length(timepoints)) > xlims(2),
      set(value(ax), 'Xlim', [xlims(1) timepoints(length(timepoints))+10]);
    end;
    xlims = get(value(ax), 'Xlim');
    if diff(xlims)>20,
      set(value(ax), 'Xlim', [xlims(2)-20, xlims(2)]);
    end;
    
    PokesPlotSection(obj, 'update');
    
    
  %---------------------------------------------------------------
  %          CASE CLOSE
  %---------------------------------------------------------------
  case 'close'
    PokesPlotSection(obj, 'close');
    if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)),
      delete(value(myfig));
    end;
    delete_sphandle('owner', ['^@' class(obj) '$']);

  otherwise,
    warning('Unknown action! "%s"\n', action);
end;

return;


