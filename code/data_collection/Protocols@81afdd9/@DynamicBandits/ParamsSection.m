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


function [x, y] = ParamsSection(obj, action, x, y)

GetSoloFunctionArgs;

switch action
    %% init
    case 'init',
        % Save the figure and the position in the figure where we are
        % going to start adding GUI elements:
        SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);
        
              
       
      
        ToggleParam(obj,'forgiveness',0,x,y,'OnString','Forgiveness Enabled','OffString','Forgiveness Disabled');
        set_callback(forgiveness, {mfilename, 'toggle_forgiveness'});
        set_callback_on_load(forgiveness,1);
        next_row(y);
        NumeditParam(obj,'forgiveness_delay',0.010,x,y,'TooltipString','If forgiveness is enabled, how long is the reward delay on a forgiveness trial');
        next_row(y);
        NumeditParam(obj,'forgiveness_available',1,x,y,'TooltipString','If forgiveness is enabled, how long after an incorrect poke does the rat have to make a correct poke');
        next_row(y);
        ToggleParam(obj,'unreward_punish',0,x,y,'OnString','Punish unrewarded trials','OffString','Do not punish unrewarded trials');
        set_callback(unreward_punish, {mfilename, 'toggle_unreward'});
        set_callback_on_load(unreward_punish,1);
        next_row(y);
        NumeditParam(obj,'unreward_time',1,x,y,'TooltipString','How much time passes between an unrewarded response and the start of the next trial.');
        next_row(y);
        NumeditParam(obj,'softdrink_time',1,x,y,'TooltipString','If softdrink is enabled, how long the rat may leave the drink port for without ending the drinktime');
        next_row(y);
        ToggleParam(obj,'enable_softdrink',1,x,y, 'OffString', 'disable softdrink', 'OnString',  'enable softdrink','TooltipString','IF soft drink time is enabled, the animal can end drinktime and move to the next trial by leaving the port and staying out for at least softdrink_time');
        set_callback(enable_softdrink, {mfilename, 'toggle_softdrink'});
        next_row(y);
        NumeditParam(obj,'drink_time',5,x,y,'TooltipString','Maximum amount of time that is allowed for the rat to drink');
        next_row(y);
        NumeditParam(obj,'reward_delay',0.010,x,y,'TooltipString','How long to wait after a side-poke before delivering reward');
        next_row(y);
        
        % Things relating to nose-in-center
        NumeditParam(obj,'cpoke_violation_timeout',1,x,y,'TooltipString','How long after a centerpoke violation can the rat resume centerpoking');
        next_row(y);
        NumeditParam(obj,'legal_cbreak',0.010,x,y,'TooltipString','How long the rat is allowed to break "fixation" for without penalty');
        next_row(y);
        NumeditParam(obj,'nose_in_center',0.200,x,y,'TooltipString','Nose-in-center time, in seconds');
        next_row(y);
        MenuParam(obj,'center_led',{'on','off','on_at_cpoke','off_at_cpoke'},1,x,y,'TooltipString','When should the center LED be lit during fixation?  "on" and "off" will leave it on (or off) both before and during fixation.  "on/off at cpoke" will light(extinguish) the light upon sucessful center poke');
        next_row(y);
        
        % Misc. things
        ToggleParam(obj,'sound_timing',0,x,y,'OnString','Sound After Cpoke','OffString','Sound for Whole Trial');
        next_row(y);
        
        
        SubheaderParam(obj, 'title', 'Params Section', x, y);
        next_row(y, 1.5);
        ParamsSection(obj,'toggle_forgiveness');
        
        
    case 'toggle_softdrink'
        
        if value(enable_softdrink)
            enable(softdrink_time);
        else
            disable(softdrink_time);
        end
        
    case 'toggle_unreward'
        
        if value(unreward_punish)
            disable(unreward_time);
        else
            enable(unreward_time);
        end
        
    case 'toggle_forgiveness'
        
        if value(forgiveness)
            enable(forgiveness_delay);
            enable(forgiveness_available);
        else
            disable(forgiveness_delay);
            disable(forgiveness_available);
        end
        
        
        %% next_trial
    case 'next_trial',
        return
        
    case 'get_center_led'
        x = value(center_led);
        
    case 'get_timing'
        
        x.nose_in_center = value(nose_in_center);
        x.legal_cbreak = value(legal_cbreak);
        x.reward_delay = value(reward_delay);
        x.softdrink_enabled = value(enable_softdrink);
        x.drink_time = value(drink_time);
        x.softdrink_time = value(softdrink_time);
        x.unreward_time = value(unreward_time);
        x.cpoke_violation_timeout = value(cpoke_violation_timeout);
        x.sound_timing = value(sound_timing);
        x.forgiveness = value(forgiveness);
        x.forgiveness_delay = value(forgiveness_delay);
        x.forgiveness_available = value(forgiveness_available);
        x.unreward_punish = value(unreward_punish);

end