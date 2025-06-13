function S=free_rat(ratname)

if iscell(ratname)
    for rx=1:numel(ratname)
        S(rx)=free_rat(ratname{rx});
    end
else
    
    
    [oldid, rig, slot, oldexp]=bdata('select schedentryid, rig, timeslot, experimenter from ratinfo.schedule where date>="{S}" and ratname="{S}" order by date desc limit 1',datestr(now,29),ratname);
    [ratID]=bdata('select internalID from ratinfo.rats where ratname="{S}"',ratname);
    
    
    
    if numel(ratID)==1
       
        try
            if ~isempty(oldid)
            %mym(bdata,'update ratinfo.schedule set ratname="", experimenter="" where schedentryid="{S}"',oldid);
            bdata('call ratinfo.update_schedule_ratname("{S}",{Si})','',oldid);
            bdata('call ratinfo.update_schedule_experimenter("{S}",{Si})','',oldid);
            bdata('call ratinfo.update_schedule_comments("{S}",{Si})','',oldid);
            bdata('call ratinfo.update_schedule_instructions("{S}",{Si})','',oldid);
            
            fprintf('Rat %s removed from the schedule: Rig %d, Slot %d\n',ratname, rig, slot);
            end
            % Set date sac and extant=0
            %mym(bdata,'update ratinfo.rats set free=1,training=0,contact="begelfer" where internalID="{S}"',ratID);
            bdata('call ratinfo.flag_rat_free("{Si}")',ratID);
            
            fprintf('Rat %s set to free\n',ratname);
            S.err=0;
        catch le
            showerror(le)
            S.err=1;
        end
        
    else
        fprintf('Failed to identify unique rat\n')
    end
end