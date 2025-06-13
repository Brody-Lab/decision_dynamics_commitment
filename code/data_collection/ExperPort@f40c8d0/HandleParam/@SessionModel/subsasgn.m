function [] = subsasgn(obj, stct, rhs)

error('Please use the ''set'' methods for this object to change values. Dot notation use is not permitted.');

% 
% 
% if length(stct) > 1
%     error('Sorry, cannot deal with nested subscript assignments');
% elseif ~strcmp(stct.type, '.')
%     error('Invalid subscript assignment for SessionModels. The only allowed type is ''.''');
% 
% elseif strcmp(stct.subs, 'training_stages')
% 
%     if cols(in_train_set) ~= 3,
%         error('The set of training stages should have three columns: the training stage string, the string to test for completion, and whether the stage was previously completed');
%     elseif ~iscell(in_train_set),
%         error('The set of training stages should be a cell array with three cols');
%     end;
%     
%     obj = subsasgn_stage_set(obj, rhs);
% 
% elseif strcmp(stct.subs, 'current_train_stage')
%     if in_curr_stage > rows(in_train_set),
%         error('Current training stage exceeds total number of training stages! Are you really done?');
%     elseif in_curr_stage < 0, error('Current training stage must be a natural number');
%     end;
%     
%     obj = subsasgn_curr_stage(obj, rhs);
% 
% else
%     error('Unknown type of assignment. Command ignored.');
% end;