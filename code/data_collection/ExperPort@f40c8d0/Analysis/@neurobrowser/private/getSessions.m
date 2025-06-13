function [sessid, sessstr]=getSessions(ratname,op)



if strncmp(ratname,'Rig',3)
    % We are in Rig Mode
    sql='select sessid, concat(ratname,", ",sessiondate,",",lpad(n_done_trials,4," "),", L:",if(left_correct<0,"NA",round(left_correct*100)),"%, R:",if(right_correct<0,"NA",round(right_correct*100)),"%") as str  from sessions where hostname="{S}" order by sessid desc';
	[sessid, sessstr]=bdata(sql,ratname);
        
else

if ~op
	% get all experimenters
	    [sessid,sessstr]=bdata('select sessid,concat(sessiondate,",",lpad(n_done_trials,4," "),", L:",if(left_correct<0,"NA",round(left_correct*100)),"%, R:",if(right_correct<0,"NA",round(right_correct*100)),"%") as str  from sessions where ratname="{S}" order by sessid desc',ratname);
else
    	[sessid,sessstr]=bdata('select distinct(s.sessid),concat(s.sessiondate,",",lpad(n_done_trials,4," "),", L:",if(left_correct<0,"NA",round(left_correct*100)),"%, R:",if(right_correct<0,"NA",round(right_correct*100)),"%") as str  from sessions s, cells c where c.sessid=s.sessid and c.ratname="{S}" order by sessid desc',ratname);

end	


end

if isempty(sessstr)
    sessstr={' '};
    sessid=0;
end