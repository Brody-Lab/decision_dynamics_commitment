function [] = plot_Pips_data

dateset = {'071031a','071102a','071116a'};
running_avg= 30;
datafields = {'tone_loc','go_loc'};

get_fields('Pips','use_dateset','range','from','071031','to','071116', 'datafields', datafields);

figure;
subplot(2,1,1);
l=plot(tone_loc,'-b'); 
set(l,'LineWidth', 2); hold on;
l=plot(go_loc,'-.g'); set(l,'LineWidth',2, 'Color', [0 0.6 0]);
set(gca,'YLim',[-1 2],'YTick',[0 1],'YTickLabel',{'off','on'});
ylabel('Localization');
xlabel('Trial #');

title('Pips - progress through training session');


hh = hit_history;
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

subplot(2,1,2);
plot(num, '.-'); nums = [nums ; {num}]; hold on;
cumtrials = cumsum(numtrials);
for i=2:length(numtrials)
    line([cumtrials(i-1) cumtrials(i-1)], [0 1.5], 'LineStyle','-','Color','k');
end;

set(gca,'YLim',[0 1], 'YTick',0:0.2:1, 'YTickLabel', 0:20:100);

ylabel('Hit rate');
xlabel('Trial #');
