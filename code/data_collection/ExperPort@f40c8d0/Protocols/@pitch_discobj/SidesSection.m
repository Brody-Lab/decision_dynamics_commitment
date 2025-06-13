function [x, y, side_list, WaterDelivery, RewardPorts] = SidesSection(obj, action, x, y);

GetSoloFunctionArgs;

class_name = ['@' class(obj) ];
 
% init_ro_args = { 'n_done_trials', n_done_trials, ...	 
% 		 'n_started_trials', n_started_trials, ...
% 		 'hit_history', hit_history, ...
% 		 'maxtrials', maxtrials }	 ;

if nargin > 2
    [x, y, side_list, WaterDelivery, RewardPorts] = SidesSection(value(super), action, x, y); 
else
    SidesSection(value(super), action);
end;
