load data/pavarotti_data_050503b

seq = rpbox_trial_sequence(saved);
cseq = console_trial_sequence(saved);

ncpokes = saved.ncenterpokes;
plot(saved.centerpoketimes(1:ncpokes), saved.centerpokedurations(1:ncpokes), '.');

l = vlines(seq(:,2));


set(l(find(cseq(:,3)==1)), 'Color', 'g')
set(l(find(cseq(:,3)==0)), 'Color', 'r')

