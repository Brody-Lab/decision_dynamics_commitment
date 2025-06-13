function RecalculateBackground(obj,pos,frameinds,varargin)

pairs={...
  'pct',   1;  ... % controls percentage of extrema from pos will be used
  'posid', 1;  ... % controls whether x (1, default) or y (2) position is used
  'ninds', []; ... % overrides pct, enter a scalar to use the ninds lowest ...
                   %   and ninds highest positions, or enter a 2 element vector
                   %   to use the ninds(1) lowest and ninds(2) highest
                   %   positions.
  };
parseargs(varargin,pairs);

cpos=pos(posid,:);
% cpos_sorted=sort(cpos);
ncpos=numel(cpos);
if isempty(ninds)
  lowind=ceil(pct*0.01*ncpos);
  hghind=floor((100-pct)*0.01*ncpos);
end
% elseif numel(ninds==1)
% posthresh=[cpos_sorted(lowind) cpos_sorted(hghind)];
% posthresh=prctile(cpos,[pct 100-pct]);
% lowframes=frameinds(cpos<=posthresh(1));
% hghframes=frameinds(cpos>=posthresh(2));
[garb,sortedinds]=sort(cpos);
lowframes=frameinds(sortedinds(1:lowind));
hghframes=frameinds(sortedinds(hghind:end));
islow=[lowframes*0+1 hghframes*0];
[cframeinds,sinds]=sort([lowframes hghframes]);
islow=islow(sinds);
% [garb,cframes]=my_mmread(obj.MovieName,cframeinds);
obj.GrabFrames(cframeinds);
obj.Background=double(obj.Frames{1}*0);
lowmat=false(size(obj.Frames{1}));
if posid==1
%   midpt=round(median(cpos));
%   midpt=round(mean([max(cpos) min(cpos)]));
%   midpt=round(median(cpos([lowframes hghframes]-frameinds(1)+1)));
  midpt=round(mean( [min(cpos(lowframes-frameinds(1)+1)) max(cpos(hghframes-frameinds(1)+1))]));
  lowmat(:,1:midpt)=true;
else
  midpt=round(median(cpos([lowframes hghframes]-frameinds(1)+1)));
  lowmat(1:midpt,:)=true;
end
% keyboard
nlow=sum(islow);
nhgh=sum(~islow);
for k=1:obj.NFrames
  tmpframes=double(obj.Frames{k});
  if islow(k)
    obj.Background(~lowmat)=obj.Background(~lowmat)+tmpframes(~lowmat)/nlow;
  else
    obj.Background( lowmat)=obj.Background( lowmat)+tmpframes( lowmat)/nhgh;
  end
end

obj.Settings.RecalculateBackground.pos=pos;
obj.Settings.RecalculateBackground.frameinds=frameinds;
obj.Settings.RecalculateBackground.pct=pct;
obj.Settings.RecalculateBackground.posid=posid;







% 
% 
% pairs={...
%   'pct',   1;  ... % controls percentage of extrema from pos will be used
%   'posid', 1;  ... % controls whether x (1, default) or y (2) position is used
%   'ninds', []; ... % overrides pct, enter a scalar to use the ninds lowest ...
%                    %   and ninds highest positions, or enter a 2 element vector
%                    %   to use the ninds(1) lowest and ninds(2) highest
%                    %   positions.
%   };
% parseargs(varargin,pairs);
% 
% 
% pixthresh=[0 3];
% chunksize=500;
% frames_per_pixel=100;
% rhob=[1.1 1.7];
% rho=[1.2 1.3];
% pixthreshb=[90 100];
% 
% 
% % convert percentage thresholds into index numbers (on sorted arrays)
% pti=round(pixthresh*obj.Width*obj.Height/100);
% if pti(1)<1, pti(1)=1; end
% if pti(2)<1, pti(2)=1; end
% if pti(1)>obj.Width*obj.Height, pti(1)=obj.Width*obj.Height; end
% if pti(2)>obj.Width*obj.Height, pti(2)=obj.Width*obj.Height; end
% 
% doneyet=false;
% nframes_matrix=zeros(obj.Height,obj.Width);
% pixvals=nframes_matrix;
% % chunkinds=obj.ChunkInds(1,obj.NumberOfFrames,chunksize);
% chunkinds=obj.ChunkInds(15239,15300,chunksize);
% currentchunk=1;
% 
% rowmat=repmat((1:obj.Height)',1,obj.Width);
% colmat=repmat((1:obj.Width),obj.Height,1);
% 
% fprintf('Recalculating background.\n');
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
% %     tmp=obj.Frames{k}; colormap gray; 
% %     tmp(isoutellipse)=128;
% %     imagesc(tmp); colormap gray; set(gca,'position',[0 0 1 1]);
% %     drawnow
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

% 
% RecalculateBackground(obj,boxvals,varargin)
%   Calculates the background box by assuming that the pdf of luminance values
%   at each pixel comes from two sources: 
%   Pij(l) = alpha*Pij_box(l) + beta*Pij_rat(l), where alpha and beta are the
%   proper weights to ensure normality.  The matrix ratvals contains 
%   Pi,j_rat(l) in a height-by-width-by-nframes matrix of luminance values of 
%   the presumed rat.  In other words,
%   hist(reshape(ratvals(i,j,:),1,nframes),bincenters)/nframes = beta*Pij_rat(l)
%   By subtracting this value from Pij(l), one should have the probability
%   distribution of luminance values from the box alone.
%
% pairs={ ...
%   'pix_bincenters', (0:4:255)+1.5;               ...
%   'bgvals',         zeros(obj.Height,obj.Width); ...
%   'isdebug',        false;                       ...
%   'frameinds',      [];                          ...
%   'method',         'argmax';                    ...
%   };
% parseargs(varargin,pairs);
%

%
% pairs={...
%   'pct',   1;  ... % controls percentage of extrema from pos will be used
%   'posid', 1;  ... % controls whether x (1, default) or y (2) position is used
%   'ninds', []; ... % overrides pct, enter a scalar to use the ninds lowest ...
%                    %   and ninds highest positions, or enter a 2 element vector
%                    %   to use the ninds(1) lowest and ninds(2) highest
%                    %   positions.
%   };
% parseargs(varargin,pairs);
%

% pixthresh=[0 3];
% chunksize=500;
% frames_per_pixel=100;
% rhob=[1.1 1.7];
% rho=[1.2 1.3];
% pixthreshb=[90 100];
% 
% 
% % convert percentage thresholds into index numbers (on sorted arrays)
% pti=round(pixthresh*obj.Width*obj.Height/100);
% if pti(1)<1, pti(1)=1; end
% if pti(2)<1, pti(2)=1; end
% if pti(1)>obj.Width*obj.Height, pti(1)=obj.Width*obj.Height; end
% if pti(2)>obj.Width*obj.Height, pti(2)=obj.Width*obj.Height; end
% 
% doneyet=false;
% nframes_matrix=zeros(obj.Height,obj.Width);
% pixvals=nframes_matrix;
% % chunkinds=obj.ChunkInds(1,obj.NumberOfFrames,chunksize);
% chunkinds=obj.ChunkInds(15239,15300,chunksize);
% currentchunk=1;
% 
% rowmat=repmat((1:obj.Height)',1,obj.Width);
% colmat=repmat((1:obj.Width),obj.Height,1);
% 
% fprintf('Recalculating background.\n');
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

% pairs={...
%   'pct',   1;  ... % controls percentage of extrema from pos will be used
%   'posid', 1;  ... % controls whether x (1, default) or y (2) position is used
%   'ninds', []; ... % overrides pct, enter a scalar to use the ninds lowest ...
%                    %   and ninds highest positions, or enter a 2 element vector
%                    %   to use the ninds(1) lowest and ninds(2) highest
%                    %   positions.
%   };
% parseargs(varargin,pairs);
% 
% cpos=pos(posid,:);
% % cpos_sorted=sort(cpos);
% ncpos=numel(cpos);
% if isempty(ninds)
%   lowind=ceil(pct*0.01*ncpos);
%   hghind=floor((100-pct)*0.01*ncpos);
% elseif numel(ninds==1)
% % posthresh=[cpos_sorted(lowind) cpos_sorted(hghind)];
% % posthresh=prctile(cpos,[pct 100-pct]);
% % lowframes=frameinds(cpos<=posthresh(1));
% % hghframes=frameinds(cpos>=posthresh(2));
% [garb,sortedinds]=sort(cpos);
% lowframes=frameinds(sortedinds(1:lowind));
% hghframes=frameinds(sortedinds(hghind:end));
% islow=[lowframes*0+1 hghframes*0];
% [cframeinds,sinds]=sort([lowframes hghframes]);
% islow=islow(sinds);
% % [garb,cframes]=my_mmread(obj.MovieName,cframeinds);
% obj.GrabFrames(cframeinds);
% obj.Background=double(obj.Frames{1}*0);
% lowmat=false(size(obj.Frames{1}));
% if posid==1
% %   midpt=round(median(cpos));
% %   midpt=round(mean([max(cpos) min(cpos)]));
% %   midpt=round(median(cpos([lowframes hghframes]-frameinds(1)+1)));
%   midpt=round(mean( [min(cpos(lowframes-frameinds(1)+1)) max(cpos(hghframes-frameinds(1)+1))]));
%   lowmat(:,1:midpt)=true;
% else
%   midpt=round(median(cpos([lowframes hghframes]-frameinds(1)+1)));
%   lowmat(1:midpt,:)=true;
% end
% % keyboard
% nlow=sum(islow);
% nhgh=sum(~islow);
% for k=1:obj.NFrames
%   tmpframes=double(obj.Frames{k});
%   if islow(k)
%     obj.Background(~lowmat)=obj.Background(~lowmat)+tmpframes(~lowmat)/nlow;
%   else
%     obj.Background( lowmat)=obj.Background( lowmat)+tmpframes( lowmat)/nhgh;
%   end
% end
% 
% obj.Settings.RecalculateBackground.pos=pos;
% obj.Settings.RecalculateBackground.frameinds=frameinds;
% obj.Settings.RecalculateBackground.pct=pct;
% obj.Settings.RecalculateBackground.posid=posid;













% function RecalculateBackground(obj,boxvals,varargin)

% pairs={ ...
%   'pix_bincenters', (0:4:255)+1.5;               ...
%   'bgvals',         zeros(obj.Height,obj.Width); ...
%   'nframes',        size(ratvals,3);             ...
%   'isdebug',        false;                       ...
%   'frameinds',      [];                          ...
%   'method',         'argmax';                    ...
%   };
% parseargs(varargin,pairs);
% 
% if isempty(frameinds)
%   frameinds=randperm(obj.NumberOfFrames);
%   frameinds=sort(frameinds(1:nframes));
%   obj.GrabFrames(frameinds);
% elseif obj.NFrames==numel(frameinds)
%   if ~all(obj.FrameInds==frameinds), obj.GrabFrames(frameinds); end
% else
%   obj.GrabFrames(frameinds);
% end
% allvals=reshape(cell2mat(obj.Frames),obj.Height,obj.Width,obj.NFrames);
% % obj.ClearFrames
% 
% if isdebug
%   figure(2289); clf;
%   hi=imagesc(obj.Background); 
%   colormap gray; 
%   set(gca,'position',[0 0 1 1],'clim',[0 255]);
%   hl=line(1,1,'linestyle','none','marker','.','color','g','markersize',10);
%   countdown=0;
% end
% 
% for irows=1:obj.Height
%   for icols=1:obj.Width
% %     if irows==59 & icols==44, keyboard; end
%     ratdist=hist(reshape(ratvals(irows,icols,:),1,nframes),pix_bincenters)/nframes;
%     alldist=hist(reshape(allvals(irows,icols,:),1,nframes),pix_bincenters)/nframes;
%     deltadist=alldist-ratdist;
%     switch upper(method)
%       case 'ARGMAX'
%         [peakval,peakind]=max(deltadist);
%         val=pix_bincenters(peakind);
%       case 'MEAN'
%         deltadist(deltadist<0)=0;
%         val=sum(deltadist.*pix_bincenters)/sum(deltadist);
%       case 'MEDIAN'
%         deltadist(deltadist<0)=0;
%         
%     
%     bgvals(irows,icols)=val;
%     
%     % --------
%     if isdebug
%       figure(394); clf;
%       line(pix_bincenters,alldist,'color','k');
%       line(pix_bincenters,ratdist,'color','r');
%       line(pix_bincenters,deltadist,'color','g');
%       line(bgvals(irows,icols),1,'linestyle','none','marker','v');
%       xlim([0 255])
%       set(hl,'xdata',icols,'ydata',irows);
%       if countdown<=0
%         str=input('(# iter),(k)eyboard,(c)ontinue,e(x)it>','s');
%         s=str2double(str);
%         if isnan(s)
%           countdown=0;
%           if     strcmpi(str,'k'), keyboard;
%           elseif strcmpi(str,'c'), countdown=Inf;
%           elseif strcmpi(str,'x'), isdebug=false;
%           end
%         else
%           countdown=s;
%         end
%       else
%         countdown=countdown-1;
%         drawnow;
%       end
%     end
%     % --------
%     
% %     if bgvals(irows,icols)<0, bgvals(irows,icols)=0; end
%   end
% end
% 
% obj.Background=bgvals;
% obj.Settings.RecalculateBackground.frameinds=frameinds;




















%
% RecalculateBackground(obj,pos,frameinds,varargin)
%
% pairs={...
%   'pct',   1;  ... % controls percentage of extrema from pos will be used
%   'posid', 1;  ... % controls whether x (1, default) or y (2) position is used
%   'ninds', []; ... % overrides pct, enter a scalar to use the ninds lowest ...
%                    %   and ninds highest positions, or enter a 2 element vector
%                    %   to use the ninds(1) lowest and ninds(2) highest
%                    %   positions.
%   };
% parseargs(varargin,pairs);
%

% pixthresh=[0 3];
% chunksize=500;
% frames_per_pixel=100;
% rhob=[1.1 1.7];
% rho=[1.2 1.3];
% pixthreshb=[90 100];
% 
% 
% % convert percentage thresholds into index numbers (on sorted arrays)
% pti=round(pixthresh*obj.Width*obj.Height/100);
% if pti(1)<1, pti(1)=1; end
% if pti(2)<1, pti(2)=1; end
% if pti(1)>obj.Width*obj.Height, pti(1)=obj.Width*obj.Height; end
% if pti(2)>obj.Width*obj.Height, pti(2)=obj.Width*obj.Height; end
% 
% doneyet=false;
% nframes_matrix=zeros(obj.Height,obj.Width);
% pixvals=nframes_matrix;
% % chunkinds=obj.ChunkInds(1,obj.NumberOfFrames,chunksize);
% chunkinds=obj.ChunkInds(15239,15300,chunksize);
% currentchunk=1;
% 
% rowmat=repmat((1:obj.Height)',1,obj.Width);
% colmat=repmat((1:obj.Width),obj.Height,1);
% 
% fprintf('Recalculating background.\n');
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

% pairs={...
%   'pct',   1;  ... % controls percentage of extrema from pos will be used
%   'posid', 1;  ... % controls whether x (1, default) or y (2) position is used
%   'ninds', []; ... % overrides pct, enter a scalar to use the ninds lowest ...
%                    %   and ninds highest positions, or enter a 2 element vector
%                    %   to use the ninds(1) lowest and ninds(2) highest
%                    %   positions.
%   };
% parseargs(varargin,pairs);
% 
% cpos=pos(posid,:);
% % cpos_sorted=sort(cpos);
% ncpos=numel(cpos);
% if isempty(ninds)
%   lowind=ceil(pct*0.01*ncpos);
%   hghind=floor((100-pct)*0.01*ncpos);
% elseif numel(ninds==1)
% % posthresh=[cpos_sorted(lowind) cpos_sorted(hghind)];
% % posthresh=prctile(cpos,[pct 100-pct]);
% % lowframes=frameinds(cpos<=posthresh(1));
% % hghframes=frameinds(cpos>=posthresh(2));
% [garb,sortedinds]=sort(cpos);
% lowframes=frameinds(sortedinds(1:lowind));
% hghframes=frameinds(sortedinds(hghind:end));
% islow=[lowframes*0+1 hghframes*0];
% [cframeinds,sinds]=sort([lowframes hghframes]);
% islow=islow(sinds);
% % [garb,cframes]=my_mmread(obj.MovieName,cframeinds);
% obj.GrabFrames(cframeinds);
% obj.Background=double(obj.Frames{1}*0);
% lowmat=false(size(obj.Frames{1}));
% if posid==1
% %   midpt=round(median(cpos));
% %   midpt=round(mean([max(cpos) min(cpos)]));
% %   midpt=round(median(cpos([lowframes hghframes]-frameinds(1)+1)));
%   midpt=round(mean( [min(cpos(lowframes-frameinds(1)+1)) max(cpos(hghframes-frameinds(1)+1))]));
%   lowmat(:,1:midpt)=true;
% else
%   midpt=round(median(cpos([lowframes hghframes]-frameinds(1)+1)));
%   lowmat(1:midpt,:)=true;
% end
% % keyboard
% nlow=sum(islow);
% nhgh=sum(~islow);
% for k=1:obj.NFrames
%   tmpframes=double(obj.Frames{k});
%   if islow(k)
%     obj.Background(~lowmat)=obj.Background(~lowmat)+tmpframes(~lowmat)/nlow;
%   else
%     obj.Background( lowmat)=obj.Background( lowmat)+tmpframes( lowmat)/nhgh;
%   end
% end
% 
% obj.Settings.RecalculateBackground.pos=pos;
% obj.Settings.RecalculateBackground.frameinds=frameinds;
% obj.Settings.RecalculateBackground.pct=pct;
% obj.Settings.RecalculateBackground.posid=posid;