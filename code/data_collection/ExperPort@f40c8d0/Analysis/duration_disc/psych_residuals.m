function [res] = psych_residuals(before, after)
% computes differences for each day after lesion with the average of
% returns 'res', an s-by-1 array where each entry is the residual from one
% day.

res=[];
for k = 1:length(after)
    curr_after = after{k}; 
    % bin input in some way here
    % bef, aft are expected inputs
    if length(curr_after) > 1 %ignore invalid days
        curr_res = sum((curr_after-before).^2);
        
    else
        curr_res = -1;
    end;       
     res = horzcat(res, curr_res);
end;
