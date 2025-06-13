function [realbins replong tally] = bin_side_choice(binmin, binmax, numbins, ...
    ispitch, to_bin, side_choice, varargin)
% bins to_bin into bins using a left-bin method
% The left-bin method means that a 'bin_center' really represents the
% lowest value that's binned into that bin.
% It also means that the rightmost bin is not binned into.
% 1, 2, 3 - helps generate bins
% 4 - is step size in log-base2 (ispitch=1) or natural-log-base (ispitch=0)
% 5 - to_bin: data which is to be binned
% 6 - side_choice: a set that forms a pair with 'to_bin' and is associated
% with it on a value-by-value basis. The sum of side_choice for each binned
% set of 'to_bin's is put in replong.
pairs = { ...
    'input_bins', 0 ; ... % use this to supply a bin set so you don't generate them in this script
    };
parse_knownargs(varargin, pairs);

if sum(input_bins) == 0
bins = generate_bins(binmin,binmax, numbins, 'pitches', ispitch);
    realbins = bins;
else
    realbins = input_bins;
    bins = input_bins;
end;
steps = numbins + 1; % here is a comment
if ispitch > 0
    space_tween = log2(binmax) - log2(binmin);
    to_bin = log2(to_bin);
    bins = log2(bins);
    
else
    space_tween = log(binmax) - log(binmin);
    to_bin = log(to_bin);
    bins = log(bins);
end;
binwidth = space_tween / (steps-1);

replong = zeros(1,length(bins)-1);
tally = zeros(1,length(bins)-1);
idx_so_far=[];
idx_crosschk=[];
dash=repmat('-',1,100);
for k = 1:length(bins)
    idx=[];
    
    if k == 1,
        idx = find(to_bin < bins(k));
    elseif k == numbins
        idx = [idx find(to_bin > bins(k)+(binwidth/2))];
    end;

    b = find(to_bin > (bins(k)-(binwidth/2)) & ...
        to_bin <= (bins(k)+(binwidth/2)) );
    
    if cols(idx) > 1, idx = idx'; end;
    if cols(b) > 1, b = b'; end;      % keep as row vector   

        idx = vertcat(idx, b);  % merge endpoints and inclusive values
        idx = unique(idx);      
        
        if cols(idx) > 1, idx = idx';end; % keep as row vector
        
        % add currently-found values to list so far to cross-check
        % I believe this clause is now non-functional.
    if ~isempty(idx)               
        idx = setdiff(idx, idx_so_far);
        if cols(idx_so_far) > 1, idx_so_far = idx_so_far'; end;
        idx_so_far = vertcat(idx_so_far,idx);
        
        if cols(idx_crosschk) > 1, idx_crosschk = idx_crosschk'; end;
        idx_crosschk = vertcat(idx_crosschk,length(idx));
    end;
    % 
%      fprintf(1, '%s\nBin %i: %1.2f to %1.2f:\n',dash, k, (bins(k)-(binwidth/2)), (bins(k)+(binwidth/2)));
%     sort(to_bin(idx))'
%     fprintf(1,'\n');

    tally(k) = length(idx);
    replong(k) = sum(side_choice(idx));
%     hitbin = hits(idx); hitbin = hitbin*multfactor;
%     binned_idbins(idx) = k; % set bin # for these hits
%     binned_hrate = [binned_hrate mean(hitbin);];
%     binned_sem = [binned_sem std(hitbin)/sqrt(length(hitbin))];
end;

if 0

idx = find(to_bin <= bins(1));
tally(1) = length(idx); replong(1) = sum(rep_long(idx));

dash = repmat('-',1,100);
for k = 2:length(bins)
    idx = intersect(find(to_bin > bins(k-1)), find(to_bin <= bins(k)));
    fprintf(1, '%s\nBin %i: %1.2f to %1.2f:\n',dash, k, bins(k-1), bins(k));
    sort(to_bin(idx))'
    fprintf(1,'\n');
    tally(k-1) = tally(k-1)+length(idx);
    replong(k-1) = replong(k-1) + sum(rep_long(idx));
end;

idx = find(to_bin >=bins(end));
tally(end) = tally(end) + length(idx);
replong(end) = replong(end) + sum(rep_long(idx));

end;