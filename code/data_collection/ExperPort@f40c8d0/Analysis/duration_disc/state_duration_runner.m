function [] = state_duration_runner

ratset = {'Elrond','Isildur','Proudfoot','Gaffer','Balrog','Denethor','Galadriel'};

for r=1:length(ratset)
    state_duration_beforeafter(ratset{r},'action','load',...
        'statelist',{'wait_for_cpoke','wait_for_apoke'},...
        'use_dateset','given');
    saveps_figures('action','thesis');
    close all;
end;
    