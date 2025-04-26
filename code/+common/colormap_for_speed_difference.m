function c = colormap_for_speed_difference()
% Color map for plotting the difference in speed between the intrinsic and input dynamics
h = figure;
c1 = colormap(h, 'gray');
c2 = colormap(h, 'copper');
c_concat = [flip(c1);c2];
c = c_concat(1:2:end,:);
close(h)