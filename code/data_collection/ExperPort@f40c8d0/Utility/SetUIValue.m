function h = SetUIValue(module,name,val,varargin)
% H = SETUIVALUE(MODULE,NAME,VAL,[LIST],[VARARGIN])
% Set the value in a gui field specified by 'tag' NAME to
% the value VAL. Extra arguments specify additional fields
% and values that are set.
% If val = [] it is not set.
% If more than one matching object is found, all are set.
% For listbox and popupmenu, the LIST argument sets the choices.

fig = findobj('tag',module,'type','figure');
if ~isempty(fig)
	h = findobj('tag',name,'parent',fig);
	if ~isempty(h)
 		for n=1:length(h)
     		switch get(h(n),'style')
	   	case {'togglebutton','checkbox','slider'}
 				if ~isempty(val) set(h(n),'value',val); end
				if ~isempty(varargin) set(h(n),varargin{:}); end
	  		case {'edit'}
 				if ~isempty(val) set(h(n),'string',val); end
				if ~isempty(varargin) set(h(n),varargin{:}); end
			case {'listbox','popupmenu'}
				if ~isempty(val) set(h(n),'value',val); end
				if nargin > 3 set(h(n),'string',varargin{1}); end
				if nargin > 4 set(h(n),varargin{2:end}); end
			otherwise
			end
   	end
	end
end

