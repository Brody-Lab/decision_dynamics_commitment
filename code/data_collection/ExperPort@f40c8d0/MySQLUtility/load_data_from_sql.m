function [saved,saved_history]=load_data_from_sql(varargin)
% [saved,saved_history]=load_data_from_sql(sessid)
% [saved,saved_history]=load_data_from_sql(data_file)
% [saved,saved_history]=load_data_from_sql(ratname, date)
% [saved,saved_history]=load_data_from_sql(ratname, daterange)
%
% If you request only one output you will get saved (which will be faster!)
% date should be of the form "YYYY-MM-DD" or a relative date like -5
% daterange should be a numeric vector in relative form like -10:-1
% if daterange(end) is not a valid session the function returns empty.

use_daterange=0;
if nargin==1 && isnumeric(varargin{1})
    sessid=varargin{1};
    protocol=bdata('select protocol from sessions where sessid="{S}"',sessid);
    if isempty(protocol)
        saved=[]; saved_history=[];
        warning('Session not found');
        return
    end
    
elseif nargin==1 && ischar(varargin{1})
    data_file=varargin{1};
    if strcmp(data_file(end-3:end),'.mat')
        data_file=data_file(1:end-4);
    end
    
    [sessid,protocol]=bdata('select sessid,protocol from sessions where data_file="{S}"',data_file);
    
elseif nargin==2
    ratname=varargin{1};
    datein=varargin{2};
    if isnumeric(datein) && isscalar(datein)
        datestr=to_string_date(datein);
    elseif isnumeric(datein) && isvector(datein)
        start_date=to_string_date(datein(1));
        end_date=to_string_date(datein(end));
        use_daterange=1;
        datestr=end_date;  % use the last date to pick the protocol.
    else
        datestr=datein;
    end
    [sessid,protocol]=bdata('select sessid,protocol from sessions where ratname="{S}" and sessiondate="{S}"',ratname, datestr);
else
    saved=[]; saved_history=[];
    warning('Failed to parse inputs.');
    return
    
end

if isempty(sessid)
    saved=[]; saved_history=[];
    warning('Session not found');
    return
end

if numel(sessid)>1
    sessid=sessid(end); 
    % this is not necessary the right thing to do <~> JCE.
end

protocol=protocol{1};

if nargout<2
    if use_daterange
        saved=bdata(['select saved from solodata.' protocol ' where ratname="{S}" and sessiondate>="{S}" and sessiondate<="{S}"'],ratname, start_date, end_date);
        
    else
        saved=bdata(['select saved from solodata.' protocol ' where sessid="{S}"'],sessid);
    end
else
    
    
    [col_names,b,c,d,e,f]=bdata(['explain solodata.' protocol]);
    
    % check if the table is properly formed - the first 5 columns must include
    % sessid, ratname, datafile,sessiondate, saved
    if numel(intersect({'sessid', 'ratname', 'datafile','sessiondate', 'saved'},col_names(1:5)))~=5
        warning('load_data_from_sql:bad_table','The table for protocol %s is malformed.', protocol)
    end
    
    f_names=col_names(6:end);  % The first 5 cols of the table are listed 4 lines up.
    
    outstr=['[saved'];
    colstr='';
    for x=1:numel(f_names)
        
        outstr=[outstr ', S{' num2str(x) '}'];
        colstr=[colstr ',' f_names{x} ];
        
    end
    if use_daterange
        sqlstr=[outstr ']=bdata(''select saved ' colstr ' from solodata.' protocol ' where ratname="{S}" and sessiondate>="{S}" and sessiondate<="{S}"'',ratname,start_date,end_date);'];
        
    else
        sqlstr=[outstr ']=bdata(''select saved ' colstr ' from solodata.' protocol ' where sessid="{S}"'',sessid);'];
    end
    
    eval(sqlstr);

    if isempty(saved) %#ok<NODEF>
        saved={[]};
        saved_history=[];
    else
        
        for sessx=1:numel(saved)
            for sx=1:numel(f_names)
                t_S=S{sx}{sessx}; %#ok<USENS>
                if ~isempty(t_S)
                    fn=fieldnames(t_S);
                    for fx=1:numel(fn)
                        saved_history{sessx}.(fn{fx})=t_S.(fn{fx}); %#ok<AGROW>
                    end
                end % isempty t_S
            end % for each session returned.
        end  % for each column
        
    end % if empty
end % if nargout<2

if ~use_daterange && ~isempty(saved)
    saved=saved{1};
    if nargout>1
    saved_history=saved_history{1};
    end
end


