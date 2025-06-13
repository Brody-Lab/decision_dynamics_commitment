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
        SoloFunctionAddVars('BlockControl','ro_args',{'LeftRewards','RightRewards'});
        
        DispParam(obj, 'Rewards',     0, x, y); next_row(y);
        SoloParamHandle(obj,'RewardTracker', 'value', 0);
        DispParam(obj, 'Trials',      0, x, y); next_row(y);
        SoloParamHandle(obj,'TrialTracker', 'value', 0);
        next_row(y);
        
        % store the value of rat performance, with columns: Score, Hits, Miss, False
       % SoloParamHandle(obj, 'perform_left', 'value', ones(maxtrials,4)*(-1)); 
       % SoloParamHandle(obj, 'perform_right', 'value', ones(maxtrials,4)*(-1)); 
       % SoloParamHandle(obj, 'perform_overall', 'value', ones(maxtrials,4)*(-1)); 
        
       % SoloFunctionAddVars('BlockControl', 'ro_args', {'perform_left', 'perform_right','perform_overall'});
        
        LastTrialevents.value = [];

        SubheaderParam(obj, 'hitrt_sbh', 'Hit History', x, y); next_row(y);
        
  
    case 'update',
        TrialTracker.value = value(TrialTracker) + 1;
        sides_till_now = side_list(1:n_done_trials);
        Trials.value = sprintf('%i (L:%i, R:%i) ', value(TrialTracker), sum(sides_till_now), length(find(sides_till_now == 0)));
        evs = value(LastTrialEvents);
        rts = value(RealTimeStates);
        
        hh = value(hit_history);

        % Note: It's fine to not have left or right answer poke after direct
        % delivery in Classical2afc
        % Find first left-right response after odor delivery:
        u = find(evs(:,1)==rts.wait_for_apoke  & (evs(:,2)==3 | evs(:,2)==5));

        % If direct delivery, then it's always a hit
        if (length(find(evs(:,1)== rts.left_dirdel)) > 0)  | (length(find(evs(:,1) == rts.right_dirdel)) > 0)
            hh(n_done_trials) = 1;
            if side_list(n_done_trials)==1,
                rew = value(LeftRewards); rew(n_done_trials)=1; LeftRewards.value = rew;
            elseif side_list(n_done_trials)==0,
                rew = value(RightRewards); rew(n_done_trials)=1; RightRewards.value = rew;
            end;
            % If it's corr poke or "only if"  poke, then its a hit only if the side poke
            % matched the trial side
        elseif ~isempty(u)
            if (evs(u(1),2)==3  &  side_list(n_done_trials)==1) % left
                rew= value(LeftRewards); rew(n_done_trials)=1; LeftRewards.value= rew;
                hh(n_done_trials) = 1;
            elseif (evs(u(1),2)==5  &  side_list(n_done_trials)==0),
                rew=value(RightRewards); rew(n_done_trials)=1; RightRewards.value=rew;
                hh(n_done_trials) = 1;
            else % no poke and not direct delivery
                hh(n_done_trials) = 0;
            end;
        else
            hh(n_done_trials) = 0;
        end;

        if hh(n_done_trials) == 1, RewardTracker.value = value(RewardTracker)+1; end;
        
        % update Reward View
        rew_val = sprintf('%i (L:%i, R: %i) ', value(RewardTracker), sum(value(LeftRewards)), sum(value(RightRewards)));
        Rewards.value = rew_val;
        % reset the events store
        push_history(LastTrialEvents);

        LastTrialEvents.value = [];
        hit_history.value = hh;
        prevtrial.value = parse_trial(evs, rts);
        
    otherwise,
        error(['Don''t know how to handle action ' action]);
end;