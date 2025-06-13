function update_folder(pname,varargin)

if nargin < 1; pname = pwd; end
disp(['Updating: ',pname]);

if numel(pname) == 1 && isnan(pname)
    disp('Not a path');
    return;
end

if exist(pname,'dir') ~= 7
    disp('Path does not exist.');
    return;
end

currdir = pwd;

cd(pname);
x = dir(pwd);

isgit = 0;
issvn = 0;
for i = 1:numel(x)
    if     strcmp(x(i).name,'.git'); isgit = 1;
    elseif strcmp(x(i).name,'.svn'); issvn = 1;  
    end
end

if isgit == 1 && issvn == 0
    disp('GIT');
    [failed,message] = system('git pull');
    if failed
        %error('Git pull returned with error: %s.\n',message);
        disp(['Git pull returned with error: ',message]);
    end
elseif isgit == 0 && issvn == 1
    disp('SVN');
    !svn cleanup
    !svn update
elseif isgit == 0 && issvn == 0
    warning('This folder is neither a Git or SVN repository. Doing Nothing');
else
    warning('This folder has BOTH Git and SVN identifiers! . Doing Nothing');
end

disp('Update COMPLETE');
cd(currdir);

