function [video, vidframes] = my_mmread(filename, frames, isgpu, vartype)

%
% [video, vidframes] = my_mmread(filename, frames, isgpu, vartype)
%     mmread reads virtually any media file.  It now uses AVbin and FFmpeg to 
%     capture the data, this includes URLs.  The code supports all major OSs and
%     architectures that Matlab runs on.
%
% INPUT
% filename      input file to read (mpg, avi, wmv, asf, wav, mp3, gif, ...)
% frames        specifies which video frames to capture, default [] for all
% isgpu         specifies whether to put vidframes on the gpu memory
%               Accelereyes Jacket must be installed for this to work
% vartype       Data type wanted (e.g. double, uint8, etc) on the gpu.  If gpu
%               not requested, the data type is set to uint8
%
% OUTPUT
% video is a struct with the following fields:
%   width           width of the video frames
%   height          height of the video frames
%   nrFramesTotal   the total number of frames in the movie regardless of
%                   how many were captured.  Unfortunately, this can not
%                   always be determined.  If it is negative then it
%                   is an estimate based upon the duration and rate
%                   (normally accurate to within .1%).   It can be 0,
%                   in which case it could not be determined at all.  If it
%                   is a possitive number then it should always be accurate.
%   rate            the frame rate of the video, if it can't be determined
%                   it will be 1.
%   totalDuration   the total length of the video in seconds.
%   times           the corresponding time stamps for the frames (in msec)
%   skippedFrames   some codecs (not mmread) will skip duplicate frames
%                   (i.e. identical to the previous) in fixed frame rate
%                   movies to save space and time.  These skipped frames
%                   can be detected by looking for jumps in the "times"
%                   field.  This field will be true when frames are
%                   skipped.
% vidframes is a 1-by-numel(frames) cell of width-by-height matrices of image
% frames
%
% EXAMPLES
%
% [vinfo,vframes] = mmread('mymovie.mpg'); % read whole movie
%
% [vinfo,vframes] = mmread('mymovie.mpg',1:10); %get only the first 10 frames
%
% Copyright 2008 Micah Richert
% 
% This file is part of mmread.
% 
% UPDATED by Joseph Jun
%   stripped out everything audio and multistream related.  This version of the
%   function is dedicated to ripping out images from the video, place time
%   stamps on them, and return basic vid information.
%   Also updated to handle video frame variables on the GPU via CUDA.  However,
%   for now, this functionality is limited to Accelereyes' Jacket libraries, and
%   does not speed up image retrieval.  In fact, it will probably slow it down
%   since the variables must be cast.  The point of this functionality is for
%   users who need to do post-processing on images and what to use CUDA for
%   those functions.
%


if nargin<2, frames=[]; end
if nargin<3, isgpu=false; end
if nargin<4, vartype='double'; end
if isgpu, typefunc=eval(['@g' vartype]); else typefunc=eval(['@' vartype]); end
currentdir = pwd;
matlabCommand='';


try
    if ~ispc
        cd(fileparts(mfilename('fullpath'))); % FFGrab searches for AVbin in the current directory
    end

	fmt = '';
	if iscell(filename)
        if length(filename) ~= 2
            error('If you are specifying filename and format, they must be in a cell array of lenght 2.');
        end
        fmt = filename{2};
        filename = filename{1};
	end

    FFGrab('build',filename,fmt,double(false),double(true),double(true));
    FFGrab('setFrames',frames);
    FFGrab('setMatlabCommand',matlabCommand);

    try
        FFGrab('doCapture');
    catch err
        if ~ispc, cd(currentdir); end
        if (~strcmp(err.message,'processFrame:STOP')), rethrow(err); end
    end

%     [nrVideoStreams] = FFGrab('getCaptureInfo');
    video = struct('width',0,'height',0,'nrFramesTotal',0);

    [width, height, rate, nrFramesCaptured, nrFramesTotal, totalDuration] = FFGrab('getVideoInfo',0);
    video.width = width;
    video.height = height;
    video.rate = rate;
    video.nrFramesTotal = nrFramesTotal;
    video.totalDuration = totalDuration;
    video.times = zeros(1,nrFramesCaptured);
    video.skippedFrames = [];
    
    vidframes=cell(1,nrFramesCaptured);
    if isgpu
        vidframes(:)={gzeros(height,width,vartype)};
    else
        vidframes(:)={zeros(height,width,vartype)};
    end

    if (nrFramesTotal > 0 && any(frames > nrFramesTotal))
    	warning('mmread:general',['Frame(s) ' num2str(frames(frames>nrFramesTotal)) ' exceed the number of frames in the movie.']);
    end

    for f=1:nrFramesCaptured
        [data, time] = FFGrab('getVideoFrame',0,f-1);

        if any(size(data) == 0)
            warning('mmread:getVideoFrame',['Frame ' num2str(f) ' could not be decoded']);
        else
            if ~isgpu
                if strcmpi(vartype,'UINT8')
                    vidframes{f} = reshape(data(1:3:end),width,height)';
                else
                    vidframes{f} = typefunc(reshape(data(1:3:end),width,height)');
                end
            else
                vidframes{f} = typefunc(reshape(data(1:3:end),width,height)'); % casts matrix into requested gpu variable type
            end
            video.times(f) = time;
        end
     end

     framerate = (max(video.times)-min(video.times))/nrFramesCaptured;
     if framerate > 0
     	video.skippedFrames = any(diff(video.times)>framerate*1.8) & abs(mean(diff(video.times))-framerate)/framerate<0.05;
     end

	% if frames are specified then make sure that the order is the same
	if (~isempty(frames) && nrFramesCaptured > 0)
    	[uniqueFrames, dummy, frameOrder] = unique(frames);
        if (length(uniqueFrames) > nrFramesCaptured)
        	warning('mmread:general','Not all frames specified were captured.  Returning what was captured, but order may be different than specified.');
        	remainingFrames = frames(frames<=uniqueFrames(nrFramesCaptured));
        	[dummy, dummy, frameOrder] = unique(remainingFrames);
    	end
        vidframes=vidframes(frameOrder);
        video.times = video.times(frameOrder);
    end
    FFGrab('cleanUp');
catch err
    try
        if ~isempty(strfind(err.message,'libavbin'))
        	switch mexext
            	case 'mexa64'
                	if exist('libavbin.so.64','file')
                    	if exist('libavbin.so','file')
                        	d64=dir('libavbin.so.64');
                        	d=dir('libavbin.so');
                            if d.bytes ~= d64.bytes
                            	R=input('libavbin.so is installed but seems to be the 32bit version.\nShall I correct this (no admin required)? [Y/n]','s');
                                if ~isequal(R,'n') && ~isequal(R,'N')
                                    if copyfile('libavbin.so.64','libavbin.so','f')
                                    	error('libavbin.so installed.  You may need to restart Matlab for mmread to function.');
                                    else
                                        error('libavbin.so failed to install:  couldn''t write to libavbin.so');
                                    end
                                end
                            end
                        else
                        	R=input('libavbin.so needs to be installed.\nShall I install this for you (no admin required)? [Y/n]','s');
                            if ~isequal(R,'n') && ~isequal(R,'N')
                            	if copyfile('libavbin.so.64','libavbin.so','f')
                                	error('libavbin.so installed.  You may need to restart Matlab for mmread to function.');
                                else
                                	error('libavbin.so failed to install:  couldn''t write to libavbin.so');
                            	end
                            end
                        end
                    end
                case 'mexglx'
                    if exist('libavbin.so.32','file')
                        if exist('libavbin.so','file')
                            d32=dir('libavbin.so.32');
                            d=dir('libavbin.so');
                            if d.bytes ~= d32.bytes
                                R=input('libavbin.so is installed but seems to be the 64bit version.\nShall I correct this (no admin required)? [Y/n]','s');
                                if ~isequal(R,'n') && ~isequal(R,'N')
                                    if copyfile('libavbin.so.32','libavbin.so','f')
                                        error('libavbin.so installed.  You may need to restart Matlab for mmread to function.');
                                    else
                                        error('libavbin.so failed to install:  couldn''t write to libavbin.so');
                                    end
                                end
                            end
                        else
                            R=input('libavbin.so needs to be installed.\nShall I install this for you (no admin required)? [Y/n]','s');
                            if ~isequal(R,'n') && ~isequal(R,'N')
                                if copyfile('libavbin.so.32','libavbin.so','f')
                                    error('libavbin.so installed.  You may need to restart Matlab for mmread to function.');
                                else
                                    error('libavbin.so failed to install:  couldn''t write to libavbin.so');
                                end
                            end
                        end
                    end
                case {'mexmac', 'mexmaci', 'mexmaci64'}
                	R=input('libavbin.dylib needs to be installed.\nShall I install this for you (no admin required)? [Y/n]','s');
                	if ~isequal(R,'n') && ~isequal(R,'N')
                    	if ~exist('~/lib','dir')
                        	if ~mkdir('~/lib')
                            	error('A lib directory doesn''t exist in your home directory, and one couldn''t be created.');
                            end
                        end
                        if copyfile('libavbin.dylib','~/lib/libavbin.dylib','f')
                        	error('libavbin.dylib installed.  You may need to restart Matlab for mmread to function.');
                        else
                            error('libavbin.dylib failed to install:  couldn''t write to libavbin.dylib');
                        end
                    end
            end
        end
        try
        	FFGrab('cleanUp');
        catch err
            if ~ispc, cd(currentdir); end
            rethrow(err);
        end
    catch err
    	if ~strcmp(computer,'PCWIN'), cd(currentdir); end
        if ~ispc, cd(currentdir); end
        rethrow(err);
    end
    if ~ispc, cd(currentdir); end
    rethrow(err);
end

if ~ispc, cd(currentdir); end

