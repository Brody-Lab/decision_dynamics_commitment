function upload_files_bucket(pname)

%This function finds the corresponding folder in bucket RATTER to pname and
%uploads all files in that pname folder to bucket which aren't already
%there.
%
%written by Chuck 10/2018

if ~strcmp(pname(end),filesep)
    pname = [pname,filesep];
end

try
    if ~exist('X:\RATTER','dir');
        map_bucket_drive;
    end
catch
    disp('Unable to connect to bucket');
    return; 
end

ratterpos = strfind(pname,'ratter');

if isempty(ratterpos)
    disp('Folder must be withing the ratter folder');
    return;
end

bname = ['X:\RATTER',pname(ratterpos+6:end)];

if ~exist(bname,'dir')
    try
        mkdir(bname);
    catch
        disp('Unable to make directory on bucket');
        return;
    end
end

pdir = dir(pname);
for i = 1:numel(pdir)
    if pdir(i).isdir == 1; continue; end
    
    if ~exist([bname,bdir(i).name],'file')
        disp(['Copying: ',pdir(i).name,'...']);
        copyfile([pname,pdir(i).name],[bname,bdir(i).name]);
    end
end
