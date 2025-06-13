% [t] = eq(u1, u2)     Applies eq.m to value(u1) and value(u2)

function [t] = eq(u1, u2)
   
   t = (value(u1) == value(u2));
   