function [sfm] = ForceState0(sfm)
% Forces an immediate switch to state 0, from whatever the current state was

   md = get(sfm.myfig, 'UserData');
   newstate = 0;
   md = state_change(md, newstate, -Inf, etime(clock, md.Init_time));
   set(sfm.myfig, 'UserData', md);
   
   