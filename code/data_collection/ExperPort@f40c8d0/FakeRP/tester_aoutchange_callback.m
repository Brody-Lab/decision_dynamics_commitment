function [] = tester_aoutchange_callback(lh1, lh2)

    [aout1, aout2] = lunghao1_gui_aoutchange_callback(lh1);
    
    SetTagVal(lh2, 'ch1in', aout1);
    SetTagVal(lh2, 'ch2in', aout2);
    