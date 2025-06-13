function aa = stitch_wrapped(x, wrap, tol)
% stitches wrapped data together in continuous data, where 0 and wrap are
% identified as the same point withint tolerance = tol

if nargin < 2, wrap = 360; end;
if nargin < 3, tol = 30; end;

x = rowvec(x);

hotspots = find(abs(diff(x)) >= wrap - tol);

for i = 1:numel(hotspots),
    if hotspots(i)+1 > length(x), break; end;
    
    jump = x(hotspots(i)+1) - x(hotspots(i));

    if jump >= wrap - tol,
        x(hotspots(i)+1:end) = x(hotspots(i)+1:end) - wrap;
    elseif jump <= -wrap + tol,
        x(hotspots(i)+1:end) = x(hotspots(i)+1:end) + wrap;
    end
end

if nargout > 0, aa = x; end;