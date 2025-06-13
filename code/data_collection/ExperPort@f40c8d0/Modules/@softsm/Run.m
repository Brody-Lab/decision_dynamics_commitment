function [ssm] = Run(ssm)
   
   mydata = get(ssm.myfig, 'UserData');
   mydata.Running = 1;
   if isempty(mydata.StateMatrix),
      % warning(['Trying to run on an empty state matrix: setting state ' ...
      %            'matrix to zeros']);
      mydata.StateMatrix = zeros(512,10);
   end;
   set(ssm.myfig, 'UserData', mydata);
      
   
   
   