function [] = SoftTrg9(lh1)

    lh1 = get_mylh1(lh1);
    lh1.AO_Bypass = 0;
    lh1.AOut1 = bitand(1, bitor(lh1.AO_Out(lh1.StateNow+1), lh1.AO_Bypass*lh1.AOBits_HighVal))>0;
    lh1.AOut2 = bitand(2, bitor(lh1.AO_Out(lh1.StateNow+1), lh1.AO_Bypass*lh1.AOBits_HighVal))>0;
    save_mylh1(lh1);
    check_aoutchange_callback(lh1);
        
