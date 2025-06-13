function [] = plot_logdiff_perf_multiday(rat, task, dates)


% megaX = [];
% megaY = [];
% for k = 1:5
%     megaX = [megaX ((k-1)*length(x))+1: k*length(x)];
%     megaY = [megaY x-(k-1)];    
% end;
% 
% plot(megaX, megaY);
% for k = 1:4
%     line([k*length(x) k*length(x)], [-3 5], 'LineStyle',':', 'Color', 'k')
% end;

len = rows(dates);
if len > 5,
    error('Sorry, can handle atmost 5 dates at a time');
end;

figure;
pos = get(0,'ScreenSize');
set(gcf, 'Position', [100 100 pos(3)*0.8 pos(3)*0.4], 'Menubar', 'none', 'Toolbar', 'none');

plot_w = (1/len)-(1/(len*8));
for k = 1:rows(dates)
    axes('Position', [(k-1)*(1/len) 0.05  (1/len)-0.01 0.85]);
    plot_logdiff_perf(rat, task, dates{k}, 'multiday', 1);
    set(gca, 'YTick', [], 'XTick', [], 'Box', 'off');
    if k > 1, xlabel(''); ylabel(''); end;
end;

