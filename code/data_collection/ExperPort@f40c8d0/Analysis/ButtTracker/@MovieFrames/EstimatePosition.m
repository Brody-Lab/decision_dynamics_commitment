function [pos,frameinds]=EstimatePosition(obj,varargin)

%
% pos=EstimatePosition(obj,varargin)
% pairs={             ...
%   'frameinds', [];  ...
%   'chunksize', 500; ...
%   'thresh',    1;   ...
%   };
%

pairs={             ...
  'frameinds', [];  ...
  'chunksize', 500; ...
  'thresh',    1;   ...
  };
parseargs(varargin,pairs);

if isempty(frameinds), frameinds=1:obj.NumberOfFrames; end

nframes=numel(frameinds);

% norm_frbg=zeros(1,nframes);
pos=zeros(2,nframes);
nelem=obj.Width*obj.Height;
thr_ind=ceil(thresh*nelem*0.01);
fprintf('\nWorking on chunk ');

% grab chunked frames
chunks=obj.ChunkInds(frameinds(1),frameinds(end),chunksize);
nchunks=size(chunks,1);

for ich=1:nchunks
  nch=fprintf('%d/%d',ich,nchunks);
  cframeinds=chunks(ich,1):chunks(ich,2);
  obj.GrabFrames(cframeinds);
%   [garb cframes]=my_mmread(obj.MovieName,cframeinds);
  for k=1:obj.NFrames
    d_cfrbg=double(obj.Frames{k})-obj.Background;
    d_cfrbg_vec=sort(d_cfrbg(:));
    valthresh=d_cfrbg_vec(thr_ind);
    [rows cols]=find(d_cfrbg<valthresh);
%     if k==179, keyboard; end
    pos(:,k+(ich-1)*chunksize)=[median(cols); median(rows)];
%     imagesc(d_cfrbg);
%     line(median(cols),median(rows),'color','g','marker','o','linestyle','none');
%     drawnow;
  end
  if ich<nchunks, fprintf(repmat('\b',1,nch)); end
end
fprintf('\n');

obj.ClearFrames;
obj.Settings.EstimatePosition.thresh=thresh;
