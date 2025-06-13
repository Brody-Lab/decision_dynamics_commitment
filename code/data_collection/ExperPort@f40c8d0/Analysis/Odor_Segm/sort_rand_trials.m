function [data_sorted] = sort_rand_trials(rand_data, rand_trial, idx)
% sort data from randomly interleaved trials
tmp = rand_data(rand_trial);
tmp = tmp(idx);
rand_data(rand_trial) = tmp;
data_sorted = rand_data;
return;