function [S, extra_args]=get_sessdata(varargin)
% [S, extra_args] = GET_SESSDATA(varargin)
% [S, extra_args] = GET_SESSDATA(sessid)
% [S, extra_args] = GET_SESSDATA(ratname,experimenter, date)
% [S, extra_args] = GET_SESSDATA(ratname,experimenter, daterange)
% [S, extra_args] = GET_SESSDATA(ratname,experimenter, daterange, ...
%                                   'do_tracking', true, 'fetch_peh', false)
%
% A frontend to get data from the sessions table that does some nice input
% parsing. Useful to use in other functions to avoid having to parse
% inputs. If you pass it all the args from a parent function the leftover
% args are returned as extra_args.  For a good example of this see
% psychoplot_delori.m (in ExperPort/Analysis/SameDifferent)
%
% Inputs:
%   sessid       - can be a single sessid or a vector of sessids
%   experimenter - name of experimenter as listed in bdata sessions table
%   date         - date string in "YYYY-MM-DD" or relative date format
%                  (e.g., -5) indicating sessions to retrieve
%   datereange   - cell array of date strings in "YYYY-MM-DD format OR
%                  array of relative dates for ALL of the desired sessions.
%                  NOTE: daterange is NOT interpreted as a start and end.
%                  Only the dates supplied will be queried.
%
% Outputs:
%   S  - struct containing the following fields for the relevant sessions
%       pd          - protocol_data - struct of data output by protocol for
%                     each trial
%       peh         - cell array of structs contained parsed events history
%                     for each trial
%       sessiondate - date of the session in YYYY-MM-DD format
%       sessid      - session ids used to uniquely identify session in bdata
%       protocol    - name of protocol associated with each session
%       ratname     - string identifying rat for each session
%       hostname    - string identifying training rig
%
% pairs={'do_tracking' false;...
% 	   'fetch_peh' true...
% 	   };
%
% See also BDATA, BDATA_CONNECT, TO_STRING_DATE

% If no input args, return empty structure
if nargin==0 || isempty(varargin{1})
    S.sessid = [];
    S.pd = {};
    S.peh = {};
    S.ratname = {};
    S.sessiondate = {};
    S.protocol = {};
    return;
end

% Determine if inputs are supplied as a cell array or comma separated
if iscell(varargin{1})
    varargin = varargin{1};
    nargs = numel(varargin);
else
    nargs = nargin;
end

%% Parse inputs
input_is_sessid = 0;
if isnumeric(varargin{1}) % Assume input is a vector of sessids
    sessid = varargin{1};
    sessid = sessid(~isnan(sessid));
    input_is_sessid = 1;
    [ratname, experimenter] = bdata(['select ratname, experimenter from ' ...
        'sessions where sessid="{S}"'],sessid(1));
    varargin = varargin(2:end);
elseif nargs >= 3 % Assume first three inputs are ratname, experimenter, daterange
    ratname = varargin{1};
    experimenter = varargin{2};
    datein = varargin{3};
    if isnumeric(datein) % Assume third input is array of relative dates (e.g. -10:0)
        for dx = 1:numel(datein)
            dates{dx} = to_string_date(datein(dx));
        end
    elseif ischar(datein) % Assume third input is a single date (e.g. '2009-05-01')
        dates{1} = datein;
    else % Assume third input is a cell array of dates
        dates = datein;
    end
    % The rest of the inputs will be treated as pairs of strings and values
    varargin = varargin(4:end);
else
    S=[];
    warning('Failed to parse inputs.');
    extra_args = varargin;
    return
end

% Process any additional optional inputs
extra_args = varargin;
pairs = {'do_tracking' false;...
    'fetch_peh' true...
    };
parseargs(extra_args, pairs,[]);


% Get a vector of the relevant sessids for bdata query if that was not
% supplied as an input argument
if ~input_is_sessid
    % Transform the cell array of dates into into a long comma separated
    % string of dates, which we can use to get sessids from bdata
    datestr = '';
    for dx = 1:numel(dates)
        datestr = [datestr ',"'  dates{dx}  '"']; %#ok<AGROW>
    end
    % Get sessid from bdata using datestr to select relevant sessions
    [sessid] = bdata(['select sessid from sessions where ratname regexp "{S}" ' ...
        'and experimenter="{S}" and sessiondate in (' datestr(2:end) ') order ' ...
        'by sessiondate'],ratname, experimenter);
end

% Transform list of sessids into a comma seperated string
sessstr = '';
for sx = 1:numel(sessid)
    sessstr = [sessstr, ',' num2str(sessid(sx))]; %#ok<AGROW>
end

%% Get data from sql
% Retrieve data from database and fill output structure S
if fetch_peh
    [S.sessiondate, S.pd, S.sessid, S.protocol, S.peh, S.ratname, S.hostname] = ...
        bdata(['select sessiondate, protocol_data, s.sessid, protocol, ' ...
        'peh, s.ratname, hostname from sessions s, parsed_events p where s.sessid ' ...
        'in (' sessstr(2:end) ') and s.sessid=p.sessid order by sessiondate']);
else
    [S.sessiondate, S.pd, S.sessid, S.protocol, S.ratname, S.hostname] = ...
        bdata(['select sessiondate, protocol_data, s.sessid, protocol, ' ...
        's.ratname, hostname from sessions s where s.sessid in (' ...
        sessstr(2:end) ') order by sessiondate']);
end

% I don't know what this does. Does anyone use it?
if do_tracking
    S.a = cell(numel(S.sessid),1);
    [T.sessid, T.ts, T.theta] = bdata(['select sessid, ts, theta from ' ...
        'tracking where sessid in (' sessstr(2:end) ')']);
    for sx = 1:numel(S.sessid)
        tx = find(T.sessid == S.sessid(sx));
  	   if ~isempty(tx)
           a.ts = T.ts{tx};
           a.theta = T.theta{tx};
           S.a{sx} = a(:);
       end
    end

end
end





