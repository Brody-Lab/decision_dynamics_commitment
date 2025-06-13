function [s] = sem(dat)

if sum(isnan(dat))>0
    warning('%s:NaN values found; ignoring in SEM computation', mfilename);
end;

s = std(dat) / sqrt(length(dat));