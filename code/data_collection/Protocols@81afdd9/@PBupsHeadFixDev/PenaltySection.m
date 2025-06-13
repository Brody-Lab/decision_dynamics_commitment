% @PBups/PenaltySection.m
% Bing, March 2009


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
    [x, y] = DistribInterface(obj, 'add', 'ITI', x, y, 'Style', ...
                    'gaussian', 'Mu', 0.001, 'Sd', 0.001, 'Min', 0, 'Max', 20);
    NumeditParam(obj, 'miss_ITI', 0, x, y, ...
        'TooltipString', 'extra ITI when previos trial was an error');
    next_row(y,1.5);
    
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
        double(figure('position', [409   316   220   450], ...
            'MenuBar', 'none',  ...
            'NumberTitle', 'off', ...
            'Name','PBups Penalty Settings', ...
            'CloseRequestFcn', [mfilename ...
            '(' class(obj) ', ''hide_window'');'])));

        
    x = 5; y = 5; boty = 5;
    
    
    [x, y] = PunishInterface(obj, 'add', 'StimPun', x, y);
    PunishInterface(obj, 'set', 'StimPun', 'SoundsPanel', 0);
    
    ToggleParam(obj, 'PunishStimLicks', 0, x, y, ...
        'OffString', 'do not punish licks during stim', ...
        'OnString',  'punish licks during stim', ...
        'TooltipString', sprintf(['\nIf brown, licking during sound stimulus does nothing;' ...
                                  '\nIf black, licking emits Violation1Sound and ITI restarts']));
    next_row(y,2);

    
    [x, y] = PunishInterface(obj, 'add', 'ITIPun', x, y);
    PunishInterface(obj, 'set', 'ITIPun', 'SoundsPanel', 0);
    ToggleParam(obj, 'PunishITIPokes', 0, x, y, ...
        'OffString', 'do not punish pokes during ITI', ...
        'OnString',  'punish pokes during ITI', ...
        'TooltipString', 'if black, punish pokes during ITI with Violation3Sound');    
    
    next_row(y, 2);
  
    NumeditParam(obj, 'BreakDrinkTime', 1, x, y, ...'position', [x y 150 20], ...
        'TooltipString', 'After this amount of time has passed without licks, we assume he is done drinking and go on');
    next_row(y);
    NumeditParam(obj, 'TotDrinkTime', 5, x, y, 'TooltipString', sprintf('\nTime over which drinking is ok')); 
    feval(mfilename, obj, 'check_drink_time');
    next_row(y);
    
    next_row(y, 1);
    
    [x, y] = PunishInterface(obj, 'add', 'ErrorPun', x, y);
    PunishInterface(obj, 'set', 'ErrorPun', 'SoundsPanel', 0);
    
    [x, y] = PunishInterface(obj, 'add', 'TimeOutPun', x, y);
    PunishInterface(obj, 'set', 'TimeOutPun', 'SoundsPanel', 0);

    ToggleParam(obj, 'LEDtemp_pun', 0, x, y, 'position', [x+180 y-25 20 20], ...
      'TooltipString', sprintf(['\nIf brown, side light choice doesn''t stay on in temporary punsihment;' ...
                                '\nIf black, it does stay on']));
    
    
    ToggleParam(obj, 'PunishSideChoice', 1, x, y, ...
        'OffString', 'do not punish wrong side choice', ...
        'OnString',  'punish wrong side choice', ...
        'TooltipString', 'If black, punish wrong side choice: choose type of punishment');

    next_row(y);

    ToggleParam(obj, 'StimRewardWait', 1, x, y, ...
        'OffString', 'reward during stim', ...
        'OnString',  'reward post stim only', ...
        'TooltipString', 'If black, animal wont get reward until after stimulus is over');

    SoloFunctionAddVars('StateMatrixSection', 'ro_args', ...
          {'PunishStimLicks'; 'PunishSideChoice'; ...
          'PunishITIPokes'; 'BreakDrinkTime'; 'TotDrinkTime'; ...
          'StimRewardWait'; 'miss_ITI'; 'LEDtemp_pun'});
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
%% check_drink_time
    case 'check_drink_time'
        if exist('DrinkTime', 'var')
            if ~isempty(PBupsSection(obj, 'get_ReplaySpecs'))
                disable(DrinkTime)
            else
                enable(DrinkTime)
            end
        end
%% get_ITI
  case 'get_ITI',
	DistribInterface(obj, 'sample', 'ITI');
	if ~isempty(hit_history) && (hit_history(n_done_trials)==0 || isnan(hit_history(n_done_trials))),
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


