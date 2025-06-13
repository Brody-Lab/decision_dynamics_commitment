function [obj] = odor_test2obj(name)
    
% -------- BEGIN Magic code that all protocol objects must have ---
%
% No need to alter this code: will work for every protocol. Jump to 
% "END Magic code" to start your own code part.
  
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
fig_dim = get(value(myfig),'position');

SoloFunctionAddVars('close', 'ro_args', 'myfig');


% Make the title of the figure be the protocol name, and if someone tries
% to close this figure, call Exper's ModuleClose function, so it'll know
% to take it off Exper's list of open protocols.
name = lower(name);
set(value(myfig),'position',fig_dim, 'Name', name, 'Tag', name, ...
                  'closerequestfcn', ['ModuleClose(''' name ''')'], ...
                  'NumberTitle', 'off'); %, 'MenuBar', 'none');

%
% -------- END Magic code that all protocol objects must have ---
%


SoloParamHandle(obj, 'n_done_trials',    'value', 0);
SoloParamHandle(obj, 'n_started_trials', 'value', 0);

SoloParamHandle(obj, 'LastTrialEvents', 'value', []);

SoloParamHandle(obj, 'FSM','value', rpbox('getstatemachine'));

DeclareGlobals(obj, 'ro_args', {'n_done_trials', 'n_started_trials','FSM'})

% get the IP address of olfactometer and create an object to represent it.
if exist(strcat(pwd, '\olfip.mat')) == 2 % make sure the file exists - should be saved in ExperPort, on each machine
    load('olfip');
else
    olf_IP = inputdlg('olf_IP:', 'Input IP of olfactometer', 1);
    save(strcat(pwd, '\olfip'), 'olf_IP');
end
% creat a SPH to pass the IP address of the OLF_meter
SoloParamHandle(obj,'OLF_IP','value', olf_IP{1});
if ~strcmpi(value(OLF_IP), 'nan'), % if the olfactometer is connectable
    SoloParamHandle(obj,'olf_meter','value', SimpleOlfClient(value(OLF_IP)));
else
    SoloParamHandle(obj, 'olf_meter', 'value',[]);
end
% create a sph to represent the olfmeter
    % to let the OdorSection to see the olfmeter object
DeclareGlobals(obj,'ro_args',{'olf_meter','OLF_IP'});
SoloFunctionAddVars('FSM_DAQ','rw_args',{'LastTrialEvents'});
SoloFunctionAddVars('OdorSection','rw_args',{'LastTrialEvents'});

% ----------

x = 1; y = 1;                     % Initial position on main GUI window

[x, y] = SavingSection(obj, 'init', x, y); 

next_column(x); y = 1;
[x, y] = OdorSection(obj, 'init', x, y);

next_column(x); y = 1;

NumeditParam(obj, 'Max_Trials', 2000, x, y);
next_row(y);

DispParam(obj, 'Trial_Counts', value(n_done_trials), x, y);
SoloFunctionAddVars('state35', 'rw_args', 'Trial_Counts');

next_row(y);

NumeditParam(obj, 'pid_daq_channel', 8, x, y);
next_row(y);
SoloFunctionAddVars('pid_plot_save','ro_args',{'pid_daq_channel'});
SoloFunctionAddVars('FSM_DAQ', 'ro_args', {'pid_daq_channel'});

MenuParam(obj, 'pid_plot', {'on', 'off'}, 1, x, y);
next_row(y);

PushButtonParam(obj,'plot_pid', x, y, 'label', 'Plot PID data'); next_row(y);
set_callback(plot_pid, {'pid_plot_save'});
NumeditParam(obj, 'inter_t_interval', 0.3, x, y);
SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args', {'Max_Trials','pid_plot','OLF_IP', 'inter_t_interval'});

figpos = get(gcf, 'Position');
HeaderParam(obj, 'prot_title', 'Testing OlfactoMeter', ...
            x, y, 'position', [10 figpos(4)-25, 400 20]);

RealTimeStates = make_and_upload_state_matrix(obj, 'init');
FSM_DAQ(obj, 'init');

push_history(class(obj));

n_started_trials.value = 1;
StopDAQ(rpbox('getstatemachine'));
StartDAQ(rpbox('getstatemachine'),[1:8]);
    
% ------------------------------------------------------------------
% List of functions to call, in sequence, when a trial is finished:
% If adding a function to this list,
%    (a) Declare its args with a SoloFunctionAddVars() call
%    (b) Add your function as a method of the current object
%    (c) As the first action of your method, call GetSoloFunctionArgs;
%
SoloParamHandle(obj, 'trial_finished_actions', 'value', { ...
%  'RewardsSection(obj, ''trial_finished'');'             ; ...
  'ComputeAutoSet'                                       ; ...
  % 'SidesSection(obj, ''choose_next_side'');'             ; ...
  % 'SidesSection(obj, ''update_plot'');'                  ; ...
  % 'TimesSection(obj, ''update_plot'');'                ;...
  'OdorSection(obj, ''end_of_trial'');'                ; ... 
  'make_and_upload_state_matrix(obj, ''next_matrix'');'  ; ... 
%  'CurrentTrialPokesSubsection(obj, ''redraw'');' ; ...
  'FSM_DAQ(obj, ''update'');'                           ;...
  'push_history(class(obj));'                            ; ... % no args
});

SoloFunctionAddVars('state35', ...
    'rw_args', {'n_done_trials', 'n_started_trials'}, ...
    'ro_args', 'trial_finished_actions');


SoloParamHandle(obj, 'within_trial_update_actions', 'value', { ...
    %'RewardsSection(obj, ''update'');'                     ; ...
%    'CurrentTrialPokesSubsection(obj, ''update_events'');' ; ...
     'OdorSection(obj, ''update_within_trial'');'...
    });
SoloFunctionAddVars('update', 'ro_args', 'within_trial_update_actions');

% ------------------------------------------------------------------

return;


