function [] = timewatch(varargin)
% plots duration of a training session for all current rats for the last
% week

pairs = { ...
    'from', -7 ; ...
    'to', 0 };
parse_knownargs(varargin,pairs);

fd = from;
td = to;
ratlist = rat_task_table('','get_current',1);

from = getdate(from); from = from(1:end-1);
to = getdate(to); to = to(1:end-1);

ht = 150;
wt = 400;
sz = get(0,'ScreenSize');
x = 10; y =900;
durations = {}; % one row per rat. Col1: ratname, Col2: session duration array
for k = 1:length(ratlist)
    [d t]= sessiontime(ratlist{k,1},from,to,'plotme',0);
    durations{end+1,1} = ratlist{k,1};
    durations{end,2} = d;
    durations{end,3} =  (d./t) * 3600;
    fprintf(1,'.');
end;

unit_ht = 50;
figure;
set(gcf,'Position',[10 10 400 length(ratlist)*unit_ht],'Menubar','none','Toolbar','none');
plotter(gcf,durations, 2,1.5,2,10);
title('Session duration for past one week');
set(gca,'YTick',[],'XLim',[1 abs(fd-td)+2.5],'Xtick',[]);

figure;
set(gcf,'Position',[450 10 400 length(ratlist)*unit_ht],'Menubar','none','Toolbar','none');
plotter(gcf,durations,3,30,60,60);
title('Average trial length for past one week');
set(gca,'YTick',[],'XLim',[1 abs(fd-td)+2.5],'XTick',[]);


function [ylbl] = hour2str(yrange)
ylbl = {};
for k = 1:length(yrange)
    frac = round(mod((yrange(k) * 100),100)/100 * 60);
    if mod(frac,10) > 8, frac = frac+1; end;
    if frac == 59, frac = 00;
    elseif frac > 30, yrange(k) = yrange(k)-1; end;
    ylbl{end+1} = sprintf('%i:%i', round(yrange(k)), frac);
end;


% plot pseudo-sparkline of column (colidx) of the duration cell array
% (d_cell), stacking data for each rat
% mark points above "threshold" in red.
% mark "mid_thresh" < points < "threshold" in orange
% stack using a spacing of y_offset between rats
% plot all this on figure with handle f
function [] = plotter(f,d_cell, colidx, mid_thresh,threshold,y_offset)
set(0,'CurrentFigure',f);
for k = 1:rows(d_cell)
    d = d_cell{k,colidx}; 
    idx = find(d > threshold);
    idx2 = intersect(find(d >mid_thresh), find(d<=threshold));
    d = d+(y_offset*(k-1));
    plot(1:length(d),d,'-b');
    hold on;
    plot(1:length(d),d,'.b');
    
    l=plot(idx, d(idx),'.r');    
    set(l,'Color',[0.7 0 0]);
    
    l=plot(idx2,d(idx2),'.r');
    set(l,'Color',[1 0.3 0]);
    y = 1; if length(d) > 0, y = max(d)+1; end;
    text(length(d)+1,y,d_cell{k,1});
end;    