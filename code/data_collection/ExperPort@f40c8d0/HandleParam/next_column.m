function [] = next_column(x, cwidth)
   
   if nargin<2, cwidth = 1; end;
   
   [x, trash] = gui_position('addcols', cwidth, x, 0);
   
   assignin('caller', inputname(1), x);
   
   