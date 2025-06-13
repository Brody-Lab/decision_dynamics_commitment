function out = GetParamUI(module,param,field)
% GETPARAMUI
% Retrieve properties of a ui associated with a PARAM.
%
% VAL = GETPARAMUI(MODULE,PARAM,FIELD);
% 		Calls 'get' on the ui associtated with PARAM
%
% H = GETPARAMUI(MODULE,PARAM);
%		Return a handle to the ui.
%
% PARAM and MODULE are strings. FIELD can be a string or
% cell array.
% 
% ZF MAINEN, CSHL, 8/00
%
global exper

sf = sprintf('exper.%s.param.%s',lower(module),lower(param));
h = GetP(sf,'h');         
if nargin < 3
	out = h;
else
	if ishandle(h)
		out = get(h,field);
	else
		out = [];
	end
end

	