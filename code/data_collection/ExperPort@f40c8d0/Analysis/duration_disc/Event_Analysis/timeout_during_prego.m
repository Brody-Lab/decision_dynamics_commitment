function [out] = timeout_during_preGO(pstruct)
% Returns the time into preGO when timeout occurred.
% Returns a cell array where each entry refers to one trial. Each cell is
% in turn an array containing all time-from-preGO-starts for that trial, 
% one entry for each timeout that occurred during preGO period.
%
% Note: Timeouts that occurred during the GO signal or before the pre-GO
% are ignored.
%
% Input arg: pstruct, the output of Analysis/parse_trial.m
%

out = cell(0,0);
for k = 1:rows(pstruct)
    temp = [];
    for pg = 1:rows(pstruct{k}.pre_go)-1

        curr_t = pstruct{k}.pre_go(pg,2); len = curr_t - pstruct{k}.pre_go(pg,1);
        dfs = curr_t - pstruct{k}.center1(:,2); dfs = dfs(find(dfs>=-1*(10^-3) & dfs <= len));
        if ~isempty(dfs), temp = [temp  (len - min(dfs))]; end;
    end;
    out{k} = temp;
end;


