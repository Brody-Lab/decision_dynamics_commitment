function state35(obj)

GetSoloFunctionArgs;

for i=1:length(trial_finished_actions),
    eval(trial_finished_actions{i});
end;

return;

