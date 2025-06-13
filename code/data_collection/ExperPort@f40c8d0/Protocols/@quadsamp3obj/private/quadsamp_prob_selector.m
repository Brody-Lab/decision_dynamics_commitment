% [choices] = quadsamp_prob_selector(rlhitfracs, hitfracs, priors, beta)
%
% Does soft spreading of probability of choosing a stimulus among four
% types of stimuli: two rights and two lefts. First does
% probabilistic_trial_selector on clumped rights v clumped lefts; then
% does it again within each group.
%
% This way the chances of choosing left or right are exactly the same
% regardless of whether there is only one stimulus for each of right
% and left, or two identical stimuli for each of right and left.
%
% In hitfracs and priors, assumes they have four rows, and that the top
% two rows are rights while the bottom two are lefts.

function [choices] = quadsamp_prob_selector(rlhitfracs, hitfracs, priors, beta)

   rghtfracs = hitfracs(1:2);
   leftfracs = hitfracs(3:4);

   rghtpriors = priors(1:2)/sum(priors(1:2));
   leftpriors = priors(3:4)/sum(priors(3:4));

   lr = probabilistic_trial_selector(mean
   