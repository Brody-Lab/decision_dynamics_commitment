function [sfm] = ForceTimeUp(sfm)
% Forces an immediate TimeUp event, in whatever the current state is

   md = get(sfm.myfig, 'UserData');
   
   newstate = md.StateMatrix(md.CurrentState+1, 7);
   md = state_change(md, newstate, 7, etime(clock, md.Init_time));
   
   set(sfm.myfig, 'UserData', md);
   
   