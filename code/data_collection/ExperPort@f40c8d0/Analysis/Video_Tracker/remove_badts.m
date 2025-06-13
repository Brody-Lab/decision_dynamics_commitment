function [ts,theta,x,y,isgood]=remove_badts(ts,theta,x,y,dt_bounds)

%
% [ts,theta,x,y,isgood]=remove_badts(ts,theta,x,y,dt_bounds);
%   Removes timestamps that are too short or too long, as defined by the
%   2-element vector defined by dt_bounds.  dt_bounds(1) is the minimum,
%   dt_bounds(2) is the maximum, default is [0.012 0.020] (12 and 20 ms).
%   First time stamp in ts is always assumed good.
%

if ~exist('dt_bounds','var'), dt_bounds=[0.012 0.020]; end

% -------- remove any bins whose difference from the preceding bin is less
% than dt_bounds(1) and greater than dt_bounds(2)
dts=diff(ts);
isgood=[true (dts>=dt_bounds(1) & dts<=dt_bounds(2))];
ts=ts(isgood);
igoodbins=find(isgood);

% -------- keep decimating until no dts less than dt_bounds(1)
while min(diff(ts))<=dt_bounds(1)
  dts=diff(ts);
  isgood=[true dts>dt_bounds(1)];
  ts=ts(isgood);
  igoodbins=igoodbins(isgood);
end

isgood=false(1,numel(ts));
isgood(igoodbins)=true;

if exist('theta','var'), if ~isempty(theta), theta = theta(isgood); end; end
if exist('x',    'var'), if ~isempty(x),         x = x(isgood);     end; end
if exist('y',    'var'), if ~isempty(y),         y = y(isgood);     end; end

