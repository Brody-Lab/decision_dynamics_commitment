

function [x, y] = ParamsSection(obj, action, x, y)

GetSoloFunctionArgs;

switch action
    %% init
    case 'init',
        % Save the figure and the position in the figure where we are
        % going to start adding GUI elements:
        SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);
        
        NumeditParam(obj,'p_forceLeft',0,x,y);
        next_row(y);
        NumeditParam(obj,'p_forceRight',0,x,y);
        next_row(y);
        NumeditParam(obj,'p_left',0.5,x,y);
        next_row(y);
        NumeditParam(obj,'p_right',0.5,x,y);
        next_row(y);
        NumeditParam(obj,'right_reward_prob',0.5,x,y);
        next_row(y);
        NumeditParam(obj,'left_reward_prob',0.5,x,y);
        next_row(y);
        NumeditParam(obj,'p_congruent',0.5,x,y);
        next_row(y);
        
        SubheaderParam(obj, 'title', 'Params Section', x, y);
        next_row(y, 1.5);
        
    case 'full_task'
        enable(p_congruent);
        disable(p_left);
        disable(p_right);
    case 'one_step'
        disable(p_congruent);
        disable(p_left);
        disable(p_right);
    case 'side_poke'
        disable(p_congruent);
        disable(p_left);
        disable(p_right);
    case 'direct_delivery'
        disable(p_congruent);
        enable(p_left);
        enable(p_right);
        
    case 'set_reward_probs'
        left_reward_prob.value = x(1);
        right_reward_prob.value = x(2);
        
    case 'set_p_congruent'
        p_congruent.value = x(1);
        
        
    case 'get_params'
        x.p_congruent = value(p_congruent);
        x.p_left = value(p_left);
        x.p_right = value(p_right);
        x.p_forceLeft = value(p_forceLeft);
        x.p_forceRight = value(p_forceRight);
        x.left_reward_prob = value(left_reward_prob);
        x.right_reward_prob = value(right_reward_prob);
        
    case 'get_better_choice'
        better_outcome = value(right_reward_prob) > value(left_reward_prob); % If reward is more likely on the right, better_outcome is 1, otherwise 0
        if value(p_congruent) > 0.5
            better_choice = better_outcome;
        else
            better_choice = ~better_outcome;
        end
        
        if better_choice
            x = 'r';
        else
            x = 'l';
        end
        
    otherwise,
        warning('Unknown action! "%s"\n', action);
end


end