function [timeout_count] = get_timeout_count(rat, task, date, f_ver)

load_datafile(rat, task, date, f_ver);
trials = eval(['saved.' task '_n_done_trials']);

timeout_count = zeros(trials,1);
for t = 1:trials
    [evs, rts] = get_trial_events(saved_history, task, t);
    to_state = rts.timeout; to_state = to_state(1);
    to = get_state_events(evs, 'RTS', rts, 'qnum', to_state);
    timeout_count(t) = size(to,1)/2;
    if mod(size(to,1),2)
        error(['Timeouts are not double-counted all the time. See #' num2str(t)]);
    end;
end;
