function [x binned_hrate binned_sem bin_nums] = bin_hits(to_bin, numbins, hits,varargin)
% Bins the range "to_bin" into "numbins" equally-spaced bins
% For each bin, calculates the hit rate.
% Returns: 
% 1) The bin centers
%  2) The mean hit rate for the bin --> changes depending on
%  get_bin_indices switch; see below
% 3) The sem for the bin --> changes like output #2

pairs = { ...
    'multfactor', 100 ; ...
    'get_bin_indices', 0 ; ... % when set to 1, returns bin # to which each 'hit' is assigned. In this case, binned_hrate becomes the var
                               % to which the indices are assigned.
                               % binned_sems is simply 0.
    };
parse_knownargs(varargin,pairs);
    

idx_crosschk = [];
binwidth = (max(to_bin) - min(to_bin)) / numbins;
[n,x] = hist(to_bin,numbins);
binned_hrate = []; binned_sem = [];
idx_so_far = []; % avoid rebinning
binned_idx = zeros(size(hits));

for k = 1:numbins
    idx=[];
    if k == 1,
        idx = find(to_bin < x(k));
    elseif k == numbins
        idx = [idx find(to_bin > x(k)+(binwidth/2))];
    end;

    b= find(to_bin > (x(k)-(binwidth/2)) & ...
        to_bin <= (x(k)+(binwidth/2)) );
    if cols(idx) > 1, idx = idx'; end;
    if cols(b) > 1, b = b'; end;
    idx = vertcat(idx, b);

    idx = unique(idx);
    
  if cols(idx) > 1, idx = idx';end;
    idx = setdiff(idx, idx_so_far);
    
    if cols(idx_so_far) > 1, idx_so_far = idx_so_far'; end;
    idx_so_far = vertcat(idx_so_far,idx);
    if cols(idx_crosschk) > 1, idx_crosschk = idx_crosschk'; end;
    idx_crosschk = vertcat(idx_crosschk,length(idx));

    hitbin = hits(idx); hitbin = hitbin*multfactor;
    binned_idx(idx) = k; % set bin # for these hits
    binned_hrate = [binned_hrate mean(hitbin);];
    binned_sem = [binned_sem std(hitbin)/sqrt(length(hitbin))];
end;

if get_bin_indices > 0
    binned_hrate = binned_idx;
    binned_sem = 0;
end;

2;