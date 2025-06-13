function [] = SoftTrg2(lh1)
% Reset EventCounter to 0
    
    lh1 = get_mylh1(lh1);
    lh1.EventCounter = 0;
    save_mylh1(lh1);
    
    