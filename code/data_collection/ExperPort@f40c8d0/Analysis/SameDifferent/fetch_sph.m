function [h] = fetch_sph(sph, ratname, sessiondate)

if isnumeric(ratname),
	try 
		[protocol] = bdata(['select protocol from sessions where sessid = ' num2str(ratname)]);
	catch
		display(['Session ' num2str(ratname) ' does not exist']);
		h = {};
		return;
	end;
	
	try
		h = bdata(lower(['select ' sph ' from protocol.' protocol{1} ' where sessid=' num2str(ratname)]));
	catch
		h = {};
		display(['Unable to fetch ' sph ' for session ' num2str(ratname)]);
	end;
else,
	try
		[sessid protocol] = bdata(['select sessid, protocol from sessions where ratname="' ratname '" and sessiondate="' sessiondate '"']);
	catch
		display(['Session does not exist for rat ' ratname ' on ' sessiondate]);
		h = {};
		return;
	end;

	if isempty(sessid),
		display(['Session does not exist for rat ' ratname ' on ' sessiondate]);
		h = {};
		return;
	end;

	try
		h = bdata(['select ' sph ' from protocol.' lower(protocol{1}) ' where sessid=' num2str(sessid)]);
	catch
		h = {};
	end;
	
	if isempty(h),
		display(['Unable to fetch ' sph ' for rat ' ratname ' on ' sessiondate]);
	end;
end;    