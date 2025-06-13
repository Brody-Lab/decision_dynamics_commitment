function [] = plotpairs(g1, g2)
% plots two pairs of data (usually before/after), one for each group.
% g1 and g2 are structs with data for each group
% each struct should have the following fields:
% g1.xtklbl - the group name
% g1.names - names of individual points (optional) - s-by-1 cell
% g1.dat - data to plot on column (s-by-2 array, one row per name)
% g1.clr - colour to plot data with.

figure;
sub__plotgrp(g1);
hold on;
sub__plotgrp(g2);

set(gca,'XLim',[0.5 2.5]);
set(gca,'XTick',1:2, 'XTickLabel',{g1.xtklbl, g2.xtklbl});
set(gcf,'Position',[440   289   301   445]);


function [] = sub__plotgrp(g)
msize=20;
dat=g.dat;
flist=g.names;

for k=1:length(flist)
    plot([1 2], dat(k,:), '.b', 'Color',g.clr,'MarkerSize',msize); hold on;
    plot([1 2], dat(k,:), '-b', 'Color',g.clr,'MarkerSize',msize);
end;