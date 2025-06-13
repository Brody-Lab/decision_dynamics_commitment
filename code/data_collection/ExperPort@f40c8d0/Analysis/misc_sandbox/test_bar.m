function [] = test_bar

mymean = [ 2 2; 3 3; 4 4;];
mysem = [1 1; 1.5 1.5; 0.5 1;];

figure;

barweb(mymean, mysem, [], {'A','B','C'}, [],'Rat','Avg. hit rate',[],[],{'Pre-lesion','Post-lesion'});