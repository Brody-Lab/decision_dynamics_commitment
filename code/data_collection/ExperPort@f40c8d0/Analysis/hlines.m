%hlines  [l] = hlines(Y, [x0=bottom], [x1=top])  Plot horiz lines
%
% Given a set of Y values (Y must be a vector), this routine plots
% a set of horizontal lines on the current axes. The default values
% of x0 (left of the lines) and x1 (right of the lines) are the
% left and right limits of the current axes.
%
% Returns line handles.
%

function [ll] = hlines(X, y0, y1)
   
   ax = axis;
   
   if nargin < 3, y1 = ax(2); end;
   if nargin < 2, y0 = ax(1); end;
   
   if size(X,2)==1, X = X'; end;
   
   l = line([y0 ; y1]*ones(1, length(X)), [X ; X]);
   set(l, 'Color', 'c');
   
   if nargout > 0, ll=l; end;