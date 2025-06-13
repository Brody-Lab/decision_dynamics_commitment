function [varargout]=nlx_video2mat(fname)
% [ts, cell_n,  waves, param, sc_n ,hd]=nlx_spike2mat(fname)
% With no outputs nlx_spike2mat returns only the header of the file.

% Jeffrey Erlich, Jan 14, 2008
% jerlich@princeton.edu
%
if exist('fname','var')
fid=fopen(fname,'r');
else
    fid=-1;
	fname=[];
end

if fid==-1
   % warning('bad filename');
    [fname, pathname, filterindex] = uigetfile('*.nvt', 'Pick a video file',[fname '*']);
    fid=fopen([pathname filesep fname],'r');
    pause(.1);
end

hd=fread(fid,16384);  % The header of all nlx files is 16384 bytes
hd=char(hd');   % reformat the header to a human readable format.


% With no output arguments, simply show the header.
if nargout==0
	varargout{1}=hd;
	return;
end

% go to end of file to get filesize.

fseek(fid, 0, 1);
pos=ftell(fid);

% Go back to the end of the header
fseek(fid, 16384, 'bof');

% each ntt record is sum([64 32 32 32*8 16*n_trodes*32])/8 bits = 76*n_trodes bytes
num_recs=(pos-16384)/(sum([16 16 16 64 32*400 16 32 32 32 32*50])/8);


if rem(num_recs,1)>0
    % There are not an even number of records.
    warning('NLX2MAT:BADRECS','There are partial records in the file, data is probably corrupt.')   
end

ts=zeros(num_recs, 1);
points=repmat(uint32(0),[num_recs,400]);
video_x=ts;
video_y=ts;
video_theta=ts;
targets=repmat(int32(0),[num_recs,50]);



for recX=1:num_recs
    fseek(fid,6,0); % skips unwanted elements in record;
    ts(recX)		= fread(fid, 1, 'int64');
    points(recX,:)		= fread(fid, 400, 'uint32');
    fseek(fid,2,0);
    video_x(recX)=fread(fid,1, 'int32');
    video_y(recX)=fread(fid,1, 'int32');
    video_theta(recX)=fread(fid,1, 'int32');
    targets(recX,:) = fread(fid,50,'int32');
end

% [ts, cell_n,  waves, param, sc_n ,hd]


varargout{1}=ts;

if nargout>1
	varargout{2}={video_x video_y video_theta};
end

if nargout>2
	varargout{3}=points;
end

if nargout>3
	varargout{4}=targets;
end

if nargout>4
	varargout{5}=hd;
end





