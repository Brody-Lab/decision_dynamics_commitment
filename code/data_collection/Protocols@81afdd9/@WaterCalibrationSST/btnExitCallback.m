function btnExitCallback

global PROTOCOL_NAME;

hndl = findobj(findall(0), 'Name', 'WATER_CALIBRATION');

answer = questdlg('Are you sure you want to exit?', 'Confirmation', 'YES', 'NO', 'NO');

if strcmpi(answer, 'YES')
    try
        mym('close');
        delete(hndl)
        feval(PROTOCOL_NAME, 'stop_calibration');
        dispatcher('Stop');
    catch %#ok<CTCH>
    end
end

end
