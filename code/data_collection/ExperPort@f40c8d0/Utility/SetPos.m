function pos = setpos(myh,varargin)
% POS = SETPOS(MYH,[H],LOC)
% place button next to another object
% H is the handle of a specified object, optional
% LOC is one of 'north', 'south', 'east' or 'west'

myh = myh(1);
myp = get(myh,'pos');
mytype = get(myh,'type');
myparent = get(myh,'parent');

if nargin < 3
   loc = varargin{1};
   others = findobj('parent',myparent,'type',mytype);
   if length(others) > 1
      h = others(end-1);
   else
      h = others;
   end
else
   h = varargin{1};
   loc = varargin{2};
end

h = h(1);
p = get(h,'pos');
hoff = p(1);
voff = p(2);
switch loc
case 'north'
   pos = [hoff voff+p(4) p(3) myp(4)];
case 'south'
   pos = [hoff voff-myp(4) p(3) myp(4)];
case 'east'
   pos = [hoff+p(3) voff myp(3) p(4)];		
case 'west'
   pos = [hoff-myp(3) voff myp(3) p(4)];		
otherwise
   pos = myp;
end
set(myh,'pos',pos);
