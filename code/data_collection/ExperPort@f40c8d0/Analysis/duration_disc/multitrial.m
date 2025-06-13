function [] = multitrial(ratname, fromdate, todate)

% fromdate = '080112';
% todate = '080118';
% ratname = 'Lascar';

f = get_files(ratname, 'fromdate', fromdate, 'todate',todate);

parray = [];
for k = 1:length(f)
    parray = horzcat(parray, sub__getpctbad(ratname, f{k}));
end;

figure;
plot(parray,'.b');
ylabel('% bad trials');
xlabel('Day #');

set(gca,'XTick', 1:length(f), 'XTickLabel', sub__trimdates(f), 'XLim', [0 length(f)+1]);
set(gca, 'YLim', [0 max(parray)+0.1], 'YTick', 0:0.1:max(parray)+0.1, 'YTickLabel', 0:10:100*(max(parray)+0.1));
title(sprintf('%s: from %s to %s', ratname, fromdate, todate));

set(gcf,'Position', [440   529   594   205]);

axes__format(gca);
sign_fname(gcf,mfilename);


% -----------------------------------------------------------------------
% Subroutines
% -----------------------------------------------------------------------

function [trm] = sub__trimdates(dates)
trm = {};
sidx = 3; if length(dates) > 20, sidx = 4;end;
for k = 1:length(dates)

    trm{end+1} = [dates{k}(sidx:4) '/' dates{k}(5:6)];
end;


function [p] = sub__getpctbad(ratname, mydate) 

%ratname = 'Hudson';mydate = '080111a';
ratrow = rat_task_table(ratname);
if strcmpi(ratrow{1,2}(1:3),'dur')
    leftf = 'dur_short';
    rightf= 'dur_long';
else
    leftf = 'pitch_low';
    rightf='pitch_high';
end;


get_fields(ratname,'use_dateset','given','given_dateset', {mydate}, ...
    'datafields', {'events',leftf, rightf, 'sides', 'events_raw','rts'});

if ~exist('numtrials', 'var')
    p = NaN;
    return;
end;

leftf = eval(leftf);
rightf = eval(rightf);

idx = sub__multi_trials(ratname, mydate, events);
 p = length(idx)/numtrials;

% figure;
% plot(ones(numtrials,1), '.b','MarkerSize',20);
% set(gca,'YLim',[0 3]);
% hold on;
% plot(idx, ones(size(idx)), '.r','MarkerSize',20);
% 
% 
% % Plot tones in multi-trials --------
% sl = sides(idx);
% lf =leftf(idx);
% rf = rightf(idx);
% 
% left = find(sl==1); right = find(sl==0);
% % plot(left, lf(left), '.b'); hold on;
% % plot(right, rf(right), '.r');
% % title('Tones for multi-trials');
% 
% %[cuelen tones] = cuetonematch(events, leftf, rightf, sides);

%load_datafile(ratname, mydate);
% stm = saved.make_and_upload_state_matrix_state_matrix_cell;
% [itifirst nextevs]= sub__getfirstiti(stm,rts, events_raw);
% cuefirst = sub__getfirstcue(stm,rts);
% 
% 2;

% _-------- Subroutines -----------------------

function [idx] = sub__multi_trials(ratname,mydate, events)
ct = [];
evs=events;
for e = 1:length(evs)
    ct = horzcat(ct, rows(evs{e}.wait_for_apoke));
end;
 idx = find(ct > 1);
 
% figure;
% plot(ct,'.b','MarkerSize',20);
% xlabel('trial#'); ylabel('# wait for cpoke'); title(sprintf('%s: %s', ratname, mydate));
% fprintf(1,'%% bad trials: %2.1f%%\n', length(idx)/length(ct)*100);
% axes__format(gca);
% idx
% 
% 2;


function [cuelen tones] = cuetonematch(evs, leftf, rightf, sides)

left = find(sides == 1); right= find(sides == 0);
tones = zeros(size(sides));
tones(left) = leftf(left);
tones(right) = rightf(right);

cuelen = [];
for r = 1:length(evs)
    curr = evs{r};
    c = curr.cue;
    cuelen = horzcat(cuelen, c(end,2) - c(end,1));
end;

figure;
plot(cuelen, '.g','MarkerSize',20);
hold on;
plot(tones, '*b', 'MarkerSize',10);

2;

function  [itifirst, nextevs] = sub__getfirstiti(stm,rts, evs)
itifirst = [];
nextevs= [];
itilen =[];

for k = 1:length(rts)
    iti = rts{k}.iti;
    tmp = stm{k+1 };
    e = evs{k};

    tmp = tmp(iti(1)+1,:);
    itifirst=vertcat(itifirst, tmp);

    sidx = intersect(find(e(:,1) == iti(1)), find(e(:,2) == 0));
    idx = intersect(find(e(:,1) == iti(1)), find(e(:,2) == 7));
    nextevs = vertcat(nextevs, e(idx:idx+1,:));
  %   itilen= vertcat(itilen, e(idx+1,3)-e(sidx,3));
end;

function [cuefirst] = sub__getfirstcue(stm,rts)
cuefirst = [];

for k = 1:length(rts)

    cue = rts{k}.cue;
    tmp = stm{k+1};
    tmp = tmp(cue(1)+1,:);
    cuefirst=vertcat(cuefirst, tmp);
end;