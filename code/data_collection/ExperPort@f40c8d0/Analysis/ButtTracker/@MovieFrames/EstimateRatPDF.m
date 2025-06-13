function [ratvals,frameinds]=EstimateRatPDF(obj,varargin)

%
% [ratvals,frameinds]=EstimateRatPDF(varargin)
%   EstimateRatPDF produces a pixel-by-pixel luminance value of the rat.  That 
%   is, using some background estimate (whatever is in obj.Background) for the 
%   box, the position, size, and orientation of the rat are estimated for 
%   nframes number of frames by fitting a 2D gaussian to a variable threshold 
%   difference between frame and background.  For each frame, the area inside 
%   the fitted 2D gaussian is filled with the actual pixel values within, all 
%   other points are filled with NaNs.  The matrix ratvals is a 
%   height-by-width-by-nframes matrix of luminance estimates for the rat.  In
%   other words, the command reshape(ratvals(i,j,:),1,nframes) will produce
%   a 1-by-nframes vector that stores all the luminance values for the pixel in
%   the ith row and jth column that occur in the frames frameinds, but only when
%   the pixel is estimated to contain the rat, otherwise it stores a NaN for
%   that frame.  
%

pairs={ ...
  'pixthresh',  [0 3];     ...
  'rhob',       [1.1 1.7]; ...
  'rho',        [1 1];     ... %[1.25 1.25];
  'pixthreshb', [80 100];  ...
  'nframes'     2000;      ...
  };
parseargs(varargin,pairs);

% convert percentage thresholds into index numbers (on sorted arrays)
pti=round(pixthresh*obj.Width*obj.Height/100);
if pti(1)<1, pti(1)=1; end
if pti(2)<1, pti(2)=1; end
if pti(1)>obj.Width*obj.Height, pti(1)=obj.Width*obj.Height; end
if pti(2)>obj.Width*obj.Height, pti(2)=obj.Width*obj.Height; end

ratvals=nan(obj.Height,obj.Width,nframes,'single');
frameinds=randperm(obj.NumberOfFrames);
frameinds=sort(frameinds(1:nframes));
obj.GrabFrames(frameinds);

rowmat=repmat((1:obj.Height)',1,obj.Width);
colmat=repmat((1:obj.Width),obj.Height,1);

fprintf('Estimating the rats PDF.\n');

for k=1:nframes
  % find darkest pixels relative to background
  dframe=double(obj.Frames{k})-obj.Background;
  [dframe_vec sortinds]=sort(dframe(:));
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
  dframe_vec=dframe(isinellipse);
  dframe_vec=sort(dframe_vec);
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
  tmp=ratvals(:,:,k);
  tmp(isinellipse)=obj.Frames{k}(isinellipse);
  ratvals(:,:,k)=tmp;
  
   
end

% 
% 
% 
% while ~doneyet && currentchunk<=size(chunkinds,1)
%   
%   nlefttodo=sum(nframes_matrix(:)<frames_per_pixel);
%   nch=fprintf('Working on chunk %d, %d more pixels need to reach threshold',...
%     currentchunk,nlefttodo);
%   
%   obj.GrabFrames(chunkinds(currentchunk,1):chunkinds(currentchunk,2));
%   for k=1:obj.NFrames
%     % find darkest pixels relative to background
%     dframe=double(obj.Frames{k})-obj.Background;
%     [dframe_vec sortinds]=sort(dframe(:));
%     rows=rowmat(sortinds(pti(1):pti(2)));
%     cols=colmat(sortinds(pti(1):pti(2)));
%     
%     % get angle and axes sizes for current frame
%     [phi,axs]=calc_angaxsfromcov2(cov(cols,rows));
%     phi=-phi;
%     x=mean(cols);
%     y=mean(rows);
%     
%     % shorthands
%     a1=rhob(1)*axs(1);
%     a2=rhob(2)*axs(2);
%     ang=pi/2+phi*pi/180;
%     ss=sin(ang);
%     cc=cos(ang);
%     
%     % find points that are outside of ellipse defined from first pass
%     isoutellipse=...
%       ((colmat-x).^2)*( (a1*ss)^2 + (a2*cc)^2 ) + ...
%       ((rowmat-y).^2)*( (a1*cc)^2 + (a2*ss)^2 ) + ...
%       ((colmat-x).*(rowmat-y))*(a2^2-a1^2)*sin(2*ang) > (a1*a2)^2;
%     
%     % find brightest points inside ellipse
%     dframe_vec=sort(dframe(~isoutellipse));
%     ptib=floor(pixthreshb*sum(~isoutellipse(:))*0.01);
%     if ptib(1)<1, ptib(1)=1; end
%     pixthreshvalsb=[dframe_vec(ptib(1)) dframe_vec(ptib(2))];
%     
%     % <<<<<<ERASE ME!
%     tmp=obj.Frames{k}; colormap gray; 
%     tmp(isoutellipse)=128;
%     imagesc(tmp); colormap gray; set(gca,'position',[0 0 1 1]);
%     drawnow
% %     ki=input('>','s');
% %     if strcmp(ki,'k'), keyboard; end
%     % ERASE ME!>>>>>>
%     
%     % redefine all points representing the rat 
%     [rows2,cols2]=find(dframe>=pixthreshvalsb(1) & dframe<=pixthreshvalsb(2) & ...
%       ~isoutellipse);
%     cols=[cols; cols2];
%     rows=[rows; rows2];
%     
%     % get angle and axes sizes for current frame
%     [phi,axs]=calc_angaxsfromcov2(cov(cols,rows));
%     phi=-phi;
%     x=mean(cols);
%     y=mean(rows);
%     
%     % shorthands
%     a1=rho(1)*axs(1);
%     a2=rho(2)*axs(2);
%     ang=pi/2+phi*pi/180;
%     ss=sin(ang);
%     cc=cos(ang);
%     
%     % find points that are outside of ellipse defined from first pass
%     isoutellipse=...
%       ((colmat-x).^2)*( (a1*ss)^2 + (a2*cc)^2 ) + ...
%       ((rowmat-y).^2)*( (a1*cc)^2 + (a2*ss)^2 ) + ...
%       ((colmat-x).*(rowmat-y))*(a2^2-a1^2)*sin(2*ang) > (a1*a2)^2;
%     
%     % <<<<<<ERASE ME!
%     tmp=obj.Frames{k}; colormap gray; 
%     tmp(~isoutellipse)=128;
%     imagesc(tmp); colormap gray; set(gca,'position',[0 0 1 1]);
%     drawnow
% %     pause;
%     % ERASE ME!>>>>>>
%     
%     % update pixel values
%     pixvals(isoutellipse) = double(obj.Frames{k}(isoutellipse)) + pixvals(isoutellipse);
%     
%     % update the number of frames used per pixel
%     nframes_matrix(isoutellipse) = nframes_matrix(isoutellipse)+1;
%   end
%   
%   % check if every pixel has enough counts
%   if all(nframes_matrix(:)>=frames_per_pixel), doneyet=true; end
%   
%   currentchunk=currentchunk+1;
%   fprintf(repmat('\b',[1 nch]));
%   
% end
% 
% fprintf('Done collecting pixels, max frames in a pixel %d, min frames %d.\n',...
%   max(nframes_matrix(:)), min(nframes_matrix(:)) );
% 
% % obtain average as background, any points not reaching threshold are darkened
% obj.Background=pixvals./nframes_matrix;
% % obj.Background(nframes_matrix<frames_per_pixel)=0;
% 
% if ~doneyet
%   warning('MATLAB:MovieFrames:RecalculateBackground',...
%     ['Never reached minimum number of frames per pixel (' ...
%     sprintf('%d',frames_per_pixel) ').  Background image may be poor.']);
%   obj.Settings.RecalculateBackground.iswarned=true;
% else
%   obj.Settings.RecalculateBackground.iswarned=false;
% end
%   
% obj.Settings.RecalculateBackground.pixthresh=pixthresh;
% obj.Settings.RecalculateBackground.frames_per_pixel=frames_per_pixel;
% obj.Settings.RecalculateBackground.rho=rho;
% obj.Settings.RecalculateBackground.nframes_matrix=nframes_matrix;
% 
% obj.ClearFrames