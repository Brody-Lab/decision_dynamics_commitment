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


function [x, y] = CpokeSection(obj, action, x, y)

GetSoloFunctionArgs;

switch action
    %% init
    case 'init',
        % Save the figure and the position in the figure where we are
        % going to start adding GUI elements:
        SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);
        
              
        MenuParam(obj,'center_led',{'on','off','on_at_cpoke','off_at_cpoke'},1,x,y,'TooltipString','When should the center LED be lit during fixation?  "on" and "off" will leave it on (or off) both before and during fixation.  "on/off at cpoke" will light(extinguish) the light upon sucessful center poke');
        next_row(y);
        NumeditParam(obj,'nose_in_center',0.200,x,y,'TooltipString','Nose-in-center time, in seconds');
        next_row(y);
        NumeditParam(obj,'legal_cbreak',0.010,x,y,'TooltipString','How long the rat is allowed to break "fixation" for without penalty');
        next_row(y);
        
        SubheaderParam(obj, 'title', 'Timing Section', x, y);
        next_row(y, 1.5);
        
        
        
        %% next_trial
    case 'next_trial',
        return
        
    case 'get_center_led'
        x = value(center_led);
        
    case 'get_timing'
        
        x.nose_in_center = value(nose_in_center);
        x.legal_cbreak = value(legal_cbreak);
        
end;