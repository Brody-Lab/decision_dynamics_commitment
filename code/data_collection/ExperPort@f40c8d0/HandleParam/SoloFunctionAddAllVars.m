function SoloFunctionAddAllVars(obj, fname, access)
% SoloFunctionAddAllVars([obj], fname, access)
% This function is a wrapper for SoloFunctionAddVars.  It adds all
% variables owned by the function from whence it is called to the function
% passed in 'fname'.  It is most handy for giving the StateMatrixSection
% read only access to a bunch of variables.
%
% [obj]         Optional, but strongly recommended for forwards
%               compatibility: the object that owns the variables being added
% fname         The function to give permissions to
% access        either 'ro_args' or 'rw_args'

if nargin==2,
  access = fname;
  fname  = obj;
  obj    = [];
end;
  

caller=determine_fullfuncname;

if isempty(caller)
    warning('Could not determine calling function, no variables affected');
    return;
end

if isempty(obj),
  vhandles=get_sphandle('fullname',caller);
else
  vhandles=get_sphandle('owner', ['@' class(obj)], 'fullname',caller);
end;


if isempty(obj),
  % estr=['SoloFunctionAddVars(''' fname ''',  ''' access ''', ' vstr '});'];
  SoloFunctionAddVars(fname, access, vhandles, 'caller_funcname', caller, 'func_owner', determine_owner);
else
  SoloFunctionAddVars(obj, fname, access, vhandles, 'caller_funcname', caller);
  % estr=['SoloFunctionAddVars(''' fname ''',  ''' access ''', ' vstr '});'];
end;
% evalin('caller', estr);

