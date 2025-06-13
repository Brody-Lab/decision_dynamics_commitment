function [nearest distance]= find_nearest(templates, points)
% given a set of templates and a number of points, returns the indices and 
% distances (Euclidean) of the points closest to each of the templates
%
% templates and points must be n by 2 matrices, where each row contains
% coordinates [x y]
%
% returns nearest, which has as many elements as templates has rows

T = cols(templates);
P = cols(points);

nearest  = zeros(T, 1);
distance = zeros(T, 1);

D = pdist([templates; points]);
D = squareform(D);

for j = 1:T,
    [minval minind] = min(D(j,T+1:end));
    nearest(j)  = minind;
    distance(j) = minval;
end;