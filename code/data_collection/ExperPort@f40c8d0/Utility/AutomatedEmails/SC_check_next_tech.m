function handles = SC_check_next_tech(handles,shift)

try
    if     shift == 1; shiftname = 'overnight'; nextdate = now;   nextname = 'morning';   shiftletter = 'A'; nextletter = 'B';
    elseif shift == 2; shiftname = 'morning';   nextdate = now;   nextname = 'evening';   shiftletter = 'B'; nextletter = 'C';
    else               shiftname = 'evening';   nextdate = now+1; nextname = 'overnight'; shiftletter = 'C'; nextletter = 'A';
    end

    nextsched = bdata(['select ',nextname,' from ratinfo.tech_schedule where date="',datestr(nextdate,'yyyy-mm-dd'),'"']);
    nextsched = nextsched{1};

    if isempty(nextsched) || all(nextsched == ' ')
        set(eval(['handles.',shiftletter,'endnote_text']),'visible','on');
    else
        set(eval(['handles.',shiftletter,'endnote_text']),'visible','off');
    end

    techlist = get(eval(['handles.',shiftletter,'tech_menu']),'string');
    techpos  = get(eval(['handles.',shiftletter,'tech_menu']),'value');
    currtech = techlist{techpos};

    currsched = bdata(['select ',shiftname,' from ratinfo.tech_schedule where date="',datestr(now,'yyyy-mm-dd'),'"']);
    currsched = currsched{1};

    if     ( isempty(currsched) ||  all(currsched == ' ')) && ~isempty(currtech)
        %no one in the schedule but a name is in the menu
        set(eval(['handles.',shiftletter,'tech_menu']),'value',1);

    elseif (~isempty(currsched) && ~all(currsched == ' ')) &&  isempty(currtech) 
        %a name is in the schedule but no name is in the menu
        firstspace = find(currsched == ' ',1,'first');
        if isempty(firstspace); firstspace = numel(currsched) + 1; end
        namesched = currsched(1:firstspace-1);

        listpos = find(strcmp(techlist,namesched) == 1,1,'first');
        if isempty(listpos) listpos = 1; end

        set(eval(['handles.',shiftletter,'tech_menu']),'value',listpos);
    end
end