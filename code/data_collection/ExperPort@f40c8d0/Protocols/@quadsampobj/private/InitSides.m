function [x, y, side_list, WaterDelivery, RewardPorts, ...
    update_sidesplot_fn, set_next_side_fn] = ...
    InitSides(x, y, n_done_trials, hit_history, maxtrials, obj);    
%
% [x, y, side_list, WaterDelivery, RewardPorts, update_sidesplot_fn, set_next_side_fn] = ...
%    InitSides(x, y, n_done_trials, hit_history, maxtrials, obj);    
%
% args:    x, y                  current UI pos, in pixels
%          n_done_trials         handle to number of completed trials
%          hit_history           handle to history of hits versus errors
%                                (vector: 1=hit, 0=error, len=n_done_trials)
%          maxtrials             max number of trials in experiment
%          obj                   A locsamp3obj object
%
% returns: x, y                  updated UI pos
%          side_list             handle to vector of correct sides,
%                                   one per trial.
%          WaterDelivery         handle to type of delivery (direct, etc).
%          RewardPorts           handle to type of reward (correct, etc.)
%          update_sidesplot_fn  function that updates sides and rewards plot
%          set_next_side_fn     fn, uses error hist to override correct side
%


    % The three params that together with the hit history, control
    % upcoming correct sides:
    EditParam(obj, 'Stubbornness', 0,   x, y); next_row(y);
    MenuParam(obj, 'MaxSame', {'1' '2' '3' '4' '5' '6' '7' '8' '9' '10' 'Inf'}, 6, x, y); next_row(y);
    EditParam(obj, 'LeftProb',     0.5, x, y); next_row(y);
    next_row(y, 0.5);
    SoloParamHandle(obj, 'side_list', 'value', zeros(1, value(maxtrials)));
    
    % A function to compute the future sides:
    SoloFunction('set_future_sides', 'rw_args', {'side_list'}, ...
        'ro_args', {'n_done_trials', 'maxtrials', 'MaxSame', 'LeftProb'});
    set_callback({LeftProb, MaxSame}, {'set_future_sides' ; 'update_sides_and_rewards_plot'});

    % A function that determines the immediate next side, based on hit
    % history
    SoloFunction('set_next_side', 'rw_args', {'side_list'}, ...
        'ro_args', {'n_done_trials', 'maxtrials', 'hit_history', 'Stubbornness', 'LeftProb'});
    
    % Params that control the reward mode:
    MenuParam(obj, 'WaterDelivery', {'direct', 'next corr poke', 'only if nxt pke corr'}, 2, x, y); next_row(y);
    MenuParam(obj, 'RewardPorts',   {'correct port', 'both ports'},1, x, y); next_row(y);

    % A function that updates a plot showing the sides and the rewards
    SoloFunction('update_sides_and_rewards_plot', 'ro_args', ...
        {'side_list', 'n_done_trials', 'hit_history', 'WaterDelivery', 'RewardPorts'});
        
    set_future_sides(obj);
    update_sides_and_rewards_plot(obj);

    update_sidesplot_fn = 'update_sides_and_rewards_plot';
    set_next_side_fn    = 'set_next_side';
    
    return;


    
