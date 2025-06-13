function [p] = get_position(sp)
   
   h = get_glhandle(sp);
   if length(h)>=1,
     p = get(h(1), 'Position');
   end;
   if length(h)>=2,
     p = [p ; get(h(2), 'Position')];
   end;
   
   

   
   