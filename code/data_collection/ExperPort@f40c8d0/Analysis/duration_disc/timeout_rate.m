function [out] = timeout_rate(events, numtrials,varargin)
% compute rate of occurrence of state 'timeout' for sessions.
% p - output of pstruct
% numtrials - array which contains number of trials in each session
% e.g. if p is events concatenated over 5 sessions, numtrials is a 1-by-5
% vector with the # trials in each of the 5 sessions

pairs = {...
    'action', 'timeout_rate' ; ... [ pct_no_timeout | timeout_hist ]
    };
parse_knownargs(varargin,pairs);

switch action
    case 'timeout_rate'
        cumtrials = cumsum(numtrials);
        out=[];
        for s = 1:length(numtrials)
            if s ==1, sidx=1;
            else sidx = cumtrials(s-1)+1;end;
            eidx = cumtrials(s);

            % focus on a session
            p = events(sidx:eidx);
            to_count = [];
            for k = 1:length(p)
                to_count = horzcat(to_count, rows(p{k}.timeout));
            end;

            out = horzcat(to_rates, sum(to_count) ./ numtrials(s));
        end;
    case 'pct_no_timeout'
        cumtrials = cumsum(numtrials);
        out=[];
        for s = 1:length(numtrials)
            if s ==1, sidx=1;
            else sidx = cumtrials(s-1)+1;end;
            eidx = cumtrials(s);

            % focus on a session
            p = events(sidx:eidx);
            to_count = [];
            for k = 1:length(p)
                to_count = horzcat(to_count, rows(p{k}.timeout));
            end;

            out = horzcat(out, length(find(to_count == 0)) / numtrials(s));
        end;
    case 'timeout_count' % raw count of occurrences of timeout state in each trial       
            p = events;
            to_count = [];
            out=[];
            for k = 1:length(p)
                if ~isempty(p{k})
                out = horzcat(out, rows(p{k}.timeout));
                end;
            end;            
    case 'timeout_hist'
    otherwise
        error('Invalid action');
end;