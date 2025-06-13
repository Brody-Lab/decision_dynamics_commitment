function [] = EventReporter(last_n_trials)

global exper;
events = exper.rpbox.param.trial_events.value;

trials = events(:,1); 
last_trial  = trials(end);
first_trial = last_trial-last_n_trials+1; 
events = events(find(ismember(trials, first_trial:last_trial)),:);

trials  = events(:,1);
times   = events(:,2);
states  = events(:,3);
signals = events(:,4);

signal_table = {'Cin ' 'Cout' 'Lin ' 'Lout' 'Rin ' 'Rout ' 'Tup '};

fprintf(1, 'Trial\tStateNum\tEvent\ttime spent in this state\n');
for i=2:length(trials),
    fprintf(1, '   %g:\t    %g\t    %s\t    %.3f\n', trials(i), states(i), signal_table{signals(i)}, times(i)-times(i-1));
end;

