% move_rat(ratname, rig, slot, varargin)
%
% Inputs:
%
% ratname       string:  of the rats name
% rig           integer: new rig to move to
% slot          [1 - 6]: timeslot to move to


function err=move_rat(ratname, rig, slot, varargin)


err=1;


[oldid, oldrig, oldslot, oldexp]=bdata('select schedentryid, rig, timeslot, experimenter from ratinfo.schedule where ratname="{S}" order by date desc limit 1',ratname);
[newid, newrat]=bdata('select schedentryid, ratname from ratinfo.schedule where rig="{S}" and timeslot="{S}" order by date desc limit 1',rig, slot);

if ~isempty(newrat{1})
    err=1;
    fprintf(2,'There is already a rat, %s, running in rig %d, session %d\n', newrat{1},rig, slot);
    return;
end


try
    %mym(bdata,'update ratinfo.schedule set ratname="{S}", experimenter="{S}" where schedentryid="{S}"',ratname, oldexp{1}, newid);
    bdata('call ratinfo.update_schedule_ratname("{S}",{Si})',ratname,newid);
    bdata('call ratinfo.update_schedule_experimenter("{S}",{Si})',oldexp{1},newid);
            
    %mym(bdata,'update ratinfo.schedule set ratname="", experimenter="" where schedentryid="{S}"',oldid);
    bdata('call ratinfo.update_schedule_ratname("{S}",{Si})','',oldid);
    bdata('call ratinfo.update_schedule_experimenter("{S}",{Si})','',oldid);
    
    fprintf('Rat %s moved from rig %d, slot %d to rig %d, slot %d\n',ratname, oldrig, oldslot, rig, slot);
    err=0;
catch
    fprintf(2,'Failed\n');
end


