% Function called when RPBox requests protocol('state35')
%
% Santiago Jaramillo - 2007.05.14

function state35(obj)

GetSoloFunctionArgs; 

NdoneTrials.value = NdoneTrials + 1;

for i=1:length(trial_finished_actions),
    eval(trial_finished_actions{i});
end;    

%%%n_started_trials.value = value(n_started_trials) + 1;

return;

