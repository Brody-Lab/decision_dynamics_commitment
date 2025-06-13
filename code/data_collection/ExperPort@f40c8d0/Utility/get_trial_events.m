function [evs, rts] = get_trial_events(saved_history, task, trial)
% ----------------------------------------------------------------------------------
% function [evs, rts] = get_trial_events(saved_history, task, trial)
% Retrieves trial events and state name-to-number mappings for the specified trial
% -------------------------------------------------------------------------

evs = eval(['saved_history.' task '_LastTrialEvents']);
rts = eval(['saved_history.' task '_RealTimeStates']);
if trial > size(evs,1)
    error(['Trial number (' num2str(trial) ') exceeds number of trials in the events array (' num2str(size(evs,1)) ')']);
end;

try,
    evs = evs{trial};
    rts = rts{trial};
catch
    error('Could not get events. Make sure you passed in the correct args');
end;

return;
