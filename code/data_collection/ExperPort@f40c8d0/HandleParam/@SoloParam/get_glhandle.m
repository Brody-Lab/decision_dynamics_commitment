function [h] = get_glhandle(sp)
   
   h = [sp.ghandle; sp.lhandle];
   