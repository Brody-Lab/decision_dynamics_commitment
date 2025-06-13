figure;
set(gcf,'Position',[112 465 1087 633]);
n_epoch = [3 3 3 2 2 2]; 
pair1 = 'EB/Prp'; pair2 = 'Hex/CA';
load('C:\Home\RatExper\SoloData\Data\NL_Analysis\nl2afc_mix2\data_summ_070226a');
ratname = {'xu1_1','xu1_2','xu1_3','xu2_1','xu2_2','xu2_3'};
for i = 1:6,
    mix2afc_ratname = eval(['mix2afc_' ratname{i}]);
    subplot(2,3,i); hold on; 
    plot((1:n_epoch(i)),cell2mat(mix2afc_ratname(2:n_epoch(i)+1,2)),'o-b', 'MarkerSize', 10);
    plot((1:n_epoch(i)),cell2mat(mix2afc_ratname(2:n_epoch(i)+1,3)),'*-r', 'MarkerSize', 12);
    set(gca,'XTick',(1:1:n_epoch(i)),'XTickLabel',{mix2afc_ratname{2:n_epoch(i)+1,1}},...
        'YLim',[30 100],'YGrid','on'); xlabel('Pair1 Frequency');
    legend(pair1, pair2);
end;
    
