function check_video_hash(Vpath,Ename_only,Rname_only,check_matching_hash,varargin)

map_bucket_drive;

if nargin < 1; Vpath = 'X:\RATTER\Video\'; end
if nargin < 2; Ename_only = ''; end
if nargin < 3; Rname_only = ''; end
if nargin < 4; check_matching_hash = 0; end

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
                
                local_datahash_file = [Rpath,'File_DataHash.mat'];
                if exist(local_datahash_file,'file')
                    load(local_datahash_file)
                else
                    local_datahash = cell(0,2);
                    save(local_datahash_file,'local_datahash');
                end
                
                Vnames = dir(Rpath);
                for k = 1:numel(Vnames)
                    if Vnames(k).isdir == 0 && numel(Vnames(k).name) > 4 && strcmp(Vnames(k).name(end-3:end),'.mp4')
                        if sum(strcmp(local_datahash(:,1),Vnames(k).name)) == 0
                            disp(Vnames(k).name);
                            [hash,mssg] = DataHash(Vnames(k).name);
                            local_datahash{end+1,1} = Vnames(k).name;
                            local_datahash{end,2}   = hash;
                            save(local_datahash_file,'local_datahash')
                        end
                        
                        filepos = find(strcmp(local_datahash(:,1),Vnames(k).name) == 1,1,'first');
                        local_hash = local_datahash{filepos,2};
                        
                        if check_matching_hash == 1
                            output = compare_local2cup_hash(Vnames(k).name,Enames(i).name,Rnames(j).name,local_hash,1);
                            
                        end
                        
                    end
                end
            end
        end
    end
end


