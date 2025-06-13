function [sph] = pop_history(sph)
% Takes the last value in the object's history list off the list. Does
% NOT affect current value. Despite the name, treats history like a
% queue, not a stack! 
   
   global private_soloparam_list;
   private_soloparam_list{sph.lpos} = ...
       pop_history(private_soloparam_list{sph.lpos});
   
