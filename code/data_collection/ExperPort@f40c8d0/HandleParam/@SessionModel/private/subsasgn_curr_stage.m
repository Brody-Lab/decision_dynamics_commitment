function [obj] = subsasgn_curr_stage(obj, rhs)

   obj = set_current_training_stage_unchecked(obj, rhs);
% obj.current_train_stage = rhs;
