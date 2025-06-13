function handles = SC_update_tech(handles,shift)



if     shift == 1; shiftltr = 'A'; shiftstring = 'overnight';
elseif shift == 2; shiftltr = 'B'; shiftstring = 'morning';
else               shiftltr = 'C'; shiftstring = 'evening';
end

if strcmp(get(handles.run_toggle,'string'),'RUN'); return; end

if strcmp(get(eval(['handles.',shiftltr,'lock_text']),'visible'),'on'); return; end

[currsched, ID] = bdata(['select ',shiftstring,', scheduleid from ratinfo.tech_schedule where date="',datestr(now,'yyyy-mm-dd'),'"']);
currsched = currsched{1};

if numel(currsched) > 1 && ~isempty(str2num(currsched(end-1:end))); return; end

firstspace = find(currsched == ' ',1,'first');
if ~isempty(firstspace); currsched = currsched(firstspace:end); 
else                     currsched = '';
end

newtechnum = get(eval(['handles.',shiftltr,'tech_menu']),'value');
allexp     = get(eval(['handles.',shiftltr,'tech_menu']),'string');

currsched = [allexp{newtechnum},currsched];

%mym(bdata,['update ratinfo.tech_schedule set ',shiftstring,'="',currsched,'" where date="',datestr(now,'yyyy-mm-dd'),'"']);

if shift == 1
    bdata('call ratinfo.append_tech_schedule_overnight("{S}","{Si}")',currsched,ID);
elseif shift == 2
    bdata('call ratinfo.append_tech_schedule_morning("{S}","{Si}")',currsched,ID);
else
    bdata('call ratinfo.append_tech_schedule_evening("{S}","{Si}")',currsched,ID);
end


