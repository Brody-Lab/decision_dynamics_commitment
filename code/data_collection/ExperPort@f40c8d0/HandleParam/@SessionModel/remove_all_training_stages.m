function [obj] = remove_all_training_stages(obj)

%
% This function deletes all registered training stages.
%

delete_current_sphandles(obj);   
obj.training_stages = {};
obj = set_current_training_stage(obj, 1);
