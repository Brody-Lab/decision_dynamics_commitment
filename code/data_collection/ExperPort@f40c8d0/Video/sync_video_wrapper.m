

F = dir(['X:\RATTER\Video\',expname,'\',ratname]);

for i = 651:numel(F)
    if F(i).isdir == 0 && numel(F(i).name) > 10 && strcmp(F(i).name(end-3:end),'.mp4')
        
        video_file = [F(i).folder,'\',F(i).name];
        [pname, fname, ext] = fileparts(video_file);
        luminance_file = [pname,filesep,fname,'.mat'];
        sync_file = [pname,filesep,fname,'_sync.mat'];
        
        brks = find(fname == '_');
        
        if exist(luminance_file,'file') && numel(brks) == 4
            
            try
                output = compute_frame_bcontrol_times_wrapper(video_file);
            catch me
                rethrow(me)
            end
        end
    end
end
        
        