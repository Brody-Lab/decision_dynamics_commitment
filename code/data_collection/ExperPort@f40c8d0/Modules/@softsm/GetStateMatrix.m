function [state_matrix] = GetStateMatrix(ssm)
   
   mydata = get(ssm.myfig, 'UserData');
   state_matrix = mydata.StateMatrix;
   
   