function btnExitWithoutSavingCallback

global SERIAL_OBJ_BALANCE;
global FIGURE_NAME;

answer = questdlg('Are you sure you want to exit without saving? ALL YOUR DATA WILL BE LOST!', 'Confirmation', 'YES', 'NO', 'NO');

if strcmp(answer, 'YES')

    hndlMassMeister = findobj(findall(0), 'Name', FIGURE_NAME);

    try
        fclose(SERIAL_OBJ_BALANCE);
        delete(SERIAL_OBJ_BALANCE);
        clear('SERIAL_OBJ_BALANCE');
    catch %#ok<CTCH>
    end

    if exist('ratinfo_temp.mat', 'file')
        delete('ratinfo_temp.mat');
    end
    
    delete(hndlMassMeister(1));

    close('all');

    clear('all');

end

end