function [mix2afc_ratname] = summry_070226(ratname, session)
load(['..\SoloData\Data\NL_Analysis\nl2afc_mix2' filesep ratname '_' session]);
keyboard;
mix2afc_ratname = {'bs_name','bs_score','test_name','test_score','test_freq',...
    'distr_name','distr_score','distr_freq'};
ranges = input('Row ranges: {Baseline, Testing, Distractor} ');
bs_name = score_blk{ranges{1}(1),1};
bs_score = mean(cell2mat(score_blk(ranges{1},3)));
test_name = score_blk{ranges{2}(1),1};
test_score = mean(cell2mat(score_blk(ranges{2},3)));
test_freq = length(ranges{2})/(length(ranges{2})+length(ranges{3}));
distr_name = score_blk{ranges{3}(1),1};
distr_score = mean(cell2mat(score_blk(ranges{3},3)));
distr_freq = length(ranges{3})/(length(ranges{2})+length(ranges{3}));
mix2afc_ratname = [mix2afc_ratname; {bs_name,bs_score,test_name,test_score,test_freq,...
    distr_name,distr_score,distr_freq}];
figure; bar([bs_score test_score distr_score]);
set(gca,'XTickLabel',{mix2afc_ratname{1,[2 4 7]}},'YLim',[30 100]);
title([ratname 'EB/Prp' bs_name 'Freq' num2str(test_freq)]);