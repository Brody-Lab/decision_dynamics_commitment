function [] = timeout_side_bias(ratname, date)

datafields = {'events','rts','sides'};
get_fields(ratname,'use_dateset', 'range', 'from',date,'to',date,'datafields',datafields);

tcount = sub__timeout_count(events);
left = find(sides == 1);
to_left = tcount(left);
right  = find(sides == 0);
to_right = tcount(right);

figure;bar([mean(to_left) mean(to_right)]);
set(gca,'XTick',[1 2], 'XTickLabel',{'On LEFT trials', 'On RIGHT trials'});
ylabel('Average # timeouts');
title(sprintf('%s: %s', ratname, date));

function [tcount] = sub__timeout_count(p)
tcount = [];
for k = 1:rows(p)
    tcount = horzcat(tcount, rows(p{k}.timeout));
end