function [obj] = solo_watervalve2obj(a)

% -------- BEGIN Magic code that all protocol objects must have ---
% Default object:
obj = struct('empty', []);
obj = class(obj, mfilename);

% If creating an empty object, return without further ado:
if nargin==0 | (nargin==1 && ischar(a) && strcmp(a, 'empty')), return; end;

delete_sphandle('owner', mfilename); % Delete previous vars owned by this object

% Non-empty: proceed with regular init of this object
if nargin==1 && isstr(a), 
    SoloParamHandle(obj, 'protocol_name', 'value', lower(a)); 
end;

% Make default figure. Remember to make it non-saveable; on next run
% the handle to this figure might be different, and we don't want to
% overwrite it when someone does load_data and some old value of the
% fig handle was stored there...
SoloParamHandle(obj, 'myfig', 'saveable', 0); myfig.value = figure;
SoloFunction('close', 'ro_args', 'myfig');
set(value(myfig), ...
    'Name', value(protocol_name), 'Tag', value(protocol_name), ...
    'closerequestfcn', ['ModuleClose(''' value(protocol_name) ''')'], ...
    'NumberTitle', 'off', 'MenuBar', 'none');

% -------- END Magic code that all protocol objects must have ---


fig_position = [485   244   500   300];
set(value(myfig), 'Position', fig_position);

x = 1; y = 1;                     % Position on GUI

next_row(y);

PushbuttonParam(obj, 'go', x, y, 'label', 'START dispensing', ...
                'position', [x y 100 20]); 
set_callback(go, {'make_and_upload_state_matrix', 'start_matrix'});

PushbuttonParam(obj, 'stop', x, y, 'label', 'STOP dispensing', ...
                'position', [x+100 y 100 20]); 
set_callback(stop, {'make_and_upload_state_matrix', 'stop_matrix'});

next_row(y, 1.5);

NumeditParam(obj, 'num_pulses', 100, x, y, 'label', '# pulses'); next_row(y);
NumeditParam(obj, 'ipi', 1, x, y, 'label', 'Inter-pulse interval');
next_row(y, 2);

NumeditParam(obj, 'right_time', 0.15, x, y, 'label', 'Right Time', ...
             'position', [x, y, 100, 20], 'labelfraction', 0.55);
NumeditParam(obj, 'right_weight', 0, x, y, 'label', 'grams', ...
             'position', [x+110 y 80 20], 'labelfraction', 0.55);
DispParam(obj, 'right_dispense', 0, x, y, 'label', 'ul/dispense', ...
             'position', [x+200 y 90 20], 'labelfraction', 0.65);
NumeditParam(obj, 'right_target', 24, x, y, 'label', 'Rt target', ...
             'position', [x+300 y 95 20], 'labelfraction', 0.65); 
NumeditParam(obj, 'right_suggest', 0, x, y, 'label', 'suggestion', ...
             'position', [x+400 y 95 20], 'labelfraction', 0.6);
PushbuttonParam(obj, 'generate', x, y, 'position', [x+420 y-21 60 20], ...
                'TooltipString', sprintf(['Given the targets, generate ' ...
                    'suggestions for\n ' ...
                    'both left1water and right1water from the existing\n' ...
                    'table entries (without any unentered current\n' ...
                    'measurements).']), ... % 'BackgroundColor', [0.3 1 0.3],
                'FontWeight', 'normal', 'label', '(generate)');

next_row(y);
NumeditParam(obj, 'left_time', 0.15, x, y, 'label', 'Left Time', ...
             'position', [x, y, 100, 20], 'labelfraction', 0.55);
NumeditParam(obj, 'left_weight', 0, x, y, 'label', 'grams', ...
             'position', [x+110 y 80 20], 'labelfraction', 0.55);
DispParam(obj, 'left_dispense', 0, x, y, 'label', 'ul/dispense', ...
             'position', [x+200 y 90 20], 'labelfraction', 0.65);
NumeditParam(obj, 'left_target', 24, x, y, 'label', 'Lt target', ...
             'position', [x+300 y 90 20], 'labelfraction', 0.65); 
NumeditParam(obj, 'left_suggest', 0, x, y, 'label', 'suggestion', ...
             'position', [x+400 y 95 20], 'labelfraction', 0.6);
next_row(y, 1.5);

SoloParamHandle(obj, 'table', 'value', WaterCalibrationTable);

if strcmp(computer, 'PCWIN'), fontsize = 8; else fontsize = 12; end;
ListboxParam(obj, 'list_table', cellstr(value(table)), ...
             length(cellstr(value(table))), ...
             x, y, 'position', [x y 400 100], ...
             'FontName', 'Courier', 'FontSize', fontsize);

next_column(x); y=1; next_row(y, 2); x = x+10;
NumeditParam(obj, 'error_tol', 5, x, y, 'label', '% Error tolerance', ...
             'position', [x y 130 20], 'labelfraction', 0.7); 
EditParam(obj, 'initials', '', x, y, 'position', [x+150, y, 100, 20]);


PushbuttonParam(obj, 'delete_entry', 420, 180, 'label', 'DELETE entry', ...
                'position', [410, 180 80, 30]);
PushbuttonParam(obj, 'add_entry', 420, 180, 'label', 'ADD entry', ...
                'position', [410, 225 80, 30]);

SoloFunctionAddVars('delete_entry', 'rw_args', {'table', 'list_table'});
SoloFunctionAddVars('add_entry', 'ro_args', {'right_time', 'left_time', ...
                    'right_dispense', 'left_dispense', 'initials'}, ...
                    'rw_args', {'table', 'list_table'});


set_callback({right_weight;right_target}, {'calculate', 'right'});
set_callback({left_weight;left_target}, {'calculate', 'left'});
set_callback(error_tol, {'calculate', 'both'});
set_callback(generate, {'calculate', 'generate'});

SoloFunctionAddVars('calculate', 'ro_args', {'num_pulses', 'right_time', ...
                    'left_time', 'right_weight', 'left_weight', ...
                    'error_tol', 'table'}, ...
                    'rw_args', {'right_dispense', 'left_dispense', ...
                    'right_suggest', 'left_suggest', 'right_target', ...
                    'left_target'}); 

HeaderParam(obj, 'prot_title', 'Water Valve Calibrator', ...
    x, y, 'position', [1 fig_position(4)-30 fig_position(3) 20], ...
    'width', fig_position(3));

SoloFunctionAddVars('make_and_upload_state_matrix', ...
    'ro_args', {'right_time', 'left_time', 'num_pulses', 'ipi'});

make_and_upload_state_matrix(obj, 'init', x, y);

% next_column(x); y = 1; next_row(y);
% next_row(y, 6.5);


% ------------------------------------------------------------------
% List of functions to call, in sequence, when a trial is finished:
% If adding a function to this list,
%    (a) Declare its args with a SoloFunction() call
%    (b) Add your function as a method of the current object
%    (c) As the first action of your method, call GetSoloFunctionArgs;
%
SoloParamHandle(obj, 'trial_finished_actions', 'value', { ...
  'make_and_upload_state_matrix(obj, ''stop_matrix'');'  ; ... 
  'push_history(class(obj));'                            ; ... % no args
});

SoloFunction('state35', 'ro_args', 'trial_finished_actions');
SoloFunction('close', 'ro_args', 'myfig');


