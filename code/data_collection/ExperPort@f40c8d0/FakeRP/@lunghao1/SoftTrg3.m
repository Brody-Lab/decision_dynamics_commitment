function [] = SoftTrg3(lh1)
% Set "running" flag to 1. Only when running do TimesUp events matter
%
   lh1 = get_mylh1(lh1);
   lh1.running = 1;
   save_mylh1(lh1);
   