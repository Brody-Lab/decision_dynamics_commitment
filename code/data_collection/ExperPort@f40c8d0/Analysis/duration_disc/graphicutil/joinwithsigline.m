function [] = joinwithsigline(ax,x1,x2,y1,y2,ytop)
% plots inverted 'U' line between two groups with significant differences
% U-stem goes from (x1,y) up to (x1,ytop), over to (x2,ytop) and down to
% (x2,y)

set(gcf,'CurrentAxes',ax);
lw=2;
clr='k';
line([x1 x1],[y1 ytop],'Color','k','LineWidth',lw);
line([x1 x2],[ytop ytop],'Color','k','LineWidth',lw);
line([x2 x2],[ytop y2],'Color','k','LineWidth',lw);
