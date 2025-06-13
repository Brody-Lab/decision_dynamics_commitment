function [nevents] = GetEventCounter(sm)
   
   mydata  = get(sm.myfig, 'UserData');
   nevents = mydata.nevents;
   
   