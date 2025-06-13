function [x, y, side_list, WaterDelivery, RewardPorts, LeftProb] = SidesSection(obj, action, x, y);

GetSoloFunctionArgs;

class_name = ['@' class(obj) ];
 
% init_ro_args = { 'n_done_trials', n_done_trials, ...	 
% 		 'n_started_trials', n_started_trials, ...
% 		 'hit_history', hit_history, ...
% 		 'maxtrials', maxtrials }	 ;

if nargin > 2
    [x, y, side_list, WaterDelivery, RewardPorts, LeftProb, bias] = ...
        SidesSection(value(super), action, x, y);
    DeclareGlobals(obj, 'ro_args', 'bias');
else
    SidesSection(value(super), action);
end;
