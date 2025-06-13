function [out] = withdrawal_during_state(pstruct, statename, varargin)
% Returns the time into the state "statename" when timeout occurred.
% Returns a cell array where each entry refers to one trial. Each cell is
% in turn an array containing all time-from-state-starts for that trial, 
% one entry for eacj timeout that occurred during that state.
%
% Input arg: pstruct, the output of Analysis/parse_trial.m
%

pairs = { ...
    'bins', []; ...
    };
parse_knownargs(varargin, pairs);

out = cell(0,0);
for k = 1:rows(pstruct)
    temp = [];
    state_set = eval(['pstruct{k}.' statename]);
    for pg = 1:rows(state_set)-1

        curr_t = state_set(pg,2); len = curr_t - state_set(pg,1);
        dfs = curr_t - pstruct{k}.center1(:,2); dfs = dfs(find(dfs>=-1*(10^-3) & dfs <= len));
        if ~isempty(dfs), temp = [temp  (len - min(dfs))]; end;
    end;
    out{k} = temp;
end;

blah = [];
for k = 1:length(out), blah = [blah out{k}]; end;

if isempty(bins)
    hist(blah * 1000);
else
    hist(blah * 1000, bins)
end;
xlabel(['Time since ' statename ' start (milliseconds)']);
ylabel('Number of occurrences');

