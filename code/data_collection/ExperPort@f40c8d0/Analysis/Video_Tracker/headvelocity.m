function newtheta = headvelocity(timestamps, theta, filterflg)
% dtheta = headvelocity(timestamps, theta)
% Takes the raw head angle and computes angular velocity

if nargin < 3,
	filterflg = 1;
end;

dtheta = diff(theta);
dtheta(abs(dtheta)>80) = 0; % no way the rat can turn > 80 degrees in one frame

dt = diff(timestamps);
dt(dt > 60) = 0; % throw out gaps of more than 60 seconds
srate = round(1/median(dt));

if filterflg,
	newtheta = exponential_filter(dtheta, srate/15);
else
	newtheta = dtheta;
end;
newtheta = newtheta*srate;