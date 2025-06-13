

function [x, y] = StimulationSection(obj, action, x, y)

GetSoloFunctionArgs;

switch action
    %%% init
    case 'init',
        % Save the figure and the position in the figure where we are
        % going to start adding GUI elements:
        SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);
        
%         NumeditParam(obj,'p_reward_stim',0,x,y);
%         next_row(y);
%         NumeditParam(obj,'p_choice_stim',0,x,y);
%         next_row(y);
        NumeditParam(obj,'p_both_stim',0.5,x,y);
        next_row(y);
        NumeditParam(obj,'laser_on',0,x,y);
        next_row(y);
        NumeditParam(obj,'stim_limit_sec',10,x,y);
        next_row(y);
        SubheaderParam(obj, 'title', 'Stimulation Section', x, y);
        next_row(y, 1.5);
    
        
        
        SoloFunctionAddVars('SMA1', 'ro_args',{'p_both_stim';...
            'stim_limit_sec'});

        %%% send to the training section
        SoloFunctionAddVars('SMA1', 'rw_args', {'laser_on'});

        
        
        
        
        
%         
%     case 'get_all'
%         
% %         x.p_reward_stim = value(p_reward_stim);
% %         x.p_choice_stim = value(p_choice_stim);
%         x.p_both_stim = value(p_both_stim);
%         x.stim_limit_sec = value(stim_limit_sec);
%         
    otherwise,
        warning('Unknown action! "%s"\n', action);
        
end



end


