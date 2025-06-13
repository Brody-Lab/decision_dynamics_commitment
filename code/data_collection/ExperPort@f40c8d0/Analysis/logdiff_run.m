function [] = logdiff_run()

rats = {'Queen','Bilbo','Executioner','Lory','Gandalf'};

for r = 1:length(rats)
    logdiff_hitrate(rats{r});
end;