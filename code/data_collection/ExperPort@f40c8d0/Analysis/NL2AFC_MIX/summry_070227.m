function [mix2afc_ratname] = summry_070227(ratname, session)
load(['..\SoloData\Data\NL_Analysis\nl2afc_mix2' filesep ratname '_' session]);
pair1 = 'EB/Prp'; pair2 = 'Hex/CA';
n_epoch = 2;
keyboard;
mix2afc_ratname = {'frequency','score_p1','score_p2'};
for i = 1:n_epoch,
    ranges = input('Row ranges and freq1: {Pair1, Pair2, a} ');
    ratio1 = score_blk{ranges{1}(1),1};
    score1 = mean(cell2mat(score_blk(ranges{1},3)));
    
    ratio2 = score_blk{ranges{2}(1),1};
    score2 = mean(cell2mat(score_blk(ranges{2},3)));
    mix2afc_ratname = [mix2afc_ratname; {ranges{3}, score1, score2}];
end;
pair1 = [pair1 num2str(ratio1)];
pair2 = [pair2 num2str(ratio2)];
figure; hold on;
plot((1:n_epoch),cell2mat(mix2afc_ratname(2:n_epoch+1,2)),'o-b', 'MarkerSize', 12);
plot((1:n_epoch),cell2mat(mix2afc_ratname(2:n_epoch+1,3)),'*-r', 'MarkerSize', 12);
legend(pair1, pair2);
set(gca,'XTick',(1:1:n_epoch),'XTickLabel',{mix2afc_ratname{2:n_epoch+1,1}},'YLim',[30 100],'YGrid','on');
