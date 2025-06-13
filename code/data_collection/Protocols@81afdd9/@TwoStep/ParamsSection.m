

function [x, y] = ParamsSection(obj, action, x, y)

GetSoloFunctionArgs;

switch action
    %% init
    case 'init',
        % Save the figure and the position in the figure where we are
        % going to start adding GUI elements:
        SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);
        NumeditParam(obj,'p_left',0.5,x,y);
        next_row(y);
        NumeditParam(obj,'p_right',0.5,x,y);
        next_row(y);
        ToggleParam(obj,'enable_drifts',0,x,y,'OnString','Drifts Enabled','OffString','Drifts Disabled');
        next_row(y);
        set_callback(enable_drifts, {mfilename,'toggle_drifts'});
        set_callback_on_load(enable_drifts,1);
        NumeditParam(obj,'drift_sigma',0.01,x,y);
        next_row(y);
        NumeditParam(obj,'right_reward_prob',0.5,x,y);
        next_row(y);
        NumeditParam(obj,'left_reward_prob',0.5,x,y);
        next_row(y);
        NumeditParam(obj,'p_congruent',0.5,x,y);
        next_row(y);
        NumeditParam(obj,'p_forceLeft',0,x,y);
        next_row(y);
        NumeditParam(obj,'p_forceRight',0,x,y);
        next_row(y);
        
        ParamsSection(obj,'toggle_drifts');
        
        SubheaderParam(obj, 'title', 'Params Section', x, y);
        next_row(y, 1.5);
        
        
        
    case 'full_task'
        enable(right_reward_prob);
        enable(left_reward_prob);
        enable(p_congruent);
        disable(p_left);
        disable(p_right);
    case 'one_step'
        enable(right_reward_prob);
        enable(left_reward_prob);
        disable(p_congruent);
        disable(p_left);
        disable(p_right);
    case 'side_poke'
        enable(right_reward_prob);
        enable(left_reward_prob);
        disable(p_congruent);
        disable(p_left);
        disable(p_right);
    case 'direct_delivery'
        disable(right_reward_prob);
        disable(left_reward_prob);
        disable(p_congruent);
        enable(p_left);
        enable(p_right);
        
    case 'toggle_drifts'
        
        if value(enable_drifts)
            enable(drift_sigma);
        else
            disable(drift_sigma);
        end
        
    case 'drift'
        
        if value(enable_drifts)
            left_reward_prob.value = value(left_reward_prob) + normrnd(0,value(drift_sigma));
            right_reward_prob.value = value(right_reward_prob) + normrnd(0,value(drift_sigma));
        end
        
        % Check that it's not greater than one or less than zero
        left_reward_prob.value = min(value(left_reward_prob),1);
        left_reward_prob.value = max(value(left_reward_prob),0);
        right_reward_prob.value = min(value(right_reward_prob),1);
        right_reward_prob.value = max(value(right_reward_prob),0);
        
        
    case 'get_params'
        x.right_reward_prob = value(right_reward_prob);
        x.left_reward_prob = value(left_reward_prob);
        x.p_congruent = value(p_congruent);
        x.p_left = value(p_left);
        x.p_right = value(p_right);
        x.p_forceLeft = value(p_forceLeft);
        x.p_forceRight = value(p_forceRight);
        
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