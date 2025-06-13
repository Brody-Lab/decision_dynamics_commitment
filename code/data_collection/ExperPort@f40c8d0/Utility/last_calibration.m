function last_calibration(rigid)

[CalIn CalDate] = bdata(['select initials, dateval from calibration_info_tbl where rig_id="',...
    num2str(rigid),'" and dateval>"',datestr(now-100,'yyyy-mm-dd'),'" order by dateval']);

[IN EX] = bdata('select initials, experimenter from ratinfo.contacts');

lastcal = CalDate{end};

temp = strcmp(IN,CalIn{end});
if sum(temp) == 1
    lasttech = EX{temp};
else
    lasttech = 'unknown';
end

disp(['Rig ',num2str(rigid),' last calibrated by ',lasttech,' on ',lastcal]);



