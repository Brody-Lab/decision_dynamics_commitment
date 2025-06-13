function [obj] = remove_training_stage(obj,idx)

% This function removes the training stage at the specified index value
% "index". All preceeding training stages remain as is; all succeeding
% training stages are moved up by one position in the list. 
% 
% If the removed stage was the active one, the one after it becomes the
% active training stage; otherwise, the active training stage retains its
% active status.

ts = get_training_stages(obj);
curr = get_current_training_stage(obj);

if idx > rows(ts)
    error('Index exceeds rows in training stages array');
elseif idx <= 0
    error('Index value must be > 0');
end;

ts_temp = ts(1:idx-1,:);
ctr = idx;

% If we're going to delete the current stage, make sure to delete its SPHs:
if idx==curr, delete_current_sphandles(obj); end;

if idx < rows(ts)
    for k = idx+1:rows(ts)
        ts_temp(ctr,1:6) = ts(k,:); ctr = ctr+1;
    end;
end;

obj.training_stages = ts_temp;

% update the currently active stage
if idx == curr % the active stage was removed; make next stage the active one
    if idx == rows(ts_temp)+1 % the last training stage of the old array was removed
        obj = set_current_training_stage(obj, rows(ts_temp));
    end;
    % otherwise, the next one in line implicitly becomes the active stage
elseif curr > idx
    obj = set_current_training_stage(obj, curr-1);    % everybody got moved up one
end;
    