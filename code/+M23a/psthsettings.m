function settings = psthsettings
% Return a struct with the parameters of peri-stimulus time histograms

% the standard deviation, in seconds, of the causal gaussian with which spike counts are convolved.
% See `M23a.convolve_counts_causalgaussian.m`
settings.sigma_s = 0.1;
% the threshold that distinguishs weak and strong evidence strength, on the bassis of the absoluate
% value of the log-odds of generative click rates between the left and right
settings.weakstrongthreshold = 1.5; 
% the width, in seconds, of the causal gaussian with which spike counts are convolved.
% See `M23a.convolve_counts_causalgaussian.m`
settings.width_s = 0.4;
% duration, in seconds
settings.duration_s = 1.0;