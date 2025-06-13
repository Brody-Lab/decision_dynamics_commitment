function status=verifyPathCVS(cvspath)
% verifyPathCVS(cvspath)
% This function takes a path and creates it if need be and adds it to the
% cvs server if need be.  The only requirement is that somewhere in the
% path there has to be CVS info.

% break down the path into individual directories
curdir=pwd;

if filesep=='/'
    dds=textscan(cvspath,'%s','delimiter','/');
else
    dds=textscan(cvspath,'%s','delimiter','\\');
end

 dds=dds{1};
 dds=dds(2:end);

pathex=dir(cvspath);
if isempty(pathex)
    mkdir(cvspath)
end

cd(cvspath)
lvlidx=numel(dds)+1;
found_cvs=0;
while ~found_cvs && (lvlidx>0)
    cvsdir=dir('CVS');
    if isempty(cvsdir)
        cd('..')
    else
        found_cvs=1;
    end
    lvlidx=lvlidx-1;
end

if lvlidx==0
    warning('No CVS root found. Please checkout a repository before using this function')
    status=1;
else
    lvlidx=lvlidx+1;
    for li=lvlidx:numel(dds)
        system(['cvs add ' dds{li}])
        cd(dds{li})
    end
    status=0;
end

cd(curdir)