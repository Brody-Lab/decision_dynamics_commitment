function [] = SoftTrg1(lh1)
% If running, trigger a go sound 1 event

    lh1 = get_mylh1(lh1);
    while( strcmp(get(lh1.timer, 'Running'), 'on') ), pause(0.05); end; 

    data1a = lh1.datain1a;
    data1b = lh1.datain1b;
    len    = lh1.datalngth1;
    
    if size(data1a,1) > size(data1a,2),
       sound([data1a(1:len,:)' ; data1b(1:len,:)'], lh1.samprate);
    else
       sound([data1a(:, 1:len) ; data1b(:, 1:len)], lh1.samprate);
    end;
    set(lh1.timer, 'StartDelay', lh1.datalngth1/lh1.samprate);start(lh1.timer);
    save_mylh1(lh1);
    


    
    