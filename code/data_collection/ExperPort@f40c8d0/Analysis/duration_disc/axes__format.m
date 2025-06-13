function [] = axes__format(ahandle,varargin)
% makes fonts on the axis bigger and bold

if nargin > 1,
    fsize = varargin{1};
else
    fsize = 18;
end;

toformat = {'Title','XLabel', 'YLabel'};
for k = 1:length(toformat)
t = get(ahandle, toformat{k});
if ~isempty(t)
    set(t,'FontWeight','bold','FontSize', fsize);
end;
end;

set(ahandle, 'FontSize', fsize, 'FontWeight','bold','Box','off');