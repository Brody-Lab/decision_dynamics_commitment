function [ssm] = Set_Trigout_Callback(ssm, callback, arg)
   
   mydata = get(ssm.myfig, 'UserData');
   mydata.tout_callback = {callback arg};
   set(ssm.myfig, 'UserData', mydata);
   
   