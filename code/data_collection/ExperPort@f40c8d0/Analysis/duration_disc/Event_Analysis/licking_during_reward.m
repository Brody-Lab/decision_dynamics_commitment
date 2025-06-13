function [] = licking_during_reward(ratname, indate)

datafields = {'pstruct','sides','rig_hostname'};

get_fields(ratname, 'use_dateset', 'given', 'given_dateset', {indate},...
    'datafields', datafields, 'suppress_out', 1);

lft = 1; rt = 0;
sl = sides; hh = hit_history;

lc = intersect(find(sl==lft), find(hh==1));
lw = intersect(find(sl==lft), find(hh==0));
rc = intersect(find(sl==rt), find(hh==1));
rw = intersect(find(sl==rt), find(hh==0));

drk_time = NaN(size(pstruct));
lick_cell = cell(size(pstruct));

for k = 1:rows(pstruct)
    curr = pstruct{k};

    % drink time
    if k < rows(pstruct)
        if ismember(k, lc)
            l=sub__rewardlicks(pstruct(k:k+1));
            drk_time(k) = l.left(end,2) - l.left(1,1);
            lick_cell{k} = l;
        elseif ismember(k,rc)
            l=sub__rewardlicks(pstruct(k:k+1));
            drk_time(k) = l.right(end,2) - l.right(1,1);
            lick_cell{k} = l;
        end;
    else
        if ismember(k, lc)
            l=sub__rewardlicks(pstruct(k));
            drk_time(k) = l.left(end,2) - l.left(1,1);
            lick_cell{k}= l;
        elseif ismember(k,rc)
            l=sub__rewardlicks(pstruct(k));
            drk_time(k) = l.right(end,2) - l.right(1,1);
            lick_cell{k} = l;
        end;
    end;

    if isnan(drk_time(k)) && (hh(k) == 1)
        error('%s:%i:Sorry, drink time cannot be NaN for a correct trial', ratname, k);
    end;
end;

[mega_licks, left_licks, right_licks] = sub__sidelicks(lick_cell, sides,hit_history);

figure; set(gcf,'Position',[ 440   545   828   189]);

% lick time as function of trial #  - side coded
axes('Position',[0.09 0.13 0.7 0.7]);
line([0 length(mega_licks)+1], [30 30],'LineStyle',':','Color', [ 1 1 1]*0.3, 'LineWidth',2);hold on;
plot(mega_licks,'.k');
plot(lc, left_licks,'.b');
plot(rc, right_licks, '.r');
ylabel('Lick duration(s)');
title(sprintf('%s: %s', ratname, indate));
set(gca,'FontSize',14,'FontWeight','bold');
%axes__format(gca);

% 
lft_mean = mean(left_licks); lft_sd = std(left_licks);
rt_mean = mean(right_licks); rt_sd = std(right_licks);

% Average/SD licking time
axes('Position',[0.85 0.13 0.1 0.7]); r=1;
patch([r-0.2 r-0.2 r r], [0 lft_mean lft_mean 0], 'b'); hold on;
plot(ones(size(left_licks))*(r-0.1), left_licks, '.r','Color', [0.5 0.5 1]);
line([r-0.1 r-0.1], [lft_mean - lft_sd, lft_mean+lft_sd], 'LineWidth',2);

patch([r r r+0.2 r+0.2], [0 rt_mean rt_mean 0], 'r'); hold on;
plot(ones(size(right_licks))*(r+0.1), right_licks, '.r', 'Color', [1 0.5 0.5]);
line([r+0.1 r+0.1], [rt_mean - rt_sd, rt_mean+rt_sd], 'LineWidth',2);
ylabel('Mean(SD)');
set(gca,'XLim',[0.6 1.4], 'XTick',[]);
%axes__format(gca);

set(gcf,'Menubar','none','Toolbar','none');
% set(gca,'XTick', 1:length(ratlist), 'XTickLabel', ratlist);
% %        min(yl(2), 120)
% yl = get(gca,'YLim'); set(gca,'YLim',[0 30],'XLim',[0 length(ratlist)+1]);
% 

% ----------------------------------------------------------------
% Subroutines

% licks during a reward state (everything from reward state of current
% state to wait_for_cpoke of next trial
function [lickies] = sub__rewardlicks(p)

curr = p{1};
if isempty(curr.left_reward), rwd_state = curr.right_reward;
else rwd_state = curr.left_reward; end;

st1 = rwd_state(1,1); % start of current reward time
cond = {'in', '>=', st1};
lickies.left = get_pokes_fancy(p{1}, 'left', cond, 'all');
lickies.right = get_pokes_fancy(p{1}, 'right', cond, 'all');
lickies.center = get_pokes_fancy(p{1}, 'center', cond, 'all');

if length(p) > 1
    st2 = p{2}.wait_for_cpoke(1,1);
    cond = {'in', '<=', st2};
    lickies.left = [lickies.left; get_pokes_fancy(p{2}, 'left', cond, 'all')];
    lickies.right = [lickies.right; get_pokes_fancy(p{2}, 'right', cond, 'all')];
    lickies.center = [lickies.center; get_pokes_fancy(p{2}, 'center', cond, 'all')];
end;


function [mega l r] = sub__sidelicks(licks, sides,hh)

lc = intersect(find(sides == 1), find(hh==1));
rc = intersect(find(sides == 0), find(hh==1));

mega = NaN(size(sides));
l=NaN(size(lc));
for k = 1:length(lc)
    tmp = licks{lc(k)}.left;
    l(k) = tmp(end,2) - tmp(1,1); % total lick time for this reward
    mega(lc(k)) = l(k);
end;

for k = 1:length(rc)
    tmp = licks{rc(k)}.right;
    r(k) = tmp(end,2) - tmp(1,1);
    mega(rc(k)) = r(k);
end;