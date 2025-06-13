function [x, y] = RewardsSection(obj, action, x, y);
%
% [x, y] = InitRewards_Display(x, y, obj);
%
% args:    x, y                 current UI pos, in pixels
%          obj                  A locsamp3obj object
%
% returns: x, y                 updated UI pos
%
% Updates (and stores) history of various measures of hit (or reward
% rates); e.g. Hit rate for Last 20 trials, # Right rewards, etc.,
% Also updates the on-screen hit-rate display
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

GetSoloFunctionArgs;
% SoloFunction('RewardsSection', 'rw_args', {'LastTrialEvents', 'hit_history'}, ...
%    'ro_args', {'RealTimeStates', 'side_list', 'n_done_trials', 'n_started_trials'});

switch action,
    case 'init',

        SoloParamHandle(obj, 'LeftRewards', 'value', zeros(1, maxtrials)); %next_row(y);
        SoloParamHandle(obj, 'RightRewards', 'value',zeros(1, maxtrials)); %next_row(y);
        DispParam(obj, 'Rewards',     0, x, y); next_row(y);
        SoloParamHandle(obj,'RewardTracker', 'value', 0);
        DispParam(obj, 'Trials',      0, x, y); next_row(y);
        SoloParamHandle(obj,'TrialTracker', 'value', 0);

        LastTrialevents.value = [];

        SubheaderParam(obj, 'hitrt_sbh', 'Hit History', x, y); next_row(y);

    case 'update',
        TrialTracker.value = value(TrialTracker) + 1;
        sides_till_now = side_list(1:n_done_trials);
        Trials.value = sprintf('%i (L:%i, R:%i) ', value(TrialTracker), sum(sides_till_now), length(find(sides_till_now == 0)));
        evs = value(LastTrialEvents);
        rts = value(RealTimeStates);
        
        hh = value(hit_history);

        uhit          = find(evs(:,1)==rts.hit_state);
        uleft_reward  = find(evs(:,1)==rts.left_reward  | evs(:,1)==rts.left_dirdel);
        uright_reward = find(evs(:,1)==rts.right_reward | evs(:,1)==rts.right_dirdel);

        if ~isempty(uhit),          hh(n_done_trials)           = 1; else hh(n_done_trials)          = 0; end;
        if ~isempty(uleft_reward),  LeftRewards(n_done_trials)  = 1; else LeftRewards(n_done_trials) = 0; end;
        if ~isempty(uright_reward), RightRewards(n_done_trials) = 1; else RightRewards(n_done_trials)= 0; end;
        

        if hh(n_done_trials) == 1, RewardTracker.value = RewardTracker+1; end;

        % update Reward View
        rew_val = sprintf('%i (L:%i, R: %i) ', value(RewardTracker), sum(value(LeftRewards)), sum(value(RightRewards)));
        Rewards.value = rew_val;

        % reset the events store
        push_history(LastTrialEvents);

        LastTrialEvents.value = [];
        hit_history.value = hh;
        prevtrial.value = parse_trial(evs, rts);

        
  case 'update_events',
        Event = GetParam('rpbox', 'event', 'user');
        LastTrialEvents.value = [value(LastTrialEvents) ; Event];

        
    otherwise,
        error(['Don''t know how to handle action ' action]);
end;