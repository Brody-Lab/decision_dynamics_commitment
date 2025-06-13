function [] = Trigger(sfm, trigger)
% Calls the triggered callback and does a GUI change 
%
   
   md = get(sfm.myfig, 'UserData');
   go_trigger(md, trigger);
   
   