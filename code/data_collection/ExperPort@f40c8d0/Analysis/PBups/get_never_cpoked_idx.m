function never_cpoked_idx = get_never_cpoked_idx(states)
    % takes a structured array of states (i.e. from parsed events history)
    % and returns the indices of the trial in which the rat never center
    % poked.
    % PBups used to bypass the need to center poke and go directly to
    % wait_for_spoke if the rat never cpoked for a long time (like half an
    % hour). This happens rarely but we should still exclude these trials
    never_cpoked_idx = cellfun(@(x)isempty(x.cpoke1),states);
end
