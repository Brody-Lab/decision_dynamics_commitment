function [training_stages] = define_training_stages(obj)
% 
% A protocol-specific page that defines strings for SessionModel
% Each training stage is defined by a train_string and completion_string.
% The output of this function is an r-by-3 cell array; for description of
% each of the three columns, see @SessionModel/add_training_stage_many.m


training_stages = cell(0,0);

% Stage 1:
% increment MinValidPokeDur by 0.1 for each trial
training_stages{1,1} = char( ...
    'VpdsSection_MinValidPokeDur.value_callback = value(VpdsSection_MinValidPokeDur) + 0.1');
training_stages{1,2} = 'single(value(VpdsSection_MinValidPokeDur)) == single(0.2)';

% Stage 2:
% Now increase duration of both tones till the shorter duration is attained
training_stages{2,1} = char( ...
    'ChordSection_Tone_Dur1.value_callback = value(ChordSection_Tone_Dur1) + 0.1;', ...
    'ChordSection_Tone_Dur2.value_callback = value(ChordSection_Tone_Dur2) + 0.1;');
training_stages{2,2} = 'single(value(ChordSection_Tone_Dur1)) == single(0.3)';

% Stage 3:
% Then increase only the second tone's duration
training_stages{3,1} = char( ...
    'ChordSection_Tone_Dur2.value_callback = value(ChordSection_Tone_Dur2) + 0.1;');
training_stages{3,2} = 'single(value(ChordSection_Tone_Dur2)) == single(0.5)';


% finally, start from scratch: mark everything as being incomplete
training_stages(1:end,3) = {0};