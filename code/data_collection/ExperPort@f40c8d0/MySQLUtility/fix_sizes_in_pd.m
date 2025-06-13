
function [pd,peh]=fix_sizes_in_pd(pd,peh,sessid)
% [pd,peh]=fix_sizes_in_pd(pd,peh,[sessid])
%
% Looks through the protocol_data structure and parsed_events_history to
% make all vectors the same length. In general, peh is the length of
% n_completed_trials, but other vectors, like hits, are n_done_trials long
% and sides is sometimes n_started_trials long.
% 
% If logged into bdata with update permissions this will also update the
% protocol_data struct in bdata.sessions
%
% Inputs:
%   pd      protocol_data struct from sessions table
%   peh     parsed_events_history from get_peh
%   sessid  the session id, only required if you want to update the tables.
%s
old_pd=pd;
if isempty(peh)
    peh=pd.hits;
end
try
    old_n=numel(peh);
    new_n=old_n;
    fn=fieldnames(pd);
    for fx=1:numel(fn)
        cur_n=numel(pd.(fn{fx}));
        if abs(new_n-cur_n)==1
            new_n=min(new_n,cur_n);
        end
    end
    
    if old_n~=new_n && nargin==3
    peh=peh(1:new_n);
    try
      mym(bdata,'update parsed_events set peh="{M}" where sessid="{S}"',peh,sessid);
        fprintf('updated peh for session %d\n',sessid);
    catch end
    end
    
    
     for fx=1:numel(fn)
        cur_n=numel(pd.(fn{fx}));
        if abs(new_n-cur_n)==1
            pd.(fn{fx})=pd.(fn{fx})(1:new_n);
        end
     end
    
     if nargin==3 && ~isequalwithequalnans(pd, old_pd)
    try
    mym(bdata,'update sessions set protocol_data="{M}" where sessid="{S}"',pd,sessid);
     fprintf('updated pd for session %d\n',sessid);
    catch me
    end
     end
    
   
catch inle
    showerror(inle)
end