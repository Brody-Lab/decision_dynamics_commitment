function [agg] = timeout_aggregator(to)
% gives percentage distribution of timeouts during sound events
% Input is a cell array, each entry of which is a struct for one trial.
% The struct contains sound events for the task, and the value for each key
% is the number of timeouts that have occurred during that event for that
% trial.
%
% to is the output of timeout_distribution_dual or
% timeout_distribution_duration
%
% e.g. 
% 3/50 timeouts occur during pre_sound
% 3/50 occur during cue
% 40/50 occur during pre-GO
% 1/50 during GO

fnames = fieldnames(to{1});
for f = 1:rows(fnames), eval(['agg.' fnames{f} '= 0;']); end;

for k = 1:rows(to)
    for f = 1:rows(fnames), eval(['agg.' fnames{f} '= agg.' fnames{f} '+ to{k}.' fnames{f} ';']); end;   
end;