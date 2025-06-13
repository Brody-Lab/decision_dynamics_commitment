function nlx_spike2wave
% [waves]=nlx_spike2wave(fname)
% this is a very specific function for reading in waves as efficiently as
% possible for passing to SVD

% Jeffrey Erlich, Mar 23, 2009
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
    [fname, pathname, filterindex] = uigetfile('*.n*', 'Pick an spike file',[fname '*']);
    fid=fopen([pathname filesep fname],'r');
    pause(.1);
end

hd=fread(fid,16384);  % The header of all nlx files is 16384 bytes
hd=char(hd');   % reformat the header to a human readable format.


% With no output arguments, simply show the header.

% go to end of file to get filesize.

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


waves=zeros(num_recs,n_trodes*32,'single');
temp_w=repmat(int16(0),[n_trodes*32,1]);

for recX=1:num_recs
 	fseek(fid, 12, 'int32');
	temp_w			= fread(fid, n_trodes*32, 'int16');
	waves(recX,:,:) = single(reshape(temp_w,n_trodes,32));
end






