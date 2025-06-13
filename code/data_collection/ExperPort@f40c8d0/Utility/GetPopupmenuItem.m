function x = GetPopupmenuItem(tag,fig)
% return the currently selected string from a popupmenu item

    if nargin < 2
        fig = double(gcf);
    end
   ui = findobj(fig,'style','popupmenu','tag',tag);
   if ishandle(ui)
       val = get(ui(1),'value');
       list = get(ui(1),'string');
       x = list{val};
   else
       x = '';
   end
