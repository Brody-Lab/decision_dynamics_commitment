function [obj] = dual_discobj(a)

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

fig_position = [440 100 680 600];

% Inherit from protocol parent
super_obj = protocolobj(value(protocol_name), 'child', obj, 'fig_position', fig_position);
SoloParamHandle(obj, 'super', 'saveable', 0); super.value = super_obj;

% <~> Disable the loading/saving buttons created by the super protocol_obj
%       until we're finished initializing. This prevents errors in which
%       sessionmodel isn't finished initializing before a load settings
%       buttonpress occurs, for example. I don't like the use of
%       get_sphandle, but I think it's okay here. (multiple handles works)
set(get_ghandle(get_sphandle('name','loadsets')), 'Enable', 'off');
set(get_ghandle(get_sphandle('name','loaddata')), 'Enable', 'off');
set(get_ghandle(get_sphandle('name','savesets')), 'Enable', 'off');
set(get_ghandle(get_sphandle('name','savedata')), 'Enable', 'off');

DeclareGlobals(obj, 'ro_args', {'n_done_trials', 'n_started_trials', 'hit_history', 'maxtrials'});
SoloFunction('SessionModel', 'rw_args', 'super');
SoloFunction('state_colors', 'rw_args', 'super');
SoloFunction('statenames', 'rw_args', 'super');

[status, hostname] = system('hostname');
hostname = lower(hostname);
hostname = hostname(~isspace(hostname));
SoloParamHandle(obj,'hostname', 'value', hostname);

% -------- END Magic code that all protocol objects must have ---
rpbox('runstart_disable');
set(value(myfig), 'Position', fig_position);

experimenter.value = 'Shraddha';
max_y = 1;

% Add more states to separate cue, pre-go period.
rts = value(RealTimeStates);
rts.cue = 0;
rts.pre_go = 0;
rts.drink_grace = 0;
RealTimeStates.value = rts;

[x, y] = WaterSection(obj,  'init', x, y); 

next_column(x);
y = 5; next_row(y);
% A. BlocksSection - Makes blocks of tone presentations
% --------------------
SoloFunction('BlocksSection','rw_args','super');
[x,y, Num_Bins,Num2Make,Blocks_Switch] = BlocksSection(obj,'init', x, y); next_row(y,0.5);

% A. Copied straight out of locsamp_childobj ------------------------------
ro_args = {'n_done_trials', 'n_started_trials', 'hit_history','maxtrials','Max_Trials','Blocks_Switch','Num2Make','Num_Bins'};
SoloFunction('SidesSection', 'ro_args', ro_args, 'rw_args', 'super');
define_function(value(super), 'function_name', 'SidesSection', 'ro_args', ro_args);
[x, y, side_list, WaterDelivery, RewardPorts, LeftProb] = SidesSection(obj, 'init', x, y); next_row(y, 0.5);
% side_list is a vector of correct sides, one per trial.
% A. End -------------------------------------------------------------------

SubheaderParam(obj, 'sched_sbh', 'Schedule', x, y);

% C. Copied straight out of locsamp_childobj ------------------------------
ro_args = {'n_done_trials', 'n_started_trials', 'maxtrials'};
SoloFunction('VpdsSection', 'ro_args', ro_args, 'rw_args', 'super');
define_function(value(super), 'function_name', 'VpdsSection', 'ro_args', ro_args);
[x, y, vpd_list] = VpdsSection(obj, 'init', x, y);         next_row(y, 0.5);
% vpd_list is a vector of valid center poke durations, one per trial.
% C. End
% --------------------------------------------------------------------

next_row(y,2);
% D. Copied straight out of locsamp_childobj ------------------------------
SoloFunction('TimesSection', 'rw_args', 'super', 'ro_args', 'LeftProb');
define_function(value(super), 'function_name', 'TimesSection');
[x, y, BadBoySound, BadBoySPL, WN_SPL, ITISound, ITILength, ITIReinitPenalty, ...
    TimeOutSound, TimeOutLength, TimeOutReinitPenalty, ...
    ExtraITIonError, DrinkTime] = ...
    TimesSection(obj, 'init', x, y);                         next_row(y, 1);
% D. End
% --------------------------------------------------------------------



max_y = max(max_y, y);
next_column(x); y = 5; next_row(y);

SoloFunction('RewardsSection', ...
    'rw_args', {'LastTrialEvents', 'RealTimeStates', 'hit_history'}, ...
    'ro_args', {'side_list', 'n_done_trials', ...
    'n_started_trials', 'maxtrials'});
[x, y, timeout_count] = RewardsSection(obj, 'init', x, y);
DeclareGlobals(obj, 'ro_args', {'timeout_count'});
SoloFunction('PokeMeasuresSection', ...
    'ro_args', {'n_done_trials', 'n_started_trials', 'RealTimeStates', 'vpd_list'}, ...
    'rw_args', {'myfig', 'LastTrialEvents'});
[x, y] = PokeMeasuresSection(obj, 'init', x, y);

SoloParamHandle(obj, 'stm_ctr','value', 0);


ro_args = {'side_list', 'n_started_trials', 'n_done_trials', 'maxtrials', 'vpd_list',...
    'Num_Bins','Num2Make','Blocks_Switch'};
SoloFunction('ChordSection', 'ro_args', ro_args, 'rw_args', 'super');
define_function(value(super), 'function_name', 'ChordSection', 'ro_args', ro_args);
[x, y, ...
    chord_sound_len, error_sound_len, tone1_list, tone2_list, prechord_list, go_dur, ...
    LegalSkipOut, Granularity,volume_factor] = ChordSection(obj, 'init', x, y);
next_row(y, 0.5);

SubheaderParam(obj, 'sounds_sbh', 'Sounds', x, y);
next_row(y);next_row(y,0.5);

% Variable that tracks how many days of psychometric trials have occurred
EditParam(obj,'psychday_counter',0,x,y);
set(get_ghandle(psychday_counter), 'Visible', 'off');
set(get_lhandle(psychday_counter), 'Visible','off');

SoloParamHandle(obj, 'protocol_start_time', 'value', clock);

% --- Making and uploading the state matrix
SoloFunction('make_and_upload_state_matrix', ...
    'rw_args', { 'super', 'stm_ctr','protocol_start_time', ...
    'RealTimeStates', 'LastTrialEvents'}, ...
    'ro_args', {'n_done_trials', ...
    'side_list', 'vpd_list', 'Blocks_Switch'...
    'chord_sound_len', 'error_sound_len', 'tone1_list', 'tone2_list', 'prechord_list', 'go_dur', ...
    'WaterDelivery', 'RewardPorts', 'DrinkTime', ...
    'WN_SPL', 'ITISound', 'ITILength', 'ITIReinitPenalty', 'ExtraITIonError', ...
    'TimeOutSound', 'TimeOutLength', 'TimeOutReinitPenalty', 'BadBoySound', 'BadBoySPL', ...
    'Granularity', 'LegalSkipOut', 'Max_Trials','MaxMins', 'volume_factor' ...
    });

make_and_upload_state_matrix(obj, 'init');
push_history(class(obj));
n_started_trials.value = 1;


% Once everything is in place, add the training stages
SoloFunction('SessionDefinition', 'ro_args', {'myfig','ratname','experimenter'});
SessionDefinition(obj, 'init', x,y);

next_row(y,4);
SubheaderParam(obj, 'sounds_sbh', 'Session Automation', x, y);
g=get_ghandle(sounds_sbh);
set(g,'BackgroundColor',[186/225 232/255 217/255]);
next_row(y);


x = 1;
HeaderParam(obj, 'prot_title', 'Pitch discrimination', ...
    x, (fig_position(2)+fig_position(4))-60, ...
    'width', fig_position(3));


% ------------------------------------------------------------------
% List of functions to call, in sequence, when a trial is finished:
% If adding a function to this list,
%    (a) Declare its args with a SoloFunction() call
%    (b) Add your function as a method of the current object
%    (c) As the first action of your method, call GetSoloFunctionArgs;
%
SoloParamHandle(obj, 'trial_finished_actions', 'value', { ...
    'ComputeAutoSet;'                                       ; ...
     'SessionDefinition(obj, ''next_trial'');'              ; ...
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
   'make_and_upload_state_matrix(obj, ''check_tup'');'  ; ...
    });
SoloFunction('update', 'ro_args', 'within_trial_update_actions', 'rw_args', 'super');

% ------------------------------------------------------------------

% <~> Re-enable saving/loading buttons now that all is initialized.
set(get_ghandle(get_sphandle('name','loadsets')), 'Enable', 'on');
set(get_ghandle(get_sphandle('name','loaddata')), 'Enable', 'on');
set(get_ghandle(get_sphandle('name','savesets')), 'Enable', 'on');
set(get_ghandle(get_sphandle('name','savedata')), 'Enable', 'on');


% only automatically load settings at start if ratname value is not the
% default one.

if ~strcmpi(value(ratname),'ratname'),
    h=figure;
    set(h,'Position',[300 300 500 75],'Color',[1 1 0],'Menubar','none','Toolbar','none');           
    uicontrol('Style','text', 'Position',[80 10 300 50],'BackgroundColor',[1 1 0], 'Fontsize', 14, 'FontWeight','bold', 'String', sprintf('Auto-loading settings for %s.\nPlease wait ...', value(ratname)));
   
    load_solouiparamvalues(value(ratname), 'experimenter','Shraddha','interactive',0);
    
     close(h);
    h=msgbox(sprintf('SETTINGS LOADED.\nPlease close this window and start the protocol.'),'Settings Loaded');
        set(h,'Position',[300 300 500 75],'Color',[0 1 0]);           
        c = get(h,'Children');  b = get(c(1),'Children'); set(b,'FontSize', 14, 'FontWeight','bold');
        for k = 1:length(c),set(c(k),'FontSize',14);end;
                refresh;
end;

DrinkTime.value = 6;
TimeOutLength.value = 2;
MaxMins.value = 120;
 LegalSkipOut.value = 75;
 Granularity.value = 25;



rpbox('runstart_enable');
return;

