function [ssm] = SetStateMatrix(ssm, state_matrix)
   
   sz = size(state_matrix);
   if length(sz) ~= 2 | sz(1) ~= 512 | sz(2) ~= 10,
      error('state_matrix must be 512 rows by 10 columns');
   end;
   
   mydata = get(ssm.myfig, 'UserData');
   mydata.StateMatrix = state_matrix;
   set(ssm.myfig, 'UserData', mydata);
   
   