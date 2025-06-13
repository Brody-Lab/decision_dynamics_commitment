%is_same_soloparamhandle_nocheck.m    [t] = is_same_soloparamhandle_ncheck(u1, u2)
%
% Same as is_same_soloparamhandle.m but ASSUMES u1 and u2 are SoloParamHandles, does not
% check for that. This speeds things up. 
%
% Checks to see whether two handles actually point to the same
% SoloParam (i.e., are equal not only in value but also in reference). 
%
   
   
function [t] = is_same_soloparamhandle_nocheck(u1, u2)
   
   t = (u1.lpos == u2.lpos);
   
