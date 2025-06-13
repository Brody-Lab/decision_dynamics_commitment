function [currentState] = GetCurrentState(sm)
    %...
    ct = size(sm.EventQueue, 1);    
    
    if (ct)
      currentState = sm.EventQueue(ct, 4);
    else
      currentState = sm.CurrentState;
    end;


    return;