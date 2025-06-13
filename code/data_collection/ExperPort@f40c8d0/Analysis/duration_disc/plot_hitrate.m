function [usefig difffig] = plot_hitrate(ratlist, varargin)

pairs = { ...
    'usefig', NaN ; ...
    'first_few', 1000; ...
    'from', '000000'; ...
    'to', '999999'; ...
    'given_dateset', {} ; ...
    'use_dateset',''; ... % [psych_before | psych_after | given | '' | span_surgery]
    % which data to use? Filter settings ------------------------------------
    'first_few', 3; ... % use data only from first X sessions
    %(note: if 'use_dataset' = 'span_surgery', this becomes X+1 sessions, counting first X of post + the last pre session)
    'psych_only', 2 ; ... % 0 = use nonpsych trials only; 1=use psych trials only; 2 = use nonpsych and psych
    % what to plot?
    'figtitle','';...
    'seriescolour', [1 1 1]*0.7;...
    'lwidth',2;... % line width for plots
    'msize', 24;... % marker size for dot plot
    'fsize', 24; ... %font size for axes and axes labels
    'plot_means', 1 ; ...
    };
parse_knownargs(varargin,pairs);

if plot_means == 0,
    seriescolour = [0 0 0];
end;

hrate_cell = {}; % s-by-2 (col1:mean and col2:sem of hit rate) for rat (key) over specified sessions (s).
hrate_diffs = {}; % (s-1)-by-1, [mean_hh(s+1) - mean_hh(s)]
diff_matrix = []; % s-by-r;one column per rat - diffs concatenated across all rats

for r=1:length(ratlist)
    [hr last_few_pre]=hitrate_raw_xsessions_onerat(ratlist{r}, 'use_dateset', use_dateset,...
        'given_dateset',given_dateset,...
        'first_few', first_few,...
        'psych_only', psych_only);
    
    eval(['hrate_cell.' ratlist{r} '= hr;']);
    eval(['hrate_diffs.' ratlist{r} '= diff(hr(:,1));']);
    
    diff_matrix = horzcat(diff_matrix, eval(['hrate_diffs.' ratlist{r}]));
end;

%-- now plot ---- 
if isnan(usefig)
    usefig=figure;
else
    set(0,'CurrentFigure',usefig);    
end;

maxdays = 0;
for r=1:length(ratlist)
    hr =  eval(['hrate_cell.' ratlist{r} ';']); 
    l=plot(1:rows(hr),hr(:,1), '-k','LineWidth',lwidth); hold on;
    set(l,'Color',seriescolour);
    l=plot(1:rows(hr),hr(:,1), '.k'); 
    set(l,'Color',seriescolour,'MarkerSize',msize);
    
   % errorbar(1:rows(hr),hr(:,1), hr(:,2), hr(:,2), '.k');
   maxdays= max(maxdays, rows(hr));
   
   if strcmpi(use_dateset,'span_surgery')
       fday=last_few_pre+1;
       l=plot(fday, hr(fday,1), '.r');
       set(l,'MarkerSize',msize);
   end;
end;

xtk = 1:maxdays;
xlbl = xtk;
if ~isnan(last_few_pre)
    line([last_few_pre+0.5 last_few_pre+0.5], [0.5 1], 'Color','k', 'LineStyle',':','LineWidth',lwidth);
    xlbl = horzcat([-1 * last_few_pre:1:-1],[1:maxdays-last_few_pre]);
end;
    
line([0 maxdays+1], [0.75 0.75],'Color',[1 1 1]*0.7, 'LineStyle',':','LineWidth',lwidth);
set(gca,'YLim',[0.6 0.95], ...
    'YTick', 0.5:0.1:1, 'YTickLabel',50:10:100,...
    'FontWeight','bold','FontSize',fsize,...
    'XTick', xtk, 'XTickLabel', xlbl,'XLim',[0.5 maxdays+0.5]);
xl=xlabel('Day');
yl=ylabel('Session average(%)');
set(xl,'FontWeight','bold','FontSize',fsize);
set(yl,'FontWeight','bold','FontSize',fsize);

set(gcf,'Position',[62 429 1159 389]);
set(gca,'Position',[0.05 0.17 0.9 0.72]);

if length(figtitle)>0
    t=title(figtitle);
    set(t, 'FontWeight','bold','FontSize',fsize);
end;

% plot diffs -------------
difffig=figure;

patch([0 0 maxdays maxdays],[0 0.5 0.5 0],[0.8 1 0.8],'EdgeColor','none');
hold on;
patch([0 0 maxdays maxdays],[0 -0.5 -0.5 0],[1 0.8 0.8],'EdgeColor','none');


maxdays=0;
minhd = +1000;
maxhd = -1000;
for r=1:length(ratlist)
    hd =  eval(['hrate_diffs.' ratlist{r} ';']); 
    l=plot(hd, '-k','LineWidth',lwidth); hold on;
    set(l,'Color',seriescolour);
    l=plot(hd, '.k'); 
    set(l,'Color',seriescolour,'MarkerSize',msize);
    
   % errorbar(1:rows(hr),hr(:,1), hr(:,2), hr(:,2), '.k');
   maxdays= max(maxdays, rows(hr));
   minhd = min(minhd, min(hd));
   maxhd =max(maxhd,max(hd));
   
   if strcmpi(use_dateset,'span_surgery')
       fday=last_few_pre;
       l=plot(fday, hd(fday), '.r');
       set(l,'Color',[1 0.7 0.7]);
       set(l,'MarkerSize',msize);
   end;
end;

diff_matrix

if plot_means > 0
% now plot the average change in performance
diff_matrix = diff_matrix';

mean_diff = mean(diff_matrix);
sd_diff = std(diff_matrix);
l=plot(mean_diff,'-k'); set(l,'LineWidth',lwidth);
l=errorbar(1:length(mean_diff), mean_diff,sd_diff, sd_diff,'.k');
set(l,'MarkerSize',msize);
    
end;

xtk = 1:maxdays;
xlbl = xtk;
ylim = [-0.15 0.15];
if ~isnan(last_few_pre)
    line([last_few_pre-0.5 last_few_pre-0.5], ylim, 'Color','k', 'LineStyle',':','LineWidth',lwidth);
    xlbl = horzcat([((-1 * last_few_pre)+1):1:-1],[1:(maxdays+1)-last_few_pre]);
end;
line([0 maxdays+1], [0 0],'Color',[1 1 1]*0.7, 'LineStyle',':','LineWidth',lwidth);
text(0.6, ylim(2)*0.9, 'Improved','FontSize',18,'FontAngle','italic');
text(0.6, ylim(1)*0.9, 'Worsened','FontSize',18,'FontAngle','italic');

xl=xlabel('Day');
yl=ylabel('Session average(%)');
set(xl,'FontWeight','bold','FontSize',fsize*0.7);
set(yl,'FontWeight','bold','FontSize',fsize*0.7);

set(gca,'YLim',ylim, 'YTick',-0.3:0.1:0.3, 'YTickLabel',-30:10:30,...
      'FontWeight','bold','FontSize',fsize*0.7,...
    'XTick', xtk, 'XTickLabel', xlbl,'XLim',[0.5 maxdays-0.5]);
set(gcf,'Position',[  405   127   750   225]);
set(gca,'Position',[0.08 0.2 0.9 0.68]);

title(sprintf('%s: Change in performance relative to previous day', figtitle));
