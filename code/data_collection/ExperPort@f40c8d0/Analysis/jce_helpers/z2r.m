

function y=z2r(x)

% you could write an algorithm ... guess that r=0.5, and check.  if it is
% too high step half way , try again.  etc.  but the current algorithm
% seems to work just fine. ;-P

r=[0:0.001:0.999]'; %'
z=r2z(r);
ts=qfind(z,abs(x));
y=r(ts).*col(sign(x));
