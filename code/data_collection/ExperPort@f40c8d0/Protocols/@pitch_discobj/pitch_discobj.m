function [obj] = pitch_discobj(a)

% -------- BEGIN Magic code that all protocol objects must have ---
% Default object:
obj = struct('empty', []);
obj = class(obj, mfilename);

% If creating an empty object, return without further ado:
if nargin==1 && strcmp(a, 'empty')
    % Inherit from protocol parent
    super_obj = protocolobj('empty');
    SoloParamHandle(obj, 'super', 'saveable', 0); super.value = super_obj;
    return; 
end;

delete_sphandle('owner', mfilename); % Delete previous vars owned by this object

% Non-empty: proceed with regular init of this object
if nargin==1 && isstr(a), 
    SoloParamHandle(obj, 'protocol_name', 'value', lower(a)); 
end;

fig_position = [440 29 680 800];

% Inherit from protocol parent 
super_obj = protocolobj(value(protocol_name), 'child', obj, 'fig_position', fig_position);
SoloParamHandle(obj, 'super', 'saveable', 0); super.value = super_obj;
SoloFunction('state_colors', 'rw_args', 'super');
SoloFunction('statenames', 'rw_args', 'super');

% -------- END Magic code that all protocol objects must have ---

set(value(myfig), 'Position', fig_position);

max_y = 1;



% A. Copied straight out of locsamp_childobj ------------------------------
ro_args = {'n_done_trials', 'n_started_trials', 'hit_history','maxtrials'};
SoloFunction('SidesSection', 'ro_args', ro_args, 'rw_args', 'super'); 
define_function(value(super), 'function_name', 'SidesSection', 'ro_args', ro_args);
[x, y, side_list, WaterDelivery, RewardPorts] = SidesSection(obj, 'init', x, y); next_row(y, 0.5);         
% side_list is a vector of correct sides, one per trial.
% A. End -------------------------------------------------------------------

SubheaderParam(obj, 'sched_sbh', 'Schedule', x, y);
next_row(y);next_row(y,0.5);

% C. Copied straight out of locsamp_childobj ------------------------------
ro_args = {'n_done_trials', 'n_started_trials', 'maxtrials'};
SoloFunction('VpdsSection', 'ro_args', ro_args, 'rw_args', 'super');
define_function(value(super), 'function_name', 'VpdsSection', 'ro_args', ro_args);
[x, y, vpd_list] = VpdsSection(obj, 'init', x, y);         next_row(y, 0.5);
% vpd_list is a vector of valid center poke durations, one per trial.
% C. End --------------------------------------------------------------------

% Written afresh
ro_args = {'side_list', 'n_started_trials', 'n_done_trials', 'maxtrials', 'vpd_list'};
SoloFunction('ChordSection', 'ro_args', ro_args, 'rw_args', 'super'); 
define_function(value(super), 'function_name', 'ChordSection', 'ro_args', ro_args);
[x, y, chord_sound_len, go_dur] = ChordSection(obj, 'init', x, y); 
next_row(y, 0.5);
% --------------------------------------------------------------------

SubheaderParam(obj, 'sounds_sbh', 'Sounds', x, y);
next_row(y);next_row(y,0.5);


max_y = max(max_y, y);
next_column(x); y = 5; next_row(y);

% D. Copied straight out of locsamp_childobj ------------------------------
SoloFunction('TimesSection', 'rw_args', 'super');
define_function(value(super), 'function_name', 'TimesSection');
[x, y, BadBoySound, BadBoySPL, WN_SPL, ITISound, ITILength, ITIReinitPenalty, ...
 TimeOutSound, TimeOutLength, TimeOutReinitPenalty, ...
 ExtraITIonError, DrinkTime] = ...
  TimesSection(obj, 'init', x, y);                         next_row(y, 1);
% D. End --------------------------------------------------------------------

max_y = max(max_y, y);
next_column(x); y = 5; next_row(y);

SoloFunction('RewardsSection', ...
             'rw_args', {'LastTrialEvents', 'hit_history'}, ...
             'ro_args', {'RealTimeStates', 'side_list', 'n_done_trials', ...
                    'n_started_trials'});
[x, y] = RewardsSection(obj, 'init', x, y);
SoloFunction('PokeMeasuresSection', 'rw_args', 'LastTrialEvents', ...
    'ro_args', {'n_done_trials', 'n_started_trials', 'RealTimeStates', 'vpd_list', ...
});
[x, y] = PokeMeasuresSection(obj, 'init', x, y);

x = 1;
HeaderParam(obj, 'prot_title', 'Pitch Discrimination', ...
    x, (fig_position(2)+fig_position(4))-60, ...
    'width', fig_position(3));

% --- Making and uploading the state matrix
SoloFunction('make_and_upload_state_matrix', ...
    'rw_args', {'RealTimeStates', 'super'}, ...
    'ro_args', {'n_done_trials', ...
    'side_list', 'vpd_list', ...
    'chord_sound_len', 'go_dur', ...
    'WaterDelivery', 'RewardPorts', 'DrinkTime', 'LeftWValve', 'RightWValve', ...
    'WN_SPL', 'ITISound', 'ITILength', 'ITIReinitPenalty', 'ExtraITIonError', ...
    'TimeOutSound', 'TimeOutLength', 'TimeOutReinitPenalty', 'BadBoySound', 'BadBoySPL' ...
     });
 
make_and_upload_state_matrix(obj, 'init');
push_history(class(obj));
n_started_trials.value = 1;

% ------------------------------------------------------------------
% List of functions to call, in sequence, when a trial is finished:
% If adding a function to this list,
%    (a) Declare its args with a SoloFunction() call
%    (b) Add your function as a method of the current object
%    (c) As the first action of your method, call GetSoloFunctionArgs;
%
SoloParamHandle(obj, 'trial_finished_actions', 'value', { ...
  'RewardsSection(obj, ''update'');'                     ; ...
  'SidesSection(obj, ''choose_next_side'');'             ; ...
  'SidesSection(obj, ''update_plot'');'                  ; ... 
  'VpdsSection(obj,  ''update_plot'');'                  ; ...
  'ChordSection(obj, ''make'');'                         ; ... 
  'ChordSection(obj, ''upload'');'                       ; ...
  'PokeMeasuresSection(obj, ''update_pokedur'');'	 ; ...
  'make_and_upload_state_matrix(obj, ''next_matrix'');'  ; ... 
  'CurrentTrialPokesSubsection(obj, ''redraw'')'         ; ...
  'push_history(class(obj));'                            ; ... % no args
});


SoloFunction('state35', 'rw_args', {'n_done_trials', 'n_started_trials','super'}, ...
    'ro_args', 'trial_finished_actions');

% List of functions to call, in sequence, when an update call is made:
SoloParamHandle(obj, 'within_trial_update_actions', 'value', { ...
    'PokeMeasuresSection(obj, ''update_counts'');'  ; ...
    });
SoloFunction('update', 'ro_args', 'within_trial_update_actions', 'rw_args', 'super');

% ------------------------------------------------------------------

return;

