function [] = blondes()

lbrun = [50 42 41 37];
dbrun = [51 39 35 32 30];
lblond= [71 62 60 55 48];
dblond=[63 57 52 43 41];

brun = [lbrun dbrun];
blond = [lblond dblond];

figure; 
boxplot(brun);
xlabel('Brunettes');
set(gca,'YLim',[20 85]);
figure;
boxplot(blond);
xlabel('Blondes');
set(gca,'YLim',[20 85]);