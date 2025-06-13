% @Multipokes3/RewardsSection.m
% Bing, June 2007


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


function [x, y] = RewardsSection(obj, action, x, y)
   
GetSoloFunctionArgs;

switch action
  case 'init',
    % Save the figure and the position in the figure where we are
    % going to start adding GUI elements:
    SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);

    DispParam(obj, 'nTrials',  0, x, y); next_row(y);
    DispParam(obj, 'nRewards', 0, x, y); next_row(y);
    DispParam(obj, 'mean_hitfrac', 0, x, y, ...
        'TooltipString', 'nRewards/nTrials'); next_row(y);
        
    SubheaderParam(obj, 'title', mfilename, x, y);
    next_row(y, 1.5);
    
    
  case 'update',
    if n_done_trials > 0,
        if rows(parsed_events.states.hit_state) > 0, hit_history.value = [hit_history(:) ; 1];
        else                                         hit_history.value = [hit_history(:) ; 0];
        end;
    
        nTrials.value = nTrials + 1;
        if hit_history(length(hit_history)) == 1, nRewards.value = nRewards + 1; end;    
        if nTrials > 0, mean_hitfrac.value = nRewards/nTrials; end;
    end;
    
  case 'reinit',
    currfig = gcf;

    % Get the original GUI position and figure:
    x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));

    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);

    % Reinitialise at the original GUI position and figure:
    [x, y] = feval(mfilename, obj, 'init', x, y);

    % Restore the current figure:
    figure(currfig);
end;


