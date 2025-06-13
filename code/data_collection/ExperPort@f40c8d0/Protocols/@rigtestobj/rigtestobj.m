function [obj] = rigtestobj(a)

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

fig_position = [485   244   246   550];
set(value(myfig), 'Position', fig_position);

x = 50; y = 10;                     % Position on GUI
next_row(y);
% 
PushbuttonParam(obj, 'leftbtn', x, y, 'label', 'LEFT', ...
                'position', [x y 50 20]); 
            PushbuttonParam(obj, 'rightbtn', x, y, 'label', 'RIGHT', ...
                'position', [x+100 y 50 20]); 
set_callback(leftbtn, {'make_and_upload_state_matrix', 'single_leftsound'});
set_callback(rightbtn, {'make_and_upload_state_matrix', 'single_rightsound'}); next_row(y);
EditParam(obj, 'sfreq', 1, x-20, y, 'label', 'Frequency (KHz)', 'TooltipString', 'Frequency of sound for speaker test'); next_row(y);
EditParam(obj, 'sspl', 65, x-20, y, 'label', 'Test SPL', 'TooltipString', 'Intensity of sound (will be 75 - x)'); next_row(y);
EditParam(obj, 'sdur', 1, x-20, y, 'label', 'Duration (s)', 'TooltipString', 'Sound duration'); next_row(y);


SubheaderParam(obj, 'spkr_sbh', 'Test sound for speaker calibration', x-20, y);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generates buttons to test valves and sound
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

next_row(y,5);
PushbuttonParam(obj, 'soundbtn', x, y, 'label', 'Test SOUND', ...
                'position', [x y 150 30],'BackgroundColor',[1 1 0.6]); 
set_callback(soundbtn, {'make_and_upload_state_matrix', 'test_speakers'});
g = get_ghandle(soundbtn);
set(g,'FontSize',12,'FontAngle','italic','FontWeight','normal');
uicontrol('Style','text','String',sprintf('Plays pure tones of 1-16KHz in LEFT speaker.\nThen does same in RIGHT speaker'),'Position',[10 150 250 50]);


next_row(y, 4);
EditParam(obj,'timedisp', 8, x, y, 'label', 'Time (sec)','labelfraction',0.8);
uicontrol('Style','text','String',sprintf('Dispenses water from left & right valves \nsimultaneously for time entered in above textbox.'),...
    'Position',[20 y-30 200 30]);
set_callback(timedisp, {'make_and_upload_state_matrix','test_timedisp'});
%
next_row(y,1.5);

% PushbuttonParam(obj, 'lightbtn', x, y, 'label', 'Test LIGHT', ...
%                 'position', [x y 100 20]); 
% %set_callback(go, {'make_and_upload_state_matrix', 'start_matrix'});

PushbuttonParam(obj, 'valvebtn', x, y, 'label', 'Test VALVES', ...
                'position', [x y 150 30],'BackgroundColor',[0.8 0.6 0.4]); 
set_callback(valvebtn, {'make_and_upload_state_matrix', 'test_valves'});
g = get_ghandle(valvebtn);

set(g,'FontSize',12,'FontAngle','italic','FontWeight','normal');

next_row(y, 4);

PushbuttonParam(obj, 'allbtn', x, y, 'label', 'Test ALL', ...
                'position', [x y 150 50]); 
g = get_ghandle(allbtn);
set(g,'FontSize',14);
uicontrol('Style','text','String',sprintf('Runs first the valve test and then\nthe sound test.'),'Position',[20 y-30 200 30]);


set_callback(allbtn, {'make_and_upload_state_matrix', 'test_all'});

next_row(y, 4);

SoloFunction('make_and_upload_state_matrix', 'ro_args', {'sfreq', 'sspl','sdur'},'rw_args',{'timedisp'});
make_and_upload_state_matrix(obj, 'init', x, y);
SoloParamHandle(obj, 'trial_finished_actions', 'value', { ...
  'make_and_upload_state_matrix(obj, ''stop_matrix'');'  ; ... 
  'push_history(class(obj));'                            ; ... % no args
});

SoloFunction('state35', 'ro_args', 'trial_finished_actions');
SoloFunction('close', 'ro_args', 'myfig');
