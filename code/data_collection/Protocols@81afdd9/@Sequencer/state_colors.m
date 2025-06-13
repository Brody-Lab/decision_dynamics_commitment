function SC = state_colors(obj) %#ok<INUSD>

SC = struct( ...
      'wait_for_cin',       [129  77 110]/255, ...  % plum
      'wait_for_rpoke1',    [255   0 255]/255, ...  % magenta
      'wait_for_rpoke2',    [255   0 255]/255, ...  % magenta
      'wait_for_rpoke3',    [255   0 255]/255, ...  % magenta
      'wait_for_rpoke4',    [255   0 255]/255, ...  % magenta
      'wait_for_lpoke1',    [150   0 200]/255, ...  % purple
      'wait_for_lpoke2',    [150   0 200]/255, ...  % purple
      'wait_for_lpoke3',    [150   0 200]/255, ...  % purple
      'wait_for_lpoke4',    [150   0 200]/255, ...  % purple
      'soft_drink_time',    [  0 255   0]/255, ...  % green
      'warndanger_warning', [0.3  0    0],    ...   % dark maroon
      'warndanger_danger',  [0.5  0.05 0.05], ...   % lighter maroon
      'reinit_cpoke',       [180   0   0]/255, ...  % medium red
      'error_state',        [255   0   0]/255, ...  % red
      'state_0',            [1   1   1  ],     ...  % white
      'check_next_trial_ready',     [0.7 0.7 0.7]);