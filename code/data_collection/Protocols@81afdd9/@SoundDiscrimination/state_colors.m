function SC = state_colors(obj) %#ok<INUSD>

SC = struct( ...
      'iti',               [  0   0   0]/255, ...  % black  
      'wait_for_cin1',     [129  77 110]/255, ...  % plum
      'wait_for_lin1',     [129  77 110]/255, ...  % plum
      'wait_for_rin1',     [129  77 110]/255, ...  % plum
      'var_gap1',          [255 236 139]/255, ...  % light goldenrod
      'var_gap2',          [255 161 137]/255, ...  % peach 
      'wait_for_cin2',     [188  77 110]/255, ...  % fuscia
      'wait_for_lin2',     [188  77 110]/255, ...  % fuscia
      'center_flash',      [188  77 110]/255, ...  % fuscia
      'left_flash',        [188  77 110]/255, ...  % fuscia
      'vargap2_offset',    [106 129 110]/255, ...  % dark sage
      'wait_for_spoke',    [132 161 137]/255, ...  % sage
      'temperror',         [61  131 157]/255, ...  % aqua teal
      'prereward',         [50  255  50]/255, ...  % green
      'soft_drink_time',   [50  255  50]/255, ...  % green
      'warndanger_warning',[0.3  0    0],    ...   % dark maroon
      'warndanger_danger', [0.5  0.05 0.05], ...   % lighter maroon
      'reinit_cpoke',      [180   0   0]/255, ...  % medium red
      'error_state',       [255   0   0]/255, ...  % red
      'no_reward',         [1   1   0  ],     ...  % yellow
      'state_0',           [1   1   1  ],  ...
      'check_next_trial_ready',     [0.7 0.7 0.7]);