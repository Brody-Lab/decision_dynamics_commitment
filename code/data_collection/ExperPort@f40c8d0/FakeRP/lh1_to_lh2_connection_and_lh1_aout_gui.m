function [] = lh1_to_lh2_connection_and_lh1_aout_gui(lh1, lh2)

    [aout1, aout2] = lunghao1_gui_aoutchange_callback(lh1);
    
    % fprintf(1, 'aout1 = %.2f  aout2 = %.2f\n', aout1, aout2);
    SetTagVal(lh2, 'ch1in', aout1);
    SetTagVal(lh2, 'ch2in', aout2);
