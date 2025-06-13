% [x, y] = SidesSection(obj, action, x, y)
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


function [x, y] = BaitingSection(obj, action, x, y)

GetSoloFunctionArgs;

switch action
    %% init
    case 'init',
        % Save the figure and the position in the figure where we are
        % going to start adding GUI elements:
        SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);
        
              
        DispParam(obj,'LeftBaited',1,x,y,'TooltipString','Is a reward available on the left side this trial?')
        next_row(y);
        DispParam(obj,'RightBaited',1,x,y,'TooltipString','Is a reward available on the right side this trial?')
        next_row(y);
        
        NumeditParam(obj,'LeftBaitProb',0.5,x,y,'TooltipString','What is the probability of reward on the left side?')
        next_row(y);
        NumeditParam(obj,'RightBaitProb',0.5,x,y,'TooltipString','What is the probability of reward on the right side?')
        next_row(y);
        set_callback(LeftBaitProb, {mfilename, 'update_baiting'});
        set_callback(RightBaitProb, {mfilename, 'update_baiting'});

        MenuParam(obj,'Trial_Type', {'Free Trial','Forced: Right','Forced: Left'}, 1, x, y,...
            'TooltipString', sprintf(['\n' ...
            'On a free trial, the rat can choose which poke to select - in a forced trial, the rat is required to go to the specified side. Trial type will be indicated to the rat using the lights.']));
        set_callback(Trial_Type, {mfilename,'update_baiting'});
        next_row(y);
        
        SubheaderParam(obj, 'title', 'Baiting Section', x, y);
        next_row(y, 1.5);
        
        BaitingSection(obj,'update_baiting');
        
        
        %% update_baiting
        
    case 'update_baiting'
        
        switch value(Trial_Type)
            case 'Free Trial'
                LeftBaited.value = uint8(rand <= value(LeftBaitProb));
                RightBaited.value = uint8(rand <= value(RightBaitProb));
            case 'Forced: Right'
                LeftBaited.value = 0;
                RightBaited.value = uint8(rand <= value(RightBaitProb));
            case 'Forced: Left'
                RightBaited.value = 0;
                LeftBaited.value = uint8(rand <= value(LeftBaitProb));
        end
     
    case 'get_baiting'
        
        x.trial_type = value(Trial_Type);
        x.left_baited = value(LeftBaited);
        x.right_baited = value(RightBaited);
        
end;