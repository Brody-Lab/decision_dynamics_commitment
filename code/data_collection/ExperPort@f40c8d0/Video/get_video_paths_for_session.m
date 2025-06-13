function paths = get_video_paths_for_session(experimenter,rat,date,video_folder)
    parent_dir = fullfile(video_folder,experimenter,rat);
    tmp=dir(parent_dir);
    names={tmp.name};
    names=names(:);
    datstr = datestr(datetime(date),'yymmdd');
    pattern=sprintf('.*%s.*.mp4$',datstr);
    paths = string(names(~cellfun(@isempty,regexp(names,pattern))));    
    paths=fullfile(parent_dir,paths);
    if isempty(paths)
        warning('No videos found in %s for date %s.',parent_dir,datestr(date));
    end
end