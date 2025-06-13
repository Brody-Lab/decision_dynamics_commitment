function [] = timeout_vpd(rat,task,date)
% Shows avg # timeouts as function of initial silent period

load_datafile(rat, task, date);

  n = eval(['saved.' task '_n_done_trials;']);
vpd = saved.VpdsSection_vpds_list; 
vpd = vpd(1:n);

tcount = timeout_count(rat, task, date,'show_plot',0);

figure;
set(gcf,'Menubar','none','Toolbar','none');
[x binned_to sem] = bin_hits(vpd, 10, tcount);
errorbar(x, binned_to, sem, sem,'.r');
xlabel('Intial poke period (s)');
ylabel('Average timeout count (#)');
s = sprintf('%s: %s (%s)\nTimeout as function of initial poke period', make_title(rat), make_title(task), date);
t = title(s); set(t,'FontSize',14);



% Bins the range "to_bin" into "numbins" equally-spaced bins
% For each bin, calculates the average value of "val".
% Returns: 1) The # of entries in each bin
%  2) The mean hit rate for the bin
function [x binned_val binned_sem] = bin_hits(to_bin, numbins, vals)
idx_crosschk = [];
binwidth = (max(to_bin) - min(to_bin)) / numbins;
[n,x] = hist(to_bin,numbins);
binned_val = []; binned_sem = [];
idx_so_far = []; % avoid rebinning
for k = 1:numbins
    idx=[];
    if k == 1,
        idx = find(to_bin < x(k));
    end;
    idx = [ idx find(to_bin > (x(k)-(binwidth/2)) & ...
        to_bin <= (x(k)+(binwidth/2)) )];
    idx = unique(idx);

    idx = setdiff(idx, idx_so_far);
    idx_so_far = [idx_so_far idx];
    idx_crosschk = [ idx_crosschk  length(idx)];

    valbin = vals(idx); 
    binned_val = [binned_val mean(valbin);];
    binned_sem = [binned_sem std(valbin)/sqrt(length(valbin))];

end;
%idx_crosschk
%n
fprintf(1, 'Bin count #1: %i, Bin count #2: %i\n', sum(idx_crosschk), sum(n));

