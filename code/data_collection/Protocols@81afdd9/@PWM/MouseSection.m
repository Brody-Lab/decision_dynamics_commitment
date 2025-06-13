% [x, y] = MouseSection(obj, action, tname, varargin)
% Emily Jane Dennis August 2019
% added functionality to see if mice have gotten enough water, temporary
% solution to no pub.
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%
%   'init'     Initializes the plugin. Sets up internal variables
%               and the GUI window.
%
% -------------
%


function [x, y] = MouseSection(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action
    
%% init    
  case 'init'
    if length(varargin) < 2
      error('Need at least two arguments, x and y position, to initialize %s', mfilename);
    end
    x = varargin{1}; 
    y = varargin{2};

    SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);

  %adds a button and a soloparam Species which opens and closes the
    %mouse-specific water window
    ToggleParam(obj, 'Species', 0, x, y, ...
        'OnString', 'Mouse', ...
        'OffString', 'Rat', ...
        'TooltipString', 'Show/Hide mouse water window'); 
  set_callback(Species, {mfilename, 'show_hide';});
    next_row(y);
 
    %this saves the position on the main PWM screen so we can return there
    %if the screen is closed/to add other buttons, etc.
    fig = double(gcf);
    oldx = x;
    oldy = y;

    
% add a SPH called mouse_waterfig that includes this window
    SoloParamHandle(obj, 'mouse_waterfig',...
        'value', double(figure('Position', [10 20 600 700], ...
        'closerequestfcn', [mfilename '(' class(obj) ', ''hide''' ');'], 'MenuBar', 'none', ...
        'NumberTitle', 'off', 'Name', mfilename)), 'saveable', 0);

    x = 10; 
    y = 10;     
    
    
    next_row(y)
    
 % return to PWM window
    x=oldx;
    y=oldy;
    figure(fig);

%% case trial_completed
  case 'trial_completed' 

% make a plot that just has a single bar

[Left_volume,Right_volume]=WaterValvesSection(obj,  'get_water_volumes');
wateramnt = (value(goodleft)*value(Left_volume)) + (value(goodright)*value(Right_volume));
%make this water amnt change each trial if rewarded on which side not by
%overall vol

if wateramnt >= 1200
    color = 'cyan';
    txt = 'DONE!';
else
    color = 'red';
    txt= 'NOT YET';
end

%plot in the mouse window
figure(value(mouse_waterfig));
MouseSection(obj,'show_hide');
bar(1,wateramnt,color); hold on;
    ylim([0 1200]);
    text(.8,500,txt,'FontSize',50)
   
%% hide, show_hide
  case 'hide',
    Species.value = 0;
    set(value(mouse_waterfig),'Visible','off');
    feval(mfilename,obj,'show_hide');
  case 'show_hide',
    if value(Species) == 1, set(value(mouse_waterfig), 'Visible', 'on');  %#ok<NODEF>
    else                      set(value(mouse_waterfig), 'Visible', 'off');
    end;


%% close
  case 'close'   
    try %#ok<TRYNC>
        if ishandle(value(mouse_waterfig)), delete(value(mouse_waterfig)); end;
        delete_sphandle('owner', ['^@' class(obj) '$'], 'fullname', [mfilename '_' tname]);
    end;
    
%% reinit
  case 'reinit'
    % Get the original GUI position and figure:
    my_gui_info = value(my_gui_info);
    x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));
    
    % close everything involved with the plugin
    feval(mfilename, obj, 'close');

    % Reinitialise at the original GUI position and figure:
    feval(mfilename, obj, 'init', x, y);
        
%% otherwise    
  otherwise
    warning('%s : action "%s" is unknown!', mfilename, action); %#ok<WNTAG> (This line OK.)

end