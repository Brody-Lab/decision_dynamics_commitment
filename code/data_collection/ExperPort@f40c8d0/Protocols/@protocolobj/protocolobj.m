function [obj] = protocolobj(a, varargin)

pairs = { ...
    'child', []       ; ...
    'fig_position', []  ; ...
    }; 
parse_knownargs(varargin, pairs);

% -------- BEGIN Magic code that all protocol objects must have ---
% Default object:
obj = struct('empty', []);
obj = class(obj, mfilename);

% If creating an empty object, return without further ado:
if nargin==1 && strcmp(a, 'empty'), return; end;

% ------- Non-empty: proceed with regular init of this object -----

% Delete previous vars owned by this object:
delete_sphandle('owner', mfilename); 

if isstr(a), 
    SoloParamHandle(obj, 'protocol_name', 'value', lower(a)); 
end;

% Set reference to child object
SoloParamHandle(obj, 'mychild', 'value', child);
child_class = ['@' class(value(mychild))];

% Make default figure. Remember to make it non-saveable; on next run
% the handle to this figure might be different, and we don't want to
% overwrite it when someone does load_data and some old value of the
% fig handle was stored there...

SoloParamHandle(obj, 'myfig', 'saveable', 0, 'param_owner', child_class, 'param_funcowner', class(value(mychild))); myfig.value = figure;
SoloFunction('close', 'ro_args', 'myfig');
set(value(myfig), ...
    'Name', value(protocol_name), 'Tag', value(protocol_name), ...
    'closerequestfcn', ['ModuleClose(''' value(protocol_name) ''')'], ...
    'NumberTitle', 'off', 'MenuBar', 'none');

% -------- END Magic code that all protocol objects must have ---

SoloFunction('define_function', 'rw_args', 'mychild');

set(value(myfig), 'Position', fig_position);

%SoloParamHandle(obj, 'Max_Trials',    'value', 150, 'param_owner', child_class, 'param_funcowner', class(value(mychild)));
SoloParamHandle(obj, 'n_done_trials',    'value', 0, 'param_owner', child_class, 'param_funcowner', class(value(mychild)));
SoloParamHandle(obj, 'n_started_trials', 'value', 0, 'param_owner', child_class, 'param_funcowner', class(value(mychild)));
SoloParamHandle(obj, 'maxtrials',        'value', 1000, 'param_owner', child_class, 'param_funcowner',class(value(mychild)));
SoloParamHandle(obj, 'hit_history',      'value', NaN*ones(1, value(maxtrials)), 'param_owner', child_class, ...
'param_funcowner', class(value(mychild)));

x = 20; y = 5;                     % Position on GUI
HeaderParam(obj, 'bottom', '', x, y, 'width', fig_position(3));

next_row(y);

[x, y, Notes,ratname,experimenter] = SavingSection(obj, 'init', x, y,mychild);  

next_row(y,1.5);
% New stuff for SavingSection --------------------------------------
NumeditParam(obj, 'Max_Trials', 999, x, y, 'position', [x y 120 20], ...
    'param_owner', child_class, 'param_funcowner', class(value(mychild)), ...
             'label', 'Session Length','labelfraction', 0.8, ...
             'TooltipString', 'After this # of trials, protocol will stop');
         
NumeditParam(obj, 'MaxMins', 105, x, y, 'position', [x+110 y 80 20], ...
     'param_owner', child_class, 'param_funcowner', class(value(mychild)), ...
             'label', 'MaxMins','labelfraction', 0.65, ...
             'TooltipString', 'After this # of mins, protocol will stop');
next_row(y,2);


  % States required for a generic trial. Child classes may add more states.
  % Note: Although states are provided, the state transition matrix is not; the child class
  % defines its own transition matrix.
 SoloParamHandle(obj, 'RealTimeStates', 'value', struct(...
  'wait_for_cpoke', 0, ...  % Waiting for initial center poke
  'pre_chord',      0, ...  % Silent period preceeding GO signal
  'chord',          0, ...  % GO signal
  'wait_for_apoke', 0, ...  % Waiting for an answer poke (after GO signal)
  'left_dirdel',    0, ...  % Direct delivery on LHS
  'right_dirdel',   0, ...  % Direct delivery on RHS
  'left_reward',    0, ...  % Reward obtained on LHS
  'right_reward',   0, ...  % Reward obtained on RHS
  'drink_time',     0, ...  % Silent time to permit drinking
  'timeout',        0, ...  % Penalty state
  'iti',            0, ...  % Intertrial interval
  'dead_time',      0, ...  % 'Filler' state needed because of Matlab lag in sending next state machine
  'state35',        0, ...  % End-of-trial state (the state number is an ancient convention)
  'extra_iti',      0), ... % State of penalty within ITI (occurs if rat pokes during ITI - usually longer than ITI)
  'param_owner', child_class, 'param_funcowner', class(value(mychild)));

SoloParamHandle(obj, 'LastTrialEvents', 'value', [], 'param_owner', child_class, 'param_funcowner', class(value(mychild)));


% ----------- Finally we manually set all necessary parameters in the
% child's workspace

%Set in child's workspace
to_assign = {'myfig', ...
    'n_done_trials', 'n_started_trials', 'maxtrials',  'MaxMins','Max_Trials','hit_history', ...   % 'RightWValve', 'LeftWValve',  ...
    'LastTrialEvents', 'RealTimeStates', 'Notes', 'ratname', 'experimenter',...
    'x', 'y'};
for s = 1:length(to_assign)
    assignin('caller', to_assign{s}, eval(to_assign{s}));
end;
