function state35(obj)

    GetSoloFunctionArgs; 
    % SoloFunction('state35', 'ro_args', 'trial_finished_actions');

    n_done_trials.value = n_done_trials + 1;

    if debugging==1, 
       fp = fopen('debugging.log', 'a');
       fprintf(fp, '\n\nn_done_trials = %d\n\n', value(n_done_trials));
       fclose(fp);
    end;
    
    t00 = clock;
    for i=1:length(trial_finished_actions),
       if debugging==1, t0=clock; end;
       eval(trial_finished_actions{i});
       if debugging==1,
          fp = fopen('debugging.log', 'a');
          fprintf(fp, ['state35: Doing "%s" took time : %g  and  %g  tot ' ...
              'time from start of state35\n'], trial_finished_actions{i}, etime(clock, t0), ...
              etime(clock, t00));
          fclose(fp);
       end;
    end;    

    n_started_trials.value = n_started_trials + 1;
    return;


