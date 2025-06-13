function registry_backup

try
    %columns we don't save: alert,training,vendor,waterperday,massArrival,po,
    %forceFreeWater,bringUpAt,bringupday,ignoredByWatermeister,larid

    [internalID,free,experimenter,contact,ratname,comments,recovery,...
        deliverydate,extant,cagemate,dateSac,forceDepWater] = bdata(['select ',...
        'internalID, free, experimenter, contact, ratname, comments, recovering, ',...
        'deliverydate, extant, cagemate, dateSac, forceDepWater from ratinfo.rats']);

    x.internalID    = internalID;
    x.free          = free;
    x.experimenter  = experimenter;
    x.contact       = contact;
    x.ratname       = ratname;
    x.comments      = comments;
    x.recovery      = recovery;
    x.deliverydate  = deliverydate;
    x.extant        = extant;
    x.cagemate      = cagemate;
    x.dateSac       = dateSac;
    x.forceDepWater = forceDepWater;

    file = ['C:\RegistryBackup\',datestr(now,'yyyymmdd'),'.mat'];
    save(file,'x');
    
    map_bucket_drive
    file = ['X:\backups\RegistryBackup\',datestr(now,'yyyymmdd'),'.mat'];
    save(file,'x');
    
catch

    senderror_report
end