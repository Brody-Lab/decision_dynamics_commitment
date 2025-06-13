function output = extract_video_luminance(vfile,do_recent,skip_running,varargin)

if nargin < 2; do_recent = 0; end
if nargin < 3; skip_running = 1; end
output = [];

if ~exist('X:\RATTER','dir')
    map_bucket_drive;
end

[pname, fname, ext] = fileparts(vfile);

output_file = [pname,filesep,fname,'.mat'];
if exist(output_file,'file')
    %disp([vfile,' luminance has already been extracted. See ',output_file]);
    return;
end

started_file = [pname,filesep,fname,'_extraction_started.mat'];
running_file = [pname,filesep,fname,'_extraction_running.mat'];

brks = find(fname == '_');
if isempty(brks)
    disp('Unknown file name format.')
    return
end
if numel(brks) > 4; brks(5:end) = []; end

try
    file_date = fname(brks(end)+1:brks(end)+6);
catch
    disp('Unknown file name format.')
    return
end

if now - datenum(file_date,'yymmdd') < 7 && (do_recent == 0 || do_recent == 2)
    %This file is less than 1 week old. We do not analyze since it may be
    %corrupted. Give cleanup code time to process it
    disp('File is less than 1 week old. To extract luminance please set do_recent input to 1');
    return;
end
if now - datenum(file_date,'yymmdd') > 100 && do_recent == 2
    %This file is more than 3 months old. 
    disp('File is more than 3 months old. To extract luminance please set do_recent input to 1');
    return;
end


if strcmp(ext,'.mp4') == 0
    disp('File extension must be .mp4');
    return
end

if ~exist(vfile,'file')
    disp([vfile,' does not exist.']);
end

%Check if a started file exists. If it does this file likely crashed
if exist(started_file,'file') && ~exist(running_file,'file')
    disp(['A started file exists for this video. That likely means extraction ',...
          'started and crashed. To run extraction first delete the file: ',...
          started_file]);
    return
else
    message_var = ['Extraction of this file was started. If this file still ',...
        'exists then extraction crashed on the call to mmread. To reattempt ',...
        'extraction delete this file and run extract_video_luminance. Otherwise ',...
        'leave this file here so the extraction wrapper will skip over this ',...
        'file avoiding future crashes.'];
    save(started_file,'message_var')
end

x = dir(vfile);
if x.bytes < 1e6
    %This file is less than 1MB. Likely not a real video file
    disp([vfile,' is less than 1MB. It likely contains no data.']);
    return
end

%Check if a running file exists. If it does this file is likely being
%analyzed by another computer
if exist(running_file,'file')
    x = dir(running_file);
    if now - x.datenum > 1
        disp(['Running file is older than 1 day. Extraction likely not still ',...
            'running. Deleting running file and starting extraction.']);
        delete(running_file);
    elseif skip_running == 0
        disp('Running file exists but user input instructs to not skip running files.')
        delete(running_file);
    else
        disp(['A running file exists for this video. That likely means extraction ',...
          'is happening on another computer. To run extraction either first delete the file: ',...
          started_file,' or set skip_running input to 0']);
        return
    end
end

disp(['Analyzing: ',vfile]);
done = 0;
cnt  = 0;

IR_flash = [];
RED_flash = [];

RI = []; BI = []; GI = [];
framerate = [];
alltimes = [];
while done == 0
    cnt = cnt + 1;
    disp(['Analyzing Frames ',num2str(((cnt-1)*1000)+1),' to ',num2str(cnt*1000),'...']);
    x = mmread(vfile,((cnt-1)*1000)+1:cnt*1000);

    %We made it past mmread so this file is likely okay to analyze. Let's
    %delete the started file and make a running file
    
    if exist(started_file,'file')
        delete(started_file);
    end
    if ~exist(running_file,'file')
        message_var = ['Extraction of this file made it past mmread so the file ',...
            'is likely okay. However if this file exists something crashed before ',...
            'extraction could be finished or it is still running on another computer.'];
        save(running_file,'message_var');
    end
    
    if isempty(x); done = 1; break; end %#ok<NASGU>
    
    if isempty(x.frames); done = 1; break; end %#ok<NASGU>
    
    for f = 1:numel(x.frames)
        R = x.frames(f).cdata(:,:,1);
        G = x.frames(f).cdata(:,:,2);
        B = x.frames(f).cdata(:,:,3);

        Ri = sum(R(:));
        Gi = sum(G(:));
        Bi = sum(B(:));

        RED_flash(end+1) = Ri - ((Gi + Bi)/2); %#ok<AGROW>%
        IR_flash( end+1) = mean([Ri,Gi,Bi]); %#ok<AGROW>

        RI(end+1) = Ri; %#ok<AGROW>
        BI(end+1) = Bi; %#ok<AGROW>
        GI(end+1) = Gi; %#ok<AGROW>
    end
    alltimes(end+1:end+numel(x.times)) = x.times;
    if isempty(framerate)
        framerate = round(1 / mean((x.times(2:end) - x.times(1:end-1))));
    end
end

output.R_luminance = RI;
output.G_luminance = GI;
output.B_luminance = BI;
output.RED_flash   = RED_flash;
output.IR_flash    = IR_flash;
output.vfile       = vfile;
output.alltimes    = alltimes;
output.framerate   = framerate;

delete(running_file);
save(output_file,'output')
