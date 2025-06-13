function dtheta=calc_dtheta(ts,theta)

%
% dtheta=calc_dtheta(ts,theta)
%   calculate derivate of each time point using slope between preceding and
%   proceeding time points.  Endpoints are calculated using difference
%   between current point and proceeding point (1st element) and current
%   point and preceding point (last element).
%

% define odd bins using boolean indices
isodd=false(1,numel(ts));
isodd(1:2:end)=true;


dts.even = diff(ts( isodd));     % odd points flank even points 
dts.odd  = diff(ts(~isodd));     % even points flank odd points
dth.even = diff(theta( isodd));  
dth.odd  = diff(theta(~isodd));

dtheta=zeros(1,numel(ts)-2);

dtheta(1:2:end)=dth.even./dts.even;
dtheta(2:2:end)=dth.odd./dts.odd;

dtheta=[...
  (theta(2)-theta(1))/(ts(2)-ts(1)) ...
  dtheta ...
  (theta(end)-theta(end-1))/(ts(end)-ts(end-1))];







