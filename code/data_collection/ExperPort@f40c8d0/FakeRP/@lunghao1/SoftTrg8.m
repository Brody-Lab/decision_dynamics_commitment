function [] = SoftTrg8(lh1)

    lh1 = get_mylh1(lh1);
    lh1.AO_Bypass = 1;
    lh1.AOut1                     = 0.6*(bitand(1, bitor(lh1.AO_Out(lh1.StateNow+1), lh1.AO_Bypass*lh1.AOBits_HighVal))>0);
    if lh1.AOut1<0.6, lh1.AOut1   = 0.3*(bitand(4, bitor(lh1.AO_Out(lh1.StateNow+1), lh1.AO_Bypass*lh1.AOBits_HighVal))>0);
    end;
    lh1.AOut2                     = 0.6*(bitand(2, bitor(lh1.AO_Out(lh1.StateNow+1), lh1.AO_Bypass*lh1.AOBits_HighVal))>0);
    save_mylh1(lh1);
    check_aoutchange_callback(lh1);

