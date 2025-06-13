function [sm] = ToggleCookedCallback(sender, event, sm)
    sm = get(sm.Fig, 'UserData');
    
    sm.CookedSMView = ~sm.CookedSMView;
    set(sm.CompactCB, 'Value', ~sm.CookedSMView);
    sm.NeedSMListBoxUpdate = 1;
    sm = UpdateStateUI(sm);
    set(sm.Fig, 'UserData', sm);
    return;
