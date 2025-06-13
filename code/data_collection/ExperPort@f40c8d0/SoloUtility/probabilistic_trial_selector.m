%[probs] = probabilistic_trial_selector(fractions_correct, priors, beta)
%
% Softmax trial selection, based on performance and prior distribution.
%
% Given a vector representing the fraction of correct trials (each element
% of the vector represents one stimulus type), and a prior distribution of
% desired probabilities, computes the probabilities for choosing the next
% stimulus trial. When beta=0, the probabilities returned are just the
% priors, regardless of performance. When beta is large (much bigger than
% 1), the trial type with the lowest per cent correct gets higher, all the
% others get lower. (A prior of 0, however, ensures a prob of 0). This
% function is most useful, then, for values of beta within the range 0 to
% 10. beta around 2 or 3 seems reasonable
%
% To get a single sample from probs, use Matlab's randsample.m like this:
%      randsample(1:length(probs), 1, true, probs)
% This will return an index from 1 to length(probs) sampled according
% to the indicated probability. 
% 
% 
% EXAMPLES:
% ---------
%
% >> probabilistic_trial_selector([1, 0.67, 0.3], [0.33 0.67 0], 0)
%      probs = [0.33   0.67   0]
%
% >> probabilistic_trial_selector([1, 0.67, 0.3], [0.33 0.67 0], 0.5)
%      probs = [0.295  0.705  0]
%
% >> probabilistic_trial_selector([1, 0.67, 0.3], [0.33 0.67 0], 10)
%      probs = [0.017  0.982  0]
%



function [p] = probabilistic_trial_selector(frac, priors, beta)
   if rows(frac)==cols(priors),
	   priors = priors';
   end;

   p = exp(-frac*beta);
   
   p = p.*priors;

   p = p./sum(p);
   
 