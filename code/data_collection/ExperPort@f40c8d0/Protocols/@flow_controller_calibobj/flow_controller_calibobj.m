function [obj] = flow_controller_calib(a)

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

% introduce the olfactometer
if exist(strcat(pwd, '\olfip.mat')) == 2 % make sure the file exists - should be saved in ExperPort, on each machine
    load('olfip');
else
    olf_IP = inputdlg('olf_IP:', 'Input IP of olfactometer', 1);
    save(strcat(pwd, '\olfip'), 'olf_IP');
end

% create a SPH to pass the IP address of the OLF_meter
SoloParamHandle(obj,'OLF_IP','value', olf_IP{1});
if ~strcmpi(value(OLF_IP), 'nan'), % if the olfactometer is connected
    SoloParamHandle(obj,'olf_meter','value', SimpleOlfClient(value(OLF_IP)));
end

% randomize the random-number-generating seed
rand('state', sum(100*clock));


% -------- END Magic code that all protocol objects must have ---

BUTTON_SIZE = [100 20];

fig_position = [225   200   575   575];
set(value(myfig), 'Position', fig_position);

x = 1; y = 1;                     % Position on GUI

EditParam(obj, 'curr_date', datestr(date, 26), x, y + 10);

EditParam(obj, 'initials', '', x, y + 30);

SoloParamHandle(obj, 'lookup_table', 'value', []);


% determine which carrier and bank to use (rig-dependent)
if ~strcmpi(value(OLF_IP), 'nan'), % if the olfactometer is connected
  [carriers, banks] = GetOlfHardware(value(olf_meter));
  active_carrier = carriers(1); % in case there are >1 carriers
  active_banks = banks(1:2); % in case there are >2 banks
else
  active_carrier = 1;
  active_banks = [1 2];
end

NumeditParam(obj, 'flow_controller', active_banks(1), x, y + 60, 'label', 'Flow controller #');

NumeditParam(obj, 'valve', 1, x, y + 80, 'label', 'Valve');


next_column(x, 1);

NumeditParam(obj, 'voltage', 0.5, x, y + 10, 'label', 'Input voltage');

NumeditParam(obj, 'flow_rate', 0, x, y + 30, 'label', 'Resulting flow');


next_column(x, 1);

BUTTON_L = x + 40;

NumeditParam(obj, 'voltage_increment', 1, x, y, 'label', 'v. inc', ...
    'position', [BUTTON_L, y + 10, BUTTON_SIZE], 'TooltipString', '''Next voltage'' button increases voltage by this amount');

PushbuttonParam(obj, 'increment_voltage', x, y, 'label', 'Add entry; Next voltage', ...
    'position', [BUTTON_L - 20, y + 30, (BUTTON_SIZE + [40 20])]); 

PushbuttonParam(obj, 'delete_last_entry', x, y, 'label', 'Del. last entry', ...
                'position', [BUTTON_L y + 90 BUTTON_SIZE], 'TooltipString', 'Deletes the last entry in the table'); 


PushbuttonParam(obj, 'start', x, y , 'label', 'Start air flow', ...
                'position', [BUTTON_L y + 150  BUTTON_SIZE]); 

PushbuttonParam(obj, 'stop', x, y, 'label', 'Stop air flow', ...
                'position', [BUTTON_L y + 170 BUTTON_SIZE]); 


PushbuttonParam(obj, 'finalize_table', x, y, 'label', 'Finalize table', ...
                'position', [BUTTON_L y + 240 (BUTTON_SIZE + [0 20])]); 

PushbuttonParam(obj, 'check_previous_calib', x, y, 'label', 'prev. calib.', ...
                'position', [BUTTON_L y + 300 BUTTON_SIZE]); 

PushbuttonParam(obj, 'fc_help', x, y, 'label', 'HELP', ...
                'position', [BUTTON_L y + 340 (BUTTON_SIZE + [0 20])]); 


SoloFunctionAddVars('air_flow', 'ro_args', {'OLF_IP', 'voltage', 'flow_controller', 'valve'});
if ~strcmpi(value(OLF_IP), 'nan'), % if the olfactometer is connected
    SoloFunctionAddVars('air_flow', 'ro_args', 'olf_meter');
end

SoloFunctionAddVars('add_calibration_pair', 'rw_args', 'lookup_table', 'ro_args', {'voltage', 'flow_rate'});

SoloFunctionAddVars('delete_calibration_pair', 'rw_args', 'lookup_table');

SoloFunctionAddVars('plot_entries', 'ro_args', 'lookup_table');

SoloFunctionAddVars('save_calibration_info', 'ro_args', {'lookup_table', 'flow_controller', 'date', 'initials'});

SoloFunctionAddVars('fc_callbacks', 'rw_args', {'flow_rate', 'voltage'}, 'ro_args', {'voltage_increment', 'flow_controller'});

set_callback(voltage, {'fc_callbacks', 'reset_flow'});

set_callback(increment_voltage, {'fc_callbacks', 'increment_voltage'});

set_callback(start, {'air_flow', 'start_flow'});
set_callback(stop, {'air_flow', 'stop_flow'});

set_callback(delete_last_entry, 'delete_calibration_pair');

set_callback(finalize_table, 'save_calibration_info');

set_callback(check_previous_calib, {'fc_callbacks', 'check_previous'});

set_callback(fc_help, {'fc_callbacks', 'help'});

plot_entries(obj, 'init');


HeaderParam(obj, 'prot_title', 'Flow Controller Calibrator', ...
    x, y, 'position', [1 fig_position(4)-30 fig_position(3) 20], ...
    'width', fig_position(3));


SoloFunction('close', 'ro_args', 'myfig');

