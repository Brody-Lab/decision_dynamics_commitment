function chunks=ChunkInds(obj,firstind,lastind,chunksize)

%
% chunks=ChunkInds(obj,firstind,lastind,chunksize)
%

ninds=lastind-firstind+1;
nchunks=ceil(ninds/chunksize);
chunks=[firstind+chunksize*(0:(nchunks-1)); firstind+chunksize*(1:nchunks)-1]';
if chunks(end,2)>lastind, chunks(end,2)=lastind; end