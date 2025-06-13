function download_files_bucket(pname)

%This function finds the corresponding folder in bucket RATTER to pname and
%downloads all files in that bucket folder to pname that aren't already
%there
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
    disp('No corresponding folder exists on bucket');
    return;
end

bdir = dir(bname);
for i = 1:numel(bdir)
    if bdir(i).isdir == 1; continue; end
    
    if ~exist([pname,bdir(i).name],'file')
        disp(['Copying: ',bdir(i).name,'...']);
        copyfile([bname,bdir(i).name],[pname,bdir(i).name]);
    end
end
