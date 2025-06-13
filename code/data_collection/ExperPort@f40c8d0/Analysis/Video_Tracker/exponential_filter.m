function a = exponential_filter(x, tau)
% applies a (backwards) exponential filter to x of width tau (in samples)

% the tau (delay constant) of an exponential distribution made this way is
% 1; we make our t vector so that there are tau samples per unit
dt = 1/tau; 
t = 0:dt:5;
f = exp(-t); 
f = f./sum(f);
%f = f(end:-1:1);
f=[zeros(1,numel(f)) f];
a = filter(f, 1, x);

% this produces a shifted result because the peaks in a are shifted from
% the peaks in x by length(t)*4/5, so we just shift them back and pad the
% missing data at the end with whatever the last value is.
shift = round(length(f)/2);
if cols(x) > rows(x),
    a = [a(shift:end) a(end)*ones(1,shift-1)]; 
else
    a = [a(shift:end); a(end)*ones(shift-1,1)];
end