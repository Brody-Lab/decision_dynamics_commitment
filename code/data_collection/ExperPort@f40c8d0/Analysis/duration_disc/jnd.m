function [s] = jnd(wb, tasktype)

if strcmpi(tasktype,'d'), m = sqrt(200*500);
elseif strcmpi(tasktype,'p'), m=sqrt(8*16);
else error('tasktype can be ''d'' or ''p''; nothing else.');
end;

    s=wb*m;