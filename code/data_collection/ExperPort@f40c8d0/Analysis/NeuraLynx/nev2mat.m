function [varargout]=nev2mat(fname)
% function [ts,ttls, event_id, extra, eventString]=nev2mat(fname)
% This function can take variable number of output arguments 
% eg. 			  [ts,ttls]=nev2mat(fname)
%		[ts,ttls, event_id]=nev2mat(fname)

% Jeffrey Erlich, March 5, 2007
% jerlich@princeton.edu
%
if exist('fname','var')
fid=fopen(fname,'r');
else
    fid=-1;
end

if fid==-1
   % warning('bad filename');
    [fname, pathname, filterindex] = uigetfile('*.Nev', 'Pick an event file');
    fid=fopen([pathname filesep fname],'r');
    pause(.2);
end

hd=fread(fid,16384);
hd=char(hd')   %display the header on the command line in a human readable format.


% With no output arguments, simply show the header.
if nargout==0
	varargout{1}=hd;
	return;
end

% go to end of file to get filesize.
fseek(fid, 0, 1);
pos=ftell(fid);

fseek(fid, 16384, 'bof');

% the file is a 16K header with a bunch of event records afterwards.
% each nev record is sum([16 16 16 64 16 16 16 32 32*8 8*128]) bits = 184 bytes

num_recs=(pos-16384)/184;

if mod(num_recs,1)>0
    warning('some bad records or sumptin')
    return;
end

ts=zeros(num_recs, 1);
ttls=ts;
event_id=ts;
extra=zeros(num_recs, 8);
e_str=zeros(num_recs,128);

for recX=1:num_recs
    fseek(fid, 2+2+2, 0);  	% ignore PktStart, PktID, PktDataSize
    ts(recX)		=fread(fid, 1, 'int64');
    event_id(recX)	=fread(fid, 1, 'int16');
    ttls(recX)		=fread(fid, 1, 'int16');
    fseek(fid, 2+4,0);    	% ignore CRC, Dummy
    extra(recX,:)	=fread(fid, 8, 'int32');
	e_str(recX,:)=fread(fid, 128);	 
end
e_str=char(e_str);

varargout{1}=ts;

if nargout>1
	varargout{2}=ttls;
end

if nargout>2
	varargout{3}=event_id;
end

if nargout>3
	varargout{4}=extra;
end

if nargout>4
	varargout{5}=e_str;
end
if nargout>5
	varargout{6}=hd;
end

