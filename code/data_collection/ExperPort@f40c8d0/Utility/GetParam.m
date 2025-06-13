function out = GetParam(module,param,field)
% GETPARAM
% Retrieve PARAM values from an exper MODULE.
% 
% OUT = GETPARAM(MODULE,PARAM)
% 		Return the 'value' field (the default)
%
% OUT = GETPARAM(MODULE,PARAM,FIELD)
%		Return the FIELD field.
%
% MODULE and PARAM are strings. 
% 
% To speed up (considerably) this function, list handling and cell
% array inputs (param, field) are no longer implemented. Use
% GetParamList to obtain the list item indexed by the current value.
% 
%
% ZF MAINEN, CSHL, 10/01
%
global exper

module = lower(module);

switch nargin
case 2
    param = lower(param);
%    list = eval(sprintf('exper.%s.param.%s.list',module,param));
    
%	if iscell(list) & ~isempty(list)
%		out = list{sprintf('exper.%s.param.%s.value',module,param)};
%    else
        out = eval(sprintf('exper.%s.param.%s.value',module,param));
%    end
case 3
    param = lower(param);
	sf = sprintf('exper.%s.param.%s',module,param);
    out = GetP(sf,field);
case 1
	out = eval(sprintf('fieldnames(exper.%s.param)',module));
end
