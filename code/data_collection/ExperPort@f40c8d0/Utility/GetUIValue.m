function val = GetUIValue(module,name,varargin)
% VAL = GETUIVALUE(MODULE,NAME,[VARARGIN])
% Get values from various ui fields according to the tag NAME
% and optional fields passed in the extra arguments.
% Returns only the value from the first UI found.

module = lower(module);
name = lower(name);
	
val = [];

f = findobj('tag',module,'type','figure');
if ~isempty(f)
	
	h = findobj(f,'tag',name,varargin{:});
	if ~isempty(h)
 		n = 1;		% assume we only want to deal with the first input
	  	switch get(h(n),'style')
	   	case {'togglebutton','checkbox','slider','popupmenu'}
 	       	val = get(h,'value');
	 	 	case {'edit'}
   	 	   val = get(h,'string');
	   	otherwise
  		end
	end
end


