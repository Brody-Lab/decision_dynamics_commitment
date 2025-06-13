% <~> This is a modified version of GetEvents. See below.
%
function [EventList] = GetEvents2(sm, first, last)

    sm = get(sm.Fig, 'UserData');
    
    if (last > sm.EventCount),
      error(sprintf(['SoftSM only has %d events so far, not' ...
                     ' %d!'], sm.EventCount, last));
    end;
    
    EventList = sm.EventList(first:last,:);
    
    % <~> Return the column # instead of 2^(column #), as GetEvents2
    %       should. This matches the RTLSM.GetEvents2 method written as
    %       part of the switch to a format that allows the RTLSM to process
    %       more than 32 input columns correctly.
    %     Change made 2008.July.24 locally.
    EventList(:,2) = log2(EventList(:,2));
    
    return;
