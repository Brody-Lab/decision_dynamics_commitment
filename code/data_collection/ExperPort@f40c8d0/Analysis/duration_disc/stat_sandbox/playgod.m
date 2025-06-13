function [] = playgod()

numSamples = 50;    % larger # samples gives smaller standard error
the_universe = zeros(1,numSamples); 

% Standard error
% Uses standard deviation of the distribution of sample means
% NOT the standard deviation of any given sample

numSims =100;    % Larger # experiments only increases

for k = 1:numSims
    the_universe(k+1,:) = ((randn(1,numSamples) .* 1))+5;
end;

the_universe = the_universe(2:end,:);
figure;
subplot(2,1,1);
sample_means = mean(the_universe');
fprintf(1,'I have %i means\n', length(sample_means));
hist(sample_means);

mean_of_means = mean(sample_means);
stdev_means = std(sample_means);

fprintf(1,'Mean of means=%1.1f, STDEV = %1.2f\n', mean_of_means, stdev_means);
title('Distribution of sample means -- Ordered universe');


% And now for the wacky distribution
parallel_universe = zeros(1,numSamples);

magic_point = 0.7;


for k = 1:numSims
    x = randn(1,numSamples);
    parallel_universe(k+1,:) = x + (magic_point * (magic_point - x));;
end;
parallel_universe = parallel_universe(2:end,:);

fprintf(1,'----------------------\nPARALLEL UNIVERSE\n');
sample_means = mean(parallel_universe');
fprintf(1,'I have %i means\n', length(sample_means));
subplot(2,1,2);
hist(sample_means);

mean_of_means = mean(sample_means);
stdev_means = std(sample_means);

fprintf(1,'Mean of means=%1.1f, STDEV = %1.2f\n', mean_of_means, stdev_means);
 