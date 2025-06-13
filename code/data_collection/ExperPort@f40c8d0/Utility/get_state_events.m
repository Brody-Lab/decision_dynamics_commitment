function [evs] = get_state_events(e, varargin)
% Returns all events from a specified statenumber or statename
% If events are desired by statename, the state name-to-number must be
% provided. This is usually in the "RealTimeStates" variable.
%
% Output columns:
%   - row number in original event matrix
%   - State number
%   - Event (1-7)
%   - Time

pairs = { ...
    'qname', '' ;...
    'RTS',      []  ; ...
    'qnum', -1   ; ...
    };
parse_knownargs(varargin,pairs);

if length(qname) > 0        % get events by state name
    if isempty(RTS)
        error('Specify state number-to-name mapping (RTS)!');
    end;    
    qnum = eval(['RTS.' qname]);
end;

if qnum >= 0                    % get events by state number
    ind = find(e(:,1) == qnum(1));
    for i = 2:length(qnum)
            temp = find(e(:,1) == qnum(i));
            ind = [ind; temp];
    end;
    evs = [ind e(ind,:)];
    
else
    error(['Invalid state number: ' num2str(qnum)]);
end;

return;
