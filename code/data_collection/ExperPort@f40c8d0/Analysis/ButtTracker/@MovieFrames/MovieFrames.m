classdef MovieFrames < handle
    
%
% Class for performing butt tracking analysis.  
%
% PROPERTIES
%     Frames            Cell array with each element holding a single frame.  This is
%                         just a buffer.  The number of frames that can be held is
%                         limited by memory.  Therefore frames are retrieved on
%                         demand.
%     FrameInds         Indexes which frame number is held in each cell of Frames.
%     FrameTimes        The time that the frame occurs in the movie (according to
%                         FFGRAB).
%     NFrames           Number of frames in the buffer, i.e. NFrames=numel(Frames)
%     Background        A matrix holding a frame of the background.
%     BackgroundWeight  Not used currently, but it is a way to place confidence in
%                         each pixel of the background.  BackgroundWeight is the same
%                         size as the Background.  Each pixel value corresponds to
%                         how much that background pixel should be considered when
%                         performing fits of the rat.
%     BackgroundMethod  
%     Width             Width of each frame.
%     Height            Height of each frame.
%     NumberOfFrames    Total number of frames in the movie.
%     MovieName         Full path to the movie.
%     Angle             1xNumberOfFrames vector of angles in degrees.
%     Axs               2xNumberOfFrames matrix of ellipse sizes in pixels.  The
%                         first row is the major axis, second row is minor axis.  In
%                         most cases, this will correspond to the length and width of
%                         the rat respecively.  But occasionally the rat will curl up
%                         or something that will violate this assumption.  Currently
%                         the algorithm makes no attempt to use any "feautures" of
%                         the rat to determine which way he is facing.
%     Pos               2xNumberOfFrames matrix of ellipse centroid positions in 
%                         pixels.  The first row is x position, the second row is y.
%     Time              1xNumberOfFrames vector of time stamps as measured in movie
%                         time.
%     T0
%     Settings
%     IsGPU
%     DataType 
%
    
    
    properties (SetAccess = protected, GetAccess = public)
        Frames
        FrameInds
        FrameTimes
        NFrames=0;
        Background
        BackgroundWeight
        BackgroundMethod
        Width
        Height
        NumberOfFrames
        MovieName
        Angle
        Axs
        Pos
        Time
        T0
        Settings
        IsGPU
        DataType
    end
  
    methods
        function obj=MovieFrames(MovieName,isGPU,datatype)
            if nargin<2
                try 
                    gsingle(1);
                    obj.IsGPU=true;
                    disp('Using CUDA device, use ginfo for more information.')
                catch exception
                    disp(exception.message);
                    disp('Either no CUDA device detected or Jacket is not installed properly.');
                    disp('Using boring old CPU mode.');
                    obj.IsGPU=false;
                end
            else
                if isGPU
                    try
                        gsingle(1);
                        obj.IsGPU=true;
                        disp('Using CUDA device, use ginfo for more information.')
                    catch exception
                        disp(exception.message);
                        disp('Unable to connect to CUDA device or Jacket is not installed properly.');
                        disp('Using CPU mode rather than requested GPU mode.');
                    end
                else
                    obj.IsGPU=isGPU;
                    disp('Using CPU.')
                end
            end
            if nargin<3, datatype='double'; end
            if ~strcmpi(datatype,'double') && ~strcmpi(datatype,'single')
                error('MovieFrames:MovieFrames:incorrectDataType',...
                      'datatype must be either ''single'' or ''double''.');
            end
        
%             mobj=mmreader(MovieName);
%             obj.MovieName      = [mobj.Path '/' mobj.Name];
            warning off;
            obj.MovieName      = fullpath(MovieName);
            v                  = my_mmread(obj.MovieName,1000000000);
            obj.Width          = v.width;
            obj.Height         = v.height;            
            obj.NumberOfFrames = abs(v.nrFramesTotal);
            obj.Angle          = zeros(1,obj.NumberOfFrames);
            obj.Axs            = zeros(2,obj.NumberOfFrames);
            obj.Pos            = zeros(2,obj.NumberOfFrames);
            obj.Time           = zeros(1,obj.NumberOfFrames);
            obj.DataType       = lower(datatype);
            warning on;
        end
        GrabFrames(obj,framenos) 
        ClearFrames(obj)
        EstimateBackground(obj,nrandframes,israndomsample)
        [pos,frameinds]=EstimatePosition(obj,varargin)  
        [ratvals,frameinds]=EstimateRatPDF(obj,varargin)
        [boxvals,frameinds]=EstimateBoxPDF(obj,varargin)
        RecalculateBackground(obj,pos,frameinds,varargin)
        [blockvals,rowcol,valtimes]=BlockPixels(obj,frameinds,varargin)
        stats=AlignMovie(obj,bv,bvt,peh,varargin)
        chunks=ChunkInds(obj,firstind,lastind,chunksize)
        Fit(obj,varargin)
        OutputMovie(obj,varargin)
        SetProperties(obj,varargin)
    end
end
  


%
% function dependencies:
%   mmread
%   my_mmread
%   parseargs
%   bdata
%   reward_function
%   align_twovectors
%   extract_stringsfrommoviename
%   calc_angaxsfromcov2
%   ellipse
%   ts2epoch
%   fullpath

