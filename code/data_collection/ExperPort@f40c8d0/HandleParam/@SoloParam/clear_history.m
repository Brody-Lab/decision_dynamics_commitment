% [sp] = clear_history(sp)
%
% Clears the entire history record for this SoloParam
%


function [sp] = clear_history(sp)
   
   sp.value_history = {};
