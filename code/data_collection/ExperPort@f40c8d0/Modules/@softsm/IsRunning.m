function [r] = IsRunning(sm)
   
   md = get(sm.myfig, 'UserData');
   r = md.Running;
   
   