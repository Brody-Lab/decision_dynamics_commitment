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

        DispParam(obj, 'LeftRewards', 0, x, y); next_row(y);
        DispParam(obj, 'RightRewards',0, x, y); next_row(y);
        DispParam(obj, 'Rewards',     0, x, y); next_row(y);
        DispParam(obj, 'Trials',      0, x, y); next_row(y);
        
        next_row(y);
        
        DispParam(obj, 'Last10',      0, x, y); next_row(y);
        DispParam(obj, 'Last20',      0, x, y); next_row(y);
        DispParam(obj, 'Last40',      0, x, y); next_row(y);
        DispParam(obj, 'Last80',      0, x, y); next_row(y);
        next_row(y,0.5);

        LastTrialevents.value = [];
        
        SubheaderParam(obj, 'hitrt_sbh', 'Hit History', x, y); next_row(y);
        
    case 'update',
        Trials.value = Trials + 1;
        evs = value(LastTrialEvents);
        rts = value(RealTimeStates);

        % Find first left-right response after tone:
        u = find(evs(:,1)==rts.wait_for_apoke  & (evs(:,2)==3 | evs(:,2)==5));
        if isempty(u), % no wat-for-answer poke, must've been direct delivery
            % Find dirdel state and first left-right response after that
            u  = find(evs(:,1)==rts.left_dirdel  |  evs(:,1)==rts.right_dirdel);
            if isempty(u), error(['No wait-for-answer, no dir del state!']); end;
            u2 = find(evs(u(1):end,2)==3  |  evs(u(1):end,2)==5);
            if isempty(u2), error('No left-right answer after dir del state!'); end;
            u = u2(1) + u(1)-1;
        end;
        % Now, did we go right when right was correct or left when left was
        % correct?
        if      (evs(u(1),2)==3  &  side_list(n_done_trials)==1)  |  ...
                (evs(u(1),2)==5  &  side_list(n_done_trials)==0),
            hit_history(n_done_trials) = 1;
        else
            hit_history(n_done_trials) = 0;
        end;

        u1 = find(evs(:,1) == rts.left_reward);
        u2 = find(evs(:,1) == rts.right_reward);

        % Count rewards
        if ~isempty(u1), LeftRewards.value  = LeftRewards+1;  end;
        if ~isempty(u2), RightRewards.value = RightRewards+1; end;
        if ~isempty(u1) | ~isempty(u2),
            Rewards.value = Rewards+1;
        end;
        
        % Update the GUI
        for del=[10 20 40 80],
            mn = max([1 n_done_trials-del]);
            muhits = mean(hit_history(mn:n_done_trials));
            eval(['Last' num2str(del) '.value = muhits;']);
        end;    
            
        % reset the events store
        push_history(LastTrialEvents);
        LastTrialEvents.value = [];
        
    otherwise,
        error(['Don''t know how to handle action ' action]);
end;    

    

    

