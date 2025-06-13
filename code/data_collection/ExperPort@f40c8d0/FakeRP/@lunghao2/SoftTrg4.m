function [] = SoftTrg4(lh1)
% If running, trigger a go sound 2 event

    lh1 = get_mylh1(lh1);
    while( strcmp(get(lh1.timer, 'Running'), 'on') ), pause(0.05); end; 

    sound(lh1.datain2(1:lh1.datalngth2), lh1.samprate); 
    set(lh1.timer, 'StartDelay', lh1.datalngth2/lh1.samprate); start(lh1.timer);
    save_mylh1(lh1);

