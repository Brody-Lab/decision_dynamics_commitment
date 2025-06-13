function [currentStateTUP] = GetCurrentStateTUP(sm)
    %...
    currentStateTUP = sm.StateMatrix(GetCurrentState(sm)+1, GetTUPCol(sm)+1);    
    return;
    