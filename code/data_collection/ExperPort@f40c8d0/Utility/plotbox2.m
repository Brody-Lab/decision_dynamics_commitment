
function plotbox2( a, c )

pp = patch( [a(1), a(1)+a(3), a(1)+a(3), a(1), a(1)], ...
    [a(2), a(2), a(2)+a(4), a(2)+a(4), a(2)], ...
    'k');
set( pp, 'FaceColor', c );
set( pp, 'EdgeColor', c );
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotbox( k,a,b,c,boxsize )

% k = center
% a = x_start
% b = x_end
% c = colour
% boxsize = deviation from center


if (nargin==4)
	boxsize = 0.5; %default box size = 1
end

X= [a, b, b, a, a];
Y = [k-boxsize, k-boxsize, k+boxsize, k+boxsize, k-boxsize];
pp = patch( X, Y, 'k');
set( pp, 'FaceColor', c );
set( pp, 'EdgeColor', c );
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

