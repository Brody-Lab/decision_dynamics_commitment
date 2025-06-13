function [ob] = pbups_counter(left, right, sample)
% inputs:
% left = times (in sec) of bups on the left
% right = times of bups on the right
% sample = time (in sec) the stimulus was played
%
% output:
% based on the sample duration, the left/right discrimination based on an
% ideal observer that is able to count bups on either side
% returns the difference in right bup counts and left bup counts
% >0 means more right bups, <0 means more left bups

l = sum(left <= sample);
r = sum(right <= sample);
ob = r-l;
return;