function [lower_overlap] = predictability(a,b,c,d,s1,s2)
  
  % Algorithm:
  % Given two ranges [a,b] and [c,d], returns
  
  amin = a;
  amax = b;
  bmin = c;
  bmax = d;
  
% s1 = 360; s2 = 660;
  
  
   s1min = amin+bmin+s1;
   s1max= amax+bmax+s1;
   s2min=amin+bmin+s2;
   s2max=amax+bmax+s2;
     
   lower_overlap = 0; upper_overlap = 0;
   
   if s1max< s2min, 
     lower_overlap = 0; upper_overlap = 0;
   
   else
   
     % prob P< s1 < Q = prob s1 > P
     lower_overlap = 1- ((s2min-s1min)/(s1max-s1min));
     upper_overlap = ((s1max-s2min)/(s2max-s2min));
  
     if abs(lower_overlap - upper_overlap) > 0.0001, error('unequal overlaps!\n'); end;
     
   end;