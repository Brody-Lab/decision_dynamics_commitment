function [err]=create_phys_session(obj)
err=0;
sessid=getSessID(obj);
try
[expr,ratname]=SavingSection(obj,'get_info');
catch
    ratname='';
    err=1;
end

sqlstr='insert into ratinfo.phys (sessid,ratname, session_notes) values ("{S}","{S}","{S}")';
bdata(sqlstr,sessid,ratname,datestr(now))