function [out, p] = state_duration(pstruct, statename, varargin)
% Returns recorded durations of all instances of the state "statename" in
% the session.
%
% Input args:
% 1. pstruct: Output of Analysis/parse_trial.m
% 2. statename: name of state for which durations are computed (e.g.
% pre_go, cue, wait_for_apoke)
%
% Returns:
% out: durations split by trial number; out is a cell array, each cell of
% which is times for a trial
% p: same content as out, except flattened into an array.

pairs =  { ...
    'followhh', 'all';... [all | hit | miss]
    'hh', [] ; ...
    'graphic', 0 ; ...
    };
parse_knownargs(varargin,pairs);

% filters
if ~strcmpi(followhh,'all')
    if isempty(hh)
        fprintf(1,'%s:followhh filter ignored because no hh given', mfilename);
    end;

    if strcmpi(followhh,'miss')
        nextidx=find(hh(1:end-1) == 0) + 1;
    elseif strcmpi(followhh,'hit')
        nextidx=find(hh(1:end-1)==1) + 1;
    else
        error('invalid value for followhh');
    end;
else
    nextidx = 1:rows(pstruct);
end;


out = cell(0,0); p = [];
for k = nextidx
    if isempty(pstruct{k})
        out{k}=NaN;
    else
        state_set = eval(['pstruct{k}.' statename]);
        if isempty(state_set)
            out{k} = NaN;
        else
            out{k} = state_set(:,2) - state_set(:,1);
            if ~strcmpi('followhh', 'all')
                out{k} = state_set(1,2)-state_set(1,1);
            end;
        end;

    end;
     p = [p out{k}'];
end;

if graphic == 0
    return;
end;

