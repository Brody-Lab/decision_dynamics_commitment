function [] = Tmax_script()

% Drug P - fed
drugp_fed = [809.44 428 757.71 906.83 712.24 561.77 511.84 756.6];
drugp_fasted = [967.82 746.45 901.11 1146.96 678.16 745.51 568.98 852.86];

metab_fed = [ 1965.17 3149.18 2448.69 3968.34 3249.45 2136.47 3694.8 1517.1;];
metab_fasted = [2622.35 3618.6 2545.05 3500.83 3362.4 2625.75 4117.14 2386.19];


% CIs on Tmax Fed/Fasted
drugp_ci90 = [1.34 4.55];
drugp_ci95 = [0.95 4.94];

met_ci90 = [1.26 2.36];
met_ci95 = [1.13 2.5];



drugp_fedtofasted = [1.15 4.80 0.67 4.5 1.8 7.5 1.67 1.5];
met_fedtofasted = [1.68 3 0.6 2.86 1.67 2 1 1.71];

figure;
plot(ones(size(drugp_fedtofasted)), drugp_fedtofasted, 'o'); hold on;
%line([0.8 1.2], [mean(drugp_fedtofasted) mean(drugp_fedtofasted)], 'LineWidth',2);
plot(ones(size(drugp_fedtofasted)) .* 2, met_fedtofasted, 'o'); 
%line([1.8 2.2], [mean(met_fedtofasted) mean(met_fedtofasted)], 'LineWidth',2);
set(gca,'XLim',[0 3],'YTick',[0 0.5 1 2 4 8],'YLim', [0 8.5],'XTick',[1 2], 'XTickLabel', {'Drug P', 'Metabolite M'});
ylabel('Fed / Fasted');
title('Tmax for Fed/Fasted');


% now draw ci bars - 95%
pmean = mean(drugp_fedtofasted);
plot(1.4,  mean(drugp_fedtofasted), '.g');
l=errorbar(1.4, mean(drugp_fedtofasted), mean(drugp_fedtofasted)-drugp_ci95(1), drugp_ci95(2)-mean(drugp_fedtofasted));
set(l,'Color','g');

metmean = mean(met_fedtofasted);
plot(2.4, metmean, '.g');
l=errorbar(2.4, metmean, metmean-met_ci95(1), met_ci95(2)-metmean);
set(l,'Color','g');


% now draw ci bars - 90%
pmean = mean(drugp_fedtofasted);
plot(1.2,  mean(drugp_fedtofasted), '.r');
l=errorbar(1.2, mean(drugp_fedtofasted), mean(drugp_fedtofasted)-drugp_ci90(1), drugp_ci90(2)-mean(drugp_fedtofasted));
set(l,'Color','r');

metmean = mean(met_fedtofasted);
plot(2.2,  metmean, '.r');
l=errorbar(2.2, metmean, metmean-met_ci90(1), met_ci90(2)-metmean);
set(l,'Color','r');

% bells and whistles
% line([0 3], [0.8 0.8],'Color','r','LineStyle',':');
line([0 3], [1 1], 'Color','r','LineStyle',':');
text(0.2, 1.01, 'Fed same as fasted', 'FontAngle','italic','FontSize',12);