function [stg] = get_current_training_stage(obj)
% returns the index of the currently active training stage
% SessionModel evaluates training stages in order of registration.
stg = obj.current_train_stage;