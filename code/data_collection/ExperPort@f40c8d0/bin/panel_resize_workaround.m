function [] = panel_resize_workaround(varargin)

   myhP = findobj(gcf, 'Tag', 'ContainerPanel');
   set(myhP, 'Units', 'pixels');
   set(myhP, 'Units', 'normalized');
