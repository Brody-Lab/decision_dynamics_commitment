function [changes, evs, rts] = count_punishment_changes(rat, task, date, f_ver)

load_datafile(rat, task, date, f_ver);

evs = eval(['saved_history.' task '_LastTrialEvents']); evs = size(evs,1);
rts = eval(['saved_history.' task '_RealTimeStates']); rts = size(rts,1);

changes = 0;
bb_sound = saved_history.TimesSection_BadBoySPL;

for i = 2:size(bb_sound,1)
    if ~strcmp(bb_sound{i-1},bb_sound{i})
        changes = changes+1;
    end;
end;

wn_sound = saved_history.TimesSection_WN_SPL;

for i = 2:size(wn_sound,1)
    if wn_sound{i-1} ~= wn_sound{i}
        changes = changes+1;
    end;
end;




