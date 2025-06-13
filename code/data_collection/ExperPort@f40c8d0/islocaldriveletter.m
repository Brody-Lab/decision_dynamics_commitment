function yes_or_no = islocaldriveletter(drive_letter)
    drive_letter = strrep(drive_letter,':','');
    drive_letter = strrep(drive_letter,'\','');
    drive_letter = strrep(drive_letter,'/','');    
    locals = local_drives();
    if ismember(drive_letter,locals)
        yes_or_no=true;
    else
        yes_or_no = false;
    end
end