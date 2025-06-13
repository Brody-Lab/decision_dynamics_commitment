
% Little script to analyse event history
% 1. Gets events for a given trial in the specified task
% 2. Gets events for particular states.

task = 'duration_discobj';
tnum = 4;

evs = get_trial_events(saved_history, task, tnum);
rts = get_state_name2number(saved_history, task, tnum);

% Output columns:
%   - row number in original event matrix
%   - State number
%   - Event (1-7)
%   - Time
e_chord = get_events(evs, 'qname', 'chord', 'RTS', rts);
e_apoke = get_events(evs, 'qname', 'wait_for_apoke', 'RTS', rts);

