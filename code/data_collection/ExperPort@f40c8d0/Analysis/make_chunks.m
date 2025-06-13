function [pd_chunks, dd_chunks] = make_chunks(first_pd, first_dd, trials)
% MAKE_CHUNKS
%   Returns contiguous trials of pd trials (each segment is an entry of
%   pd_chunks) and dd trials (ditto dd_chunks)

pd_chunks = cell(0,0);
dd_chunks = cell(0,0);
dd_i = 1; pd_i = 1;
% which task do we start with?
if min(first_pd) < min(first_dd)
    if min(first_pd) > 1
        curr_task = 'd';
    else
        curr_task = 'p';
        pd_i = pd_i + 1;
    end;
else
    if min(first_dd) > 1
        curr_task = 'p';
    else
        curr_task = 'd';
        dd_i = dd_i + 1;
    end;
end;

% now weave
curr = 1;
pd_seg = 1; dd_seg = 1
while curr < trials+1
    if strcmp(curr_task,'p')
        if dd_i <= length(first_dd)
            last_pd = first_dd(dd_i) - 1;
            pd_chunks{pd_seg,1} = curr:last_pd;pd_seg=pd_seg+1;
            curr = first_dd(dd_i);
            dd_i = dd_i + 1;
            curr_task = 'd';
        else           
            last_pd = trials;
            pd_chunks{pd_seg,1} = curr:last_pd;
            curr = trials+1;
        end;
    
    else
        if pd_i <= length(first_pd)
            last_dd = first_pd(pd_i) - 1;
            dd_chunks{dd_seg,1} = curr:last_dd; dd_seg=dd_seg+1;
            curr = first_pd(pd_i);
            pd_i = pd_i+1;
            curr_task = 'p';
        else
            last_dd = trials;
            dd_chunks{dd_seg,1} = curr:last_dd;
            curr = trials+1;
        end;
    end;
end;