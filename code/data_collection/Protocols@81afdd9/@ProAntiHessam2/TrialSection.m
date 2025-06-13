function  [x y] =  TrialSection(obj, action, x, y)


GetSoloFunctionArgs(obj);


switch action
    
    %% init
    case 'init',
        
        DispParam(obj, 'prob_right_anti', '0', x, y, 'label', 'Pr(Right&Anti)');
        next_row(y, 1);
        DispParam(obj, 'prob_left_anti', '0', x, y, 'label', 'Pr(Left&Anti)');
        next_row(y, 1);
        DispParam(obj, 'prob_right_pro', '0.5', x, y, 'label', 'Pr(Right&Pro)');
        next_row(y, 1);
        DispParam(obj, 'prob_left_pro', '0.5', x, y, 'label', 'Pr(Left&Pro)');
        next_row(y, 1);
        MenuParam(obj, 'maxSameTarget', {'1', '2', '3', '4', '5', '6', '7', 'Inf'}, 5, ...
        x, y, 'TooltipString', 'Maximum number of times the same side (L or R) can appear');
        next_row(y, 1.5);
        
        DispParam(obj, 'target', 'L', x, y, 'label', 'Target');
        next_row(y, 1);
        DispParam(obj, 'context', 'P', x, y, 'label', 'Context');
        next_row(y, 1.5);
        
        DispParam(obj, 'forgiving', '0', x, y, 'label', 'Forgiving');
        
        SubheaderParam(obj, 'title', 'TrialSection', x, y);
        next_row(y, 1.5);
        
    case 'prepare_next_trial',
        probs = feval(mfilename, obj, 'get_probs');
        
        if(numel(target_history) >= value(maxSameTarget) && all(target_history(end-maxSameTarget+1:end) == target_history(end))) %#ok<COLND>
            switch (target_history(end)) %#ok<COLND>
                case 'r',
                    if(probs(1) + probs(2) > 1e-6)
                        probs(3) = 0;
                        probs(4) = 0;
                        probs = probs ./ sum(probs(:));
                    end
                case 'l',
                    if(probs(3) + probs(4) > 1e-6)
                        probs(1) = 0;
                        probs(2) = 0;
                        probs = probs ./ sum(probs(:));
                    end
            end
            disp(target_history(end)); %#ok<COLND>
            disp('maxSameTarget taking effect!');
            disp(probs);
        end
        
        this_trial = 1 + sum(rand > cumsum(probs(:)));
        targets = ['L', 'L', 'R', 'R'];
        contexts = ['P', 'A', 'P', 'A'];
        target.value = targets(this_trial); %#ok<STRNU>
        context.value = contexts(this_trial); %#ok<STRNU>
%         if(context == 'A')
%             forgiving.value = 1; %#ok<STRNU>
%         else
%             forgiving.value = 0; %#ok<STRNU>
%         end
        
    case 'set_probs',
        disp('called set_probs!');
        disp(x);
        if(any(x(:) < 0) || any(size(x) > 2) || all(size(x) == 1))
            disp('invalid x given to TrialSection, set_probs');
            disp(x);
            return;
        end
        
        probs = feval(mfilename, obj, 'get_probs');
        if(size(x, 1) == 1)
            probs = sum(probs, 2) * x;
        elseif(size(x, 2) == 1)
            probs = x * sum(probs, 1);
        else
            probs = x;
        end
        assert(all(size(probs) == 2))
        probs = probs ./ sum(probs(:));
        assert(abs(1 - sum(probs(:))) < 1e-6);
        prob_left_pro.value = probs(1, 1); %#ok<STRNU>
        prob_right_pro.value = probs(1, 2); %#ok<STRNU>
        prob_left_anti.value = probs(2, 1); %#ok<STRNU>
        prob_right_anti.value = probs(2, 2); %#ok<STRNU>
        
    case 'get_probs',
        x = [value(prob_left_pro) value(prob_right_pro); value(prob_left_anti) value(prob_right_anti)];  %#ok<NODEF>
    
    case 'get_left_prob'
        
    case 'get_target',
        x = lower(value(target)); %#ok<NODEF>
        
    case 'get_context',
        x = lower(value(context)); %#ok<NODEF>
        
    case 'forgiving',
        x = value(forgiving); %#ok<NODEF>
        
    otherwise,
        disp('PunishmentSection ERROR: unknown case');
        
end

end