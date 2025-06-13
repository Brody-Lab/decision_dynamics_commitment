function [currentStateTS] = GetCurrentStateTS(sm)
    %...
    ct = size(sm.EventQueue, 1);    
    
    if (ct)
      currentStateTS = sm.EventQueue(ct, 3);
    else
      currentStateTS = sm.CurrentStateTS;
    end;

    return;
    