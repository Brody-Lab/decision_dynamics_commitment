function [] = SoftTrg10(lh1)
% set the PCReady Flag

    lh1 = get_mylh1(lh1);
    lh1.pc_is_ready_fg = 1;
    save_mylh1(lh1);
    EventOccurred(lh1);
    
    
    
    