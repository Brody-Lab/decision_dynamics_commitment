function [rxn_times] = rxn_time_wrapper(rat, task, date)

load_datafile(rat, task, date);

evs = eval(['saved_history.' task '_LastTrialEvents']);
rts = eval(['saved_history.' task '_RealTimeStates']);

if rows(rts) == rows(evs) + 1, rts = rts(1:end-1); end;
pstruct = parse_trial(evs, rts);
vlst = saved_history.ChordSection_ValidSoundTime; vlst = cell2mat(vlst);

rxn_times = reaction_times(pstruct, vlst);

hist(rxn_times*1000);
ylabel(sprintf('# Trials'));
xlabel('Reaction times (ms)');
title(sprintf('%s: %s (%s)\nReaction Time Histogram', make_title(rat), make_title(task), date));
