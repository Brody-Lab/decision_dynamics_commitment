function [p1 p2] = lick_analysis(ratname, indate)

% from S022/080922, S025/080922, S035/080922
% A rewarded lick seems to last ~100ms (< 200ms)
% is spaced from other licks by ~ 25-75ms
% and is part of a set of 30+ licks

datafields = {'pstruct','sides','rts'};
get_fields(ratname, 'use_dateset','given','given_dateset', indate, 'datafields', datafields);

licks = sub__get_licks(sides, hit_history, pstruct,rts);

hh= hit_history;
sl = sides;

left_correct = intersect(find(hh > 0),find(sl > 0));
left_incorrect = intersect(find(hh == 0),find(sl > 0));
right_correct = intersect(find(hh > 0),find(sl == 0));
right_incorrect = intersect(find(hh == 0),find(sl == 0));

set3 = {};
set3.pattern2 =right_correct;
set3.type2 = 'right';
set3.name2 ='Right correct';
set3.pattern1 =left_correct;
set3.type1 = 'left';
set3.name1 ='Left correct';

[p1 p2] = sub__compare_licks(licks, set3, 1);


% plot histograms of 
% a) lick counts
% b) inter-lick intervals comparing set1 and set 
function [p1 p2] = sub__compare_licks(licks, in_set, graphic)


fnames = fieldnames(in_set);
for idx=1:length(fnames)
    eval([fnames{idx} ' = in_set.' fnames{idx} ';']);
end;

[p1_ct p1_lickdur p1_ili] = sub__count_and_ili_licks(licks(pattern1),type1);
[p2_ct p2_lickdur p2_ili] = sub__count_and_ili_licks(licks(pattern2),type2);

p1_ili = p1_ili*1000;
p2_ili = p2_ili*1000;

f = {'p1_ili', 'p2_ili', 'p1_lickdur','p2_lickdur'};
for idx =1:length(f)
    tmp = eval(f{idx});
    pct99 = percentile(tmp, 95);
    idx2 = find(tmp < pct99);
    eval([f{idx} ' = ' f{idx} '(idx2);']);    
end;


p1.ct = p1_ct;
p1.ili = p1_ili;
p1.lickdur = p1_lickdur;

p2.ct = p2_ct;
p2.ili = p2_ili;
p2.lickdur = p2_lickdur;

if graphic == 0
    return;
end;

% now plot
figure; set(gcf,'Position',[ 440   395   905   339]);
ypos = 0.1;
axes('Position',[.03 ypos 0.3 0.80]);
overlap_hists(p1_ct,p2_ct);
title('Count of licks');

axes('Position',[0.36 ypos 0.3 0.80]);
overlap_hists(p1_ili, p2_ili);
title('Inter-lick interval');
xlabel('milliseconds');
legend({name2, name1});

axes('Position',[0.68 ypos 0.3 0.80]);
overlap_hists(p1_lickdur, p2_lickdur);
title('Lick duration');
xlabel('seconds');
legend({name2, name1});


% cell array of licks for each trial
% each cell contains a struct with keys 'left','center', 'right'
function [lick_cell] = sub__get_licks(sl, hh, p,rts)
lick_cell = {};

for k = 1:rows(p)
    if k == 22
        2;
    end;
    if hh(k) > 0
        st = p{k}.wait_for_apoke;
        drk = p{k}.drink_time;
        st1 = st(1,1);
        st2 = drk(1,2);
    else
        st = p{k}.wait_for_apoke;
        st_extra = p{k}.extra_iti;
        st1 =st(1,1);
        st2 = st_extra(1,2);
    end;

    cond = {'in', '>=', st1; ...
        'out', '<=', st2; ...
        };
    tmp = {};
    tmp.left = get_pokes_fancy(p{k}, 'left', cond, 'all');
    tmp.right = get_pokes_fancy(p{k}, 'right', cond, 'all');
    tmp.center = get_pokes_fancy(p{k}, 'center', cond, 'all');
    %lick_cell{end+1} = tmp;
    lick_cell{end+1} = tmp;
end;

% returns # licks per trial
function [ctr lickdur ili totaltime] = sub__count_and_ili_licks(larray,ltype)
ctr = [];
lickdur =[];
ili = [];
for k = 1:length(larray)
    curr = larray{k};
    curr = eval(['curr.' ltype ';']);
    ctr = horzcat(ctr, rows(curr));
    tmp = curr(:,2)-curr(:,1); % inter-lick interval
    
    prevm = NaN;
    for m = 1:rows(curr)
        lickdur = horzcat(lickdur, curr(m,2) - curr(m,1));
        if ~isnan(prevm)
            ili = horzcat(ili, curr(m,1) - prevm);            
        end;
        prevm = curr(m,2);
    end;

%     if rows(tmp) > 1, tmp = tmp'; end;
%     ili = horzcat(ili, tmp);
2;
end;

function [] = overlap_hists(x1,x2)

hist(x2);
p=findobj(gca,'Type','patch'); set(p,'FaceColor', [1 0 0],'EdgeColor',[1 0 0],'facealpha',0.75);
hold on;
hist(x1);
p=findobj(gca,'Type','patch');
set(p,'facealpha',0.25, 'EdgeColor','none');


% set1 = {};
% set1.pattern1 =left_correct;
% set1.type1 = 'left';
% set1.name1 ='Left correct';
% set1.pattern2 =left_incorrect;
% set1.type2 = 'right';
% set1.name2 ='Left incorrect';
% compare_licks(licks,set1);
% 
% set2 = {};
% set2.pattern1 =right_correct;
% set2.type1 = 'right';
% set2.name1 ='Right correct';
% set2.pattern2 =right_incorrect;
% set2.type2 = 'left';
% set2.name2 ='Right incorrect';
% compare_licks(licks, set2);
