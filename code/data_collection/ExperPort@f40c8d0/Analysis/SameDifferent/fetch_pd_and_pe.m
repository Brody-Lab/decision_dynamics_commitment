function [pd pe] = fetch_pd_and_pe(ratname, sessiondate)

[sessid] = bdata(['select sessid from sessions where ratname="' ratname '" and sessiondate="' sessiondate '"']);
% 
if isempty(sessid),
    display(['Session does not exist for rat ' ratname ' on ' sessiondate]);
    pd = {};
    pe = {};
    return;
end;
% 
% pd = bdata(['select protocol_data from sessions where sessid=' num2str(sessid)]);
% pe = bdata(['select ProtocolsSection_parsed_events from protocol.' protocol{1} ' where sessid=' num2str(sessid)]);
% 

S=get_sessdata(sessid);
pd=S.pd;
peh=S.peh;

 if isempty(pd) || isempty(peh),
     display(['Unable to fetch pd and pe for rat ' ratname ' on ' sessiondate]);
 else
     pd = pd{1};
	 for x=1:numel(peh), pe{x}=peh(x); end;
 end;
    