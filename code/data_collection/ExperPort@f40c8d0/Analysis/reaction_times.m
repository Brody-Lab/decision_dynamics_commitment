function [rxn_times] = reaction_times(pstruct, vlst)
% Provides reaction times for trials which have a ValidSoundTime (period of
% GO signal after which a withdrawal is allowed during the GO chord)
% Input args:
% 1. pstruct of the session (output of Analysis/parse_trial.m)
% 2. ValidSoundTimes for all trials in the session (array)
% Returns: Array with reaction times (in seconds) for all trials in the
% session
%
% NOTE:
% (1) The Reaction time is defined as:
% (Time of answer poke) - (Time of allowed withdrawal from center poke)
% (2) pstruct must have the following fields: left_reward, right_reward,
% extra_iti, chord
UNGODLY_HIGH_NO = 10000;

rxn_times = [];
for k = 1:rows(pstruct)
    r = pstruct{k};
    % get first answer poke
    apoke = -45;
    if rows(r.left_reward) > 0      % hit on Left
       dfs = r.left_reward(1,1) - r.left1(:,1);             % last left poke before start of left_reward
       dfs = dfs(find(dfs >= 0)); apoke = r.left_reward(1,1) - min(dfs);                       
    elseif rows(r.right_reward) > 0 % hit on Right
       dfs = r.right_reward(1,1) - r.right1(:,1);             % last right poke before start of right_reward
       dfs = dfs(find(dfs >= 0)); apoke = r.right_reward(1,1) - min(dfs);                       
    elseif rows(r.extra_iti) > 0  % miss
        % first try on the right
       dfs = r.extra_iti(1,1) - r.right1(:,1);             % last right poke before start of right_reward
       dfs = dfs(find(dfs >= 0)); dfs_R = min(dfs);       
       
       % now try on the left
       dfs = r.extra_iti(1,1) - r.left1(:,1);
       dfs = dfs(find(dfs >= 0)); dfs_L = min(dfs);
                     
       if isempty(dfs_L) && isempty(dfs_R)
           error('This cannot be. The rat must have made either a L or R poke during extra ITI');
       elseif isempty(dfs_L), apoke = r.extra_iti(1,1) - dfs_R;
       elseif isempty(dfs_R), apoke = r.extra_iti(1,1) - dfs_L;
       else apoke = r.extra_iti(1,1) - min(dfs_L, dfs_R);        
       end;
    else
        error('Trial %i: There should either be a Left Reward, a Right Reward or Extra ITI', k);        
    end;
    
    % Now get the reaction time:
    % Defined as the time between the point when he was allowed to make a
    % valid Cout
    % and when he made his answer poke
    % The former would be the time of Chord onset + ValidSoundTime
    allowed_time = r.chord(end,1) + vlst(k);
    rxn_times(k) = apoke - allowed_time;    
end;


