function [] = flipped_sides(ratname, date);
%load_datafile('S018','080310a');
load_datafile(ratname, date);

ratrow = rat_task_table(ratname);
task = ratrow{1,2};


n= eval(['saved.' task '_n_done_trials;']);
sl = saved.SidesSection_side_list; sl = sl(1:n);
left = find(sl == 1); right = find(sl == 0);

if strcmpi(task(1:3), 'dur'),
eff = saved.ChordSection_effective_dur;
ylim=[100 600];
else
    eff = saved.ChordSection_effective_pitch;
    ylim = [5 17];
end;

figure;
plot(left, eff(left), '.b');
hold on;
plot(right, eff(right), '.r'); 

text(0.9*n, ylim(2)*0.95, 'Go left', 'Color','b','FontWeight','bold','FontSize',16);
text(0.9*n, ylim(2)*0.9, 'Go right', 'Color','r','FontWeight','bold','FontSize',16);
xlabel('Trial #'); ylabel('Cue value');
t=title(sprintf('%s: Cue-side relationship for %s', ratname,date));
set(t,'FontWeight','bold','FontSize',18);
set(gca,'FontWeight','bold','FontSize',16);


set(gca,'YLim',ylim);

function [stim] = sub__stim_at(x,y, pt)
if min(y) > pt || max(y) < pt % you're asking for a point that isn't on the curve
    stim=-1;
    return;
end;

stim = find(abs(y - pt) == min(abs(y-pt)));