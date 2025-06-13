function [] = Close(sm)
    
    set(sm.Fig, 'UserData', []);
    delete(sm.Fig);
    delete(sm.SMListBoxFig);
    sm = [];    
    return;
    