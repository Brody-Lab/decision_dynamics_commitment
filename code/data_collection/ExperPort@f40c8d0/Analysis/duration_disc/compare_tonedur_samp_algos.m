% global private_soloparam_list;
% psl  = private_soloparam_list;
% ind = 0;
% for shreds = 1:length(psl)
%     if ~isempty(psl{shreds}) && strcmp(get_name(psl{shreds}),'LastTrialEvents')
%         ['***** ' int2str(shreds)  ' *****']
%         name = get_name(psl{shreds})
%         owner = get_owner(psl{shreds})
%         fullname = get_fullname(psl{shreds})
%      %   ind = shreds;
%     end;
% end;
%
% ind
% % ind = 4;
%
% % name = get_name(psl{ind})
% % owner = get_owner(psl{ind})
% % fullname = get_fullname(psl{ind})

% Quick-n-dirty script to compare the range of bin sampling of the old tone
% sampling method
% OLD: Sample uniformly in normal (not log) space of tone duration ranges
% to the new method
% NEW: Sample uniformly in log space of tone duration ranges
%
% In both cases, binning is done in log-spaced bins, under the assumption
% of scalar law of timing.

% Finding (051227):
% The average range of the old algorithm is 24 units, while that of the
% new algorithm is 16 units. So although both do not perfectly sample
% uniformly, the latter gives better results.
% 300 units are used to determine sampling ranges.


num = 200;

samp_units = 500;

f1 = 300; t1 = 548;
otherf1 = 548; othert1 = 1000;

f2 = log(f1); t2 = log(t1);
otherf2 = log(otherf1); othert2 = log(othert1);

b = generate_bins(f1, othert1, 8);
range_old = zeros(1,num);
range_new = zeros(1,num);

for i = 1:num

    q = (rand(1,samp_units/2) * (othert1-otherf1)) + otherf1;
    q2 = (rand(1,samp_units/2) * (t1-f1)) + f1;
    m = [q q2]; n2=hist(m,b);
    range_old(i) = max(n2) - min(n2);
%    sprintf('n2 = %s\nrange = %2.0f', num2str(n2), range)

    r = (rand(1,samp_units/2) * (othert2-otherf2)) + otherf2;
    r2 = (rand(1,samp_units/2) * (t2-f2)) + f2; d = exp([r r2]);
    n = hist(d, b); 
    range_new(i) = max(n) - min(n);
%    sprintf('n = %s\nrange=%2.0f', num2str(n), range)
end;
