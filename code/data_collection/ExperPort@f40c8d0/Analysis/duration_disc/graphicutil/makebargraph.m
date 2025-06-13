function [g1x g2x] = makebargraph(g1, g2,varargin)
% draws a stack of two bars on a new axis.
% bar represents mean of data with error bars of sem.
% g1 is coloured blue; g2, red.
% if third input arg is given , this should be an axis on which bar is to
% be drawn.

pairs = { ...
    'ax', 0 ; ...
    'ylbl', 'metric'; ...
    'figtitle', 'Average metric g1/g2 surgery' ; ...
    'g1_clr', 'b' ; ...
    'g2_clr' ,'r' ; ...
    'g1_lbl', 'g1' ; ...
    'g2_lbl', 'g2' ; ...
    'color_errbar', [1 1 1]*0.3; ...
    'errtype', 'sem' ; ... % [std|sem|iqr]
    'what2show', 'mean' ; ... % or median
    };
parse_knownargs(varargin, pairs);

if ax == 0
    figure;
else
    set(gcf,'CurrentAxes',ax);
end;

switch what2show
    case 'mean'
m1 = mean(g1);
m2 = mean(g2);
    case 'median'
        m1=median(g1);
        m2=median(g2);
    otherwise
        error('value should be mean or median');
end;

switch errtype
    case 'std'
        s1=std(g1);
        s2=std(g2);
    case 'sem'
        s1=std(g1)/sqrt(length(g1));
        s2=std(g2)/sqrt(length(g2));
    case 'iqr'
        s1=iqr(g1);
        s2=iqr(g2);
    otherwise
        error('value should be std,sem or iqr');
end;

m=m1;s = s1;
g1x=0.5;
patch([0 0 1 1], [0 m m 0],g1_clr,'EdgeColor','none');
hold on;
line([0.5 0.5], [m-s m+s],'Color',color_errbar);

m=m2; s = s2;
g2x=1.5;
patch([1 1 2 2], [0 m m 0],g2_clr,'EdgeColor','none');
line([1.5 1.5], [m-s m+s],'Color', color_errbar);

set(gca, 'XLim',[-1 3], 'XTick', [0.5 1.5], 'XTickLabel',{g1_lbl, g2_lbl});
ylabel(ylbl);
title(figtitle);





