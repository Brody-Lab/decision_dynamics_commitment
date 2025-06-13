function [thresh, sd] = get_discriminability_points(x,y)

% Task: any
% Given a set of x and y points, returns the x value for which y is at its
% mean value (thresh) or that at x-value for the y 1 standard deviation 
% away from the mean. These two values may be used to calculate the Weber
% ratio

xx = min(x):0.02:max(x);    % choice of 0.02 is arbitrary
yy = ppval(spline(x,y),xx);

% find x closest to 50% mark
thresh = abs(yy-mean(yy));
thresh = find(thresh == min(thresh));
thresh = xx(thresh);

% find x closest to stdev
sd = abs(yy - std(yy));
sd = find(sd == min(sd));
sd = xx(sd);

% % find x closest to 25% mark
% first_qrt = abs(yy-0.25);
% first_qrt = find(first_qrt == min(first_qrt));
% first_qrt = xx(first_qrt);

% % find x closest to 25% mark
% third_qrt = abs(yy-0.75);
% third_qrt = find(third_qrt == min(third_qrt));
% third_qrt = xx(third_qrt);
