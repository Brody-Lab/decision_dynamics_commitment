function [sig pct_farther] = permutationtest_diff(x,y,varargin)
% does a permutation test to see if mean(x)-mean(y) is significantly
% different from zero 
% (null hypothesis is that mean(x) - mean(y) = 0).
% returns 1 if probability of getting so large a difference is < alphaval; else
% returns 0.
%
% The type of permutation test done depends on the setting of param
% 'typeoftest'.
% * two_tailed: does a two-tailed test; if |x-y| sig ~= 0, return true.
% * onetailed_gt0: does a one-tailed test for x-y > 0
% * onetailed_ls0: does a one-tailed test for x-y < 0
% 
% NaN points --- are removed from each simulated set, NOT from the original dataset.

pairs = { ...
    'numsims', 1000 ; ...
    'alphaval', 0.05 ; ...
    'typeoftest', 'two_tailed'; ... % one of [two_tailed | onetailed_gt0 | onetailed_ls0]
    'plotme', 0 ; ... % set to 1 to plot distribution of simulations
    };
parse_knownargs(varargin,pairs);


realdiff = mean(x) - mean(y);

if rows(x) > 1 && cols(x) > 1
    error('x can only be a vector');
elseif rows(y) > 1 && cols(y) > 1
    error('y can only be a vector');
end;
if rows(y) > 1
    y = y'; % convert to row vector
end;
if rows(x) > 1
    x = x';
end;

lumped = [x y];
x_sims = []; y_sims = [];
for k = 1:numsims
    permorder = randperm(length(lumped));
    x_sims = vertcat(x_sims,lumped(permorder(1:length(x))));
    y_sims = vertcat(y_sims, lumped(permorder(length(x)+1:end)));
end;

x_sims = x_sims';
y_sims = y_sims';
diff_sims = nanmean(x_sims,1) - nanmean(y_sims,1);

switch typeoftest
    case 'two_tailed'
        idx_larger = find(abs(diff_sims) >= abs(realdiff));
        pct_farther = length(idx_larger) / length(diff_sims);
    case 'onetailed_gt0'
        idx_gt0 = find(diff_sims >=realdiff);
        pct_farther = length(idx_gt0) / length(diff_sims);
    case 'onetailed_ls0'
        idx_ls0 = find(diff_sims <= realdiff);
        pct_farther = length(idx_ls0) / length(diff_sims);
    otherwise
        error('Invalid value for typeoftest: should be one of [two_tailed | onetailed_gt0 | onetailed_ls0]');
end;

if plotme
    figure;
    hist(diff_sims, 10);
    hold on; 
    ylim = get(gca,'YLim');
    line([realdiff realdiff], [0 ylim(2)] ,'Color','r','LineWidth',2);
end;

if pct_farther <= alphaval
    sig = 1; % if less than alpha % differences are this large, our diff is significant; reject null
else
    sig = 0; % it's not sig; do not reject null
end;

