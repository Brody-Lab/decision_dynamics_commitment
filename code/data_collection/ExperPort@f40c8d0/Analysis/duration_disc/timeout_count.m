function [tcount] = timeout_count(rat,task,date, varargin)

pairs = { ...
    'show_plot', 1 ; ...
    'flg__show_timeout_rate', 0 ; ...
    };
parse_knownargs(varargin,pairs);

  status = load_datafile(rat,date);
  if status ~=1, return; end;
  set_tlen = cell2mat(saved_history.TimesSection_TimeOutLength);
  evs = eval(['saved_history.' task '_LastTrialEvents;']);
  rts = eval(['saved_history.' task '_RealTimeStates;']); 
  if length(evs) == length(rts)-1, rts = rts(1:end-1); end;
  p = parse_trial(evs,rts);
  
  winsize = 15;
  
  tcount = []; tlen_norm = [];
  for k = 1:rows(p)
       tcount = [tcount rows(p{k}.timeout)];
       if rows(p{k}.timeout) > 0
       diff = p{k}.timeout(:,2) - p{k}.timeout(:,1);
                 tlen_norm = [tlen_norm sum(diff/set_tlen(k))];
       else
         tlen_norm = [tlen_norm 0];
       end;          
  end;
  
  trate = [];
  for k = winsize+1:rows(p)
      trate = [trate mean(tcount(k-winsize:k))];
  end;
 
  if show_plot > 0
  figure;
  set(gcf,'Name', 'Timeout Metrics','Menubar','none','Toolbar','none', ...
          'Position',[859 242 350 350]);
  subplot('Position',[0.3 0.4 0.4 0.4]);
  lbls = {};
  threshes = [0 1 2 3 4 10000];
  n=[];
  
  n = length(find(tcount == 0));
  lbls{1} = sprintf('%i (%i%%)',threshes(1), round((n(1)/length(tcount)) * 100)); 
  
%  [n x] = hist(tcount); 
   ctr = 1;
  for k = 2:length(threshes), 
      tmp = intersect(find(tcount > threshes(k-1)),find(tcount <= threshes(k)))
      if length(tmp) > 0
      n = horzcat(n, length(tmp));
          lbls{ctr+1} = sprintf('%i (%i%%)',threshes(k), round((n(ctr)/length(tcount)) * 100)); 
          ctr = ctr+1;
      end;
  end;
    
  maxidx = find(n == max(n)); xplode = zeros(size(n)); xplode(maxidx) =1;
  if sum(n) > 0
  p = pie(n,xplode,lbls);
  toppos = 0.5;% get(gcf,'Position'); toppos = (toppos(2) + toppos(4)) - (0.25 * toppos(4));
  for k = 2:2:length(p), 
      set(p(k-1), 'EdgeColor','none'); 
      set(p(k),'FontWeight','bold','FontSize',14,'Position',[-2 toppos 0]);
      toppos = toppos - 0.3;
      end;
  xlabel('Timeout #s');
  s = sprintf('%s: %s (%s)\nTO Count Distn.', make_title(rat), make_title(task), date);
t= title(s); set(t,'FontSize',14);
colormap jet;
  end;
  
%    subplot('Position',[0.7 0.3 0.3 0.3]);
%    [n x] =hist(tlen_norm);
%   pie(n, x);
%   xlabel('Effective timeout #');
%   s = sprintf('Norm. TO count');
% t=title(s);
% set(t,'FontSize',14);
  
%   subplot('Position', [0.1 0.07 0.8 0.2]);
%   plot(1:length(tlen_norm),tlen_norm,'.r');
%   ylabel('Effective timeout #'); xlabel('Trial#');
%   s = sprintf('%s: %s (%s)\nNormalized Timeout Count', make_title(rat), make_title(task), date);
% title(s);

 subplot('Position', [0.1 0.1 0.8 0.2]); 
 
if flg__show_timeout_rate > 0
 plot(winsize+1:length(tlen_norm),trate,'.b');
 maxie = max(2,max(trate));
 if maxie > 2, set(gca,'Color','y'); end;
 if isempty(maxie), maxie = 1; end;
 set(gca,'YLim', [0 maxie], 'XLim',[winsize+1 max(winsize+2,length(tlen_norm))],'YTick',0:1:maxie);
 hold on;
 line([winsize+1 length(tlen_norm)],[0.5 0.5],'LineStyle','-','Color', ...
      'g');
 ylabel(sprintf('Timeout rate (winsize=%i)',winsize)); xlabel('Trial#');
    s = sprintf('%s: %s (%s)\nTimeout Rate', make_title(rat), make_title(task), date);

else
    plot(tcount,'.b');
    if max(tcount) > 5, set(gca,'Color','y'); end;
    ylabel('numOccur TO');
    xlabel('Trial #');    
       s = sprintf('%s: %s (%s)\nTimeout count', make_title(rat), make_title(task), date);
       yl = get(gca,'YLim');
       text(length(tcount)*0.95, yl(2)*0.9, sprintf('%1.0f', mean(tcount)), 'FOntSize', 12,'FontWeight', 'bold');
      

  end;
  
title(s);
  end;