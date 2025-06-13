% [ll] = vlines(x, [y0], [y1])
%
% Given a vector x of x-positions, puts vertical lines at each of those
% positions on the current axis. Default is to go from current bottom of
% axes to current top. Optional parameter y0 specifies a bottom; optional
% parameter y1 specifies a top.
%
% vlines(ax, ... )  when ax is an axes handle is the same but puts the
% lines on axes ax.
%
% Returns ll = handles of drawn lines
%
%
% written by Carlos Brody so long ago he can't remember. Updated by CDB Oct 07
function [ll] = vlines(varargin)
if numel(varargin{1})==1  &&  ishandle(varargin{1}) &&  strcmp(get(varargin{1}, 'Type'), 'axes')==1,
    ax = varargin{1}; varargin = varargin(2:end);
else
    ax = gca;
end;
x = varargin{1};
yls = get(ax, 'Ylim');
if length(varargin) < 3, y1 = yls(2); else y1 = varargin{3}; end;
if length(varargin) < 2, y0 = yls(1); else y0 = varargin{2}; end;
if numel(x) ~= length(x),
    error('Need x to be a vector');
end;
if size(x,1) > size(x,2), x = x'; end;
l = line([x ; x], [y0*ones(size(x)) ; y1*ones(size(x))], 'Parent', ax);
if nargout > 0, ll = l; end;
