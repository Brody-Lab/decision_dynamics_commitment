function [ang,axs]=calc_angaxsfromcov2(c)

%
% [ang,axs]=calc_angaxsfromcov2(c)
%
% assumes 2D covariance, c must be 2x2 matrix.  Zero is measured at vertical, 
% and positive direction is clockwise.  Use appropriate transformations to 
% change origin and direction.
%

detthresh=1e-12;
minax=1e-10;

if det(c)>detthresh
  [U,S]=svd(inv(c));
  axs=2*sqrt([1/S(2,2); 1/S(1,1)]);
  ang=sign(c(1,2))*abs(asin(U(1,2))*180/pi);
else
  ang = sign(c(1,2))*atan(sqrt(c(1,1)/c(2,2)))*180/pi;
  axs = 2*[sqrt(c(1,1) + c(2,2)); minax];
end