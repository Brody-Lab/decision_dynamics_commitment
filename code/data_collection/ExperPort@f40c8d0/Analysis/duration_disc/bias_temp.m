sl = value(side_list);
if n_done_trials > 0,
 if value(onesidemode) > 0,
   fprintf(1,'onesidemode ON: opp_hit_ctr = %i\n', value(opp_hit_ctr));
  mn = max(1, n_done_trials - min(value(last_change), 5));
  if value(LeftProb) > 0, opprew = LeftRewards; else opprew = RightRewards; end;
  opp_hit_ctr.value = sum(opprew(mn:n_done_trials));   
  if opp_hit_ctr > 4,
    onesidemode.value = 0;
    last_change.value = 0;
    LeftProb.value = 0.5;
    MaxSame.value = 3;
  else
    last_change.value = value(last_change) + 1;
  end;
 else
  mn = max(1, n_done_trials - 15);
  fprintf(1, 'Indexing sides from %i to %i\n', mn, n_done_trials);
 left_trials = sum(sl(mn:n_done_trials));
 lefthits = sum(LeftRewards(mn:n_done_trials));
 if left_trials == 0, lefthits=0; else lefthits = lefthits/left_trials; end;
 tmp = sl(mn:n_done_trials); right_trials = length(find(tmp==0));
 righthits = sum(RightRewards(mn:n_done_trials));
 if right_trials == 0, righthits = 0; else righthits = righthits/right_trials; end;
              
 b = lefthits - righthits;
 fprintf(1,'b is: %2.1f, last_change is %i\n', b, value(last_change));
   
 if (b > 0.7 | b < -0.7) & value(last_change) > 3,
   onesidemode.value = 1;
   opp_hit_ctr.value = 0;
   last_change.value = 0;
   if b > 0.7, LeftProb.value = 0; else LeftProb.value = 1; end; 
    MaxSame.value = 'Inf';
 elseif b > 0.25 & value(last_change) > 3,
   plus_cbk(LeftProb, -0.1);
   last_change.value = 0;
 elseif b < 0.25 & value(last_change) > 3,
   plus_cbk(LeftProb, +0.1);
   last_change.value = 0;
 elseif value(last_change) > 5,
   LeftProb.value = 0.5;
   last_change.value = 0;
 else
   last_change.value = value(last_change) + 1;
 end;
 end;
end;
  