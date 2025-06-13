% @TBups/PenaltySection.m


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
    % [x, y] = DistribInterface(obj, 'add', 'ITI', x, y, 'Style', ...
    %                 'gaussian', 'Mu', 0.001, 'Sd', 0.001, 'Min', 0, 'Max', 20);
    % NumeditParam(obj, 'miss_ITI', 0, x, y, ...
    %     'TooltipString', 'extra ITI when previos trial was an error');
    % next_row(y,1.5);
    
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
        double(figure('position', [409   316   250   450], ...
            'MenuBar', 'none',  ...
            'NumberTitle', 'off', ...
            'Name','TBups Penalty Settings', ...
            'CloseRequestFcn', [mfilename ...
            '(' class(obj) ', ''hide_window'');'])));

        
    x = 5; y = 5; boty = 5;
    
    [x, y] = PunishInterface(obj, 'add', 'ErrorPun', x, y);
    PunishInterface(obj, 'set', 'ErrorPun', 'SoundsPanel', 0);
    next_row(y);
    [x, y] = PunishInterface(obj, 'add', 'TempErrorPun', x, y);
    PunishInterface(obj, 'set', 'TempErrorPun', 'SoundsPanel', 0);
    next_row(y);

    [x, y] = PunishInterface(obj, 'add', 'ViolPun', x, y);
    PunishInterface(obj, 'set', 'ViolPun', 'SoundsPanel', 0);

    % [x, y] = PunishInterface(obj, 'add', 'TimeOutPun', x, y);
    % PunishInterface(obj, 'set', 'TimeOutPun', 'SoundsPanel', 0);

    NumeditParam(obj, 'viol_no_sound_dur', 2, x, y, 'position', [x y 100 20], ...
      'labelfraction', 0.6, ...
      'TooltipString', sprintf(['\nDuration of violation timeout state']));
    next_row(y);
    ToggleParam(obj, 'SideChoicePunishmentType', 0, x, y, ...
        'OffString', 'trial terminates -> error sound', ...
        'OnString',  'temporary err sound, cpoke or spoke again to retry', ...
        'TooltipString', sprintf(['\nIf brown, upon wrong side choice the trial is terminated and TimeOutSound plays' ...
                                  '\nIf black, wrong side choice plays no sound; stimulus sound is not turned off']));
    next_row(y);
    
    ToggleParam(obj, 'PunishSideChoice', 1, x, y, ...
        'OffString', 'do not punish error', ...
        'OnString',  'punish error', ...
        'TooltipString', 'If black, punish error: choose type of punishment');
    next_row(y);

    ToggleParam(obj, 'ViolPunishmentType', 0, x, y, ...
        'OffString', 'trial terminates -> viol sound', ...
        'OnString',  'no viol sound and trial terminates', ...
        'TooltipString', sprintf(['\nIf brown, upon wrong side choice the trial is terminated and TimeoutSound plays' ...
                                  '\nIf black, no sound plays and trial is terminated']));
    next_row(y);
    
    ToggleParam(obj, 'PunishViol', 1, x, y, ...
        'OffString', 'do not violation', ...
        'OnString',  'violation', ...
        'TooltipString', 'If black, violation: choose type of punishment');

    next_row(y);

    [x, y] = DistribInterface(obj, 'add', 'ITI', x, y, 'Style', ...
                    'gaussian', 'Mu', 2, 'Sd', 1, 'Min', 0, 'Max', 20);

    NumeditParam(obj, 'miss_ITI', 2, x, y, ...
        'TooltipString', 'extra ITI when previos trial was an error');
    
    SoloFunctionAddVars('StateMatrixSection', 'ro_args', ...
          { 'ITI'; 'miss_ITI'; ...
          'PunishSideChoice'; 'SideChoicePunishmentType'; ...
          'PunishViol'; 'ViolPunishmentType';'viol_no_sound_dur'});
    for i = 1:numel(value(active_curricula))
      % Construct the function call with the updated curriculum name
      current_curricula = value(active_curricula{i});
      function_call = sprintf("SoloFunctionAddAllVars(obj, 'TS_%s', 'rw_args');", current_curricula);
      eval(function_call);
    end   
    SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
    feval(mfilename, obj, 'window_toggle');    
   
    x = origx; y = origy; figure(fig);
    return;

  case 'get_ITI',
    DistribInterface(obj, 'sample', 'ITI');
    if ~isempty(hit_history) && hit_history(n_done_trials)==0 && probe_history(n_done_trials) == 0,
      extra_iti = value(miss_ITI);
    else
      extra_iti = 0;
    end;
      x = DistribInterface(obj, 'get_current_sample', 'ITI') + extra_iti;

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
    if exist('WarningSoundPanelFigure', 'var'),
      delete(value(WarningSoundPanelFigure));
    end;  
    delete(value(mypfig));    
    
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


