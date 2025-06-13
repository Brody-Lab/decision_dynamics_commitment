function pname=fullpath(file)

%
% pname=fullpath(file)
%   given partial, i.e. relative pathname of file, returns full path name
%   of file (starting from root directory).
%   Example:
%   pname=fullpath('dir3/tmp.mat'); called from /dir1/dir2/ would output
%   pname = '/dir1/dir2/dir3/tmp.mat';
%

if file(1)=='/'
    pname=file;
else
    cpath=pwd;
    inds=strfind(file,cpath);
    if isempty(inds), pname=fullfile(cpath,file);
    else              pname=file;
    end
    pname=regexprep(pname,'[.][/]','');
end
