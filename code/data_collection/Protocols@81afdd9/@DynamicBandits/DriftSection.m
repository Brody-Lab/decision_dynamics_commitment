% [x, y] = ParamsSection(obj, action, x, y)
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


function [x, y] = DriftSection(obj, action, x, y)

GetSoloFunctionArgs;

switch action
    %% init
    case 'init',
        % Save the figure and the position in the figure where we are
        % going to start adding GUI elements:
        SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);
        
        ToggleParam(obj,'random_start',1,x,y,'OnString','New values on startup','OffString','Keep previous values');
        next_row(y);
        ToggleParam(obj,'enable_drifts',1,x,y,'OnString','Drifts Enabled','OffString','Drifts Disabled');
        set_callback(enable_drifts, {mfilename,'toggle_drifts'});
        next_row(y);
        NumeditParam(obj,'var1',0.01,x,y,'TooltipString','Variance of the drift in context one');
        next_row(y);
        NumeditParam(obj,'var2',0.01,x,y,'TooltipString','Variance of the drift in context two');
        next_row(y);
        

        
        SubheaderParam(obj, 'title', 'Drift Section', x, y);
        next_row(y, 1.5);
        
        
      
    case 'toggle_drifts'
        
        if value(enable_drifts)
            enable(var1);
            enable(var2);
        else
            disable(var1);
            disable(var2);
        end
        
        %% drift - takes probabilities, drifts them, and returns new probabilities
    case 'drift',
        
        % x will be a vector of the current values of the reward
        % probabilities.  if drifting is enabled, apply gaussian random
        % drift to these with the appropriate sigma
        
        if value(enable_drifts)
            drifts = [value(var1),value(var1),value(var2),value(var2)];
            
            for prob_i = 1:4
                
                x(prob_i) = x(prob_i) + normrnd(0,drifts(prob_i));
                
            end
            
            x(x < 0) = 0;
            x(x > 1) = 1;
        end
        
    case 'first_trial'
        
        if value(random_start)
            x = rand(1,4);
        else
            x = NaN;
        end
end