function varargout = errorshade(X,Y,SE,LineColor,varargin)
%
%   ERRORSHADE     Shaded error bar plot
%
%    p = errorshade(X,Y,STD,LineColor,{LineWidth},{ShadeColor})
%
%   Plots Y against X in LineColor. A shaded error bar is added
%   between Y-STD and Y+STD. 
%
%   Optional arguments LineWidth and ShadeColor default to 2 and grey.
%   LineColor defaults to blue, you can use shortend styles as well ('r:').
%   Output returns the handles for the line and the shaded error bar.
%
%   AK 6/2004


lw = 2;
ShadeColor = [0.6 0.6 0.6];
if nargin > 4
    lw = varargin{1};
end
if nargin > 5
    ShadeColor = varargin{2};
end
if nargin < 4
    LineColor = 'b';
end

if (min(size(SE)) > 1) 
   E = SE;    
else
   E(1,:) = Y - SE;
   E(2,:) = Y + SE;
end 
hold on;
p1=patch([X X(end:-1:1)],[E(1,:) E(2,end:-1:1)],ShadeColor);
set(p1,'EdgeColor',ShadeColor,'FaceColor',ShadeColor);

if length(LineColor)>1 && ~isnumeric(LineColor)
    p2=plot(X,Y,'Color',LineColor(1),'LineWidth',lw);
    set(p2,'linestyle',LineColor(2:end))
else
    p2=plot(X,Y,'Color',LineColor,'LineWidth',lw);
end

if nargout == 1 
    varargout{1} = [p1 p2];
end