function [nevents] = GetEventCounter(sm)
   
   sm  = get(sm.Fig, 'UserData');
   nevents = sm.EventCount;
   return;
   