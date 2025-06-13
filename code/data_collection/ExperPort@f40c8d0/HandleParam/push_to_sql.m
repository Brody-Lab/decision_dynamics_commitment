% [] = push_to_sql(ratname, varargin)
%
% Pushes the data for a single trial as a struct 'saved' to sql SoloData
% table
%
%
% PARAMETERS:
% ----------
%
% ratname     This will determine which directory the file goes into.
%
% OPTIONAL PARAMETERS:
% --------------------
%
% child_protocol     by default, empty. If non-empty, should be an SPH
%                    that holds an object whose class will indicate the
%                    class of the child protocol who is the real
%                    owner of the vars to be saved.
%



function [] = push_to_sql(varargin)

pairs = { ...
    'child_protocol', [] ; ...
    'owner'           '' ; ...
    };
parse_knownargs(varargin, pairs);

if isempty(child_protocol),
    if isempty(owner), owner = determine_owner; end;
else
    owner = class(value(child_protocol));   % the child protocol owns all vars
    % owner = c(2:end);
end;

%  owner = owner;  this is an odd line of code.

handles = get_sphandle('owner', owner);
k = zeros(size(handles));
for xi=1:length(handles),
    k(xi)= get_saveable(handles{xi});
end;
handles = handles(k==1);

saved = struct;
for i=1:length(handles),
    hname=get_fullname(handles{i});
    saved.(get_fullname(handles{i}))=value(handles{i});
    if strfind(hname,'Events')
        sh=get_history(handles{i});
        saved.(get_fullname(handles{i}))=sh{end};
   
    end
end;
   


protocol=owner(2:end-3);  % This strips the '@' off the front and the 'obj' off the back
ratname=saved.SavingSection_ratname;
trialnum=saved.multipokesobj_n_done_trials;
hostname=saved.SavingSection_hostname;
sql=['insert into trials (ratname, trialnum, protocol, hostname, sessiondate, trialtime, saved) values ' ...
        '("{S}","{S}","{S}","{S}","{S}","{S}","{M}")'];

try
    connect2solodata;  % The details in this file determine which SQL server is connected to.
  
    mym(sql,ratname, trialnum, protocol, hostname, yearmonthday,  datestr(now,'HH:MM:SS'), saved);
catch
    display(lasterr);
    warning('Error sending data to SQL server')
end

end


