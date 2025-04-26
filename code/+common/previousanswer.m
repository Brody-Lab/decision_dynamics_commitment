function x = previousanswer(Trials)
% location of the reward on previous trial when the animal responded
%
% ARGUMENT
%
%   Trials
%       a struct containing the behavioral and task events of a session
%
% RETURN
%   
%   a numeric vector indicating the location of the reward on previous trial when the animal
%   responded. On a trial when the animal did not respond, the value is NaN. The value is 0 if no
%   responded trial that precedes this trial. The value are -1 and 1 if the previous reward is on
%   the left and right, respectively.
respondedindices = find(Trials.responded);
rewardlocation = 2*(Trials.pokedR(respondedindices) == Trials.is_hit(respondedindices)) - 1;
previousreward = [0;rewardlocation(1:end-1)];
x = nan(size(Trials.responded));
x(respondedindices) = previousreward;