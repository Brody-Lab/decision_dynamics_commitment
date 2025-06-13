function output = load_luminance_data_for_session(experimenter,rat,date,video_folder)

    paths = get_video_paths_for_session(experimenter,rat,date,video_folder);
    
    if isempty(paths)
        output=[];
        return
    end
    
    count=0;
    for i=1:numel(paths)
        luminance_path = strrep(paths(i),'mp4','mat');
        if isfile(luminance_path)
            tmp = load(luminance_path);
            count=count+1;
            output(count) = tmp.output;
            output(count).vfile = paths(i);
            fprintf('Loaded luminance data for %s.\n',paths(i));            
        else
            warning('Luminance data for %s does not exist.',paths(i));
        end
    end

end