
%This function will read in data from neuralynx, filter it and give the option to run PCA on the filtered data to extract features. In order to run this
%on raw data from Nerualynx you need the following in the directory in which you are
%working: data filename.ntt, nlx_spike2mat.m., denoiseNLX.m. In order to perform PCA you will also
%need: pcawaves.m. Once we cluster we use the function plotclusters to read clusters into matlab as well as plot them.

function [waves,ts,param,sc_n,hd]=nlx_spike2mat_DN(varargin)
%need to set output arguments to 0 so that we can run pca alone in
%case:'runpcaonly..'

if length(varargin) < 7
    hd = [];
end

if length(varargin) < 6
    sc_n = [];
end

if length(varargin) < 5
    param = [];
end

if length(varargin) < 4
    denoisedts = [];
end

if length(varargin) < 3
    denoisedwv = [];
end

if length(varargin) < 2
    mvavg = 10;
end

if length(varargin) < 1
    [fname, pathname] = uigetfile('*.n*', 'Pick a spike file',['' '*']);
    olddir=cd;
    cd(pathname);
    fid=fopen([pathname filesep fname],'r');
else
    pathname = '.';
    fname=varargin{1};
    fid=fopen([pathname filesep fname],'r');
end

% 'Denoise and give the option for PCA',
hd=fread(fid,16384);  % The header of all nlx files is 16384 bytes
hd=char(hd');   % reformat the header to a human readable format.
fseek(fid, 0, 1);
pos=ftell(fid);

% Go back to the end of the header
fseek(fid, 16384, 'bof');

% Current incarnation of code depends on correct file extension.
% Another possibility would be to check if
switch lower(fname(end-2:end))
    case 'nse'
        n_trodes=1;
    case 'nst'
        n_trodes=2;
    case 'ntt'
        n_trodes=4;
    otherwise
        fprintf(2,'File type not recognized for %s.  Only neuralynx spike formats supported\n',fname);
        return;
end

% each ntt record is sum([64 32 32 32*8 16*n_trodes*32])/8 bits = 76*n_trodes bytes
num_recs=(pos-16384)/(sum([64 32 32 32*8 16*n_trodes*32])/8);


if rem(num_recs,1)>0
    % There are not an even number of records.
    warning('NLX2MAT:BADRECS','There are partial records in the file, data is probably corrupt.')
end

ts=zeros(num_recs,1);
for i = 1:num_recs
        ts(recX)		= fread(fid, 1, 'int64'); %timestamps; fid is returned by reference
        fseek(fid, sum([32 32 32*8 16*n_trodes*32])/8,'cof')
end
    
    % [denoisedwv,denoisedts,param,sc_n]=denoiseNLX_2(mvavg,num_recs,s,denoisedwv,denoisedts,param,sc_n); %calls the denoise function to filter out electrical noise
    [gd_idx]=denoise(mvavg, ts);
	ts=zeros(num_recs, 1);
    cell_n=ts;
    sc_n=ts;
    param=zeros(num_recs,8);
    waves=zeros(num_recs,n_trodes,32);
    fseek(fid, 16384, 'bof');

	recX=1;
	
	
for i = 1:num_rec
	
if ismember(i, gd_idx)	
	 fseek(fid, 8, 'cof'); %timestamps; fid is returned by reference
     sc_n(recX)		= fread(fid, 1, 'int32'); %spike count
     cell_n(recX)	= fread(fid, 1, 'int32'); %cell number
     param(recX,:)	= fread(fid, 8, 'int32')';
     temp_w			= fread(fid, n_trodes*32, 'int16');
     waves(recX,:,:) = reshape(temp_w,n_trodes,32); %waveforms
	 recX=recX+1;
else
  fseek(fid, sum([64 32 32 32*8 16*n_trodes*32])/8,'cof')

end	
end



