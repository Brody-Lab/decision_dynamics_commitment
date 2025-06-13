function [] = deadtime_length(ratname, date);

% Computes dead-time length for each occurrence of dead-time
% and plots statistics of its length, correlation of # pokes and deadtime
% length, etc.,

pstruct = get_pstruct(ratname, date);

deadtime = []; % duration of deadtime for each trial
multi_rows = cell(0,0);
for k = 1:rows(pstruct)
    dt = pstruct{k}.dead_time;
    if rows(dt) > 1, multi_rows(rows(multi_rows)+1,1:2) = {k rows(dt)}; end;
    dtmp = [];
    for r = 1:rows(dt)
        dtmp = [dtmp dt(r,2) - dt(r,1)];
    end;
    deadtime = [deadtime sum(dtmp)];
end;

figure;
threshes = [0 2 5 10 30 60 10000]; % slices of pie chart  (in seconds of deadtime)
n=[];

n = length(find(deadtime == 0));
lbls{1} = sprintf('%i (%i%%)',threshes(1), round((n(1)/length(deadtime)) * 100));

%  [n x] = hist(deadtime);
for k = 2:length(threshes),
    tmp = intersect(find(deadtime > threshes(k-1)),find(deadtime <= threshes(k)))
    n = [n length(tmp)];
    lbls{k} = sprintf('%i (%i%%)',threshes(k), round((n(k)/length(deadtime)) * 100));
end;

maxidx = find(n == max(n)); xplode = zeros(size(n)); xplode(maxidx) =1;
p = pie(n,xplode,lbls);
t=title(sprintf('%s (%s): What % session had deadtime with duration = X?',ratname,date));
set(t,'FontSize',14, 'FontWeight','bold');
toppos = 0.5;
for k = 2:2:length(p),
    set(p(k-1), 'EdgeColor','none');
    set(p(k),'FontWeight','bold','FontSize',12); %'Position',[-1.5 toppos 0]);
    %  toppos = toppos - 0.1;
end;
%hist(deadtime);

t = deadtime_pokestats(pstruct);

figure;
subplot(1,3,1);
plot(1:length(deadtime), deadtime, '.g')
title('Deadtime duration');
subplot(1,3,2);
plot(1:length(t), t, '.r')
title('Time spent poking during deadtime');
subplot(1,3,3);
plot(deadtime, t,'.b')
title('Time poking versus deadtime');
c=corrcoef(deadtime,t);
