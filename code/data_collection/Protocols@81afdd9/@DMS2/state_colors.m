function SC = state_colors(obj) %#ok<INUSD>

% Colors that the various states take when plotting
SC = struct( ...
    'wait_for_cpoke',          [129  77 110]/255, ...  % plum
    'cpoke',                   [255   0 110]/255, ...  % pink
    'wait_for_sounds_to_end',  [255 156 187]/255, ...  % violet
    'give_reward',             [ 40  98  40]/255, ...  % dark green
    'go_sound_state',          [166 146  43]/255, ...  % gold
    'wait_for_spoke',          [188  77 110]/255, ...  % pink
    'hit_state',               [50  255  50]/255, ...  % bright green
    'drink_state',             [ 16  33  74]/255, ...  % dark blue
    'temp_error_state',        [255 255   0]/255, ...  % bright yellow
    'wait_for_spoke_retry',    [243  18  85]/255, ...  % bright pink
    'retry_hit_state',         [50  255  50]/255, ...  % bright green
    'error_state',             [255   0   0]/255, ...  % bright red
    'violation_state',         [255 119   0]/255, ...  % orange
    'general_final_state',     [128 128 128]/255, ...  % gray
    'hit_final_state',         [183 229 197]/255, ...  % gray/green
    'error_final_state',       [218 168 168]/255, ...  % gray/red
    'violation_final_state',   [208 165 128]/255, ...  % gay/red
    'state_0',                 [255 255 255]/255, ...  % white
    'check_next_trial_ready',  [ 33  33  33]/255);     % black