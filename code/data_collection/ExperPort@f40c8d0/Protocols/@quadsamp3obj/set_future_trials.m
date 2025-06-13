function set_future_trials(obj)

    GetSoloFunctionArgs; % rw: Side_List; ro: nDoneTrials, LeftProb, MaxSame

    sl          = value(Side_List);
    maxtrials   = value(MaxTrials);
    starting_at = nDoneTrials+1;
    
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

    Side_List.value = sl;
    return;


