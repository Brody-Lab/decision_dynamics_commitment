function [] = set_ylimits(n_started_trials, axpokesplot, trial_limits, start_trial, end_trial, ntrials);

   switch trial_limits,
     case 'from, to',
       set(axpokesplot, 'Ylim', [value(start_trial)-0.5 max(value(end_trial)+0.5, value(start_trial)+0.5)]);
       
     case 'last n',
       bottom = max(n_started_trials-ntrials+0.5,0.5);
       set(axpokesplot, 'Ylim', [bottom bottom+ntrials]);

     otherwise,
       warning('@pokesplot/private/%s : unknown trial limits setting "%s"', mfilename, trial_limits);
   end;

