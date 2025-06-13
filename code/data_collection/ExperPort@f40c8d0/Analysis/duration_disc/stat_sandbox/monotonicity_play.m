function [] = monotonicity_test()

% 
% Play script. Goal is to determine whether data has monotonic trend.
% Uses Monte Carlo simulation to ascertain whether the slope of the datafit
% is "significantly" different from zero.
% 

x = 1:7;
y = x * 10;


p = polyfit(x,y,1);
real_slope = p(1);

slopes = [];
for s = 1:200
    newy = y(randperm(length(y)));
    p = polyfit(x,newy,1);
    slopes = [slopes p(1)];
end;

figure;
hist(slopes);
hold on;
line([mean(slopes) mean(slopes)], [0 30], 'Color','r','LineWidth',2);
line([-1*std(slopes) std(slopes)], [15 15], 'Color','r','LineWidth',2);
line([real_slope real_slope], [0 30], 'COlor','g','LineWidth',2);