function [obj] = nl_odorsampobj(name)
    
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
load('olfip'); 
if isempty(olf_IP)
    olf_IP = inputdlg('You must input something :)', 'Input IP of olfactometer', 1);
    save('C:\Home\RatExper\ExperPort\Protocols\@nl_odorsampobj\olfip', 'olf_IP');
else
    olf_IP = inputdlg('olf_IP:', 'Input IP of olfactometer', 1, olf_IP);
end

save('c:\Home\RatExper\ExperPort\Protocols\@nl_odorsampobj\olfip', 'olf_IP');


% creat a SPH to pass the IP address of the OLF_meter
SoloParamHandle(obj,'OLF_IP','value', olf_IP{1});
if ~strcmpi(value(OLF_IP), 'nan'), % if the olfactometer is connectable
    SoloParamHandle(obj,'olf_meter','value', SimpleOlfClient(value(OLF_IP)));
    % to let the OdorSection to see the IP address
    SoloFunctionAddVars('OdorSection','ro_args','olf_meter');
end

% to let the OdorSection to see the IP address
SoloFunctionAddVars('OdorSection','ro_args','OLF_IP');
SoloFunctionAddVars('make_and_upload_state_matrix','ro_args','OLF_IP');

SoloParamHandle(obj, 'myfig', 'saveable', 0); myfig.value = figure;
fig_dim = get(value(myfig),'position');
fig_dim(4) = fig_dim(3)+500;

% Give close.m access to myfig, so that upon closure the figure may be
% deleted: 
SoloFunctionAddVars('close', 'ro_args', 'myfig');


% Make the title of the figure be the protocol name, and if someone tries
% to close this figure, call Exper's ModuleClose function, so it'll know
% to take it off Exper's list of open protocols.
name = lower(name);
set(value(myfig),'position',fig_dim, 'Name', name, 'Tag', name, ...
                  'closerequestfcn', ['ModuleClose(''' name ''')'], ...
                  'NumberTitle', 'off', 'MenuBar', 'none');

%
% -------- END Magic code that all protocol objects must have ---
%



% Ok, at this point we have one SoloParamHandle, myfig 

% Let's put the figure where we want it and give it a reasonable size:
set(value(myfig), 'Position', [385   250   630   550]);


% Let's declare some globals that everybody is likely to want to know about.
% Number of finished trials:
SoloParamHandle(obj, 'n_done_trials',    'value', 0);

% Number of trials started (*during* a trial, n_started_trials will be
% one greater than n_done_trials; during an intertrial interval, the
% two will be the same):
SoloParamHandle(obj, 'n_started_trials', 'value', 0);

% History of hit/miss:
SoloParamHandle(obj, 'hit_history',      'value', []);

SoloParamHandle(obj, 'LastTrialEvents', 'value', []);

SoloParamHandle(obj, 'prevtrial',        'value', []);

% Every function will be able to read these, but only those explicitly
% given r/w access will be able to modify them:
DeclareGlobals(obj, 'ro_args', {'n_done_trials', 'n_started_trials', ...
                    'hit_history', 'prevtrial'});

% Let RewardsSection, the part that parses what happened at the end of
% a trial, write to hit_history:
SoloFunctionAddVars('RewardsSection', 'rw_args', {'hit_history', 'prevtrial','LastTrialEvents'});

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


% Section that sets the parameter of the olfactometer. 
next_column(x); y = 1;
[x, y] = OdorSection(obj, 'init', x, y);


% Section that chooses the next correct side and keeps track of previous
% side history. 
%[x, y] = SidesSection(obj, 'init', x, y);

next_column(x); y = 1;

% Section that sets ITI times, etc. 
[x, y] = TimesSection(obj, 'init', x, y);


figpos = get(gcf, 'Position');
HeaderParam(obj, 'prot_title', 'Odor Operant/Sampling training', ...
            x, y, 'position', [10 figpos(4)-25, 400 20]);

RealTimeStates = make_and_upload_state_matrix(obj, 'init');

RewardsSection(obj, 'init');        

% --- current trial pokes figure
SoloFunctionAddVars('CurrentTrialPokesSubsection', ...
    'ro_args', {'RealTimeStates'}, 'rw_args', 'LastTrialEvents');
[x, y] = CurrentTrialPokesSubSection(obj, 'init', x, y);

push_history(class(obj));

n_started_trials.value = 1;


prevtrial.value = parse_trial([], value(RealTimeStates));


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
  % 'SidesSection(obj, ''choose_next_side'');'             ; ...
  % 'SidesSection(obj, ''update_plot'');'                  ; ...
  'TimesSection(obj, ''update_plot'');'                ;...
  'OdorSection(obj, ''update_odor'');'                ; ... 
  'make_and_upload_state_matrix(obj, ''next_matrix'');'  ; ... 
  'CurrentTrialPokesSubsection(obj, ''redraw'');' ; ...
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
% update on RewardsSection to ask it to 0accumulate the events for the
% trial.
SoloParamHandle(obj, 'within_trial_update_actions', 'value', { ...
    %'RewardsSection(obj, ''update'');'                     ; ...
    'CurrentTrialPokesSubsection(obj, ''update_events'');' ; ...
    });
SoloFunctionAddVars('update', 'ro_args', 'within_trial_update_actions');

% ------------------------------------------------------------------

return;


