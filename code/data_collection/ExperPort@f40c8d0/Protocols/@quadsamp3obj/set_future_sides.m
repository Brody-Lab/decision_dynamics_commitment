function set_future_sides(obj)

    GetSoloFunctionArgs; 
    % SoloFunction('set_future_sides', 'rw_args', {'side_list'}, ...
    %    'ro_args', {'n_done_trials', 'maxtrials', 'MaxSame', 'LeftProb'});

    sl          = value(side_list);
    starting_at = n_done_trials+1;
    
    sl(starting_at:maxtrials) = rand(1,maxtrials-starting_at+1)>=LeftProb;

    if MaxSame < 10,
        seg_starts  = find(diff([-Inf sl -1]));
        seg_lengths = diff(seg_starts);
        long_segs   = find(seg_lengths > MaxSame);
        while ~isempty(long_segs),
            switch_point = seg_starts(long_segs(1)) + ceil(seg_lengths(long_segs(1))/2);
            sl(switch_point) = 1 - sl(switch_point);
            seg_starts  = find(diff([-Inf sl]));
            seg_lengths = diff(seg_starts);
            long_segs   = find(seg_lengths > MaxSame);
        end;
    end;

    side_list.value = sl;

    return;


