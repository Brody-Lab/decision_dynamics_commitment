function [ssm] = Set_Dout_Callback(ssm, callback, arg)
   
   mydata = get(ssm.myfig, 'UserData');
   mydata.dout_callback = {callback arg};
   set(ssm.myfig, 'UserData', mydata);
   
   