function pathstr=get_path(filename)

%
% pathstr=get_path(filename)
%   retrieves the name of a directory that a file is sitting in.
%

pathstr=fullpath(filename);

locs=regexp(pathstr,'/');

pathstr(locs(end):end)=[];
pathstr=[pathstr '/'];


