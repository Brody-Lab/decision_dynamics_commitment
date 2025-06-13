function [lh1] = LeftOut(lh1)

    lh1 = get_mylh1(lh1);
    if ~lh1.running, return; end;
    lh1.LeftOut = 1;
    save_mylh1(lh1);
    EventOccurred(lh1);
    