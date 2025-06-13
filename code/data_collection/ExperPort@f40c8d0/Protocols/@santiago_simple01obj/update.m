% Function called when RPBox requests protocol('update')
%
% Santiago Jaramillo - 2007.05.14

function [] = update(obj)

GetSoloFunctionArgs;

for i=1:length(within_trial_update_actions),
    eval(within_trial_update_actions{i});
end;



