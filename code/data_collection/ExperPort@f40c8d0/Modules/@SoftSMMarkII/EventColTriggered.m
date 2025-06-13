function [sm] = EventColTriggered(sm, col, ts)
    
    % debug
    if (sm.debug), 
      display(sprintf('Got event col %d', col));
    end;
    
    if (col > size(sm.StateMatrix, 2)),
      if (sm.debug),
        display(sprintf('No StateMatrix column %d for input event!', ...
                        col));
      end;
      return;
    end;

    if (sm.IsRunning),
      sm = EnqueueEvent(sm, col, ts);
    end;
    
    return;