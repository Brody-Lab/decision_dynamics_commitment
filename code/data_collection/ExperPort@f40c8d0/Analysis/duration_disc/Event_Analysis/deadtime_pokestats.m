function [timespent] = deadtime_pokestats(pstruct)

%pstruct = get_pstruct(ratname,date);
[cen left right] = pokes_during_iti(pstruct);
ct = []; lt = []; rt = []; % count the pokes in each trial
timespent = []; % time spent poking in each trial
for k = 1: length(cen)
    ct = [ct rows(cen{k})];
    lt = [lt rows(left{k})];
    rt = [rt rows(right{k})];

    ctime = sum(cen{k}(:,2) - cen{k}(:,1));
    ltime = sum(left{k}(:,2) - left{k}(:,1));
    rtime = sum(right{k}(:,2) - right{k}(:,1));
    timespent = [timespent ctime+ltime+rtime];
end;
2;
