% Constructor
function [obj] = nl2afcobj(a)

global Solo_Try_Catch_Flag;

% -------- BEGIN Magic code that all protocol objects must have ---
% Default object:
obj = class(struct, mfilename);

% If creating an empty object, return without further ado:
if nargin==0 || (nargin==1 && ischar(a) && strcmp(a, 'empty'))
    return;
end;

flush_solo(['@', mfilename]); % Delete previous vars owned by this object

% Non-empty: proceed with regular init of this object
hackvar = 10; SoloFunctionAddVars('SessionModel', 'ro_args', 'hackvar');

if nargin==1 && isstr(a),
    SoloParamHandle(obj, 'protocol_name', 'value', lower(a));
end;


% Make default figure. Remember to make it non-saveable; on next run
% the handle to this figure might be different, and we don't want to
% overwrite it when someone does load_data and some old value of the
% fig handle was stored there...
SoloParamHandle(obj, 'myfig', 'saveable', 0);
myfig.value = figure;
set(value(myfig), ...
    'Name', value(protocol_name), 'Tag', value(protocol_name), ...
    'closerequestfcn', ['ModuleClose(''' value(protocol_name) ''')'], ...
    'NumberTitle', 'off', 'MenuBar', 'none');

% Give close.m access to myfig, so that upon closure the figure may be
% deleted: 
SoloFunctionAddVars('close', 'ro_args', 'myfig');


% introduce the olfactometer
load('olfip'); 
if isempty(olf_IP)
    olf_IP = inputdlg('You must input something :)', 'Input IP of olfactometer', 1);
    save(strcat(pwd, '\Protocols\@', value(protocol_name), 'obj\olfip'), 'olf_IP');

else
    olf_IP = inputdlg('olf_IP:', 'Input IP of olfactometer', 1, olf_IP);
end

save(strcat(pwd, '\Protocols\@', value(protocol_name), 'obj\olfip'), 'olf_IP');

% creat a SPH to pass the IP address of the OLF_meter
SoloParamHandle(obj,'OLF_IP','value', olf_IP{1});
if ~strcmpi(value(OLF_IP), 'nan'), % if the olfactometer is connected
    SoloParamHandle(obj,'olf_meter','value', SimpleOlfClient(value(OLF_IP)));
    % to let the OdorSection to see the IP address
    SoloFunctionAddVars('OdorSection','ro_args','olf_meter');
end
SoloFunctionAddVars('OdorSection','ro_args','OLF_IP');
SoloFunctionAddVars('make_and_upload_state_matrix','ro_args','OLF_IP');

% -------- END Magic code that all protocol objects must have ---

rpbox('runstart_disable');

set(value(myfig), 'Position', [485   244   700   750]);
SoloParamHandle(obj, 'n_done_trials',    'value', 0);
SoloParamHandle(obj, 'n_started_trials', 'value', 0);
SoloParamHandle(obj, 'maxtrials',        'value', 1000);
SoloParamHandle(obj, 'hit_history',      'value', NaN*ones(1, value(maxtrials)));

SoloParamHandle(obj, 'prevtrial',        'value', []);



SoloParamHandle(obj, 'LastTrialEvents', 'value', []);
DeclareGlobals(obj, 'ro_args', {'n_done_trials', 'n_started_trials', ...
                    'maxtrials',  'hit_history', 'prevtrial'});
SoloFunctionAddVars('RewardsSection', 'rw_args', 'prevtrial');



x = 1; y = 1;                     % Position on GUI
[x, y] = SavingSection(obj, 'init', x, y);  
[x, y] = WaterSection(obj,  'init', x, y);  

SoloFunctionAddVars('SidesSection', 'ro_args', {'maxtrials'});
[x, y, side_list, WaterDelivery] = ...
    SidesSection(obj, 'init', x, y); next_row(y, 0.5);

SoloFunctionAddVars('OdorSection', 'ro_args', 'side_list');


% Section that sets the parameter of the olfactometer. 
next_column(x); y = 1;
[x, y, iti_list, RewardAvail] = TimesSection(obj, 'init', x, y); 
    next_row(y, 0.5);

[x, y] = OdorSection(obj, 'init', x, y);
    next_row(y, 0.5);

next_column(x); y = 1;
NumeditParam(obj, 'Max_Trials', 150, x, y, 'position', [x+110 y 80 20], ...
             'label', 'MaxTrials','labelfraction', 0.65, ...
             'TooltipString', 'After this # of trials, protocol will stop');
next_row(y);
SubheaderParam(obj, 'mt_sh', 'Max_Trials', x, y); next_row(y, 1.5);

SoloFunctionAddVars('make_and_upload_state_matrix', ...
                    'ro_args', {'side_list', 'iti_list', 'WaterDelivery', ...
                    'RewardAvail', 'Max_Trials'});                
                
RealTimeStates = make_and_upload_state_matrix(obj, 'init');

% --- current trial pokes figure
SoloFunctionAddVars('CurrentTrialPokesSubsection', ...
    'ro_args', {'RealTimeStates'}, 'rw_args', 'LastTrialEvents');
[x, y] = CurrentTrialPokesSubSection(obj, 'init', x, y);


SoloFunctionAddVars('RewardsSection', 'ro_args', {'side_list', ...
                    'RealTimeStates'},  'rw_args', {'LastTrialEvents', ...
                    'hit_history'}); 
[x, y] = RewardsSection(obj, 'init', x, y);


% ... and the pretty bow
fig_position = get(value(myfig), 'Position');
HeaderParam(obj, 'prot_title', 'Odor 2AFC', 1, fig_position(4)-20, ...
            'width', fig_position(3));

push_history(class(obj));
n_started_trials.value = 1;
prevtrial.value = parse_trial([], value(RealTimeStates));
 
 % And now, for the actions at the end of a trial, and during a trial
 % ------------------------------------------------------------------
 SoloParamHandle(obj, 'trial_finished_actions', 'value', { ...
    'ComputeAutoSet;'                                      ; ...
    'RewardsSection(obj, ''update'');'                     ; ...
    'SessionDefinition(obj, ''next_trial'');'              ; ...
    'SidesSection(obj, ''choose_next_side'');'             ; ...
    'SidesSection(obj, ''update_plot'');'                  ; ...
    'OdorSection(obj, ''update_odor'');'                   ; ...
    'TimesSection(obj, ''update'');'                       ; ...
    'make_and_upload_state_matrix(obj, ''next_matrix'');'  ; ...
    'CurrentTrialPokesSubsection(obj, ''redraw'');'         ; ...
    'push_history(class(obj));'                            ; ... % no args
    });


SoloFunctionAddVars('state35', 'rw_args', ...
                    {'n_done_trials', 'n_started_trials'}, ...
                    'ro_args', 'trial_finished_actions');

% List of functions to call, in sequence, when an update call is made:
SoloParamHandle(obj, 'within_trial_update_actions', 'value', { ...
  'CurrentTrialPokesSubsection(obj, ''update_events'');'         ; ...
  'OdorSection(obj, ''monitor_olf'');'...
    });

SoloFunctionAddVars('update', 'ro_args', 'within_trial_update_actions');

% ------------------------------------------------------------------

% Once everything is in place, add the training stages
SoloFunctionAddVars('SessionDefinition', 'ro_args', {'myfig', 'RewardAvail'});
next_row(y,1.5);
SessionDefinition(obj, 'init', x,y);

rpbox('runstart_enable');

return;



