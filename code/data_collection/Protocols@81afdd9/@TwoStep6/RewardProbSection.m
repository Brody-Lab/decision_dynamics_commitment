

function [x, y] = RewardProbSection(obj, action, x, y)

GetSoloFunctionArgs;

switch action
    %% init
    case 'init',
        
        ToggleParam(obj,'enable_drifts',0,x,y,'OnString','Drifts Enabled','OffString','Drifts Disabled');
        next_row(y);
        set_callback(enable_drifts, {mfilename,'toggle'});
        set_callback_on_load(enable_drifts,1);
        NumeditParam(obj,'drift_sigma',0.01,x,y);
        next_row(y);
        
        ToggleParam(obj,'enable_flips',0,x,y,'OnString','Flips Enabled','OffString','Flips Disabled');
        next_row(y);
        set_callback(enable_flips, {mfilename,'toggle'});
        set_callback_on_load(enable_flips,1);
        ToggleParam(obj,'performance_flips',0,x,y,'OnString','Performance-triggered Flips','OffString','Nonperformance Flips');
        next_row(y);
        set_callback(performance_flips, {mfilename,'toggle'});
        set_callback_on_load(enable_flips,1);
        NumeditParam(obj,'p_flip_is_reward',1,x,y);
        next_row(y);
        DispParam(obj,'flipCounter',0,x,y);
        next_row(y);
        DispParam(obj,'flipPerformance',0,x,y);
        next_row(y);
        DispParam(obj,'flipReady',0,x,y);
        next_row(y);
        NumeditParam(obj,'threshold_for_flip',0.8,x,y);
        next_row(y);
        NumeditParam(obj,'nTrials_for_flip',50,x,y);
        next_row(y);
        NumeditParam(obj,'flip_prob_if_ready',1,x,y);
        next_row(y);
        
        
        RewardProbSection(obj,'toggle');
        
        SubheaderParam(obj, 'title', 'Reward Probs Section', x, y);
        next_row(y, 1.5);
        
    case 'drift'
        
        params = ParamsSection(obj,'get_params');
        left_reward_prob = params.left_reward_prob;
        right_reward_prob = params.right_reward_prob;
        
        if value(enable_drifts)
            left_reward_prob = left_reward_prob + normrnd(0,value(drift_sigma));
            right_reward_prob = right_reward_prob + normrnd(0,value(drift_sigma));
        end
        
        % Check that it's not greater than one or less than zero
        left_reward_prob = min(left_reward_prob,1);
        left_reward_prob = max(left_reward_prob,0);
        right_reward_prob = min(right_reward_prob,1);
        right_reward_prob = max(right_reward_prob,0);
        
        ParamsSection(obj,'set_reward_probs',[left_reward_prob,right_reward_prob]);
        
        
    case 'next_trial'
        
        if value(enable_drifts)
            RewardProbSection(obj,'drift');
        end
        
        if value(enable_flips)
            RewardProbSection(obj,'flip');
        end
        
    case 'flip'
        
        
        
        % If we're monitoring performance, update the performance
        if value(performance_flips)
            hist = HistorySection(obj,'get_all');
            if hist.nTrials > value(nTrials_for_flip);
                flipPerformance.value = nanmean(hist.better_choices_history(end-value(nTrials_for_flip):end));
            end
        end
        
        % If it's been enough trials that we should think about flipping AND (performance is good enough OR we're not checking performance)
        if value(flipCounter) >= nTrials_for_flip && (value(flipPerformance) >= value(threshold_for_flip) || ~value(performance_flips))
            
            flipReady.value = 1;
            
        end
        
        % Increment the flip counter
        
        flipCounter.value = value(flipCounter) + 1;
        
        % Is a flip pending?  If so, trigger the flip with the appropriate
        % probability
        
        if value(flipReady)
            if rand < value(flip_prob_if_ready)
                params = ParamsSection(obj,'get_params');
                if rand < value(p_flip_is_reward) % It's a reward prob flip
                    new_left_prob = params.right_reward_prob;
                    new_right_prob = params.left_reward_prob;
                
                    ParamsSection(obj,'set_reward_probs',[new_left_prob,new_right_prob]);
                
                else  % It's a transition flip
                    new_p_congruent = 1 - params.p_congruent;
                    ParamsSection(obj,'set_p_congruent',new_p_congruent);
                end
                    
                
                flipReady.value = 0;
                flipCounter.value = 0;
            end
        end
        
    case 'toggle'
        
        if value(enable_drifts)
            enable(drift_sigma);
        else
            disable(drift_sigma);
        end
        
        if value(enable_flips)
            enable(performance_flips);
            enable(nTrials_for_flip);
            enable(flip_prob_if_ready);
            enable(threshold_for_flip);
            enable(flipReady);
            enable(flipCounter);
            
            if value(performance_flips)
                enable(flipPerformance);
                enable(threshold_for_flip);
            else
                disable(flipPerformance);
                disable(threshold_for_flip)
            end
        else
            disable(performance_flips);
            disable(nTrials_for_flip);
            disable(flip_prob_if_ready);
            disable(threshold_for_flip);
            disable(flipReady);
            disable(flipCounter);
            disable(flipPerformance);
        end
        
    otherwise,
        warning('Unknown action! "%s"\n', action);
end


end