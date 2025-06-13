function fields_to_vars(S)
% field_to_vars(S)
% Takes a struct S and creates variables from the fields in the caller

if ~isstruct(S)
	warning('need struct input');
else
	fn=fieldnames(S);
	for fx=1:numel(fn)
		assignin('caller',fn{fx}, S.(fn{fx}));
	end
end
