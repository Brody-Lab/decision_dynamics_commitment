function [statedurs] = state_duration_sessionavg(pstruct, statelist, varargin)
pairs = { ...
    'followhh', 'all'; ... [all | hit | miss] % filter by trials FOLLOWING either a hit or miss    
    'hh', []; ... % must be supplied if followhh is either 'hit' or 'miss'
    };
parse_knownargs(varargin,pairs);

statedurs = 0; % keys = states, values = average duration in a session

for k = 1:length(statelist)
    [blah dat] = state_duration(pstruct, statelist{k},'followhh',followhh, 'hh', hh);       
    eval(['statedurs.' statelist{k} '=nanmean(dat);']);
end;

