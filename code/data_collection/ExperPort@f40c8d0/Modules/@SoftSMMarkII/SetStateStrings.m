function [sm] = SetStateStrings(sm, strs)

    sm = get(sm.Fig, 'UserData');
    
    sm.StateStrings = strs;
    sm.NeedSMListBoxUpdate = 1;
    sm = UpdateStateUI(sm);
    
    set(sm.Fig, 'UserData', sm);

return;