function p = test_nonzero(x)
% two-tailed bootstrap test of the mean of the samples being different from zero
validateattributes(x, {'numeric'}, {'vector'})
observed = abs(mean(x));
nboot = 1e4;
z = bootstrp(nboot, @(x) abs(mean(x)), x - mean(x));
p = sum(z > observed)/nboot;
p = max(p, 1/nboot);