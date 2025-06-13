function btnSaveAndExitCallback

global FIGURE_NAME;
global SERIAL_OBJ_BALANCE;

hndlMassMeister = findobj(findall(0), 'Name', FIGURE_NAME);
handles = guihandles(hndlMassMeister(1));

%Check to see if entries already exist for any of the rats weighed in the
%current session
assert(logical(exist('ratinfo_temp.mat', 'file')));
load('ratinfo_temp.mat'); %Loads 'RATLIST' 'CAGEMATELIST' 'MASSLIST' 'TIMESLOTLIST' 'ISRECOVERINGLIST' 'ISNEWLIST' 'ISTRAININGLIST'

userinitials = get(handles.editUserInitials, 'String');

answer = questdlg('Are you sure you want to save your data and exit?', 'Confirmation', 'YES', 'NO', 'NO');

if strcmp(answer, 'YES')
    
    hndlWaitBar = waitbar(0, 'Writing to the database, please wait...', 'CloseRequestFcn', '', 'WindowStyle', 'modal');
    for ctr = 1:length(RATLIST) %#ok<USENS>
        
        if ISNEWLIST(ctr)
            sqlstr = ['SELECT weighing FROM ratinfo.mass WHERE ratname="' RATLIST{ctr} '" AND date="' datestr(now, 29) '";'];
            data = bdata(sqlstr);
            if isempty(data.weighing) && ~isempty(MASSLIST{ctr}) %#ok<USENS>
                sqlstr = ['INSERT INTO ratinfo.mass (ratname, date, mass, tech) ' ...
                    'VALUES ("' RATLIST{ctr} '", "' datestr(now, 29), '", ', num2str(round(eval(MASSLIST{ctr}))), ', "', userinitials, '");'];
                bdata(sqlstr); %needs to be changed to procedure but I don't think this is used anymore
            else
                if ~isempty(MASSLIST{ctr})
                    sqlstr = ['CALL ratinfo.update_mass_tbl(' num2str(data.weighing(1)) ', ' num2str(round(eval(MASSLIST{ctr}))), ', "' userinitials '")'];
                    bdata(sqlstr);
                end
            end
        end
        
        waitbar(ctr/length(RATLIST), hndlWaitBar);
        
    end
    delete(hndlWaitBar(1));
    
    
    try
        fclose(SERIAL_OBJ_BALANCE);
        delete(SERIAL_OBJ_BALANCE);
        clear('SERIAL_OBJ_BALANCE');
    catch %#ok<CTCH>
    end
    
    bdata('close');
    
    if exist('ratinfo_temp.mat', 'file')
        delete('ratinfo_temp.mat');
    end
    
    delete(hndlMassMeister(1));
    
    close('all');
    
    clear('all');
    
end