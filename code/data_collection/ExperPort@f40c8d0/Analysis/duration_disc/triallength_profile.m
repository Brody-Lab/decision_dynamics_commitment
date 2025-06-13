function [] = triallength_profile(ratname, indate)
% shows profile of trial lengths for a given session
% see also trial_duration.m

get_fields(ratname, 'use_dateset','given', 'given_dateset', {indate}, ...
    'datafields', {'events_raw'});

events = events_raw;
firste= events{1};
sessionstart = firste(1,3);

tlen = [];
tm_twixt = []; 

prev_end = 0;
for k = 1:length(events)
    curre = events{k};
    tlen = horzcat(tlen, curre(end,3) - curre(1,3));    
    if k > 1, tm_twixt = horzcat(tm_twixt, curre(1,3) - prev_end); end;
    
    prev_end = curre(end,3);
        
end;

figure;
plot(tlen,'.b');
ylabel('seconds');
xlabel('trial #');
title(sprintf('%s: Trial length for session file %s', ratname, indate));

tlen_sum = sum(tlen);
twixt_sum = sum(tm_twixt);
fprintf(1,'Total: %2.1f sec, %2.1f min\n', tlen_sum, tlen_sum/60);
fprintf(1,'Time between trials: %2.1f sec, %2.1f min\n', twixt_sum, twixt_sum/60);

axes__format(gca);
set(gcf,'Position',[100 200 500 200]);

