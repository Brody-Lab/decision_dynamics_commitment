function [] = verify_trial_length(ratname,doffset)
% Matches recorded event length of a trial to length of trial as parameters
% should have set them.

times = state_times(ratname, doffset, doffset);
pstruct = get_pstruct(ratname, getdate(doffset));

load_datafile(ratname,getdate(doffset));

vpd = saved.VpdsSection_vpds_list;
left = saved.ChordSection_tone1_list;
right = saved.ChordSection_tone2_list;
sides = saved.SidesSection_side_list;
pc = saved.ChordSection_prechord_list;

tone = zeros(length(left));
tone(find(sides > 0)) = left(find(sides>0));
tone(find(sides < 1)) = right(find(sides < 1));
n = saved.duration_discobj_n_done_trials;

vpd = vpd(2:n);
sides = sides(2:n);
tone = tone(2:n);
pc = pc(2:n);

trial_length = vpd; %+ tone + pc;
figure;
plot(1:length(trial_length),trial_length,'.b');
event_dur = [];
for k = 2:rows(pstruct)
    prec= pstruct{k}.pre_chord;
    dur = prec(:,2)-prec(:,1);
    event_dur = horzcat(event_dur,max(dur));
end;
hold on;
plot(1:length(event_dur), event_dur, '.r');

diffs = event_dur - vpd;

plot(1:length(diffs), diffs,'.g');
%set(gca,'XLim',[20 30]);
t=title(sprintf('Trial Length for %s on %s', ratname, getdate(doffset)));
set(t,'FontSize',14);
set(gcf,'Toolbar','none');

