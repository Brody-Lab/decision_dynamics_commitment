function [obj] = quadsampobj(a)
    
% -------- BEGIN Magic code that all protocol objects must have ---
% Default object:
obj = class(struct, mfilename);

% If creating an empty object, return without further ado:
if nargin==0 || (nargin==1 && ischar(a) && strcmp(a, 'empty')), return; end;


flush_solo(['@', mfilename]); % Delete previous vars owned by this object

% Non-empty: proceed with regular init of this object

hackvar = 10;
SoloFunctionAddVars('SessionModel', 'ro_args', 'hackvar');

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

rpbox('runstart_disable');
set(value(myfig), 'Position', [485   244   669   702]);

SoloParamHandle(obj, 'n_done_trials',    'value', 0);
SoloParamHandle(obj, 'n_started_trials', 'value', 0);
SoloParamHandle(obj, 'maxtrials',        'value', 1000);
SoloParamHandle(obj, 'hit_history',      'value', NaN*ones(1, value(maxtrials)));
SoloParamHandle(obj, 'prevtrial',        'value', []);


DeclareGlobals(obj, 'ro_args', {'n_done_trials', 'n_started_trials', ...
                    'hit_history', 'prevtrial'});
SoloFunctionAddVars('RewardsSection', 'rw_args', 'prevtrial');

x = 1; y = 1;                     % Position on GUI
[x, y] = SavingSection(obj, 'init', x, y);  next_row(y, 0.5);
[x, y] = WaterSection(obj,  'init', x, y);  next_row(y, 0.5);

SoloFunction('SidesSection', 'ro_args', ...
    {'n_done_trials', 'n_started_trials', 'hit_history','maxtrials'});
[x, y, side_list, WaterDelivery,RewardPorts,SChoiceWindow,Sbeta] = ...
    SidesSection(obj, 'init', x, y); next_row(y, 0.5);         
DeclareGlobals(obj, 'ro_args', {'side_list'});
% side_list is a vector of correct sides, one per trial.

next_column(x); y = 1;

SoloFunction('VpdsSection', 'ro_args', ...
    {'n_done_trials', 'n_started_trials', 'maxtrials'});
[x, y, vpd_list] = VpdsSection(obj, 'init', x, y);         next_row(y, 0.5);
% vpd_list is a vector of valid center poke durations, one per trial.

SoloFunction('ChordSection', ...
   'ro_args', {'side_list', 'n_done_trials', 'n_started_trials', 'vpd_list'});
[x, y, chord_sound_len,go_dur,Sound_type,Granularity,LegalSkipOut]=...
    ChordSection(obj, 'init', x, y); next_row(y, 0.5);

[x, y, BadBoySound, ITISound, ITILength, ITIReinitPenalty, ...
 TimeOutSound, TimeOutLength, TimeOutReinitPenalty, ...
 APokePenalty,  ...
 ExtraITIonError, DrinkTime] = ...
  TimesSection(obj, 'init', x, y);                         next_row(y, 1);


% --- Making and uploading the state matrix
SoloFunction('make_and_upload_state_matrix', ...
    'ro_args', {'n_done_trials', 'side_list', 'vpd_list', ...
    'chord_sound_len', 'go_dur', 'Granularity', 'LegalSkipOut', ...
    'WaterDelivery', 'RewardPorts', 'DrinkTime', ...
    'BadBoySound', 'ITISound', 'ITILength', 'ITIReinitPenalty', ...
    'TimeOutSound', 'TimeOutLength', 'TimeOutReinitPenalty', ...
    'APokePenalty', ...
    'ExtraITIonError'});

next_column(x); y = 1;
next_row(y, 13.5);
NumeditParam(obj, 'TrialLimit', 150, x, y, 'position', [x+110 y 80 20], ...
             'label', 'MaxTrials','labelfraction', 0.65, ...
             'TooltipString', 'After this # of trials, protocol will stop');
next_row(y);
NumeditParam(obj, 'MaxMins', 240, x, y, 'position', [x+110 y 80 20], ...
             'label', 'MaxMins','labelfraction', 0.65, ...
             'TooltipString', 'After this # of mins, protocol will stop');
SoloParamHandle(obj, 'protocol_start_time', 'value', clock);
SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args', ...
                    {'TrialLimit', 'MaxMins', 'protocol_start_time'});
next_row(y, -14.5);


RealTimeStates = make_and_upload_state_matrix(obj, 'init');
push_history(Sound_type);
push_history(class(obj));
n_started_trials.value = 1;

% zeroth trial has nothing in it:
prevtrial.value = parse_trial([], value(RealTimeStates));


% ---- Reporting on rewards and pokes

SoloParamHandle(obj, 'LastTrialEvents', 'value', []);

SoloFunction('RewardsSection', ...
             'rw_args', {'LastTrialEvents', 'hit_history'}, ...
             'ro_args', {'RealTimeStates', 'side_list'});
[x, y] = RewardsSection(obj, 'init', x, y);
SoloFunction('PokeMeasuresSection', 'rw_args', 'LastTrialEvents', ...
    'ro_args', {'RealTimeStates', 'Sound_type'});
[x, y] = PokeMeasuresSection(obj, 'init', x, y);

SoloFunction('ReportHitsSection', 'ro_args', {'side_list'});
[x, y] = ReportHitsSection(obj, 'init', x, y, SChoiceWindow, Sbeta);

next_row(y, -1);
next_row(y, 2.5);
% PushbuttonParam(obj, 'export',  1, 1, 'position', [x y 60 20], ...
%                 'FontWeight', 'normal', 'TooltipString', ...
%                 sprintf(['Click here for an advanced export fn.']));
% set_callback(export, {'ExportSection', 'export'});
HeaderParam(obj, 'prot_title', 'Quadsamp', x+110, y, 'width', 140);
SoloFunctionAddVars('SaveSettings', 'rw_args', 'prot_title');

SoloParamHandle(obj, 'debugging', 'value', 0);
if debugging==1, 
   fp = fopen('debugging.log', 'a'); 
   fprintf(fp, '\n\n\n******* Opening %s on %s\n\n', class(obj), ...
           datestr(now));
   fclose(fp); 
end;

% ------------------------------------------------------------------
% List of functions to call, in sequence, when a trial is finished:
% If adding a function to this list,
%    (a) Declare its args with a SoloFunction() call
%    (b) Add your function as a method of the current object
%    (c) As the first action of your method, call GetSoloFunctionArgs;
%
% Below, push_history(class(obj)) will push the history of all GUI
% SoloParamHandles; in addition, we explicitly do push_history of
% Sound_type because it is a non-GUI bit we want to record its history
% anyway. 
SoloParamHandle(obj, 'trial_finished_actions', 'value', { ...
  'RewardsSection(obj, ''update'');'                     ; ...
  'ComputeAutoSet'                                       ; ...
  'SessionDefinition(obj, ''next_trial'');'              ; ...
  'SidesSection(obj, ''choose_next_side'');'             ; ...
  'ReportHitsSection(obj, ''update'');'                  ; ...
  'ReportHitsSection(obj, ''update_chooser'');'          ; ...
  'SidesSection(obj, ''update_plot'');'                  ; ... 
  'VpdsSection(obj,  ''update_plot'');'                  ; ...
  'ChordSection(obj, ''make'');'                         ; ... 
  'ChordSection(obj, ''upload'');'                       ; ...
  'make_and_upload_state_matrix(obj, ''next_matrix'');'  ; ... 
  'push_history(Sound_type);'                            ; ...
  'push_history(class(obj));'                            ; ... % no args
  'CurrentTrialPokesSubsection(obj, ''redraw'')'         ; ...
  'SavingSection(obj, ''check_autosave'')'               ; ...
});
SoloFunction('state35', ...
    'rw_args', {'n_done_trials', 'n_started_trials', 'Sound_type'}, ...
    'ro_args', {'trial_finished_actions', 'debugging'});


% List of functions to call, in sequence, when an update call is made:
SoloParamHandle(obj, 'within_trial_update_actions', 'value', { ...
    'PokeMeasuresSection(obj, ''update_counts'');'  ; ...
    });
SoloFunction('update', 'ro_args', ...
             {'within_trial_update_actions', 'debugging'});

% ------------------------------------------------------------------


% Once everything is in place, add the training stages
SoloFunction('SessionDefinition', 'ro_args', {'myfig'});
next_row(y,0.5);
SessionDefinition(obj, 'init', x,y);

rpbox('runstart_enable');



return;


