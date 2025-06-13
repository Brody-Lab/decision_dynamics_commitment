function [] = plot2groupdots(g1, g2)
% plots two columns of data, one for g1 and other for g2.
% g1 and g2 are structs with data for each group
% each struct should have the following fields:
% g1.xtklbl - the group name
% g1.names - names of individual points (optional)
% g1.dat - data to plot on column
% g1.clr - colour to plot data with.

xt={};

figure;
if isempty(g1.dat)
    warning('g1 is empty');
else
    sub__plotgrp(g1,1);
    xt = g1.xtklbl; 
hold on;
end;

if isempty(g2.dat)
    warning('g2 is empty');
else
    sub__plotgrp(g2,2);
    xt = horzcat(xt, g2.xtklbl);
end;


set(gca,'XLim',[0.5 2.5]);
set(gca,'XTick',1:2, 'XTickLabel',xt);
set(gcf,'Position',[440   289   301   445]);


function [] = sub__plotgrp(g,xpos)

msize=20;
dat=g.dat;
plot(ones(length(dat))*xpos, dat, '.b', 'Color',g.clr,'MarkerSize',msize);

% optional: put names of individual by the dots
if isfield(g,'names')
    flist=g.names;
    for k=1:length(flist)
        text(xpos+0.2, dat(k), flist{k},'FontWeight','bold','FontSize',14);
    end;
end;