function [thresh bestperf] = cueonset2go_perf(s1,s2, a, b, varargin)
% This analysis is done for duration_disc
% It computes the best performance a rat can achieve by timing from the
% onset of the tone to the onset of the GO signal
% (includes the long or short cue, the pre-GO silent period and onset of
% GO signal)
% Note: This period follows a uniform distribution because the pre-GO
% silent period is uniform.
%
% Returns:
% 1- poke duration threshold at which best performance occurs
% 2- best hit rate solely by poke duration
  
  pairs = { ...
      'other_a', a ; ...   % uniform distribution MIN for long tones
      'other_b', b ; ...   % un dist MAX for long tones
      };
  parse_knownargs(varargin, pairs);

 
  short_min = s1 + a;
  short_max = s1 + b;
  
  long_min = s2 + other_a;
  long_max = s2 + other_b;
  
 
  pr_short_correct = [];
  pr_long_correct = [];
 threshrange = short_min: 0.1: long_max;
 for thresh = threshrange
    pshort = cdf_uni(short_min, short_max, thresh);
    plong = 1 - cdf_uni(long_min, long_max, thresh);
    
    pr_short_correct = [pr_short_correct pshort];
    pr_long_correct = [pr_long_correct plong];
    
 end;
 
  both_tog = pr_short_correct + pr_long_correct;
 maxidx = find(both_tog == max(both_tog));
 
 thresh = threshrange(maxidx(1));
 both_tog = both_tog(maxidx(1));
 
 bestperf = both_tog / 2;
 
 
 if 1 
 % Figure 1 - probs of getting trials correct
 figure;
% set(gcf,'Menubar','none','Toolbar','none');
 
   subplot(2,1,1);
 plot(threshrange, pr_short_correct,'-b', threshrange, pr_long_correct, ...
      '-g');
 hold on;
 plot(threshrange, pr_short_correct,'.b', threshrange, pr_long_correct, ...
      '.g');
 line([min(threshrange) max(threshrange)], [0.8 0.8], 'Color','r', 'LineStyle',':');
 title(sprintf(['Probability of accuracy based solely on \n timing cue ' ...
                'onset to GO signal']));
 xlabel('Poke duration threshold (seconds)');
 ylabel('Probability of trials correct');
 legend({'Short','Long'});
 
 set(gca,'YLim', [0 1.2]);
 
 % Figure 2 - Graphically shows overlap and duration which maximises sum
 % of both types of trials
 subplot(2,1,2);
 line([short_min short_max],[1 1], 'Color','b','LineWidth',4);
 hold on;
 line([long_min long_max], [2 2], 'Color','g','LineWidth',4);
 set(gca,'XLim', [short_min-0.2 long_max+0.2], ...
         'YTickLabel',{},'YTick',[], 'YLim', [0 3], ...
         'XTick', short_min:0.2:long_max);
%  for k = 1:length(maxidx)
%  line([threshrange(maxidx(k)) threshrange(maxidx(k))], [0 3],'Color','r');
% end;
 xlabel('Time since cue onset (seconds)');
 
 
 
 end;
 
 
 
 % Returns P(c < U[a,b])
function [prob] = cdf_uni(a,b,c)
  
  prob =0;
  if c < a, prob= 0;
  elseif c > b, prob = 1;
  else prob = (c-a)/(b-a);
  end;
  
  
  