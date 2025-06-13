function [] = trial_duration(p)
% examines trial duration for given pstruct

td = [];
for k=2:rows(p)
    curr =p{k}.wait_for_cpoke;
    prev =p{k-1}.wait_for_cpoke;
    td = horzcat(td, curr(1,1) - prev(1,1));
end;

bins =[5 15 30 60 120 150];
figure; hist(td,bins);
title(sprintf('Distribution of trial durations'));
pctl_array = [25 50 75 99];
pct = percentile(td, pctl_array);
for k = 1:length(pctl_array)
    fprintf(1,'%ith percentile: %i seconds\n', pctl_array(k), round(pct(k)));
end;
set(gca,'XLim',[0 min(max(bins), pct(4))]);
