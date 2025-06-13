function [] = EventOccurred(lh1)
% Trigger off writing in an event, and go to where the StateMatrix tells
% you.
%
    lh1 = get_mylh1(lh1);
    oldstate  = lh1.StateNow;
    olddout   = lh1.DOut;
    oldaout1  = lh1.AOut1;
    oldaout2  = lh1.AOut2;
    
    % Compute the StateSum
    inputs = [lh1.CenterIn lh1.CenterOut lh1.LeftIn lh1.LeftOut lh1.RightIn lh1.RightOut lh1.GoNextState lh1.StateNow];
    multip = 2.^(0:7);
    statesum = sum(inputs.*multip);

    % Increment the Event Counter, and write in the Event Time and Event ID
    lh1.EventCounter = lh1.EventCounter+1;
    lh1.EventTime(lh1.EventCounter) = etime(clock, lh1.starttime);
    lh1.Event(lh1.EventCounter) = statesum;
    
    % Reset triggers to zero, set current state
    lh1.CenterIn    = 0; 
    lh1.CenterOut   = 0;
    lh1.LeftIn      = 0;
    lh1.LeftOut     = 0;
    lh1.RightIn     = 0;
    lh1.RightOut    = 0;
    lh1.GoNextState = 0;    
    lh1.StateNow    = lh1.StateMatrix(statesum+1);
    % Special check:
    if     lh1.StateNow == 0, lh1.pc_is_ready_fg = 0; 
    elseif lh1.StateNow == 35 & lh1.pc_is_ready_fg,
        lh1.StateNow = 0; lh1.pc_is_ready_fg = 0;
    end;    
    lh1.Timer       = lh1.TimDurMatrix(lh1.StateNow+1);
    lh1.DOut        = bitor(lh1.DIO_Out(lh1.StateNow+1), ...
        bitor(lh1.DIO_Bypass1.active*lh1.Dio_Hi_Bits, lh1.DIO_Bypass2*lh1.Bits_HighVal));
    lh1.AOut1       = 0.6*(bitand(1, bitor(lh1.AO_Out(lh1.StateNow+1), lh1.AO_Bypass*lh1.AOBits_HighVal))>0);
    if lh1.AOut1<0.6,
        lh1.AOut1   = 0.3*(bitand(4, bitor(lh1.AO_Out(lh1.StateNow+1), lh1.AO_Bypass*lh1.AOBits_HighVal))>0);
    end;
    lh1.AOut2       = 0.6*(bitand(2, bitor(lh1.AO_Out(lh1.StateNow+1), lh1.AO_Bypass*lh1.AOBits_HighVal))>0);
    
    
    % --- Horrid hack 16-Sep-05  following the physical rig, generate copycat entry,
    % but this time for state just entered:  
    % Compute the StateSum
    inputs = [lh1.CenterIn lh1.CenterOut lh1.LeftIn lh1.LeftOut lh1.RightIn lh1.RightOut lh1.GoNextState lh1.StateNow];
    multip = 2.^(0:7);
    statesum = sum(inputs.*multip);

    % Increment the Event Counter, and write in the Event Time and Event ID
    lh1.EventCounter = lh1.EventCounter+1;
    lh1.EventTime(lh1.EventCounter) = etime(clock, lh1.starttime);
    lh1.Event(lh1.EventCounter) = statesum;
    % ---- end horrid hack
    
    save_mylh1(lh1);
    
    if olddout ~= lh1.DOut,                            check_doutchange_callback(lh1); end;
    if oldaout1 ~= lh1.AOut1 | oldaout2 ~= lh1.AOut2, check_aoutchange_callback(lh1); end;
    if oldstate ~= lh1.StateNow; 
        check_statechange_callback(lh1);
        stop(lh1.timers(lh1.timerid));
        lh1.timerid = rem(lh1.timerid,2)+1; % Toggle to other timer so we can start a timer even if we're currently 
                                            % going through a TimerFcn callback.
        save_mylh1(lh1); 
        stop(lh1.timers(lh1.timerid));

        % if lh1.Timer < 0.025, % anything less than 20 ms should be treated as instantaneous
        %    TimesUp(lh1);    
        % else    
        set(lh1.timers(lh1.timerid), 'StartDelay', lh1.Timer); start(lh1.timers(lh1.timerid));
        % end;
    end;   
