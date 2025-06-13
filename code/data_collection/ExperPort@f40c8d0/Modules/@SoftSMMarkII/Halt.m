function [sm] = Halt(sm)

    sm = get(sm.Fig, 'UserData');

    sm.IsRunning = 0;

    set(sm.Fig, 'UserData', sm);

    return;