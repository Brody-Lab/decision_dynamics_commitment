function [t] = plotstar(ax,x,y,varargin)
% plots significance asterix on axes handle "ax" at (x,y).
% if varargin{1}='ns', puts 'n.s.' on that spot instead.

if length(varargin)>0
    b=varargin{1};
    if strcmpi(b,'ns')
        t=text(x*0.93,y, 'n.s.','Color','k','FontWeight','normal','FontSize',24);
        return;
    else
        error('invalid arg');
    end;
end;

fsize=28;
set(gcf,'CurrentAxes',ax);
t=text(x*0.99,y, '*','Color','r','FontWeight','bold','FontSize',fsize);
