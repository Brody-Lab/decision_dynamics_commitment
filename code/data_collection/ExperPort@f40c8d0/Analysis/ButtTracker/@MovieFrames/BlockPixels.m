function [blockvals,rowcol,valtimes]=BlockPixels(obj,frameinds,varargin)

pairs={...
  'blocksize', [8 8];                                     ...
  'func_hand', @(block_struct) max(max(block_struct.data)); ...
  'chunksize', 500;                                         ...
  };
parseargs(varargin,pairs);

chunks=obj.ChunkInds(frameinds(1),frameinds(end),chunksize);
nchunks=size(chunks,1);

newHeight=ceil(obj.Height/blocksize(1));
newWidth=ceil(obj.Width/blocksize(2));
npixels=newHeight*newWidth;
rowcol=[reshape(repmat((1:newHeight)',1,newWidth),npixels,1) ...
        reshape(repmat(1:newWidth,newHeight,1),npixels,1)];
blockvals=zeros(npixels,numel(frameinds),'uint8');
valtimes=zeros(1,numel(frameinds));

% keyboard
fprintf('\nWorking on chunk ');

for ich=1:nchunks
  nch=fprintf('%d/%d',ich,nchunks);
  cframeinds=chunks(ich,1):chunks(ich,2);
  obj.GrabFrames(cframeinds);
  valtimes(cframeinds)=obj.FrameTimes;
  for k=1:numel(cframeinds)
    blockvals(:,(ich-1)*chunksize+k)=...
      reshape(blockproc(obj.Frames{k},blocksize,func_hand),npixels,1);
  end
  if ich<nchunks, fprintf(repmat('\b',1,nch)); end
end
fprintf('\n');

obj.Settings.BlockPixels.frameinds=frameinds;
obj.Settings.BlockPixels.blocksize=blocksize;
obj.Settings.BlockPixels.func_hand=func_hand;