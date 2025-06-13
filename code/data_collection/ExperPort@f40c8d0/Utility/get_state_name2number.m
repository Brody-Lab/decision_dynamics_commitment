function [rts] = get_state_name2number(saved_history, task, trial)
% Retrieves trial events for the specified trial

rts = eval(['saved_history.' task '_RealTimeStates']);
if trial > size(rts,1)
    error(['Trial number (' num2str(trial) ') exceeds number of trials in the events array (' num2str(size(rts,1)) ')']);
end;

try,
    rts = rts{trial};
catch
    error('Could not get events. Make sure you passed in the correct args');
end;

return;
