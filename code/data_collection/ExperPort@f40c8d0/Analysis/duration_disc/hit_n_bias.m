function [hrate] = hit_n_bias(rat, task, varargin)
  
  pairs =  { ...
      'from', '000000'; ...
      'to', '999999'; };
  parse_knownargs(varargin, pairs);
  
  dates = get_files(rat, 'fromdate', from, 'todate', to);
 
  bs = []; hrate = [];
  for d = 1:rows(dates)
  load_datafile(rat, task, dates{d});
  
  l = sum(saved.RewardsSection_LeftRewards); 
  r = sum(saved.RewardsSection_RightRewards);
  b = (l-r)/(l+r); bs = [bs b];
  numtrial = eval(['saved.' task '_n_done_trials']);
  hrate = [ hrate (l+r)/numtrial ];
  
  end;
  
  figure;
  set(gcf,'Menubar','none', 'Toolbar','none');
  s = sprintf('%s: Bias (%s to %s)', rat, from, to);
  subplot(2,1,1);
  plot(1:length(bs), bs, '.b');
  mb = mean(bs);
  hold on; line([1 length(bs)], [mb mb], 'Color','r');
  title(s);
  xlabel('Session #');
  ylabel('Left rate - Right rate');
  
  subplot(2,1,2);
  s = sprintf('%s: Hit Rate (%s to %s)', rat, from, to);
  plot(1:length(hrate), hrate, '.r');
  mh = mean(hrate);
  hold on; line([1 length(hrate)], [mh mh], 'Color','b');
  title(s);
  xlabel('Session #');
  ylabel('Session hit rate');
  