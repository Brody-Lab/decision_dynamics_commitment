function [ts] = fix_bad_ts_in_tracking(sessid, forceupdate)

if nargin < 2,
    forceupdate = 0;
end;

[ts] = get_tracking(sessid);
if isempty(ts),
    fprintf(2, 'No tracking info for session %d \n', sessid);
    return;
end;

bad = find(ts<0);
if isempty(bad),
    fprintf(2, 'All good timestamps in session %d \n', sessid);
else
    ssize = median(diff(ts));
    for i = bad,
        dts = ceil(diff(ts(i-1:i+3))/ssize);
        dts(abs(dts)>1e6) = 0;
        % this is the characteristic hiccup we're looking for
        if isequal(dts, [0 0 2 2]) || isequal(dts, [0 0 1 1]) || isequal(dts, [0 0 3 3]),
            % assume that, in reality, time ticked as usual
            ts(i:i+2) = ts(i-1) + ssize*(1:3);
        else
            fprintf(2, 'Negative timestamps at ts=%d in session %d, but not of the characteristic type. BAD!!\n', i, sessid);
        end;
    end;


if forceupdate
    mym(bdata, 'update tracking set ts="{M}" where sessid="{Si}"', ts, sessid);
    fprintf(2, 'Negative timestamps in session %d have been fixed \n', sessid);
end;
end            