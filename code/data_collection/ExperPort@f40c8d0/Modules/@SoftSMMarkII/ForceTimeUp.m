function [sm] = ForceTimeUp(sm)

    sm = get(sm.Fig, 'UserData');
    
    sm.ForceTUP = 1;
    
    set(sm.Fig, 'UserData', sm);
    
    return;