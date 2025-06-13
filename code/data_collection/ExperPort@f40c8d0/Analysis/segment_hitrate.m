function [segrate] = segment_hitrate(rat, task, date, segs)

% segs is a c-by-2 cell array, each row of which has the start and end
% trial for which hit rate is required.

load_datafile(rat, task, date(1:end-1), date(end));
hh = eval(['saved.' task '_hit_history']);
t = eval(['saved.' task '_n_done_trials']);

hh = hh(1:t);

for k = 1:rows(segs)
    try,
       segrate(k,1:3) = { segs{k,1} segs{k,2} mean(hh(segs{k,1}:segs{k,2})) };
    catch
        error('Sorry, could not get hit rate for [%i, %i]', segs{k,1}, segs{k,2});
    end;
end;