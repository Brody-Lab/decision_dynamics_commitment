function [] = simulate_bias(rat, task, date)
  
  % What went wrong with bias correction implemented at end of April?
    % This script simulates the calculate of 'b' for bias, because
    % changes to LeftProb and RightProb were made based on this value.
  
  load_datafile(rat, task, date);
  side_list = saved.SidesSection_side_list;
  n_done_trials = eval(['saved.' task '_n_done_trials']);
  LeftRewards = saved.RewardsSection_LeftRewards; LeftRewards = ...
      LeftRewards(1:n_done_trials);
  RightRewards= saved.RewardsSection_RightRewards; RightRewards = ...
      RightRewards(1:n_done_trials);
  
  hh= eval(['saved.' task '_hit_history']);
  hh = hh(1:n_done_trials);
  
  
  sl = value(side_list); 
  winsize = 15;
  
  bs = [];% array of b's 
  right_zero = []; left_ones = [];
  right_notleft = []; 
  lrate = []; rrate = [];
  
  for k = 1:n_done_trials
   mn = max(1, k - 15);   
    fprintf(1, 'Indexing sides from %i to %i\n', mn, k);  
    left_trials = sum(sl(mn:k));  left_ones = [left_ones left_trials];
    lefthits = sum(LeftRewards(mn:k));  
    if left_trials == 0, lefthits=0; 
    else lefthits = lefthits/left_trials; 
    end;  
    % Method 1: Right trials are trials with side == 0
    tmp = sl(mn:k);    
    right1 = length(find(tmp < 1));  
    right_zero = [right_zero right1];
    
    % Method 2: Right trials are trials that are not left trials
      right2 = 15 - left_trials;  
      right_notleft = [right_notleft right2];
    righthits1 = sum(RightRewards(mn:k));  
    righthits2 = sum(RightRewards(mn:k));  
    
    if right1 == 0, 
      righthits1 = 0; 
    else 
      righthits1 = righthits1/right1; 
    end;  
    
        if right2 == 0, 
      righthits2 = 0; 
    else 
      righthits2 = righthits2/right2; 
    end;  

% $$$     fprintf(1, 'Indexing sides from %i to %i\n', mn, n_done_trials);  
% $$$     idx = mn:n_done_trials;
% $$$     mini_s = sl(idx);
% $$$     mini_h = hh(idx);
% $$$     left_trials = find(mini_s > 0);
% $$$     right_trials = find(mini_s < 1);
% $$$     lefthits = sum(mini_h(left_trials));
% $$$     righthits = sum(mini_h(right_trials));
% $$$     
% $$$      if left_trials == 0, lefthits=0; 
% $$$     else lefthits = lefthits/length(left_trials); 
% $$$      end;  
% $$$       if right_trials == 0, 
% $$$       righthits = 0; 
% $$$     else 
% $$$       righthits = righthits/length(right_trials); 
% $$$     end;
   % left_trials = sum(sl(mn:n_done_trials));  
   % lefthits = sum(LeftRewards(mn:n_done_trials));  
  
    lrate = [lrate lefthits];
    %right_trials = length(find(tmp < 1));  
    %righthits = sum(RightRewards(mn:n_done_trials));  
      
    rrate = [rrate righthits1];
    bs1(k) = lefthits - righthits1;
    bs2(k) = lefthits - righthits2;
    % Interpretation
    % b < 0 --> righthits > lefthits; there is a right bias; increase
    % LEFT trials
    % b > 0 --> lefthits > righthits; increase RIGHT trials
  end;
  
  figure; 
  subplot(3,1,1);
  plot(1:length(lrate), lrate, '-b', 1:length(rrate), rrate, '-r');
  title('BIAS SIMULATOR');
  legend({'Left', 'Right'});
  xlabel('Trial window'); ylabel('Side-specific hit rates');
  
  subplot(3,1,2);
  plot(1:length(right_zero), right_zero, '-r', 1:length(right_notleft), ...
       right_notleft, '-b'); title('(R) Right zero, (L) Right = 15-Left');
      
%  subplot(3,1,3);
%  plot(1:length(right_zero), right_zero+left_ones, '-r', ...
%       1:length(right_notleft), right_notleft+left_ones, '-b');
%  set(gca,'YTick', [14 15 16], 'YLim', [12 17]);
  
  subplot(3,1,3);
  title('B value (1) -- zero, (2) -- 15-Left');
  xlabel('Trial window'); ylabel('b-value');
  plot(1:length(bs1), bs1, '-r', 1:length(bs2), bs2,'b');
   set(gca,'YLim', [-0.4 0.4]);
