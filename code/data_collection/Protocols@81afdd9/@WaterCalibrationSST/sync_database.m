function sync_database

% mym('close');
% mym('open', 'sonnabend.princeton.edu', 'user', 'pass');
% mym('use bdata');
mym('close');
bdata('connect', 'sonnabend.princeton.edu');
%Current database: bdata

Calibration_Data_Directory = bSettings('get', 'GENERAL', 'Calibration_Data_Directory');
if isnan(Calibration_Data_Directory)
    Calibration_Data_Directory = '\ratter\CNMC\Calibration';
end
Calibration_Data_Directory = strrep(Calibration_Data_Directory, '\', filesep);
[status, hostname] = system('hostname'); hostname = lower(hostname);
hostname = regexprep(hostname, '\s', ''); hostname = regexprep(hostname, '\..*', '');


rig_id = bSettings('get', 'RIGS', 'Rig_ID');

if ~isnan(rig_id)
    rig_id = num2str(rig_id);
    % Sync calibration_info_tbl from the database and the calibration
    % data MAT file. The primary source of data is the MAT file.
    
    if ~is_calibration_data_available(Calibration_Data_Directory, hostname)
        sqlstr = ['SELECT initials, dateval, valve, timeval, dispense, isvalid ' ...
            'FROM calibration_info_tbl ' ...
            'WHERE rig_id="' rig_id '" ' ...
            'ORDER BY dateval ASC'];
        data = mym(bdata, sqlstr);
        wt = struct([]);
        for ctr = 1:length(data.initials)
            wt(end+1).initials = data.initials{ctr}; %#ok<AGROW>
            wt(end).date = datenum(data.dateval{ctr});
            wt(end).valve = data.valve{ctr};
            wt(end).time = data.timeval(ctr);
            wt(end).dispense = data.dispense(ctr);
            wt(end).isvalid = logical(data.isvalid(ctr));
        end
        if ~isempty(wt)
            if ~exist(Calibration_Data_Directory, 'dir')
                mkdir(Calibration_Data_Directory);
            end
            save(fullfile(Calibration_Data_Directory, [hostname, '_watertable.mat']), 'wt', '-v7');
        end
    else
        
        %Sort the entries in the file according to date
        load(fullfile(Calibration_Data_Directory, [hostname, '_watertable.mat'])); %Contains wt
        for ctr = 1:length(wt) %#ok<NODEF>
            if ~isfield(wt(ctr), 'isvalid') || isempty(wt(ctr).isvalid)
                wt(ctr).isvalid = true; %#ok<AGROW>
            end
        end
        wt_cell = struct2cell(wt);
        wt_cell = reshape(wt_cell, size(wt_cell, 1), length(wt));
        wt_cell = wt_cell.';
        wt_cell = sortrows(wt_cell, 2); %The second column stores the date
        for ctr = 1:length(wt)
            wt(ctr) = cell2struct(wt_cell(ctr, :), fieldnames(wt), 2); %#ok<AGROW>
            wt(ctr).initials = upper(wt(ctr).initials); %#ok<AGROW>
        end
        save(fullfile(Calibration_Data_Directory, [hostname, '_watertable.mat']), 'wt', '-v7');

        
        %     %DELETE all rows corresponding to rig ID rig_id
        %     sqlstr = 'DELETE FROM calibration_info_tbl ';
        %     sqlstr = [sqlstr, 'WHERE rig_id="', rig_id, '"'];
        %     mym(sqlstr);
        
        % INSERT all new calibration data into the SQL database
        for ctr = 1:length(wt)
            initials = wt(ctr).initials;
            dateval = datestr(wt(ctr).date, 31); %Date format 31 is compatible with the SQL DATETIME format
            valve = wt(ctr).valve;
            timeval = num2str(wt(ctr).time);
            dispense = num2str(wt(ctr).dispense);
            isvalid = logical(wt(ctr).isvalid);
            if isvalid
                isvalid = 'TRUE';
            else
                isvalid = 'FALSE';
            end
            
            
            sqlstr = ['SELECT MAX(dateval) AS maxdate FROM calibration_info_tbl ' ...
                'WHERE rig_id="' rig_id '" AND valve="' valve '"'];
            maxdateobj = mym(bdata, sqlstr);
            
            if isempty(maxdateobj.maxdate{1}) || datenum(dateval) > datenum(maxdateobj.maxdate{1})
                sqlstr = ['INSERT INTO calibration_info_tbl (rig_id, initials, dateval, valve, timeval, dispense, isvalid) ' ...
                    'VALUES ("' rig_id '", "' initials '", "' dateval '", "' valve '", ' timeval ', ' dispense ', ' isvalid ')'];
                mym(bdata, sqlstr);
            end
        end
    end
    
end
mym('close');

end

%%

function rvalue = is_calibration_data_available(Calibration_Data_Directory, hostname)

rvalue = true;
if exist(fullfile(Calibration_Data_Directory, [hostname, '_watertable.mat']), 'file')
    load(fullfile(Calibration_Data_Directory, [hostname, '_watertable.mat']));
    if isempty(wt)
        rvalue = false;
        return;
    end
else
    rvalue = false;
    return;
end

end

