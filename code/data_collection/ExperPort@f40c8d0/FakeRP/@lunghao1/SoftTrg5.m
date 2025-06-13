function [] = SoftTrg5(lh1)
% Bypass1 for DIO_Out 
%
    lh1 = get_mylh1(lh1);
    lh1.DIO_Bypass1.active = 1;
    lh1.DOut        = bitor(lh1.DIO_Out(lh1.StateNow+1), ...
        bitor(lh1.DIO_Bypass1.active*lh1.Dio_Hi_Bits, lh1.DIO_Bypass2*lh1.Bits_HighVal));
    set(lh1.DIO_Bypass1.timer, 'TimerFcn', {@lunghao1_dio_bypass1_timer_callback, lh1}, ...
        'StartDelay', lh1.Dio_Hi_Dur/6000);
    start(lh1.DIO_Bypass1.timer);
    save_mylh1(lh1);
    check_doutchange_callback(lh1);
