function SC = state_colors(obj) %#ok<INUSD>

SC = struct( ...
      'wait_for_cin',       [129  77 110]/255, ...  % plum
      'context',            [255   0 255]/255, ...  % magenta
      'nicstim',            [200   0 255]/255, ...  % purple
      'stimon_nosein',      [255 100 200]/255, ...  % pink
      'stimon_noseout',     [255 100 200]/255, ...  % pink
      'gostate',            [255 165   0]/255, ...  % orange
      'wait_for_cout',      [200 190 100]/255, ...  % dark mustard
      'csgap',              [255 236 139]/255, ...  % light goldenrod
      'stim_on',            [255 161 137]/255, ...  % peach 
      'stim_off',           [255 161 137]/255, ...  % peach 
      'wait_for_spoke',     [188  77 110]/255, ...  % fuscia
      'son_reward_chooser', [  0 255   0]/255, ...  % green
      'soff_reward_chooser',[  0 255   0]/255, ...  % green
      'reward_son',         [  0 255   0]/255, ...  % green
      'reward_soffwon',     [  0 255   0]/255, ...  % green
      'reward_soff',        [  0 255   0]/255, ...  % green
      'reward_big_son',     [  0 255   0]/255, ...  % green
      'reward_big_soffwon', [  0 255   0]/255, ...  % green
      'reward_big_soff',    [  0 255   0]/255, ...  % green
      'post_reward_on',     [  0 255   0]/255, ...  % green
      'post_reward_off',    [  0 255   0]/255, ...  % green
      'soft_drink_time',    [  0 255   0]/255, ...  % green
      'warndanger_warning', [0.3  0    0],    ...   % dark maroon
      'warndanger_danger',  [0.5  0.05 0.05], ...   % lighter maroon
      'reinit_cpoke',       [180   0   0]/255, ...  % medium red
      'error_state',        [255   0   0]/255, ...  % red
      'temperror',          [1   1   0  ],     ...  % yellow
      'start_new_trial',    [0.5 0.5 0.5],     ...  % dark gray
      'state_0',            [1   1   1  ],     ...  % white
      'check_next_trial_ready',     [0.7 0.7 0.7]);