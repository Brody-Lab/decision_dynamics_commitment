function theta=move_anglediscontinuity(theta,anglec)

%
% theta=move_anglediscontinuity(theta,anglec)
%   say theta are angle values that range from 0-359 (or any integer
%   multiple of that range).  Then going from 359 to 0 creates an apparent
%   discontinuity of -359 degrees when really the movement was only 1
%   degree.  This function shifts the placement of that discontinuity to
%   somewhere more convenient but keeps the origin intact.  
%   For example, if the target movement moves about zero degrees with 
%   noise, then plotting theta will look crazy.  Moving the discontinuity 
%   to, say, 180 degrees avoids this issue.  In that case going up one
%   degree from 179 will map to -180 degrees.  In general,
%   theta=mod(theta-anglec,360)-mod(-anglec,360);
%   See for example: plot(0:360,move_anglediscontinuity(0:360,270))
%

theta=mod(theta-anglec,360)-mod(-anglec,360);