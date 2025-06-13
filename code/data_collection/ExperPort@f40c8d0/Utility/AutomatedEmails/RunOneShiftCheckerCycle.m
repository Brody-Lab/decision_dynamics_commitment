function RunOneShiftCheckerCycle

if rem(str2num(datestr(now,'MM')),5) == 0
    handles = ShiftChecker2;
    x = get(handles.figure1,'Children');

    handles.run_toggle.Value = 1;
    handles.runonecycle = 1;

    for id=1:numel(x)
        if strcmp(get(x(id),'Tag'),'run_toggle')
            break
        end
    end

    ShiftChecker2('update',x(id),[],handles);
end