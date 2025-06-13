function [] = psychblock_side_runs(ratname, from, to)

dates = get_files(ratname,'fromdate', from,'todate', to);

runlen = [];

for d =1:length(dates)
    r = sub__runlen_session(ratname, dates{d}, 0);
    runlen = horzcat(runlen, r);
end;

runbins = 1:10;
figure; hist(runlen, runbins);
ylabel('# of such runs'); xlabel('Run length');
title(sprintf('%s: Length of runs in psych stimulus samples\n(%s to %s)', ratname, from, to));
axes__format(gca);



function [runlen] = sub__runlen_session(ratname,indate, graphic)
load_datafile(ratname, indate);

b_on = cell2mat(saved_history.BlocksSection_Blocks_Switch);
sl = saved.SidesSection_side_list;

sl = sl(b_on == 1);
diffsl = diff(sl); 
changes = find(diffsl ~= 0);

runlen = changes(1);

if graphic > 0
figure;
plot(sl,'.k');
hold on;
plot(changes, ones(size(changes))*3, '*b');
set(gca,'YTick',[0 1 3], 'YTickLabel',{'R', 'L', 'Swtch'},'YLim',[-1 6]);
end;

for c = 2:length(changes)
    
    runlen = horzcat(runlen, changes(c) - changes(c-1));
    if graphic > 0
    t=text((changes(c-1)+changes(c))/2, 5, sprintf('%i', runlen(end)));
    set(t,'FontSize',12,'FontWEight','bold');
    end;
end;


