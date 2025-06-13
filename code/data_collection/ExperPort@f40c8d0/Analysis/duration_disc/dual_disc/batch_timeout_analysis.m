function [result_cell] = batch_timeout_analysis()

rat = 'chanakya';
task = 'dual_discobj';
%date = '051203a';


global Solo_datadir;
if isempty(Solo_datadir), mystartup; end;


dates = available_dates(rat, task, 'realign', 1);
result_cell = cell(0,0);
result_cell(1) = {'Date' 'Timeout_Distribution_Dual', 'Timeout Aggregation', 'Cross testing'};
% 1. date
% 2. result of timeout_distribution_dual
% 3. result of aggregation
% 4. result of cross_tester

for k = 1:rows(dates)
    date = deblank(dates(k,:))
    load_datafile(rat, task, date(1:end-1), date(end), 'realign', 1);
    evs = saved_history.dual_discobj_LastTrialEvents;
    rts = saved_history.dual_discobj_RealTimeStates;
  %  try
        p = parse_trial(evs, rts);
%     catch
%         error('Darn it! Crashing when parse_trial-ing!');
%     end;

    sound_evs = parse_sound_evs_dual(saved, saved_history);
    to = timeout_distribution_dual(p, sound_evs);
    agg = timeout_aggregator(to);
    xtest = cross_tester(p, to);

    result_cell{k+1,1} = date;
    result_cell{k+1,2} = to;
    result_cell{k+1,3} = agg;
    result_cell{k+1,4} = xtest;

end;


