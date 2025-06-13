function [] = punish_state_occurrences(ratname, indate)
% shows average occurrences of punishment states 

statename = 'iti';

itidur = [];
p=get_pstruct(ratname, indate);
for k = 1:rows(p)
d = eval(['p{k}.' statename '(end,2) - p{k}.' statename '(1,1);']);  d2=0;
    %     d = p{k}.iti(end,2) - p{k}.iti(1,1); d2 = 0;
%     if ~isempty(p{k}.extra_iti)
%         d2 = p{k}.extra_iti(end,2) - p{k}.extra_iti(1,1);
%     end;
    itidur = horzcat(itidur,d + d2);
end;

2;

figure; plot(itidur/60,'.b'); title(sprintf('%s:%s (%s)',ratname, indate, statename));
blah = max(itidur/60);
set(gca,'YTick', [0 0.5 1 2 5 10], 'YGrid','on');
set(gca,'YLim',[0 blah+5]);
ylabel('minutes'); xlabel('trial #');
set(gcf,'Position',[440 500 700 230]);
axes__format(gca);

fprintf(1,'Minutes spent in ITI = %1.2f', sum(itidur) / 60);