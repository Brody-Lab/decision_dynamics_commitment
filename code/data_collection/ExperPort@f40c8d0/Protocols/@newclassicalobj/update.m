function [] = update(obj)

GetSoloFunctionArgs;
% SoloFunction('update', 'ro_args', 'within_trial_update_actions');

for i=1:length(within_trial_update_actions),
    eval(within_trial_update_actions{i});
end;



