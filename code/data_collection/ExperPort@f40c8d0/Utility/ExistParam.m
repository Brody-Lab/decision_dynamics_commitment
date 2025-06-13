function out = ExistParam(module,param)

module = lower(module);

sf = sprintf('isfield(exper,''%s'')',module);
out = evalin('caller',sf);
if out & nargin > 1
    param = lower(param);
	sf = sprintf('isfield(exper.%s.param,''%s'')',module,param);
	out = evalin('caller',sf);
end
