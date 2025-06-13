function [sfm] = BypassDout(sfm, d)

   md = get(sfm.myfig, 'UserData');
   
   md.Dout_bypass = d;  
   md = check_dout_change(md);
   
   set(sfm.myfig, 'UserData', md);
   