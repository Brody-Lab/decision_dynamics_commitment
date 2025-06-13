function [sm] = Run(sm)

    sm = get(sm.Fig, 'UserData');
    
    sm.IsRunning = 1;

    set(sm.Fig, 'UserData', sm);

    return;