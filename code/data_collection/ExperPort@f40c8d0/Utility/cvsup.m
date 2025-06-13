function cvsup(sd)
% cvsup(sd)
% runs 'cvs up -d -P in the directory specified by 'sd'.
% if no arguments are passed in then it runs cvs up in the currect
% directory.
%
% <~> Note that this does not use the argument -A, and therefore does not
%       strip tags from files.
%
if nargin==0
    sd='.';
end


olddir=cd;

try

    cd(sd);

    [croot] = bSettings('get','CVS','CVSROOT_STRING');
    if isnan(croot)
        system('cvs up -d');
    else
        system(['cvs -d ' croot ' up -d -P']);
    end
catch
    display(lasterr)
end

cd(olddir);

