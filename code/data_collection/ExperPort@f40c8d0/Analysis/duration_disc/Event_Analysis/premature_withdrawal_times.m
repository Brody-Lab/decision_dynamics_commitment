function [state_times] = premature_withdrawal_times(pstruct, varargin)
% This is an extension of timeout_during_prego.m
% Given a set of states, returns the time relative to state start that Cout
% occurred. 
%
% Returns a cell array of size RxC, where rows have information for each
% state, and columns have information for each trial. The first column is a header with names of the
% states. 
% Each cell is an array containing all withdrawal times (rel. state start) for that trial,
% one entry per instance of withdrawal.
% Input args: 
% 1. pstruct, the output of Analysis/parse_trial.m
% 2. state_types: An R-by-1 cell array where each row contains the name of
% a state to be included in the set.
% (Default: 'pre_chord'; 'cue';'pre_go')
%
% e.g. All instances of withdrawal-during-cue-period for trial # 45 are in
% cell (2,46), since 'cue' is the second entry in the set of states.
%

pairs = { ...
    'state_types', {'pre_chord'; 'cue';'pre_go'}; ...
    };

parse_knownargs(varargin, pairs);
state_times = cell(0,0);

for k = 1:rows(pstruct)
    if k == 9, 
        2; 
    end;
    for st = 1:rows(state_types)
        temp = [];
        this_set = eval(['pstruct{k}.' state_types{st}]);
        for pg = 1:rows(this_set)
            curr_t = this_set(pg,2); len = curr_t - this_set(pg,1);
            % get the last cout poke that occurred during this state (i.e.
            % before the state exit)
            dfs = curr_t - pstruct{k}.center1(:,2); dfs = dfs(find(dfs>=-1*(10^-3) & dfs <= len));
            if ~isempty(dfs), 
                temp = [temp  (len - min(dfs))]; 
            end;
        end;
        state_times{st,k} = temp;
    end;
end;

temp = cell(rows(state_times), cols(state_times)+1);
temp(:,1) = state_types;
temp(:,2:end) = state_times;

state_times = temp;

