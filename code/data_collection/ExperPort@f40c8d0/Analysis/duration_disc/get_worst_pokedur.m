function [] = get_worst_pokedur
  
  
  load '~/ExperPort/Analysis/stat_sandbox/analysis_070205.mat';
  
  % loaded bestmat
  % values: pre_min,pre_max, post_min, post_max, s1, s2
  
    a = find(abs(bestmat(:,5)-0.3) < 0.0000001);
   tmp = bestmat(a,:);
   b = find(abs(tmp(:,6)-0.7) < 0.0000001);
   tmp = tmp(b,:);

  
  both_tog = tmp(:,7) + tmp(:,8);
  idx = find(both_tog == min(both_tog));
  
  bestmat(idx,:)
  
  % given range in poke_duration_simulation,
  % worst combination is at 
  % pre = 0.15-0.8, post = 0.15-0.2, short = 400, long = 600
  % prob(short correct) = 73%, prob(long correct) = 60%
  
  
  