function [] = timeout_toggling_bbspl(ratname, indate)

load_datafile(ratname, indate);
ratrow = rat_task_table(ratname); task = ratrow{1,2};
n = eval(['saved.' task '_n_done_trials;']);

tolast15 = saved.RewardsSection_to_rate_tracker;
pokelast15 = saved.RewardsSection_poke_rate_tracker;
lprob = cell2mat(saved_history.SidesSection_LeftProb);

bbspl = saved_history.TimesSection_BadBoySPL;

bb = zeros(length(bbspl), 1);
i = find(strcmpi(bbspl, 'normal'));
bb(i) = 1;
i = find(strcmpi(bbspl, 'Louder'));
bb(i) = 2;
i = find(strcmpi(bbspl,'Loudest'));
bb(i) = 3;

tolast15 = tolast15(1:n);
pokelast15 = pokelast15(1:n);
lprob = lprob(1:n);
bb = bb(1:n);

figure;
subplot(4,1,1);
plot(bb,'.b'); set(gca,'XLim',[1 n]); ylabel('bbspl');
subplot(4,1,2);
plot(tolast15,'.k'); set(gca,'XLim',[1 n]); ylabel('to last 15');
hold on;
line([1 n],[1 1], 'LineStyle',':','Color','b');
line([1 n],[1.3 1.3], 'LineStyle',':','Color','r');
subplot(4,1,3);
plot(pokelast15,'.k'); set(gca,'XLim',[1 n]); ylabel('poke last 15');
subplot(4,1,4);
plot(lprob,'.k'); set(gca,'XLim',[1 n]); ylabel('lprob');

2;


