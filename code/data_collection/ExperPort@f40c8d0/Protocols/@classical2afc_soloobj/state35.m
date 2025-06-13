function state35(obj)

    GetSoloFunctionArgs; 
    % SoloFunction('state35', 'ro_args', 'trial_finished_actions');

    n_done_trials.value = n_done_trials + 1;

    if debugging==1, 
       fp = fopen('debugging.log', 'a');
       fprintf(fp, '\n\nn_done_trials = %d\n\n', value(n_done_trials));
       fclose(fp);
    end;
    
    for i=1:length(trial_finished_actions),
      if i==10,
        gu = 'a';
      end;
      if debugging==1, tic; end;
      eval(trial_finished_actions{i}); drawnow;
      if debugging==1,
        tocked = toc;
        fp = fopen('debugging.log', 'a');
        fprintf(fp, 'state35: Doing "%s" took time : %g\n', ...
          trial_finished_actions{i}, tocked);
        fclose(fp);
      end;
    end;
    
    n_started_trials.value = n_started_trials + 1;
    return;


