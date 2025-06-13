function [sm] = FlushQueue(sm)
    sm = get(sm.Fig, 'UserData');
    
    if (sm.debug),
      display(sprintf('FlushQueue: qsize %d',size(sm.EventQueue, ...
                                                  1)));
    end;

    haveEvents = 1;

    while haveEvents,
       while(size(sm.EventQueue, 1)),
        sm = ProcessNextQueuedEvent(sm);
        now = etime(clock, sm.T0);      
        sm = ProcessTimers(sm, now);      
      end;

      now = etime(clock, sm.T0);      
      sm = ProcessTimers(sm, now);
      
      % below code is necessary because drawnow might cause an
      % inputclicked event which means that our sm 'pointer' needs
      % to be re-set.
      set(sm.Fig, 'UserData', sm);
      drawnow;
      sm = get(sm.Fig, 'UserData');
      
      haveEvents = size(sm.EventQueue, 1);

      if (haveEvents),
        sm = UpdateRunningSchedWavesGUI(sm);
        sm = UpdateCurrentTimeGUI(sm, now);
      end;
      
      if (sm.debug & haveEvents),
        disp(sprintf('flushqueue time: %05.5f', now));
      end;
    
    end;
      
    sm = UpdateRunningSchedWavesGUI(sm);
    sm = UpdateCurrentTimeGUI(sm);
    
    set(sm.Fig, 'UserData', sm);

    
    return;
