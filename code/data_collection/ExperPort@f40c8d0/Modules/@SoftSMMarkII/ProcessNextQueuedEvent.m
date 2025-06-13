function [sm] = ProcessNextQueuedEvent(sm)
    nQueue = size(sm.EventQueue, 1);
    if (nQueue < 1), 
      if (sm.debug),
        display('Cannot dequeue empty event list!');
      end;
      return;
    end;
    
    prevState = sm.EventQueue(1,1);
    evtId     = sm.EventQueue(1,2);
    ts        = sm.EventQueue(1,3);
    newState  = sm.EventQueue(1,4);
    
    if (nQueue == 1), 
      sm.EventQueue = zeros(0, 4);
    else
      sm.EventQueue = sm.EventQueue(2:nQueue, 1:4);
    end;

    sm.EventCount = sm.EventCount + 1;    
    sm.EventList(sm.EventCount,1:4) = ...
        [ prevState  evtId ts newState ];
    sm.CurrentState = newState;
    
    if newState == 0, 
       set(sm.Fig, 'UserData', sm);
       sm = ReallySetStateMatrix(sm); 
    end;
    
    if (prevState ~= newState)
      % set start_time of current state, jump to new state, do outputs, 
      sm.CurrentStateTS = ts;
      sm = UpdateStateUI(sm);
      sm = DoOutputs(sm, ts);
    else % don't change start_time, jump to self, don't do outputs, 

       % Only change start time if we jumped to self and evtId was a timer
    % GetTUPcol changed to GetTUPCol
    if evtId == 2.^(GetTUPCol(sm)-1), sm.CurrentStateTS = ts; end;
       
       if (sm.debug),
        % debug
        display('State transition to same state ignored outputs!');
      end;

    end;
    
    return;
    