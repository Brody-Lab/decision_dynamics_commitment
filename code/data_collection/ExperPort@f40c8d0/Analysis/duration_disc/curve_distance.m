function [my_metric] = curve_distance(a, b)
% Given two sets of data points, computes the following distance metric between the points:
% metric = sum( |a1-b1| + |a2-b2| + ... + |aN - bN|)
% where N is the size of both datasets

if length(a) ~= length(b)
	error('Both datasets must be of equal length');
end;

my_metric = sum(abs(a - b));
