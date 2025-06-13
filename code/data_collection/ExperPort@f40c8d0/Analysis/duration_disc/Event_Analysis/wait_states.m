function [wc_dur wa_dur] = wait_states(ratname,indate)
% wait_states: Plots duration of wait_for_cpoke and wait_for_apoke as fn of
% trial

pstruct = get_pstruct(ratname,indate);

% duration of wait_for_cpoke and wait_for_apoke states
wc_dur = NaN(size(pstruct));
wa_dur = NaN(size(pstruct));
gc_dur = NaN(size(pstruct));
iti_dur = NaN(size(pstruct));
eiti_dur = NaN(size(pstruct));
% tally of wait_for_cpoke and wait_for_apoke states
wc_tally = [];
wa_tally = [];
for k = 2:length(pstruct)
    c = pstruct{k}.wait_for_cpoke;
    wc_tally(k) =rows(c);
    wc_dur(k) = (c(1,2)-c(1,1));

    a = pstruct{k}.wait_for_apoke;
    wa_tally(k) = rows(a);
    wa_dur(k) = (a(end,2)-a(end,1));
    
    i = pstruct{k}.iti;
    iti_dur(k) = (i(end,2) - i(1,1));
 
    i = pstruct{k}.extra_iti;
    if rows(i) > 0, eiti_dur(k) = (i(end,2) - i(1,1)); end;
end;

% Now plot

if 1
% first wc
figure;
set(gcf,'Toolbar','none','Menubar','none','Position',[ 440   489   980   245]);

% plot wc_dur
axes('Position',[0.05 0.12, 0.3 0.8]);
plot(2:length(wc_dur)+1, wc_dur, '.k');
hold on;
line([0 length(wc_dur)],[60 60], 'LineStyle',':','Color','r'); % minute line
text(1,61, '1min','FontAngle','italic','FontSize',12);
idx = find(wc_dur > 60);
l=plot(idx+1, wc_dur(idx), '.r');
set(l,'Color',[0.7 0 0]);

line([0 length(wc_dur)],[30 30], 'LineStyle',':','Color','r'); % half-minute line
text(1,31, '30s','FontAngle','italic','FontSize',12);
idx = intersect(find(wc_dur > 30), find(wc_dur <= 60));
l=plot(idx+1, wc_dur(idx), '.r');
set(l,'Color',[1 0.3 0]);
title('Duration of wait-for-cpoke');
xlabel('trial #');
ylabel('seconds');
set(gca,'YLim', [0 1.5*max(wc_dur)]);
axes__format(gca);

% Distribution of wait_for_cpoke lengths in pie form
axes('Position',[0.4 0.12, 0.2 0.8]);
threshes = [5 15 30 60 120 600 10000];
n=[];

n = length(find(wc_dur < 5));
lbls{1} = sprintf('%i (%i%%)',threshes(1), round((n(1)/length(wc_dur)) * 100));

%  [n x] = hist(wc_dur);
for k = 2:length(threshes),
    tmp = intersect(find(wc_dur > threshes(k-1)),find(wc_dur <= threshes(k)))
    n = [n length(tmp)];
    lbls{k} = sprintf('%i (%i%%)',threshes(k), round((n(k)/length(wc_dur)) * 100));
end;

maxidx = find(n == max(n)); xplode = zeros(size(n)); xplode(maxidx) =1;
p = pie(n,xplode,lbls);
toppos = 0.5;
for k = 2:2:length(p),
    set(p(k-1), 'EdgeColor','none');
    set(p(k),'FontWeight','bold','FontSize',10); %'Position',[-1.5 toppos 0]);
    %  toppos = toppos - 0.1;
end;
title('Dur of waitforcpoke');

% plot wa_dur
axes('Position',[0.62 0.12, 0.3 0.8]);
plot(2:length(wa_dur)+1, wa_dur, '.r');
title('Duration of wait-for-apoke');
xlabel('trial #');
ylabel('seconds');

% rat name
axes('Position',[0.97 0 0.05 1]);
set(gca,'Color','y','XTick',[],'YTick',[],'XLim',[-1 1],'YLim',[-1 1]);
t=text(0,0,ratname); set(t,'Rotation',90,'FontSize',12,'FontWeight','bold');

end;

% iti_dur
figure;
subplot(1,2,1);
plot(iti_dur','.r');
xlabel('trial #');
ylabel('seconds');
title('ITI dur');

subplot(1,2,2);
plot(eiti_dur,'.r');
xlabel('trial #');
ylabel('seconds');
title('Extra ITI dur');
