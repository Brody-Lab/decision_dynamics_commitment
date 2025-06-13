function [boxvals,frameinds]=EstimateBoxPDF(obj,varargin)

%
% [boxvals,frameinds]=EstimateBoxPDF(varargin)
%   EstimateBoxPDF produces a pixel-by-pixel luminance value of the box for 
%   specified frames.  That is, using some background estimate (whatever is in 
%   obj.Background) for the box, the position, size, and orientation of the rat 
%   are estimated for nframes number of frames by fitting a 2D gaussian to a 
%   variable threshold difference between frame and background.  For each frame, 
%   the area outside the fitted 2D gaussian is filled with the actual pixel 
%   values without, all points inside are filled with NaNs.  The matrix boxvals
%   is a height-by-width-by-nframes matrix of luminance estimates for the box.  
%   In other words, the command reshape(boxvals(i,j,:),1,nframes) will produce
%   a 1-by-nframes vector that stores all the luminance values for the pixel in
%   the ith row and jth column that occur in the frames frameinds, but only when
%   the pixel is estimated to be outside the rat, otherwise it stores a NaN for
%   that frame.  
%

pairs={ ...
  'pixthresh',  [0 3];     ...
  'rhob',       [1.1 1.7]; ...
  'rho',        [1 1];     ... %[1.25 1.25];
  'pixthreshb', [80 100];  ...
  'nframes',    2000;      ...
  'chunksize',  100;       ...
  };
parseargs(varargin,pairs);

% convert percentage thresholds into index numbers (on sorted arrays)
pti=round(pixthresh*obj.Width*obj.Height/100);
if pti(1)<1, pti(1)=1; end
if pti(2)<1, pti(2)=1; end
if pti(1)>obj.Width*obj.Height, pti(1)=obj.Width*obj.Height; end
if pti(2)>obj.Width*obj.Height, pti(2)=obj.Width*obj.Height; end



if obj.IsGPU
    castfunc=eval(['@g' obj.DataType]);
    rowmat=castfunc(repmat((1:obj.Height)',1,obj.Width));
    colmat=castfunc(repmat((1:obj.Width),obj.Height,1));
else
    rowmat=repmat((1:obj.Height)',1,obj.Width);
    colmat=repmat((1:obj.Width),obj.Height,1);
end

% grab chunked frames
boxvals=nan(obj.Height,obj.Width,nframes,'single');
frameinds=randperm(obj.NumberOfFrames);
frameinds=sort(frameinds(1:nframes));
chunks=obj.ChunkInds(1,nframes,chunksize);
nchunks=size(chunks,1);

fprintf('Estimating the box PDF.\n');

for ich=1:nchunks
    obj.GrabFrames(frameinds(chunks(ich,1):chunks(ich,2)));
%     disp(getfield(gpu_entry(13),'gpu_free'));
    for k=chunks(ich,1):chunks(ich,2)
%         disp(frameinds(k))
        if frameinds(k)==25258, keyboard; end

        k2=k-chunks(ich,1)+1;
        % find darkest pixels relative to background
        dframe=obj.Frames{k2}-obj.Background;
        [garbage sortinds]=sort(dframe(:));
        rows=rowmat(sortinds(pti(1):pti(2)));
        cols=colmat(sortinds(pti(1):pti(2)));
    
        % get angle and axes sizes for current frame
        [phi,axs]=calc_angaxsfromcov2(cov(cols,rows));
        phi=-phi;
        x=mean(cols);
        y=mean(rows);
    
        % shorthands
        a1=rhob(1)*axs(1);
        a2=rhob(2)*axs(2);
        ang=pi/2+phi*pi/180;
        ss=sin(ang);
        cc=cos(ang);
  
        % find points that are inside of ellipse defined from first pass
        isinellipse=...
            ((colmat-x).^2)*( (a1*ss)^2 + (a2*cc)^2 ) + ...
            ((rowmat-y).^2)*( (a1*cc)^2 + (a2*ss)^2 ) + ...
            ((colmat-x).*(rowmat-y))*(a2^2-a1^2)*sin(2*ang) <= (a1*a2)^2;
  
        % sort and threshold the brightest points
        dframe_vec=sort(dframe(isinellipse));
        ptib=floor(pixthreshb*sum(isinellipse(:))*0.01);
        if ptib(1)<1, ptib(1)=1; end
        pixthreshvalsb=[dframe_vec(ptib(1)) dframe_vec(ptib(2))];
        
        % redefine all points representing the rat 
        [rows2,cols2]=find(dframe>=pixthreshvalsb(1) & dframe<=pixthreshvalsb(2) & isinellipse);
        cols=[cols; cols2];
        rows=[rows; rows2];
  
        % get angle and axes sizes for current frame
        [phi,axs]=calc_angaxsfromcov2(cov(cols,rows));
        phi=-phi;
        x=mean(cols);
        y=mean(rows);
    
        % shorthands
        a1=rho(1)*axs(1);
        a2=rho(2)*axs(2);
        ang=pi/2+phi*pi/180;
        ss=sin(ang);
        cc=cos(ang);
  
        % find points inside of ellipse defined from first pass
        isinellipse=...
            ((colmat-x).^2)*( (a1*ss)^2 + (a2*cc)^2 ) + ...
            ((rowmat-y).^2)*( (a1*cc)^2 + (a2*ss)^2 ) + ...
            ((colmat-x).*(rowmat-y))*(a2^2-a1^2)*sin(2*ang) <= (a1*a2)^2;
  
        % set 
        tmp=boxvals(:,:,k);
        tmp(~isinellipse)=obj.Frames{k2}(~isinellipse);
        boxvals(:,:,k)=tmp;
    end    
end