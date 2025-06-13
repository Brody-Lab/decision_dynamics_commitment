function [err] = sendstarttime(obj)
% function [err] = sendstarttime(obj)
%
% This function sends the current time as starttime to the sessions table.
% It should be called by runrats at the time the 'Run' button is pressed

try
	rigID=getRigID;
    if isnan(rigID)
		% if not running on a real rig, don't send to sql
	    err=42;
		return
	end;
	
    hostname=sprintf('Rig%02d',rigID);

    
    
	sessid = getSessID(obj);
	starttime = datestr(now, 13);
	sessiondate = datestr(now, 29);
	ratname = get_sphandle('fullname', 'SavingSection_ratname');
	if isempty(ratname), ratname = '';
	else			     ratname = value(ratname{1});
	end;
	
	colstr = 'sessid, sessiondate, starttime, was_ended, ratname, hostname, rigid';
	valstr = '"{Si}", "{S}", "{S}", "{Si}", "{S}", "{S}","{S}"';
	sqlstr = ['insert into bdata.sess_started (' colstr ') values (' valstr ')'];
	bdata(sqlstr, sessid, sessiondate, starttime, 0, ratname,hostname, rigID);
	bdata('call cleanup_crashed("{S}","{S}")',sessid,rigID); % Mark old sessions from the same rig as ended if they are not marked as such yet.
	err = 0;
catch
	fprintf(2, 'Failed to send starttime to sql\n');
	showerror
	err = 1;
end;

