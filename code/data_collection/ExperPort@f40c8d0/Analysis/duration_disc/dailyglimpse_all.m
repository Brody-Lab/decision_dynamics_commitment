function [] = dailyglimpse_all(date)

ratlist = rat_task_table('','get_current',1);

pos = get(0,'ScreenSize');

x = 10; y = 10;
wd = 400;
ht = 300;
[rathosts notfound] = show_hosts('','from',date(1:end-1),'to',date(1:end-1),'show_all',1,'quiet',1);

[b idx] = sort(rathosts(:,2));

tmplist = {};
for k = 1:length(idx)
    tmplist(end+1,:) = ratlist(idx(k),:);
end;
ratlist = tmplist;
hostlist = rathosts(idx,2);
prevhost = '';
prevcolour = [0 0 0];
for r = 1:rows(ratlist)
    sessionperf(ratlist{r,1}, ratlist{r,2}, date);
    currhost = rathosts{r,2};
    if strcmpi(currhost, prevhost),
        currcolour = prevcolour;
    else
        currcolour = rand(1,3);
    end;
set(gcf,'Position',[x     y   wd   ht],'Color', currcolour);
set(gcf,'Tag','sessionview');
h = uicontrol(gcf,'Style','text','String',rathosts{r,2},'FontSize',14);
p = get(h,'Position'); set(h,'Position',[p(1) p(2) p(3)*1.5, p(4)]);
datacursormode on;
y = y + (1.1*ht);
if (pos(4)-y) < ht
    x = x + wd;
    y = 10;
end;

prevcolour = currcolour;
prevhost = currhost;

end;

fprintf(1,'-----------------------------------------\n');
fprintf(1,'Did not find data for the following rats:\n');
fprintf(1,'-----------------------------------------\n');
for r=1:rows(notfound), fprintf(1,'%s\n',notfound{r});end;
fprintf(1,'-----------------------------------------\n');