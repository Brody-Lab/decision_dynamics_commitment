function [d] = filterdates(ratname, dset, dstart, dend, lastfew)

% given a dateset and 3 filtering params, returns the subset of dates
% requested

if isstr(dset)
    if strcmpi(dset,'Before')
        ratrow=rat_task_table(ratname);
        dset=ratrow{1,4};
        dset=get_files(ratname, 'fromdate', dset{1}, 'todate', dset{2});
    elseif strcmpi(dset, 'After')
        ratrow=rat_task_table(ratname);
        dset=ratrow{1,5};
         dset=get_files(ratname, 'fromdate', dset{1}, 'todate', dset{2});
    else
        error('dset - if a string - should either be ''before'' or ''after''');
    end;
end;

useidx = sub__whichdates2use(dset, dstart, dend, lastfew);
d=dset(useidx);


% --------------------------------------
% Subroutines

% determines subset of sessions wanted using arg 2,3,4
function [useidx] = sub__whichdates2use(dateset, dstart, dend, lastfew)
useidx=1:length(dateset);

str=sprintf('both ''lastfew'' and ''dend'' have been set. dstart=%i,dend=%i,lastfew=%i\n', dstart,dend,lastfew);
if lastfew < 1000 && dend<1000
    error(str);
elseif lastfew < 1000
    if dstart > 1
        error('sorry, dstart must be 1 if using lastfew');
    end;
    lastfew = min(lastfew, length(dateset));
    dstart=length(useidx)-(lastfew-1);
    dend = length(useidx);
    %    useidx = useidx(end-(lastfew-1):end);
elseif dend < 1000 % first few X sessions
    dstart=1;
    % useidx=useidx(1:i);
else
    dstart=1; dend=length(dateset); % use whole set
end;

d2use=dstart:dend;
% base case - dateset isn't long enough; must use all dates therein
if length(dateset) < length(d2use)
    fprintf(1,'\t%s:Not enough dates to filter; using whole set\n', mfilename);
    useidx = 1:length(dateset);
else
    useidx=useidx(dstart:dend);
end;