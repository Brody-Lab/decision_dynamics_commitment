function out = maxmin(x)

% maxmin returns max and min of an image x

a = max(max(x));
b = min(min(x));

out = [b a];