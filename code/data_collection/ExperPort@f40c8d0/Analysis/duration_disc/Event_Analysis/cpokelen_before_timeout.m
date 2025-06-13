function [] = cpokelen_before_timeout(ratname, doffset)
% Show cpoke length before timeouts occur
pstruct = get_pstruct(ratname, getdate(doffset));

cp = [];
for k = 1:rows(pstruct)
    curr=pstruct{k};
    to = curr.timeout;
    for m  = 1:rows(to) % for each timeout
        tmp = abs((curr.center1(:,2)-to(m,1))); % find distance in time from its start to the last Cout
        idx = find(tmp == min(tmp)); % the center poke that just preceded the start of the timeout state
        cp = vertcat(cp, curr.center1(idx,2)-curr.center1(idx,1));       
    end;
end;

figure;
hist(cp);
title(sprintf('%s (%s): Cpoke length before timeout occurrence'));
