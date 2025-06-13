function [stim_hh] = stimulus_hit_rate(saved, saved_history, task)

% This method is used for tasks with interleaved blocks of pitch and
% duration discrimination (e.g. pitch_disc2obj, dual_discobj). 
% Given the saved, saved_history and taskname, it
% computes the hit rate for each of the four stimulus types (pitch
% discrimination L/R, duration discrimination L/R)

% Pitch discrimination trials are those that have 1KHz on the LHS and 15
% KHz set for RHS
pitch_L = cell2mat(saved_history.ChordSection_Tone_Freq_L);
pitch_R = cell2mat(saved_history.ChordSection_Tone_Freq_R);

dur_L = cell2mat(saved_history.ChordSection_Tone_Dur_L);
dur_R = cell2mat(saved_history.ChordSection_Tone_Dur_R);

% LHS is 1, RHS is 0.
sides = saved.SidesSection_side_list;

% 15KHz tones - RHS
stim_type1 = find(pitch_R==15);
stim_type1 = intersect(stim_type1, find(sides == 0));

% 3.8KHz < 0.5s - LHS
freq_ind = intersect(find(pitch_L > 1), find(pitch_L < 13));
stim_type2 = intersect(freq_ind, find(dur_L < 0.5));
stim_type2 = intersect(stim_type2, find(sides == 1));

% 1KHz - LHS
stim_type3 = find(pitch_L==1);
stim_type3 = intersect(stim_type3, find(sides == 1));

% 3.8KHz > 0.5s - RHS
stim_type4 = intersect(freq_ind, find(dur_R > 0.5));
stim_type4 = intersect(stim_type4, find(sides == 0));

hh = eval(['saved.' task '_hit_history']);
hh = hh(find(~isnan(hh)));
dummy = 1:length(hh);

stim_type1 = intersect(stim_type1, dummy);
stim_type2 = intersect(stim_type2, dummy);
stim_type3 = intersect(stim_type3, dummy);
stim_type4 = intersect(stim_type4, dummy);
2;

stim_hh = zeros(1,4);
for i = 1:4
    len = eval(['length(stim_type' num2str(i) ')']);
    str = [ 'sum(hh(stim_type' num2str(i) '))/len'];
    stim_hh(i) = eval(str);
end;

% Printout
result = char( ...
    'Hit rate for different stimuli in dual_discobj', ...
    '----------------------------------------------', ...
    ['15KHz @ 0.5s (RHS): ' sprintf('%2.2f', stim_hh(1)*100)], ...
    ['3.8KHz @ 0.3s (LHS): ' sprintf('%2.2f', stim_hh(2)*100)], ...
    ['1KHz @ 0.5s (LHS): ' sprintf('%2.2f', stim_hh(3)*100)], ...
    ['3.8KHz @ 1.0 (RHS): ' sprintf('%2.2f', stim_hh(4)*100)] ...
    );

result
