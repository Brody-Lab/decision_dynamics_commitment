function [time] = GetTime(sm)
   
   sm = get(sm.Fig, 'UserData');
   time = etime(clock, sm.T0);
   return;
   