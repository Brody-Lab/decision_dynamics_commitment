function [] = autostring_chk(rat, task, date)
  
  load_datafile(rat, task, date);
  
  hh = eval(['saved.' task '_hit_history']);
  hh = hh(~isnan(hh));
  logdiff = 1.8;
  session_length = 200;
  win = 30;
  
  last_change = 0;
  stay_here = 0;
  sl = saved.SidesSection_side_list;
  LeftRewards = saved.RewardsSection_LeftRewards;
  RightRewards = saved.RewardsSection_RightRewards;
  
  last_change = 0;
  staylist = zeros(size(hh));
  lastchangelist = zeros(size(hh));
  blist = zeros(size(hh));
  last30list = zeros(size(hh));
  ldlist = zeros(size(hh));
  
  % simulate trial by trial
  fprintf(1, '%i trials', length(hh));
  for t = 1:length(hh)
      m = max(t-win, 1);
      hrate30 = mean(hh(m:t)); 
      
      mn = max(1, t - 15);        
      fprintf(1, 'Indexing sides from %i to %i\n', mn, t);       
      left_trials = sum(sl(mn:t));        
      lefthits = sum(LeftRewards(mn:t));         
      if left_trials == 0, lefthits=0;        
      else lefthits = lefthits/left_trials;         
      end;        
      tmp = sl(mn:t);        
      right_trials = length(find(tmp < 1));         
      righthits = sum(RightRewards(mn:t));         
      if right_trials == 0,            
        righthits = 0;        
      else             
        righthits = righthits/right_trials;         
      end;         
      b = lefthits - righthits;         
      
                   
% autostring starts evaluating here      
if stay_here < 1 & last_change > 20 & hrate30 > 0.85 & (b > -0.2 & b < 0.2),        
    stay_here = 1;                                          
    last_change = 0;                                        
elseif stay_here > 0 & last_change > 15 & hrate30 > 0.85 & (b > -0.2 & b < 0.2),    
    logdiff = logdiff -0.4;                                           
    last_change = 0;                                        
    stay_here = 0;                                          
elseif hrate30 < 0.65 & last_change > 20,                                           
    logdiff = min(3.8, logdiff+0.4);
    last_change = 0;                                        
    stay_here = 0;                                          
elseif (b < -0.2 | b > 0.2)                                                         
  stay_here = 0;                                            
else                                                                                
    last_change = last_change + 1; 
end;                                                                            
           
blist(t) = b;
staylist(t) = stay_here;
lastchangelist(t) = last_change;
last30list(t) = hrate30;
ldlist(t) = logdiff;
  end; 
  
  
  
  % Now plot the simulated values
  
  nump = 4;
  figure;
  subplot(4,1,1);
  plot(1:length(ldlist), ldlist, '.b');
 % set(gca,'YLim', [-1 2]);
 set(gca, 'YLim', [1 2]); 
 
  subplot(4,1,2);
  plot(1:length(blist), blist, '.b');
  hold on;
  line([1 length(blist)], [-0.2 -0.2], 'LineStyle', ':', 'Color','r');
 line([1 length(blist)], [0.2 0.2], 'LineStyle', ':', 'Color','r');
 set(gca,'YLim',[-0.25 0.25]);
 
 subplot(4,1,3);
  plot(1:length(lastchangelist), lastchangelist, '.b');
  hold on;
  
  subplot(4,1,4);
  plot(1:length(last30list), last30list, '-k');
  set(gca,'YLim', [0.7 1]);
  line([1 length(last30list)], [0.85 0.85], 'LineStyle', ':', 'Color','r');
 
 
 
  