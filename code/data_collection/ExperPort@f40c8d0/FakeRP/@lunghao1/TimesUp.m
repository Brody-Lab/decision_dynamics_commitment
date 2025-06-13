function [] = TimesUp(lh1)
% Execute a GoNextState if we are running
%
    lh1 = get_mylh1(lh1);
    if ~lh1.running, return; end; 
    lh1.GoNextState = 1;
    save_mylh1(lh1);
    EventOccurred(lh1);
    
