function out = RmParam(module,param)

param = lower(param);
module = lower(module);

% Make sure module exists.
sf = sprintf('isfield(exper,''%s'')',module);
out = evalin('caller',sf);
if out
	% Make sure param exists.
	sf = sprintf('isfield(exper.%s.param,''%s'')',module,param);
	out = evalin('caller',sf);
	if out
		% Remove the param from the structure if it exists.
		sf = sprintf('exper.%s.param=rmfield(exper.%s.param,''%s'');',module,module,param);
		evalin('caller',sf);
	end
end