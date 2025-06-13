function x=getSessID(obj)

% Each behavioral session is associated with a single sessid.
% This function returns the sessid.  If no sessid has been assigned then it goes to the mysq
% server and gets a new id and then saves it as a SoloParamHandle: 'sessid'

GetSoloFunctionArgs(obj);

if ~exist('sessid','var')
	% we want sessid to be 'owned' by the procotol.  Not the function
	% getSessID, so pass the param_funcowner.  BUT then we have to make it
	% readable by us!
	SoloParamHandle(obj,'sessid','value',-1,'param_funcowner',class(obj));
	SoloFunctionAddVars(obj,'getSessID','rw_args','sessid');
end

if value(sessid)==-1
	try	bdata('insert into sess_list () values ()');
		x=bdata('select last_insert_id()');
		sessid.value=x;
	catch
		sessid.value=-1;
	end
else
	x=value(sessid);
end