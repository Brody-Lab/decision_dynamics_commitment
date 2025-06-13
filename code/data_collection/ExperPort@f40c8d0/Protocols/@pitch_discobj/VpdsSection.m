function [x, y, vpds_list] = VpdsSection(obj, action, x, y);

GetSoloFunctionArgs;
% 
% init_ro_args = { ...
% 	'n_done_trials'		, n_done_trials, ...
% 	'n_started_trials'	, n_started_trials, ...
% 	'maxtrials'		, maxtrials, ...
% };

if nargin > 2
    [x, y, vpds_list] = VpdsSection(value(super), action, x, y);
else
    VpdsSection(value(super), action);
end;
