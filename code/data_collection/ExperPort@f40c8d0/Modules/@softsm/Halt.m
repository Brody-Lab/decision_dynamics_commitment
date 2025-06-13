function [ssm] = Halt(ssm)
   
   mydata = get(ssm.myfig, 'UserData');
   mydata.Running = 0;
   set(ssm.myfig, 'UserData', mydata);
   
   