function [sm] = ReadyToStartTrial(sm)

    sm = get(sm.Fig, 'UserData');
    
    sm.ReadyForTrialFlg = 0;
    
    if (sm.CurrentState == sm.ReadyForTrialJumpstate),
      % immediately jump to state 0
      sm = ForceState(sm, 0);
    else
      % otherwise note that next time we reach state 35, jump to 0
      sm.ReadyForTrialFlg = 1;
    end;
    
    set(sm.Fig, 'UserData', sm);


    return;