function [] = dead_time_2secgap(ratname, indate)
% there is a 2 second gap in the event listing between trials
% SCURR = the last state of the current trials is in p{k}.dead_time(1,:)
% SLAST = the first state of the previous trial is in p{k-1}.dead_time(end,:)
% the hole is SCURR - SLAST.
% I'm not sure why this 2 second gap exists

p=get_pstruct(ratname, indate);

dgap = NaN(rows(p)-1,1);
for k = 2:rows(p)
    k
    dgap(k-1) = p{k}.dead_time(1,1) - p{k-1}.dead_time(end,2);        
end;

figure;
plot(dgap,'.b');
ylabel('DT(k) start - DT(k-1) end (seconds)');
title(sprintf('%s:%s', ratname, indate));
axes__format(gca);