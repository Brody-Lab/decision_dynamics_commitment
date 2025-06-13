function [sm] = ForceState(sm, state)
   
    sm = get(sm.Fig, 'UserData');

    sm = EnqueueEvent(sm, state);
    
    set(sm.Fig, 'UserData', sm);

    return;