function Fit(obj,varargin)

%
% Fit(varargin)
%
% pairs={...
%   'frameinds',  [];         ...  % frames where fit is desired, empty means all frames
%   'chunksize',  500;        ...  % b/c of memory limits, the frames are broken into working chunks  
%   'pixthresh',  [0 3];      ...  % thresholds as percentage for acceptance of pixel 
%   'dthresh',    90;         ...  % threshold as percentage for distance of pixel to centroid
%   'usebright',  true;       ...  % set to true if bright portions of frame-bg are to be used as well, only bright pixels within a region of the dark pixels are used (this prevents lights from destroying elliptical fits).
%   'pixthreshb', [90 100];   ...  % thresholds (as threshold) for bright pixels
%   'rhob',       [1.25 1.8]; ...  % multiplies the axes sizes that determine the elliptical area used to search for bright pixels
%   'tmpfile',    [];         ...  % name of file to store intermediate calculations
%   'startchunk', 1;          ...  % just in case something broke
%   'issave',     true;       ...  % toggles saving
%   };
%

pairs={...
  'frameinds',  [];         ...  % frames where fit is desired, empty means all frames
  'chunksize',  500;        ...  % b/c of memory limits, the frames are broken into working chunks  
  'pixthresh',  [0 5];      ...  % thresholds as percentage for acceptance of pixel 
  'dthresh',    90;         ...  % threshold as percentage for distance of pixel to centroid
  'usebright',  true;       ...  % set to true if bright portions of frame-bg are to be used as well, only bright pixels within a region of the dark pixels are used (this prevents lights from destroying elliptical fits).
  'pixthreshb', [90 100];   ...  % thresholds (as threshold) for bright pixels
  'rhob',       [1.25 1.8]; ...  % multiplies the axes sizes that determine the elliptical area used to search for bright pixels
  'tmpfile',    [];         ...  % name of file to store intermediate calculations
  'startchunk', 1;          ...  % just in case something broke
  'issave',     true;       ...  % toggles saving
  };
parseargs(varargin,pairs);

if isempty(frameinds), frameinds=1:obj.NumberOfFrames; end

if isempty(tmpfile)
  [ratname,datestr,expname]=extract_stringsfrommoviename(obj.MovieName);
  slashpos=findstr(obj.MovieName,'/');
  pname=obj.MovieName(slashpos(1):slashpos(end));
  tmpfile=[pname '/tmp_' expname '_' ratname '_' datestr 'a.mat'];
end

if startchunk>1
  try
    load(tmpfile);
  catch exception
    disp(exception.message)
    disp('Unable to load previously saved data.  Fitting from the start.');
    startchunk=1;
  end
end

% convert percentage thresholds into index numbers (on sorted arrays)
pti=round(pixthresh*obj.Width*obj.Height/100);
if pti(1)<1, pti(1)=1; end
if pti(2)<1, pti(2)=1; end
if pti(1)>obj.Width*obj.Height, pti(1)=obj.Width*obj.Height; end
if pti(2)>obj.Width*obj.Height, pti(2)=obj.Width*obj.Height; end

% These calculations can be done once and stored
rowmat=repmat((1:obj.Height)',1,obj.Width);
colmat=repmat((1:obj.Width),obj.Height,1);

% grab chunked frames
chunks=obj.ChunkInds(frameinds(1),frameinds(end),chunksize);
nchunks=size(chunks,1);

fprintf('\nWorking on chunk ');

for ich=startchunk:nchunks
  
  % display chunk no
  nch=fprintf('%d/%d',ich,nchunks);
  
  % grab frames
  cframes=chunks(ich,1):chunks(ich,2);  
  obj.GrabFrames(cframes);  
  obj.Time(cframes)=obj.FrameTimes;
  
  % perform fit
  for k=1:obj.NFrames
    
    % take the difference between current frame and background
    delta_framebg=(double(obj.Frames{k})-obj.Background);
    
    [delta_framebg_vec sortinds]=sort(delta_framebg(:));
    rows=rowmat(sortinds(pti(1):pti(2)));
    cols=colmat(sortinds(pti(1):pti(2)));
    
%     % find threshold value using relative pixel strengths
%     delta_framebg_vec=delta_framebg(:);
%     delta_framebg_vec=sort(delta_framebg_vec);
%     pixthreshvals=[delta_framebg_vec(pti(1)) delta_framebg_vec(pti(2))];
    
%     % all points that pass through thresholding (presumably points representing
%     % the rat)
%     [rows,cols]=find(delta_framebg>=pixthreshvals(1) & delta_framebg<=pixthreshvals(2));

    % now apply a second filter on the spatial location of points, i.e.
    % remove extreme points using mahalanobis distances
    distances=mahal([cols rows],[cols rows]);
    [distances,dinds]=sort(distances);
    dti=floor(numel(distances)*dthresh*0.01);
    if dti<1, dti=1; end
    rows=rows(dinds(1:dti));
    cols=cols(dinds(1:dti));
    
    % get angle and axes sizes for current frame
    ind=cframes(k); % shorthand for current frame
    [obj.Angle(ind),obj.Axs(:,ind)]=calc_angaxsfromcov2(cov(cols,rows));
    obj.Angle(ind)=-obj.Angle(ind);
    obj.Pos(1,ind)=mean(cols);
    obj.Pos(2,ind)=mean(rows);
    
    % use bright pixels if requested
    if usebright
      
      % shorthands
      a1=rhob(1)*obj.Axs(1,ind);
      a2=rhob(2)*obj.Axs(2,ind);
      ang=pi/2+obj.Angle(ind)*pi/180;
      ss=sin(ang);
      cc=cos(ang);
      
      % find points that belong inside ellipse defined from first pass
      isinellipse=...
        ((colmat-obj.Pos(1,ind)).^2)*( (a1*ss)^2 + (a2*cc)^2 ) + ...
        ((rowmat-obj.Pos(2,ind)).^2)*( (a1*cc)^2 + (a2*ss)^2 ) + ...
        ((colmat-obj.Pos(1,ind)).*(rowmat-obj.Pos(2,ind)))*(a2^2-a1^2)*sin(2*ang) <= (a1*a2)^2;
      
      % sort and threshold the brightest points
      delta_framebg_vec=delta_framebg(isinellipse);
      delta_framebg_vec=sort(delta_framebg_vec);
      ptib=floor(pixthreshb*sum(isinellipse(:))*0.01);
      if ptib(1)<1, ptib(1)=1; end
      pixthreshvalsb=[delta_framebg_vec(ptib(1)) delta_framebg_vec(ptib(2))];
      
      % redefine all points representing the rat 
      [rows2,cols2]=find(delta_framebg>=pixthreshvalsb(1) & delta_framebg<=pixthreshvalsb(2) & isinellipse);
      cols=[cols; cols2];
      rows=[rows; rows2];

      % get angle and axes sizes for current frame again
      [obj.Angle(ind),obj.Axs(:,ind)]=calc_angaxsfromcov2(cov(cols,rows));
      obj.Angle(ind)=-obj.Angle(ind);
      obj.Pos(1,ind)=mean(cols);
      obj.Pos(2,ind)=mean(rows);
    end
  end
  
  if issave, save(tmpfile,'obj'); end
  if ich<nchunks, fprintf(repmat('\b',1,nch)); end
  
end

fprintf('\n');

obj.ClearFrames;

% save settings
obj.Settings.Fit.pixthresh=pixthresh;
obj.Settings.Fit.dthresh=dthresh;
obj.Settings.Fit.usebright=usebright;
obj.Settings.Fit.pixthreshb=pixthreshb;
obj.Settings.Fit.rhob=rhob;

if issave
  save([pname '/data_' expname '_' ratname '_' datestr 'a.mat'],'obj');
  eval(['!rm ' tmpfile]);
end
