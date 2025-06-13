function [] = SoftTrg7(lh1)

    lh1 = get_mylh1(lh1);
    lh1.DIO_Bypass2 = 0;
    lh1.DOut        = bitor(lh1.DIO_Out(lh1.StateNow+1), ...
        bitor(lh1.DIO_Bypass1.active*lh1.Dio_Hi_Bits, lh1.DIO_Bypass2*lh1.Bits_HighVal));
    save_mylh1(lh1);
    check_doutchange_callback(lh1);
