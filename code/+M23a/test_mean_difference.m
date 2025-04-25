function p = test_mean_difference(x,y)
% two-tailed bootstrap test of the difference in mean between two sets of samples
validateattributes(x, {'numeric'}, {'vector'})
validateattributes(y, {'numeric'}, {'vector'})
observed_difference = abs(mean(x)-mean(y));
newx = x - mean(x) + mean(y);
nboot = 1e4;
boot_mean_newx = bootstrp(nboot, @mean, newx);
boot_mean_y = bootstrp(nboot, @mean, y);
z = abs(boot_mean_newx - boot_mean_y);
p = sum(z > observed_difference)/nboot;
p = max(1/nboot, p);