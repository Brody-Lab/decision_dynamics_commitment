function [] = side_correction_play(ratname, indate)

load_datafile(ratname, indate);

b_on = cell2mat(saved_history.BlocksSection_Blocks_Switch);
sl = saved.SidesSection_side_list;

sl = sl(b_on == 1);

  [sl_sub, no_change2] = correct_alternation(sl, 0.5, 5);   % HARDCODED value: Any block of alternation > 5 is considered a run
%[sltmp nc] = MaxSame_correction(sl, 5)

2;