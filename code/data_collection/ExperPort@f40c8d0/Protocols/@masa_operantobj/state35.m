function state35(obj)

    GetSoloFunctionArgs; 
    % SoloFunction('state35','rw_args', {'n_done_trials', 'n_started_trials'}, ...
    %'ro_args', 'trial_finished_actions');

    n_done_trials.value = n_done_trials + 1;
    
    for i=1:length(trial_finished_actions),
        eval(trial_finished_actions{i});
    end;    

    n_started_trials.value = n_started_trials + 1;
    return;


