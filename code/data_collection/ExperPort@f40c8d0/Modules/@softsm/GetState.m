function [currentstate] = GetState(sfm)
   
   mydata = get(sfm.myfig, 'UserData');
   
   currentstate = mydata.CurrentState;
   
   