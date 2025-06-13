function [obj] = templateobj(name)
    
% -------- BEGIN Magic code that all protocol objects must have ---
%
% No need to alter this code: will work for every protocol. Jump to 
% "END Magic code" to start your own code part.
%
   
% Default object:
obj = class(struct, mfilename);

% If creating an empty object, return without further ado:
if nargin==0 || (nargin==1 && ischar(name) && strcmp(name, 'empty')), 
   return; 
end;

% Delete previous vars owned by this object:
delete_sphandle('owner', ['^@', mfilename '$']); 

% Non-empty: proceed with regular init of this object
if nargin~=1 || ~isstr(name), 
   error(['To initialize this protocol, you need to call the constructor ' ...
          'with the name of the protocol as its only arg.']); 
end;

% Make default figure. We remember to make it non-saveable; on next run
% the handle to this figure might be different, and we don't want to
% overwrite it when someone does load_data and some old value of the
% fig handle was stored as SoloParamHandle "myfig"
SoloParamHandle(obj, 'myfig', 'saveable', 0); myfig.value = figure;

% Give close.m access to myfig, so that upon closure the figure may be
% deleted: 
SoloFunctionAddVars('close', 'ro_args', 'myfig');


% Make the title of the figure be the protocol name, and if someone tries
% to close this figure, call Exper's ModuleClose function, so it'll know
% to take it off Exper's list of open protocols.
name = lower(name);
set(value(myfig), 'Name', name, 'Tag', name, ...
                  'closerequestfcn', ['ModuleClose(''' name ''')'], ...
                  'NumberTitle', 'off', 'MenuBar', 'none');

%
% -------- END Magic code that all protocol objects must have ---
%



% Ok, at this point we have one SoloParamHandle, myfig 

% Let's put the figure where we want it and give it a reasonable size:
set(value(myfig), 'Position', [485   244   650   650]);


% Let's declare some globals that everybody is likely to want to know about.
% Number of finished trials:
SoloParamHandle(obj, 'n_done_trials',    'value', 0);

% Number of trials started (*during* a trial, n_started_trials will be
% one greater than n_done_trials; during an intertrial interval, the
% two will be the same):
SoloParamHandle(obj, 'n_started_trials', 'value', 0);

% History of hit/miss:
SoloParamHandle(obj, 'hit_history',      'value', []);


SoloParamHandle(obj, 'total_length',      'value', 0);

SoloParamHandle(obj, 'total_length2',      'value', 0);

% Every function will be able to read these, but only those explicitly
% given r/w access will be able to modify them:
DeclareGlobals(obj, 'ro_args', {'n_done_trials', 'n_started_trials', ...
                    'hit_history'});

% Let RewardsSection, the part that parses what happened at the end of
% a trial, write to hit_history:
SoloFunctionAddVars('RewardsSection', 'rw_args', 'hit_history');

SoloFunctionAddVars('SoundSection', 'rw_args', {'total_length', 'total_length2'});

SoloFunctionAddVars('make_and_upload_state_matrix', 'rw_args', {'total_length', 'total_length2'});

% ----------

x = 1; y = 1;                     % Initial position on main GUI window

% Section of the code that takes care of saving/loading data and
% settings. This section's GUIs will be placed at x, y, and upon returning
% from its initialization, it will have updated x and y so that the next
% section's GUIs doesn't go on top.
[x, y] = SavingSection(obj, 'init', x, y); 


% Section of the code that takes care of how long to keep the water valves
% open when giving a water reward:
[x, y] = WaterValvesSection(obj, 'init', x, y);  


% Section that chooses the next correct side and keeps track of previous
% side history. 
[x, y] = SidesSection(obj, 'init', x, y);

% Section that sets ITI times, etc. 
[x, y] = TimesSection(obj, 'init', x, y);


figpos = get(gcf, 'Position');
HeaderParam(obj, 'prot_title', 'Click Pattern Discrimination', ...
            x, y, 'position', [10 figpos(4)-25, 400 20]);
numeditparam(obj,'click1',.5,420,440);
numeditparam(obj,'delay1',.2,420,420);
numeditparam(obj,'click2',.5,420,400);
numeditparam(obj,'delay2',.2,420,380);
numeditparam(obj,'click3',.5,420,360);
numeditparam(obj,'delay3',0,420,340);
numeditparam(obj,'click4',0,420,320);
numeditparam(obj,'delay4',0,420,300);
numeditparam(obj,'click5',0,420,280);
numeditparam(obj,'delay5',0,420,260);
numeditparam(obj,'click6',.05,420,200);
numeditparam(obj,'delay6',.05,420,180);
numeditparam(obj,'click7',.05,420,160);
numeditparam(obj,'delay7',.05,420,140);
numeditparam(obj,'click8',1,420,120);
numeditparam(obj,'delay8',0,420,100);
numeditparam(obj,'click9',0,420,80);
numeditparam(obj,'delay9',0,420,60);
numeditparam(obj,'click10',0,420,40)
numeditparam(obj,'delay10',0,420,20);


numeditparam(obj,'Tone_Frequency',2000,210,440);
MenuParam(obj, 'Tone_Type', {'Tone' 'WhiteNoise'}, ...
                'Tone', 210, 410);


SoloFunctionAddVars ('SoundSection', 'ro_args', {'Tone_Frequency','Tone_Type','click1', 'delay1', 'click2', 'delay2', 'click3', 'delay3', 'click4', 'delay4', 'click5', 'delay5', 'click6', 'delay6', 'click7', 'delay7', 'click8', 'delay8', 'click9', 'delay9', 'click10', 'delay10'});










next_column(x); y = 1;
% Section that sets the sound for each side. 
[x, y] = SoundSection(obj, 'init', x, y);


% Initialize section that takes care of preparing and uploading the state
% matrix, and pload up the first trial's state matrix.
make_and_upload_state_matrix(obj, 'init');
% The first trial starts upon uploading the first state matrix:
n_started_trials.value = 1;


% Initialize section that parses the results of each trial, and keeps
% track of hits and errors. 
RewardsSection(obj, 'init');



% ------------------------------------------------------------------
% List of functions to call, in sequence, when a trial is finished:
% If adding a function to this list,
%    (a) Declare its args with a SoloFunctionAddVars() call
%    (b) Add your function as a method of the current object
%    (c) As the first action of your method, call GetSoloFunctionArgs;
%
% Below, push_history(class(obj)) will push the history of all GUI
% SoloParamHandles; 
SoloParamHandle(obj, 'trial_finished_actions', 'value', { ...
  'RewardsSection(obj, ''trial_finished'');'             ; ...
  'ComputeAutoSet'                                       ; ...
  'SidesSection(obj, ''choose_next_side'');'             ; ...
  'SidesSection(obj, ''update_plot'');'                  ; ...
  'SoundSection(obj, ''make_sounds'');'                  ; ... 
  'SoundSection(obj, ''upload_sounds'');'                ; ... 
  'make_and_upload_state_matrix(obj, ''next_matrix'');'  ; ... 
  'push_history(class(obj));'                            ; ... % no args
});
% Here's a breakdown of what we did above:
% 1) parse the result of the latest trial, update hit_history
% 2) go through any autoset strings defined for GUI parameters
% 3) Choose which side is going to be the next correct side:
% 4) update the plot of sides.
% 5) upload new sounds if necessary
% 6) prepare and send the next state matrix

% state 35 will add one to n_done_trials, then go through the
% trial_finished actions, then add one to n_started_trials
SoloFunctionAddVars('state35', ...
    'rw_args', {'n_done_trials', 'n_started_trials'}, ...
    'ro_args', 'trial_finished_actions');


% List of functions to call, in sequence, when an update call is made.
% (Every 350 ms or so, the RPbox.m module polls the RT machine to ask for
% the latest events, and then calls the update.m method on the
% current protocol.)
% This has a similar structure to trial_finished_actions. Here we call 
% update on RewardsSection to ask it to accumulate the events for the
% trial.
SoloParamHandle(obj, 'within_trial_update_actions', 'value', { ...
    'RewardsSection(obj, ''update'');'                    ; ...
    });
SoloFunctionAddVars('update', 'ro_args', 'within_trial_update_actions');

% ------------------------------------------------------------------

return;


