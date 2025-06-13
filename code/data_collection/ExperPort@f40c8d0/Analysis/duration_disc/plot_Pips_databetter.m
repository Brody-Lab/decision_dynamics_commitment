function [] = plot_Pips_data

ratname = 'Pips';

ratrow = rat_task_table(ratname);
task = ratrow{1,2};
if strcmpi(task(1:3), 'dur'), psychf='psych_flag'; else psychf='pitch_psych'; end;
dateset = {'071031a','071102a','071116a'};
datafields = {'tone_loc','go_loc'};%'logdiff',psychf};

fromdate ='071031';
todate = '071116';
get_fields(ratname, 'use_dateset','range','from',fromdate,'to',todate, 'datafields', datafields);
%if strcmpi(task(1:3), 'dur'), psychf=psych_flag; else psychf=pitch_psych; end;


figure;
subplot(2,1,1);
l=plot(tone_loc,'-b'); 
set(l,'LineWidth', 2); hold on;
l=plot(go_loc,'-.g'); set(l,'LineWidth',2, 'Color', [0 0.6 0]);
set(gca,'YLim',[-1 2],'YTick',[0 1],'YTickLabel',{'off','on'});
set(gca,'XLim',[1 sum(numtrials)]);
ylabel('Localization');
xlabel('Trial #');

title(sprintf('%s - progress through training %s to %s', ratname, fromdate, todate));

hh = hit_history;
subplot(2,1,2);
plot_hh(hh,numtrials,dates);
set(gca,'YLim',[0.5 1], 'YTick',0.5:0.05:1, 'YTickLabel', 50:5:100);
set(gca,'XLim',[1 sum(numtrials)]);

ylabel('Hit rate');
xlabel('Trial #');

% subplot(2,1,3);
% plot(logdiff);
% ylabel('Logdiff');
% set(gca,'XLim',[1 sum(numtrials)],'YLim',[0.4 1.2]);
% % 
% subplot(2,1,4); plot(psychf); ylabel('Psych on');
% set(gca,'YLim',[-1 2]);


function [] = plot_hh(hh,numtrials,dates)
running_avg = 30;

x = 1:length(hh);

nums=[];
  t = (1:length(hh))';
            a = zeros(size(t));
for i=1:length(hh),
    x = 1:i;
    kernel = exp(-(i-t(1:i))/running_avg);
    kernel = kernel(1:i) / sum(kernel(1:i));

    a(i) = sum(hh(x)' .*kernel);
end;
num = a;

plot(num, '.-'); nums = [nums ; {num}]; hold on;
cumtrials = cumsum(numtrials);
for i=2:length(numtrials)
    line([cumtrials(i-1) cumtrials(i-1)], [0 1.5], 'LineStyle','-','Color','k','LineWidth',2);
    text(cumtrials(i-1), 0.95, dates{i});
end;
line([0 cumtrials(end)], [0.8 0.8],'LineStyle',':','Color','r');
