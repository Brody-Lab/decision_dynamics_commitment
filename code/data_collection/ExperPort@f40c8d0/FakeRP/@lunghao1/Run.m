function [] = Run(lh1)

    lh1 = get_mylh1(lh1);
    
    lh1.rp_machine = Run(lh1.rp_machine);
    lh1.running = 1;
    lh1.starttime = clock;
    lh1.EventCounter = 0;
    lh1.StateNow = 0;
    lh1.Timer = lh1.TimDurMatrix(lh1.StateNow+1);
    set(lh1.timers(lh1.timerid), 'StartDelay', lh1.Timer); start(lh1.timers(lh1.timerid));
    save_mylh1(lh1);
    EventOccurred(lh1);
    