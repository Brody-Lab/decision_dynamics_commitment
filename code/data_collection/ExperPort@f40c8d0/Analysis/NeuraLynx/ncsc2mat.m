function [csc]=ncsc2mat(fname,fldr)
% [csc]=csc2mat(fname,fldr)
% Jeffrey Erlich, March 5, 2007
% jerlich@princeton.edu
%

if nargin<1
    fname='';
    fldr='';
end

if nargin<2
    fldr='.';
end



fid=fopen([fldr,filesep,fname],'r');
if fid==-1
    warning('bad filename');
    [fname, pathname] = uigetfile('*.ncs', 'Pick an CSC file');
    fid=fopen([pathname filesep fname],'r');
end

hd=fread(fid,16384);
hd=char(hd');

% go to end of file to get filesize.
% note, that this info is also in the header... maybe in future do a double
% check of the header info and the file size.

fseek(fid, 0, 1);
pos=ftell(fid);

fseek(fid, 16384, 'bof');

% the file is a 16K header with a bunch of CSC records afterwards.
% each CSC record is 64+32+32+32+512*16 bits = 1044 bytes

num_recs=(pos-16384)/1044;

if mod(num_recs,1)>0
    warning('some bad records or sumptin')
    return;
end

ts=zeros(num_recs, 1,'uint64');
channel=zeros(num_recs, 1,'uint32');
sampFreq=zeros(num_recs, 1,'uint32');
nValSamp=zeros(num_recs, 1,'uint32');
data=zeros(num_recs, 512,'int16');

for recX=1:num_recs
    ts(recX)=fread(fid, 1, 'uint64');
    channel(recX)=fread(fid, 1, 'uint32');
    sampFreq(recX)=fread(fid, 1, 'uint32');
    nValSamp(recX)=fread(fid, 1, 'uint32');
    data(recX,:)=fread(fid,512,'int16');
end
fclose(fid);
csc.ts=ts;
clear ts
if numel(unique(channel))==1
csc.channel=channel(1);
else
    warning('WIERD channel information')
    csc.channel=channel;
end
clear channel
if numel(unique(sampFreq))==1
csc.sampFreq=sampFreq(1);
else
    warning('WIERD sampFreq infomation')
    csc.sampFreq=sampFreq;
end
clear sampFreq

csc.nValSamp=nValSamp;
clear nValSamp
csc.data=data;
csc.hd=hd;

