function [h he] = basicbar(data, varargin)
% draws one bar along with its error bar

pairs = { ...
    'errortype','sem' ; ...
    'bcolor', 'b'; ...
    'xpos', 0 ; ... 
    'barwidth', 1 ; ... % 1 unit on axis
    };
parse_knownargs(varargin,pairs);

m=mean(data);
h=patch([xpos xpos xpos+barwidth xpos+barwidth] ,...
    [0 m m 0], ...
    bcolor, 'EdgeColor','none');
hold on;

s = std(data);
if strcmpi(errortype,'sem')
    s= s/sqrt(length(data));
end;
he=line([ xpos+(barwidth/2) xpos+(barwidth/2) ], [m-s m+s], 'Color','k','LineWidth',2);
