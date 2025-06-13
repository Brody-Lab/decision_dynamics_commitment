function [h xupp xlow xmin xmaj] = ellipse(x,y,major,minor,theta,props)
	
%
% [h xupp xlow xmin xmaj] = ellipse(x,y,major,minor,rotation,properties)
%
% Plots an ellipse with inputed stats.
%
% INPUTS:
% ------
% x
%   x position of center of ellipse
% y
%   y position of center of ellipse
% major
%   size of major axis
% minor
%   size of minor axis  
% theta
%   rotation of major axis counterclockwise from x axis in degrees
% props (OPTIONAL)
%   line properties
%   - props.clr       = color (0.3*[1 1 1])
%   - props.lw        = linewidth (2)
%   - props.lwax      = linewdith for axis lines (1)
%   - props.isAxlines = toggle interior axis lines (true)
%   - props.nsamples  = number of points used in ellipse (100)
%   - props.h         = replaces data on set of ellipse axes rather than generating from de novo
%   - props.isdir     = puts a dot at the "head" of the ellipse (false)
%   - props.marksize  = size of the dot for the head
%
% OUTPUTS:
% -------
% h
%   graphics handle of ellipse
% xupp xlow xmin xmaj
%   
%
%   Written by Joseph Jun, jkjun@princeton.edu
%   Date 03/8/2007
%

if exist('props','var'),      mydeal(props);     end
if ~exist('clr','var'),       clr=[0.3 0.3 0.3]; end
if ~exist('lw','var'),        lw=2;              end
if ~exist('lwax','var'),      lwax=1;            end
if ~exist('isAxlines','var'), isAxlines=true;    end
if ~exist('nsamples','var'),  nsamples=100;      end            
if ~exist('h','var'),         h=[];              end     
if ~exist('isdir','var'),     isdir=false;       end
if ~exist('marksize','var'),  marksize=60;       end

theta=theta*pi/180;
R=[cos(-theta) sin(-theta); -sin(-theta) cos(-theta)];

dx=major/nsamples;

xt=-major:dx:major;
xupp=R*[xt;  minor*sqrt(1-(xt.^2)/major^2)]+[x*ones(1,numel(xt)); y*ones(1,numel(xt))];
xlow=R*[xt; -minor*sqrt(1-(xt.^2)/major^2)]+[x*ones(1,numel(xt)); y*ones(1,numel(xt))];
xmaj=R*[-major major;  0    0     ]+[x x; y y];
xmin=R*[ 0     0    ; -minor minor]+[x x; y y];
if isdir, xhead=R*[-major; 0]+[x; y]; end

if isempty(h)
  h(1)=line(xupp(1,:),xupp(2,:));
  h(2)=line(xlow(1,:),xlow(2,:));
  set(h,'color',clr,'linewidth',lw);
  if isAxlines
    h(3)=line(xmaj(1,:),xmaj(2,:));
    h(4)=line(xmin(1,:),xmin(2,:));
    set(h(3:4),'linestyle','--','color',clr,'linewidth',lwax)
    if isdir
      h(5)=line(xhead(1),xhead(2),'linestyle','none','marker','.','markersize',marksize,'color',clr);
    end
  else
    if isdir
      h(3)=line(xhead(1),xhead(2),'linestyle','none','marker','.','markersize',marksize,'color',clr);
    end
  end
else
  set(h(1),'XData',xupp(1,:),'YData',xupp(2,:));
  set(h(2),'XData',xlow(1,:),'YData',xlow(2,:));
  set(h,'color',clr,'linewidth',lw);
  if isAxlines
    set(h(3),'XData',xmaj(1,:),'YData',xmaj(2,:));
    set(h(4),'XData',xmin(1,:),'YData',xmin(2,:));
    set(h(3:4),'linestyle','--','color',clr)
    if isdir
      set(h(5),'XData',xhead(1),'YData',xhead(2));
    end
  else
    if isdir
      h(3)=set(h(3),'XData',xhead(1),'YData',xhead(2));
    end
  end
end




















