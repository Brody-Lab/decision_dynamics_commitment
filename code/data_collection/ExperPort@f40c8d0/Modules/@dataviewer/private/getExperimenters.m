function [x,r]=getExperimenters

olddir=cd;
try

    dd=bSettings('get','GENERAL','Main_Data_Directory');

    if isnan(dd)
        dd='../SoloData';
    end
    
    if dd(end)~=filesep
        dd(end+1)=filesep;
    end
    
    dd=[dd 'Data/'];

    cd(dd);
    cvsup('.');
    fname=dir;
    x={};r={};

    for xi=1:numel(fname)
        if strcmp(upper(fname(xi).name), 'CVS') || fname(xi).name(1)=='.'
            continue;
        end
        if fname(xi).isdir
            if isexper(fname(xi).name);
                x(end+1)={fname(xi).name};
            else
                r(end+1)={fname(xi).name};
            end
        end
    end

    x=x';
    r=r';

catch
end
cd(olddir);

function y=isexper(d)

oldd=cd;
cd(d)
fn=dir('*.mat');
matflag=isempty(fn);
fn=dir;
subflag=0;
for xi=1:numel(fn)
    if strcmp(upper(fn(xi).name), 'CVS') || fn(xi).name(1)=='.'
        continue;
    end
    if fn(xi).isdir;

        subflag=1;
        break;
    end
end

% If there are subdirectories and no mat files, we can be confident
% that this is a experimenter dir.
if subflag && matflag
    y=1;
elseif subflag
    % If there are matfiles AND subdirectories, we are confused, but we'll
    % assume they are experimenters with junk in there settings directory
    y=1;
    display(sprintf(['Is "' d '" really an experimenter?\n Please ask admin to check Setting directory\n']))
elseif matflag
    % If there no mat files and no subdirectories then it is hard to know
    % what this is, but it doesn't really matter since there won't be any
    % settings or protocol to load.

    y=0;
else
    % display(sprintf(['Is "' d '" really an experimenter?\n Please ask admin to check Setting directory\n']))
    % There were no subdirs and there were mat files, so we are pretty sure
    % that this is a rat.

    y=0;
end

cd(oldd)