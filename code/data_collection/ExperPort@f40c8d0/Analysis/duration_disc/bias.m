function [b] = bias(rat, task, date)
  
  load_datafile(rat, task, date);
  side_list = saved.SidesSection_side_list;
  LeftRewards = saved.RewardsSection_LeftRewards;
  RightRewards = saved.RewardsSection_RightRewards;
% calculate side-specific hits/misses
  n_done_trials = 190;
 
  % needs access to LeftRewards, RightRewards, 
  
 trials = value(n_done_trials);
 
 if value(onesidemode) > 0
  mn = min(1, trials - min(value(last_change), 5));
  if value(LeftProb) > 0, opprew = LeftRewards; else opprew = RightRewards; end;
  opp_hit_ctr.value = sum(opprew(mn:trials));   
  if opp_hit_ctr > 4
    onesidemode.value = 0;
    last_change.value = 0;
    LeftProb.value = 0.5;
    MaxSame.value = 3;
  else
    last_change.value = value(last_change) + 1;
  end;
 else
  mn = min(1, trials - 15);
 left_trials = sum(side_list(mn:trials));
 lefthits = sum(LeftRewards(mn:trials));
 if left_trials == 0, lefthits=0; else lefthits = lefthits/left_trials; end;
 tmp = side_list(mn:trials); right_trials = length(find(tmp==0));
 righthits = sum(RightRewards(mn:trials));
 if right_trials == 0, righthits = 0; else righthits = righthits/right_trials; end;
              
 b = lefthits - righthits;  
   
 if (b > 0.7 | b < -0.7) & value(last_change) > 10,
   onesidemode.value = 1;
   opp_hit_ctr.value = 0;
   last_change.value = 0;
   if b > 0.7, LeftProb.value = 0; else LeftProb.value = 1; end; 
    MaxSame.value = 'Inf';
 elseif b > 0.25 & value(last_change) > 10,
   plus_cbk(LeftProb, -0.1);
   last_change.value = 0;
 elseif b < 0.25 & value(last_change) > 10,
   plus_cbk(LeftProb, +0.1);
   last_change.value = 0;
 elseif value(last_change) > 10,
   LeftProb.value = 0.5;
   last_change.value = 0;
 else
   last_change.value = value(last_change) + 1;
 end;
 end;
 