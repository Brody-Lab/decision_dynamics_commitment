function [] = metric_beforeafter_runner

ratset = {'Elrond','Isildur','Proudfoot','Gaffer','Balrog','Denethor','Galadriel'};


for r=1:length(ratset)
    metric_beforeafter(ratset{r},'hitrate');
        metric_beforeafter(ratset{r},'numtrials');
    saveps_figures('action','thesis');
    close all;
end;
    