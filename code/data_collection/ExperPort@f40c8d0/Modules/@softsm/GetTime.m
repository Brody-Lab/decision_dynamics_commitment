function [time] = GetTime(sm)
   
   mydata = get(sm.myfig, 'UserData');
   time = etime(clock, mydata.Init_time);
   
   