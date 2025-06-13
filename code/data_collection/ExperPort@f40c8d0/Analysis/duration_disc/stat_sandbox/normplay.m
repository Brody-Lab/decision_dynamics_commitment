function []  = normplay()

mean__s1 = 3;
sd__s1 = 1.5;

mean__s2 = 3;
sd__s2 = 3;

% 99% of the data lie within 3sd
[s1ps s1ms] = sub__sd3(mean__s1, sd__s1);
[s2ps s2ms] = sub__sd3(mean__s2, sd__s2);

vals = s1ms:0.001:s1ps;
cdf_array = normcdf(vals, mean__s1, sd__s1);
plot(vals, cdf_array,'.b');
vals = s2ms:0.001:s2ps;
cdf_array = normcdf(vals, mean__s2, sd__s2);
hold on;
plot(vals, cdf_array,'.r');


ylabel('P(X < x)');
xlabel('x-value');


% n= 2000;
% r = randn(1,n);
% 
% 2;
% 
% 
% figure; 
% subplot(2,1,1);
% hist(r);
% 
% title('Normal');
% subplot(2,1,2);
% 
% logn = exp(r);
% title('Log normal');
% hist(logn);
% 

function [ps ms] = sub__sd3(mu, sigma)
ms = mu - (3*sigma);
ps = mu + (3*sigma);
