function val = GetUI(module,name,field,varargin)
% VAL = GETUI(MODULE,NAME,FIELD,[VARARGIN])
% Get values from various ui fields according to the tag NAME
% and optional fields passed in the extra arguments.
% Returns only the value of any FIELDS found.

module = lower(module);
name = lower(name);
	
val = [];

f = findobj('tag',module,'type','figure');
h = findobj(f,'tag',name,varargin{:});
if ~isempty(h)
	val = get(h,field);
end


