function output = compute_frame_bcontrol_times_wrapper(video_file,sessid,varargin)

%This is a wrapper function used to align a video to Bcontrol times for
%that training session.
%
%Optional Inputs
%
%   video_file      Full path and file name to the video file. If not
%                   provided a file browser window will open from which you
%                   can select one.
%
%   sessid          The sessid for the behavior session you want to align
%                   the video to. If not provided the function will attempt
%                   to parse the video_file name and determine the sessid.
%
%Output
%
%   This function saves the output structure to a file with name
%   "video file name"_sync.mat.  The structure contains all necessary
%   information regarding how the video aligns to the behavior session.
%   Below is a description of the data contained in each of the fields in
%   the output variable
%
%   R_luminance     The total red value summed across all pixels for each
%                   frame of the video
%
%   G_luminance     The total green value summed across all pixels for each
%                   frame of the video
%
%   B_luminance     The total blue value summed across all pixels for each
%                   frame of the video
%
%   RED_flash       Red luminance normalized by the mean of the green and
%                   blue luminance for each frame. This gives the best
%                   signal to noise when trying to detect sync flashes that
%                   use a red LED
%
%   IR_flash        Mean luminance across all channels for each frame. This
%                   gives the best signal to nosie when trying to detect 
%                   sync flahses that use an IR LED
%
%   vfile           The video file the sync was run on
%
%   alltimes        The frame times recorded in the video file. Using the
%                   grandstream video encoder these do not appear very
%                   reliable
%
%   framerate       The frame rate of the video
%
%   equation1       Given a bcontrol time stored in variable T, evaluate
%                   this equation to find the video frame most closely
%                   aligned with this time. Bcontrol_frame_times (see
%                   below) now gives a better estimate
%
%   equation2       Like equation 1 except it does not round to the nearest
%                   whole frame number
%
%   timeshift       Value in seconds that the video time and bcontrol time
%                   are off by. This is the time between dispatcher
%                   starting and the video recording starting
%
%   timescale       Alignment estimate of the ratio of the video clock rate
%                   to the bcontrol clock rate
%
%   alignment_error Difference between the sync flashes detected in the
%                   video and the bcontrol time when flashes should occur.
%                   Lower value corresponds to better alignment. Values
%                   less than 1 indicate a good alignment. Between 1 and 10
%                   is a poor alignment. Greater than 10 the alignment is
%                   bad
%
%   all_scores      If multiple thresholds are tested for detecting the
%                   sync flashes this gives the alignment_error for each of
%                   them
%
%   video_derivative Difference in luminance between successive frames for
%                   the channel used to detect sync flashes
%
%   video_threshold The threshold in absolute luminance value used to
%                   detect sync flashes
%
%   flash_channel   The luminance channel the flash events were detected on
%
%   video_events    The frame corresponding to the center of each detected 
%                   flash event. This takes a weighted average of the
%                   frames the flash occurs across and therefore the value
%                   is not a whole number
%
%   valve_times     The bcontrol times of the sync flashes. Originally
%                   these were tied to the water valves, hence the fields
%                   name
%
%   eventpairs      The video_events and valce_times that were determined
%                   to correspond to each other from the alignment 
%                   algorithm
%
%   droppedframes
%
%   droppedframesnum 
%
%   RED_flash_insframes Same as the RED_flash vector except nans are 
%                   inserted where dropped frames were estimated to have 
%                   happened 
%
%   real_frame_number After attepting to find where dropped frames happen
%                   this vector maps new frame numbers back to the original
%                   frames of the video. Estimated dropped frames will have 
%                   a value of nan in the vector. For example, if the code
%                   estimates a frame was dropped between video frames 1
%                   and 2 this vector will read [1,nan,2...]
%
%   Bcontrol_frame_times The Bcontrol time corresponding to the center of 
%                   each frame. This uses a piecewise linear alignment not
%                   attempting to find where dropped frames occur.
%                   
%
%

if nargin < 1
    [f,p] = uigetfile('*.mp4');
    video_file = [p,f];
end

disp('Starting Bcontrol video sync for')
disp(video_file)

[pname, fname, ext] = fileparts(video_file);

data_file = [];
if strcmp(fname(1:5),'video')
    if ~isempty(str2num(fname(end))); remove_camera_number = 1;
    else                              remove_camera_number = 0;
    end
    
    data_file = ['data',fname(6:end-remove_camera_number)];
end

if nargin < 2
    brks = find(fname == '_');
    if numel(brks) ~= 4
        disp('Unable to parse video file name.')
        disp('Please provide sessid as input and recall this function')
        return
    end
    ratname = fname(brks(3)+1:brks(4)-1);
    sessdate = datestr(datenum(fname(brks(4)+1:brks(4)+6),'yymmdd'),'yyyy-mm-dd');
    
    sessid = bdata(['select sessid from sessions where ratname="',...
        ratname,'" and sessiondate="',sessdate,'"']);
    
    if numel(sessid) ~= 1
        if ~isempty(data_file)
            sessid = bdata(['select sessid from sessions where ratname="',...
                ratname,'" and sessiondate="',sessdate,'" and data_file="',data_file,'"']);
        end
        
        if numel(sessid) ~= 1
            disp('Please provide a single sessid as input and recall this function')
            return
        end
    end
end

luminance_file = [pname,filesep,fname,'.mat'];
if ~exist(luminance_file,'file')
    disp('Video luminance extraction needs to run...')
    extract_video_luminance(video_file,1,0);
    disp('Video luminance extraction complete.')
else
    disp('Video luminance file already exists for this video...')
end

sync_file = [pname,filesep,fname,'_sync.mat'];
if ~exist(sync_file,'file')
    disp('Video sync needs to run...')
    output = sync_video_to_trials4(sessid,luminance_file,'lr','RED',[],0);
    save(sync_file,'output')
    disp('Video sync complete.')
else
    disp('Video sync file already exists for this video...');
    disp(['Loading file ',sync_file]);
    load(sync_file)
end

if isfield(output,'Bcontrol_frame_times')
    disp('Sync File already contains Bcontrol frame times')
else
    disp('Computing Bcontrol frame times...')
    F = piecewise_video_bcontrol_alignment([],output,sessid);
    output.Bcontrol_frame_times = F;
    save(sync_file,'output')
end

disp('COMPLETE')
    
    
    
