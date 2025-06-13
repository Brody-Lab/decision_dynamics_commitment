function write_video_network(videofile)

if ~exist('X:\RATTER\Video','dir')
    map_bucket_drive;
    disp('Mapping Network Drive...');
else
    disp('Network drive already mapped');
end

[pname,fname,ext] = fileparts(videofile);

pstart = strfind(pname,'Video');

if ~exist(['X:\RATTER\',pname(pstart:end),filesep],'dir')
    mkdir(['X:\RATTER\',pname(pstart:end),filesep]);
    disp(['Making directory ',pname(pstart:end),'...']); 
end
    
if ~exist(['X:\RATTER\',pname(pstart:end),filesep,fname,ext],'file')
    copyfile(videofile,['X:\RATTER\',pname(pstart:end),filesep,fname,ext],'f');
    disp(['Video file ',fname,ext,' copied successfully']);
else
    disp(['Video file ',fname,ext,' already exists. FILE NOT COPIED.']);
end
    