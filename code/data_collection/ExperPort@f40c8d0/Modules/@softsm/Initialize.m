function [ssm] = Initialize(ssm)

   mydata = get(ssm.myfig, 'UserData');
   
   mydata.Running      = 0;
   mydata.StateMatrix  = [];
   mydata.Dout         = 0;
   mydata.Trigout      = 0; 
   mydata.nevents      = 0;
   mydata.EventList    = zeros(200000, 4);
   mydata.Init_time    = clock;
   mydata.PC_Ready     = 1;
   mydata.CurrentState = 0; 
   mydata.Dout_bypass  = 0;

   set(ssm.myfig, 'UserData', mydata);   
   