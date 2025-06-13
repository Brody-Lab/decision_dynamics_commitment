function [myrow] = access_bestmat(prea, preb, posta, postb, s1, s2)
  
   load '~/ExperPort/Analysis/stat_sandbox/analysis_070205.mat';
  
   a = find(abs(bestmat(:,1)-prea) < 0.0000001);
   tmp = bestmat(a,:);
   b = find(abs(tmp(:,2)-preb) < 0.0000001);
   tmp = tmp(b,:);
   c = find(abs(tmp(:,3)-posta) < 0.0000001);
   tmp = tmp(c,:);
   d = find(abs(tmp(:,4)-postb) < 0.0000001);
   tmp = tmp(d,:);
   e = find(abs(tmp(:,5)-s1) < 0.0000001);
   tmp = tmp(e,:);
   f = find(abs(tmp(:,6)-s2) < 0.0000001);
   tmp = tmp(f,:);
  
   
  myrow = tmp;
  