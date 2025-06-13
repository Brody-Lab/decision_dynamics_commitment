% [obj] = mark_as_complete(obj, ind)
%
% Simply marks the indicated training stage as complete. Does not delete
% any helper vars or do anything else.
%

function [obj] = mark_as_complete(obj, ind)

ts = get_training_stages(obj);

ts{ind, obj.is_complete_COL} = 1;
obj.training_stages = ts;
