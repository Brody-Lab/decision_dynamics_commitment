function [] = next_row(y, rheight)
   
   if nargin<2, rheight = 1; end;
   
   [trash, y] = gui_position('addrows', rheight, 0, y);
   
   assignin('caller', inputname(1), y);
   