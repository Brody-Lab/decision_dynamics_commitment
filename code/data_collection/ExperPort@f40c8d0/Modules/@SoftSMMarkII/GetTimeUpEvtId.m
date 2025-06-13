function [evtId] = GetTimeUpEvtId(sm)


    evtId = 2^(GetTUPCol(sm)-2);
    
    return;
    