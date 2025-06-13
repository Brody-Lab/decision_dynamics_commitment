function [state] = GetState(sm)

    sm = get(sm.Fig, 'UserData');
    
    state = sm.CurrentState;
    
    return;