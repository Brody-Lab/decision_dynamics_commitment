function schedule_backup

try
    [timeslot,rig,ratname,instructions,C,D] = bdata(['select ',...
      'timeslot, rig, ratname, instructions, comments, date ',...
      'from ratinfo.schedule where date="',datestr(now-1,'yyyy-mm-dd'),'"']);

    x.timeslot      = timeslot;
    x.rig           = rig;
    x.ratname       = ratname;
    x.instructions  = instructions;
    x.comments      = C;
    x.date          = D;
    
    file = ['C:\ScheduleBackup\',datestr(now-1,'yyyymmdd'),'.mat'];
    save(file,'x');
    
    map_bucket_drive
    file = ['X:\backups\ScheduleBackup\',datestr(now,'yyyymmdd'),'.mat'];
    save(file,'x');
    
catch

    senderror_report
end