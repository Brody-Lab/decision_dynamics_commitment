% [x, y] = YOUR_SECTION_NAME(obj, action, x, y)
%
% Section that takes care of YOUR HELP DESCRIPTION
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%            'init'      To initialise the section and set up the GUI
%                        for it
%
%            'reinit'    Delete all of this section's GUIs and data,
%                        and reinit, at the same position on the same
%                        figure as the original section GUI was placed.
%
% x, y     Relevant to action = 'init'; they indicate the initial
%          position to place the GUI at, in the current figure window
%
% RETURNS:
% --------
%
% [x, y]   When action == 'init', returns x and y, pixel positions on
%          the current figure, updated after placing of this section's GUI. 
%


function [x, y] = PenaltySection(obj, action, x, y)
   
GetSoloFunctionArgs;

switch action
%% init
  case 'init',
    
    
    % Save the figure and the position in the figure where we are
    % going to start adding GUI elements:
    fig = double(gcf);
    SoloParamHandle(obj, 'my_gui_info', 'value', [x y fig]);

    % this is the only thing that shows up on the main GUI window:
    ToggleParam(obj, 'penalty_button', 0, x, y, ...
        'OnString', 'Penalties Panel Showing', ...
        'OffString', 'Penalties Panel Hidden', ...
        'TooltipString', 'Show/Hide the window that controls penalties for the protocol');
    next_row(y);
    set_callback(penalty_button, {mfilename, 'window_toggle'}); %#ok<NODEF>

    origx = x; origy = y;
    

    % Now we set up the window that pops up to specify penalties
    SoloParamHandle(obj, 'mypfig', 'saveable', 0, 'value', ...
        figure('position', [409   316   410   440], ...
            'MenuBar', 'none',  ...
            'NumberTitle', 'off', ...
            'Name','PBups Penalty Settings', ...
            'CloseRequestFcn', [mfilename ...
            '(' class(obj) ', ''hide_window'');']));

        
    x = 5; y = 5; 
     [x, y] = PunishInterface(obj, 'add', 'early_sidepokes_penalty_2r', x, y);
    PunishInterface(obj, 'set', 'early_sidepokes_penalty_2r', 'SoundsPanel', 0);

     [x, y] = PunishInterface(obj, 'add', 'early_sidepokes_penalty_2l', x, y);
    PunishInterface(obj, 'set', 'early_sidepokes_penalty_2l', 'SoundsPanel', 0);

    [x, y] = PunishInterface(obj, 'add', 'early_sidepokes_penalty_1', x, y);
    PunishInterface(obj, 'set', 'early_sidepokes_penalty_1', 'SoundsPanel', 0);

    [x, y] = PunishInterface(obj, 'add', 'dangerpokes_penalty', x, y);
    PunishInterface(obj, 'set', 'dangerpokes_penalty', 'SoundsPanel', 0)

   [x, y] = PunishInterface(obj, 'add', 'violation_penalty1', x, y);
    PunishInterface(obj, 'set', 'violation_penalty1', 'SoundsPanel', 0);
    
     [x, y] = PunishInterface(obj, 'add', 'violation_penalty2', x, y);
    PunishInterface(obj, 'set', 'violation_penalty2', 'SoundsPanel', 0);
 
    [x, y] = PunishInterface(obj, 'add', 'unreward_penalty', x, y);
    PunishInterface(obj, 'set', 'unreward_penalty', 'SoundsPanel', 0);
 
    [x,y] = WarnDangerInterface(obj,'add','wd',x,y);
    
    next_column(x);
    y=5;
         [x, y] = PunishInterface(obj, 'add', 'early_sidepokes_penalty_2r_2nd', x, y);
    PunishInterface(obj, 'set', 'early_sidepokes_penalty_2r_2nd', 'SoundsPanel', 0);

     [x, y] = PunishInterface(obj, 'add', 'early_sidepokes_penalty_2l_2nd', x, y);
    PunishInterface(obj, 'set', 'early_sidepokes_penalty_2l_2nd', 'SoundsPanel', 0);

    [x, y] = PunishInterface(obj, 'add', 'early_sidepokes_penalty_1_2nd', x, y);
    PunishInterface(obj, 'set', 'early_sidepokes_penalty_1_2nd', 'SoundsPanel', 0);

    [x, y] = PunishInterface(obj, 'add', 'dangerpokes_penalty_2nd', x, y);
    PunishInterface(obj, 'set', 'dangerpokes_penalty_2nd', 'SoundsPanel', 0)

   [x, y] = PunishInterface(obj, 'add', 'violation_penalty1_2nd', x, y);
    PunishInterface(obj, 'set', 'violation_penalty1_2nd', 'SoundsPanel', 0);
    
     [x, y] = PunishInterface(obj, 'add', 'violation_penalty2_2nd', x, y);
    PunishInterface(obj, 'set', 'violation_penalty2_2nd', 'SoundsPanel', 0);
 
    [x, y] = PunishInterface(obj, 'add', 'unreward_penalty_2nd', x, y);
    PunishInterface(obj, 'set', 'unreward_penalty_2nd', 'SoundsPanel', 0);
 
    [x,y] = WarnDangerInterface(obj,'add','wd_2nd',x,y);
    
    SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
    feval(mfilename, obj, 'window_toggle');    
    
    x = origx; y = origy; figure(fig);
    return;
       
%% window_toggle
  case 'window_toggle', 
    if value(penalty_button) == 1,  %#ok<NODEF>
            set(value(mypfig), 'Visible', 'on');    
    else
            set(value(mypfig), 'Visible', 'off');
    end;
    
%% hide_window
  case 'hide_window', 
    penalty_button.value_callback = 0;
    
    %% close
    case 'close',
        
        % Close any subwindows that are open
        PunishInterface(obj, 'set', 'early_sidepokes_penalty', 'SoundsPanel', 0);
        PunishInterface(obj, 'set', 'doublepokes_penalty', 'SoundsPanel', 0);
        PunishInterface(obj, 'set', 'dangerpokes_penalty', 'SoundsPanel', 0);
        PunishInterface(obj, 'set', 'violation_penalty', 'SoundsPanel', 0);
        
        if exist('WarningSoundPanelFigure', 'var'),
            delete(value(WarningSoundPanelFigure));
        end;
        delete(value(mypfig));
    
        %% resend
    case 'resend'
        
        % resend the penalty sounds to the sound manager
        SoundInterface(obj,'update','violation_penalty_OngoingSnd');
        
%% reinit
  case 'reinit',
    currfig = double(gcf);

    % Get the original GUI position and figure:
    x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));

    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);
    DistribInterface(obj, 'reinit', 'ITI');

    % Reinitialise at the original GUI position and figure:
    [x, y] = feval(mfilename, obj, 'init', x, y);

    % Restore the current figure:
    figure(currfig);
end;


