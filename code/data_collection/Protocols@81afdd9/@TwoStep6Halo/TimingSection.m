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


function [x, y] = TimingSection(obj, action, x, y)

GetSoloFunctionArgs;

switch action
    %% init
    case 'init',
        % Save the figure and the position in the figure where we are
        % going to start adding GUI elements:
        SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);
        
        ToggleParam(obj,'unreward_water',0,x,y,'OnString','Give water on unrewarded trials','OffString','Do not give water on unrewarded trials');
        next_row(y);
        set_callback(unreward_water, {mfilename, 'toggle_unreward_water'});
        set_callback_on_load(unreward_water,1);
        
        NumeditParam(obj,'unreward_mult',1,x,y,'TooltipString','Fraction of the full reward given on "unrewarded" trials.');
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
        MenuParam(obj,'sound_timing',{'No Sound','After Cpoke','After 1st Sidepoke'},1,x,y);
        next_row(y);
        MenuParam(obj,'side_light_timing',{'Both On','Both Off','Instructed'},3,x,y);
        next_row(y);

        SubheaderParam(obj, 'title', 'Timing Section', x, y);
        next_row(y, 1.5);
        
    case 'full_task'
        enable(center_led);
        enable(nose_in_center);
        enable(legal_cbreak);
        enable(cpoke_violation_timeout);
        enable(reward_delay);
        enable(drink_time);
        enable(softdrink_time);
        enable(unreward_time);
    case 'one_step'
        enable(center_led);
        enable(nose_in_center);
        enable(legal_cbreak);
        enable(cpoke_violation_timeout);
        enable(reward_delay);
        enable(drink_time);
        enable(softdrink_time);
        enable(unreward_time);
    case 'side_poke'
        disable(center_led);
        disable(nose_in_center);
        disable(legal_cbreak);
        disable(cpoke_violation_timeout);
        disable(reward_delay);
        enable(drink_time);
        enable(softdrink_time);
        disable(unreward_time);
    case 'direct_delivery'
        disable(center_led);
        disable(nose_in_center);
        disable(legal_cbreak);
        disable(cpoke_violation_timeout);
        disable(reward_delay);
        disable(drink_time);
        disable(softdrink_time);
        disable(unreward_time);
        
    case 'toggle_softdrink'
        
        if value(enable_softdrink)
            enable(softdrink_time);
        else
            disable(softdrink_time);
        end
        
    case 'toggle_unreward_water'
        if value(unreward_water)
            enable(unreward_mult);
        else
            disable(unreward_mult);
        end
        
    case 'get_timing'
        x.center_led = value(center_led);
        x.nose_in_center = value(nose_in_center);
        x.legal_cbreak = value(legal_cbreak);
        x.cpoke_violation_timeout = value(cpoke_violation_timeout);
        x.reward_delay = value(reward_delay);
        x.drink_time = value(drink_time);
        x.softdrink_time = value(softdrink_time);
        x.unreward_time = value(unreward_time);
        x.sound_timing = value(sound_timing);
        x.side_light_timing = value(side_light_timing);
        x.unreward_punish = value(unreward_punish);
        x.softdrink_enabled = value(enable_softdrink);
        x.unreward_mult = value(unreward_mult);
        x.unreward_water = value(unreward_water);
    otherwise,
        warning('Unknown action! "%s"\n', action);
end



end


