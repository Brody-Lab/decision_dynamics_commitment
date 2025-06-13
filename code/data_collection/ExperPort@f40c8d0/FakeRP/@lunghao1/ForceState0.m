function [] = ForceState0(lh1)

    lh1 = get_mylh1(lh1);
    lh1.StateNow = 0;
    save_mylh1(lh1);
    EventOccurred(lh1);
    
    
    
    