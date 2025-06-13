function [ssm] = SetPCReadyFlag(ssm)
   
   md = get(ssm.myfig, 'UserData');
   md.PC_Ready = 1;
   md = state_change(md, md.CurrentState, -Inf, etime(clock, md.Init_time));
   set(ssm.myfig, 'UserData', md);

   
   