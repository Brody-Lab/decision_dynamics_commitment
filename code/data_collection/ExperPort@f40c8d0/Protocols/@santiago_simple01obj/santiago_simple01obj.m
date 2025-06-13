% Constructor of protocol object
% This is the only place where (non GUI?) Solo objects should be created (using
% 'SoloParamHandle') in order to make debugginh easier. These will
% be passed to particular sections using 'SoloFunctionAddVars'.
%
% Santiago Jaramillo - 2007.05.14

function [obj] = santiago_simple01obj(a)

% -------- BEGIN Magic code that all protocol objects must have -----------
% Default object:
obj = class(struct, mfilename);

% If creating an empty object, return without further ado:
if nargin==0 || (nargin==1 && ischar(a) && strcmp(a, 'empty')), return; end;

% Delete previous vars owned by this object
flush_solo(['@', mfilename]);

% Non-empty: proceed with regular init of this object
if nargin==1 && isstr(a),
    SoloParamHandle(obj, 'protocol_name', 'value', lower(a));
end;

% Make default figure. Remember to make it non-saveable; on next run
% the handle to this figure might be different, and we don't want to
% overwrite it when someone does load_data and some old value of the
% fig handle was stored there...
SoloParamHandle(obj, 'myfig', 'saveable', 0); myfig.value = figure;
SoloFunctionAddVars('close', 'ro_args', 'myfig');
set(value(myfig), ...
    'Name', value(protocol_name), 'Tag', value(protocol_name), ...
    'closerequestfcn', ['ModuleClose(''' value(protocol_name) ''')'], ...
    'NumberTitle', 'off', 'MenuBar', 'none');

% -------- END Magic code that all protocol objects must have -----------

rpbox('runstart_disable');              %%%%%%%%% CHANGED!!!!! %%%%%%%%%%

%%%set(value(myfig), 'Position', [485   244   700   560]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define hardware parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global left1water;
global right1water;

%%%%%%  FIX LvalveVolPerSec !!!
SoloParamHandle(obj,'HardwareParams');
HardwareParams.value = struct(...
    'LvalveID',left1water,...
    'RvalveID',right1water,...
    'LvalveVolPerSec',1,...
    'RvalveVolPerSec',1);
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define general protocol variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SoloParamHandle(obj, 'NdoneTrials', 'value', 0);
SoloParamHandle(obj, 'MaxTrials', 'value', 1000);
SoloParamHandle(obj, 'HitHistory', 'value', nan(value(MaxTrials),1));
SoloParamHandle(obj, 'ErrorHistory', 'value', nan(value(MaxTrials),1));

%%%% REMOVE VARIABLE ErrorHistory %%%%%


SoloParamHandle(obj, 'trial_finished_actions', 'value', { ...
    'tic',...
    'make_and_upload_state_matrix(obj, ''next_matrix'');', ...
    '  fprintf(''make_and_upload_state_matrix: %0.6f\n'',toc);', ...
    'EvaluateTrialEvents(obj);', ...
    '  fprintf(''EvaluateTrialEvents: %0.6f\n'',toc);', ...
    'SidesSection(obj,''updateplot'');', ...
    '  fprintf(''SidesSection: %0.6f\n'',toc);', ...
    'disp(''-------------------------------'')'               , ...
    });



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize GUI sections and state matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% -- Define sounds --
SoloParamHandle(obj,'GoAttenuation','value',40); % In dB
SoloParamHandle(obj,'GoBaseFreq','value',1000);  % In Hz
SoloParamHandle(obj,'GoNTones','value',16);
SoloParamHandle(obj,'GoDuration','value',0.100);   % In sec 
SoloParamHandle(obj,'GoSignalWave');
%%%%%%% HARDCODED sampling rate SHOULD CHANGE!!! %%%%%%
%srate = get_generic('sampling_rate'); % didn't work
SoundSamplingRate = 200e3;                           % Lynx sound cards
GoSignalWave.value = MakeChord(SoundSamplingRate, value(GoAttenuation), value(GoBaseFreq), ...
                            value(GoNTones), value(GoDuration)*1000,3);
SoloFunctionAddVars('UpdateSounds', 'rw_args',...
                    {'GoSignalWave'});
                
%%%%%% Initialize sound server (still using RPBox) %%%%
rpbox('InitRP3StereoSound');
UpdateSounds(obj);

% -- Reward variables --
SoloParamHandle(obj,'RewardAvailab','value',3); % In sec
SoloParamHandle(obj,'VolPerRewardL','value',0.15); % In uL
SoloParamHandle(obj,'VolPerRewardR','value',0.15); % In uL

% -- Sides variables --
SoloParamHandle(obj,'LeftProb','value',0.5);
SoloParamHandle(obj,'SidesList','value',zeros(value(MaxTrials),1));  % Left:1  Right:0
SoloParamHandle(obj,'hSidesAxes','value', axes('Position', [0.1, 0.75, 0.8, 0.2]));
SoloParamHandle(obj,'hSidesPlot','value', []);
SoloParamHandle(obj,'hHitPlot','value', []);
SoloParamHandle(obj,'hErrorPlot','value', []);
SoloParamHandle(obj,'NtrialsToPlot','value',20);
SoloFunctionAddVars('SidesSection','rw_args',...
                    {'NdoneTrials','MaxTrials','LeftProb',...
                    'SidesList','hSidesAxes','hSidesPlot','hHitPlot',...
                    'hErrorPlot','NtrialsToPlot',...
                    'HitHistory','ErrorHistory'});
SidesSection(obj,'update');
SidesSection(obj,'initplot');

% -- Initializing the State Matrix --
SoloParamHandle(obj,'RealTimeStates');
SoloParamHandle(obj,'StateMatrix');
SoloFunctionAddVars('make_and_upload_state_matrix', 'rw_args',...
                    {'RealTimeStates','StateMatrix','GoDuration',...
                    'RewardAvailab','HardwareParams',...
                    'VolPerRewardL','VolPerRewardR',...
                    'SidesList','NdoneTrials',...
                    });
make_and_upload_state_matrix(obj, 'init');


% -- Evaluate trial events --
SoloFunctionAddVars('EvaluateTrialEvents', 'rw_args',...
                    {'NdoneTrials','HitHistory','ErrorHistory','RealTimeStates'});



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Interface function for RPBox calls
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SoloFunctionAddVars('state35', 'rw_args', ...
                    {'NdoneTrials','trial_finished_actions'});
%                    {'n_done_trials', 'n_started_trials'}, ...
%                    'ro_args', 'trial_finished_actions');
SoloParamHandle(obj,'within_trial_update_actions','value',{});
SoloFunctionAddVars('update', 'ro_args', 'within_trial_update_actions');
%SoloFunctionAddVars('close', 'ro_args', 'myfig');


rpbox('runstart_enable');

return









%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


SoloParamHandle(obj, 'n_done_trials',    'value', 0);
SoloParamHandle(obj, 'n_started_trials', 'value', 0);
SoloParamHandle(obj, 'maxtrials',        'value', 1000);
SoloParamHandle(obj, 'hit_history',      'value', NaN*ones(1, value(maxtrials)));
SoloParamHandle(obj, 'prevtrial',        'value', []);
SoloParamHandle(obj, 'LastTrialEvents', 'value', []);

DeclareGlobals(obj, 'ro_args', {'n_done_trials', 'n_started_trials', ...
                    'maxtrials',  'hit_history', 'prevtrial'});


SoloFunctionAddVars('RewardsSection', 'rw_args', 'prevtrial');


%%% Code lifted from Masa and Gidon to extract event times using NSpike clock
SoloFunctionAddVars('TrialEventsNSpike', 'rw_args', {}, ...
    'ro_args', {'n_done_trials', 'n_started_trials', 'maxtrials'});
TrialEventsNSpike(obj, 'init');
%%% end code lifted from Masa and Gidon

x = 1; y = 1;                     % Position on GUI
[x, y] = SavingSection(obj, 'init', x, y);  
[x, y] = WaterSection(obj,  'init', x, y);  

SoloFunctionAddVars('SidesSection', 'ro_args', {'maxtrials'});
[x, y, side_list, WaterDelivery] = ...
    SidesSection(obj, 'init', x, y); next_row(y, 0.5);

next_column(x); y = 1;
SoloFunctionAddVars('ChordSection', 'ro_args', 'side_list');
[x, y, chord_sound_len] = ChordSection(obj, 'init', x, y); ...
    next_row(y, 0.5);

next_column(x); y = 1;

[x, y, iti_list, RewardAvail] = TimesSection(obj, 'init', x, y); ...
    next_row(y, 0.5);

NumeditParam(obj, 'Max_Trials', 150, x, y, 'position', [x+110 y 80 20], ...
             'label', 'MaxTrials','labelfraction', 0.65, ...
             'TooltipString', 'After this # of trials, protocol will stop');
next_row(y);
SubheaderParam(obj, 'mt_sh', 'Max_Trials', x, y); next_row(y);

SoloFunctionAddVars('make_and_upload_state_matrix', ...
                    'ro_args', {'side_list', 'iti_list', 'WaterDelivery', ...
                    'chord_sound_len', 'RewardAvail', 'Max_Trials'});
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
HeaderParam(obj, 'prot_title', 'Localization (operant/classical)', 1, fig_position(4)-20, ...
            'width', fig_position(3));

push_history(class(obj));
n_started_trials.value = 1;
prevtrial.value = parse_trial([], value(RealTimeStates));
 
 % And now, for the actions at the end of a trial, and during a trial
 % ------------------------------------------------------------------
% $$$  SoloParamHandle(obj, 'trial_finished_actions', 'value', { ...
% $$$     'TrialEventsNSpike(obj, ''end_of_trial_update'');'           ; ...
% $$$     'ComputeAutoSet;'                                      ; ...
% $$$     'RewardsSection(obj, ''update'');'                     ; ...
% $$$     'SidesSection(obj, ''choose_next_side'');'             ; ...
% $$$     'SidesSection(obj, ''update_plot'');'                  ; ...
% $$$     'ChordSection(obj, ''make'');'                         ; ...
% $$$     'ChordSection(obj, ''upload_sounds'');'                ; ...
% $$$     'TimesSection(obj, ''update'');'                       ; ...
% $$$     'make_and_upload_state_matrix(obj, ''next_matrix'');'  ; ...
% $$$     'TrialEventsNSpike(obj, ''push_history_then_reset'');'       ; ...
% $$$     'CurrentTrialPokesSubsection(obj, ''redraw'');'         ; ...
% $$$     'push_history(class(obj));'                            ; ... % no args
% $$$     });
 
 SoloParamHandle(obj, 'trial_finished_actions', 'value', { ...
    'tic;TrialEventsNSpike(obj, ''end_of_trial_update'');toc'           ; ...
    'ComputeAutoSet;toc'                                      ; ...
    'RewardsSection(obj, ''update'');toc'                     ; ...
    'SidesSection(obj, ''choose_next_side'');toc'             ; ...
    'SidesSection(obj, ''update_plot'');toc'                  ; ...
    'ChordSection(obj, ''make'');toc'                         ; ...
    'ChordSection(obj, ''upload_sounds'');toc'                ; ...
    'TimesSection(obj, ''update'');toc'                       ; ...
    'make_and_upload_state_matrix(obj, ''next_matrix'');toc'  ; ...
    'TrialEventsNSpike(obj, ''push_history_then_reset'');toc'       ; ...
    'CurrentTrialPokesSubsection(obj, ''redraw'');toc'         ; ...
    'push_history(class(obj));toc'                            ; ... % no args
    'disp(''-------------------------------'')'               ; ...
    });

 %'SessionDefinition(obj, ''next_trial'');'              ; ...
%%% 'TrialEventsNSpike' calls above added to extract NSpike times (lifted
%%% from Masa and Gidon)


SoloFunctionAddVars('state35', 'rw_args', ...
                    {'n_done_trials', 'n_started_trials'}, ...
                    'ro_args', 'trial_finished_actions');

% List of functions to call, in sequence, when an update call is made:
SoloParamHandle(obj, 'within_trial_update_actions', 'value', { ...
  'TrialEventsNSpike(obj, ''within_trial_update'');'                      ; ...
  'CurrentTrialPokesSubsection(obj, ''update_events'');'         ; ...
    });
%%% 'TrialEventsNSpike' calls above added to extract NSpike times (lifted
%%% from Masa and Gidon)

SoloFunctionAddVars('update', 'ro_args', 'within_trial_update_actions');

% ------------------------------------------------------------------

if(~1)  %%% DELETE %%%
% Once everything is in place, add the training stages
SoloFunctionAddVars('SessionDefinition', 'ro_args', {'myfig', 'RewardAvail'});
next_row(y,1.5);
SessionDefinition(obj, 'init', x,y);
end  %%% DELETE %%%

rpbox('runstart_enable');

return;



