% [t] = isequal(u1, u2)     Applies isequal.m to value(u1) and value(u2)

function [t] = isequal(u1, u2)
   
   t = isequal(value(u1), value(u2));
   