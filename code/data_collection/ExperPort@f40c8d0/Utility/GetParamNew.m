function out = GetParam(module,param,field)
% GETPARAM
% Retrieve PARAM values from an exper MODULE.
% 
% OUT = GETPARAM(MODULE,PARAM)
% 		Return the 'value' field (the default)
% 		(except for lists, where the default is the string of the current
% 		list selection.
%
% OUT = GETPARAM(MODULE,PARAM,FIELD)
%		Return the FIELD field.
%
% MODULE and PARAM are strings.
% FIELD can be a cell array of field names, FIELD = {'f1','f2'},
% in which case the output is a corresponding cell array VAL = {'v1','v2'}
%
% ZF MAINEN, CSHL, 8/00
%
global exper

module = lower(module);

switch nargin
case 2
    param = lower(param);
    list = eval(sprintf('exper.%s.param.%s.list',module,param));
    
	if iscell(list) & ~isempty(list)
		out = list{sprintf('exper.%s.param.%s.value',module,param)};
    else
        out = eval(sprintf('exper.%s.param.%s.value',module,param));
    end
case 3
	sf = sprintf('exper.%s.param.%s',module,param);
    param = lower(param);
    out = GetP(sf,field);
case 1
	out = eval(sprintf('fieldnames(exper.%s.param)',module));
end
