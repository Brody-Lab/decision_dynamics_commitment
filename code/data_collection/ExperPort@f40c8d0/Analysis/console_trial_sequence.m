function [seq] = console_trial_sequence(saved)

   ntrials   = saved.trials-1;
   side_list = saved.sidelist(1:ntrials);
   rwhist    = saved.rewardhistory(1:ntrials);
   
   u = find(rwhist=='m');
   side_list(u) = 1-side_list(u);
   
   seq = zeros(size(side_list));
   seq(find(side_list==1)) = 'R';
   seq(find(side_list==0)) = 'L';
   seq = double([(1:length(seq))' seq' rwhist=='h']);
   
   
   