function extract_video_luminance_wrapper(Vpath,Ename_only,Rname_only,do_recent,varargin)

map_bucket_drive;

if nargin < 1; Vpath = 'X:\RATTER\Video\'; end
if nargin < 2; Ename_only = ''; end
if nargin < 3; Rname_only = ''; end
if nargin < 4; do_recent = 2; end

Enames = dir(Vpath);

for i = 1:numel(Enames)
    if Enames(i).isdir == 1 && ~strcmp(Enames(i).name,'.') && ~strcmp(Enames(i).name,'..')
        if ~isempty(Ename_only) && ~strcmp(Enames(i).name,Ename_only)
            continue;
        end
        
        Epath = [Vpath,Enames(i).name,filesep];
        cd(Epath);
        
        Rnames = dir(Epath);
        for j = 1:numel(Rnames)
            if Rnames(j).isdir == 1 && ~strcmp(Rnames(j).name,'.') && ~strcmp(Rnames(j).name,'..')
                if ~isempty(Rname_only) && ~strcmp(Rnames(j).name,Rname_only)
                    continue;
                end
        
                Rpath = [Epath,Rnames(j).name,filesep];
                cd(Rpath);
                disp(Rpath);
                
                Vnames = dir(Rpath);
                for k = 1:numel(Vnames)
                    if Vnames(k).isdir == 0 && numel(Vnames(k).name) > 4 && strcmp(Vnames(k).name(end-3:end),'.mp4')
                        disp(Vnames(k).name);
                        
                        vfile = [Rpath,Vnames(k).name];
                        output = extract_video_luminance(vfile,do_recent);
                        
                    end
                end
            end
        end
    end
end

exit

