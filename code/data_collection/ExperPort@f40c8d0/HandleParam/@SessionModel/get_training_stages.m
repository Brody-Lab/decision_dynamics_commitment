function [ts] = get_training_stages(obj)
% Returns the list of registered training stages in the order in which they
% are being evaluated.
% The output is an r-by-3 cell array, each row of which is a registered
% training stage. The columns are:
% 1. train_stage: the string that is evaluated when the current stage is
% active. It contains update rules and contingencies.
% 2. completion_test: the string that is evaluated to test whether the
% current training stage has reached the point of completion. It is a
% string that must evaluate to either true or false
% 3. is_complete: a "1" or "0" indicating whether the current training
% stage is complete or not, respectively.


ts = obj.training_stages;

return;