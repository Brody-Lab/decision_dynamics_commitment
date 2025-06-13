function [EventList] = GetEvents(sm, first, last)

    sm = get(sm.Fig, 'UserData');
    
    if (last > sm.EventCount),
      error(sprintf(['SoftSM only has %d events so far, not' ...
                     ' %d!'], sm.EventCount, last));
    end;
    
    EventList = sm.EventList(first:last,:);
    
    return;
