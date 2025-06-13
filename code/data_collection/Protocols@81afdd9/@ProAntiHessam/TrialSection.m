function  [x y] =  TrialSection(obj, action, x, y)


GetSoloFunctionArgs(obj);


switch action
    
    %% init
    case 'init',
        next_row(y, 1.5);
        SubheaderParam(obj, 'title', 'TrialSection', x, y);
        
        SoloParamHandle(obj, 'correct_side', 'value', 'L');
        SoloParamHandle(obj, 'target_probs', 'value', [0.5, 0.5]);
        
    case 'prepare_next_trial',
        if(rand < target_probs(1))
            correct_side.value = 'L';
        else
            correct_side.value = 'R';
        end
        
    case 'set_target_probs',
        fprintf('called set_target_probs!');
        disp(x);
        target_probs.value = x;
        
    case 'get_side',
        x = lower(value(correct_side));
        
    otherwise,
        disp('PunishmentSection ERROR: unknown case');
        
end

end