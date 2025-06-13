function output = aviwrite(x,filename,info)

%-------------------------------------------------------------------------
% result = AVIWrite(DATA,FILENAME,INFO)
%
% write a 3D stack of images (X,Y,T) as a Windows AVI file, suitable
% for importing to PowerPoint. Stores the current colormap. 
%
% DATA is an image array with dimension (x,y,time) specifying a movie. 
% DATA can be of type uint8, uint16 or double; DATA must range from 0 to 255
% in the case of double (it is converted to uint16 by 
%
%
% Due to an unknown bug, x and y dimensions must be divisible by 8
%
% INFO is a structure by which extra information can be passed, as follows
%
% info.avg		int		factor by which to multiply double 
%								image data before storing as uint16
%
% info.rate		int		rate in frames/sec for playback
%
% info.vec		char(1x256)	   an array of 1-byte data
% info.param	int(1x256)		an array of 4-byte data
%
%
% Zach Mainen 
% zach@cshl.org
% 1/25/2000
%
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
% checking if files is existing and a valid RIFF/AVI file
%-------------------------------------------------------------------------

  if nargin == 0; 
     disp(['-------------------------------']);  
     disp([' aviwrite'])
     disp(['-------------------------------']);
     disp([' usage: y = aviwrite(data,filename,info)'])
     error(['### no parameters']); 
  end
    
  fid = fopen(filename, 'w');
  if fid < 3; error(['### aviwrite: ', filename, ' could NOT be opened.']); end
  fclose(fid);
  
columns = size(x,1);
lines = size(x,2);
frames = size(x,3);

if mod(columns,8) | mod(lines,8)
	error(['### aviwrite: x and y dimensions must be divisible by 8']);    
end

if isa(x,'uint8')
    bytes = 1;
else
    bytes = 2;
end

if nargin < 3
   info.rate = 30;
   info.avg = 1;
end

  
% Perpare the current colormap, which needs to be expanded to 256 elements
% per color 

m = colormap;

for i=1:3
   map(:,i) = interp(m(:,i),256/size(m,1));
end

cm = zeros(size(map,1),4);
cm(:,1:3) = map*256;

% store vec in the colormap's 4th dimension
% must be values from 0 to 255.
if isfield(info,'vec')
   cm(:,4) = info.vec';
end

cm4 = reshape(cm',256*4,1);
cm4length = length(cm4);
cm4start = 213;
cm4end = 213+cm4length-1;


flength = lines*columns*bytes;
headerlength = 4096;
filelength = headerlength + (flength+8)*frames + frames*16;

header = uint8(zeros(1,headerlength));

header(1:4) = uint8('RIFF');
header(5:8) = sepbytes(filelength,4);		% file length
header(9:12) = uint8('AVI ');

% Define the main AVI header

FramesPerSec = info.rate;			% frame rate (frames/sec)
MicroSecPerFrame = 1e6/FramesPerSec;		% frame duration in microsec
MaxBytesPerSec = 1966080;		% max transfer rate
PaddingGranularity = 0;			% pad to multiples of this size; normally 2K
Flags = 2064;						% not sure what these flags are, but they're important
%Flags = 0;
TotalFrames = frames;			% # frames in file
InitialFrames = 0;				% -- not sure if this should be 0
Streams = 1;						% # of video streams
SuggestedBufferSize = flength;	%
Width = size(x,1);
Height = size(x,2);				% -- this is where there seems to be a Matrox error
AviHeader = sb([MicroSecPerFrame MaxBytesPerSec PaddingGranularity Flags TotalFrames ...
      InitialFrames Streams SuggestedBufferSize Width Height],4);

header(13:16) = uint8('LIST');
header(17:20) = sepbytes(192+cm4length,4);	% should be the size of the LIST
header(21:24) = uint8('hdrl');

header(25:28) = uint8('avih');  
header(29:32) = sepbytes(length(AviHeader)+16,4);	% size of the avih block
header(33:72) = AviHeader;
header(69:72) = [56 255 255 255];	% not sure what this is, but 

% Define the video STREAM header
% The definition is found in Microsoft's "VFW.H" file (included with VC++)

FCCType = 'DIB ';					% the Four Character Code: 'DIB ', 'RAW ', 'RGB ', etc
Handler = 0;
Flags = 0;
Priority =0;
Language = 0;
InitialFrames =0;
Scale = TotalFrames;
SRate = Scale*FramesPerSec;			
Start = 0;
Length = TotalFrames;
SampleSize = 0;
Frame = 0;

header(89:92) = uint8('LIST');
header(93:96) = sepbytes(116+cm4length,4);
header(97:100) = uint8('strl');
header(101:104) = uint8('strh');
header(105:108) = sepbytes(56,4);
header(109:112) = uint8('vids');
header(113:116) = uint8(FCCType);
header(117:120) = sepbytes(Handler,4);
header(121:124) = sepbytes(Flags,4);
header(125:126) = sepbytes(Priority,2);
header(127:128) = sepbytes(Language,2);
header(129:132) = sepbytes(Scale,4);
header(133:136) = sepbytes(SRate,4);				% Rate/Scale == samples/second
header(137:140) = sepbytes(Start,4);
header(141:144) = sepbytes(Length,4);			% in units above...
header(145:148) = sepbytes(SuggestedBufferSize,4);				
header(149:152) = sepbytes(info.avg,4);
header(153:156) = sepbytes(SampleSize,4);
header(157:160) = sepbytes(0,4);					% ???????????
header(161:164) = [0 1 0 255];					% not sure what this is!
% note -- not sure what needs to be in 156:164

% This is the bitmap info header, which we are not exactly 
% ready to deal with
% The definition is found in Microsoft's "WINGDI.H" file (included with VC++)


Planes = 1;					% planes
BitCount = bytes*8;		% bit count
Compression = 0;
SizeImage = Width*Height;
XpelsPerMeter = 1000;		% some kind of scaling?
YpelsPerMeter = 1000;		% some kind of scaling?
ClrUsed = size(map,1);				% colors used?
ClrImportant = 0;			% colors important?


header(165:168) = uint8('strf');  
header(169:172) = sepbytes(40+cm4length,4);			
header(173:176) = sepbytes(40,4);			% ???????????
header(177:180) = sepbytes(Width,4);		% Width
header(181:184) = sepbytes(Height,4);
header(185:186) = sepbytes(Planes,2);		
header(187:188) = sepbytes(BitCount,2);	
header(189:192) = sepbytes(Compression,4);	
header(193:196) = sepbytes(SizeImage,4);
header(197:200) = sepbytes(XpelsPerMeter,4);	
header(201:204) = sepbytes(YpelsPerMeter,4);
header(205:208) = sepbytes(ClrUsed,4);		
header(209:212) = sepbytes(ClrImportant,4);		


header(cm4start:cm4end) = cm4;

junklength = 4084-8-cm4end;

header(cm4end+1:cm4end+4) = uint8('EXTR');
header(cm4end+5:cm4end+8) = sepbytes(junklength,4);
if isfield(info,'param')
	for i=0:255
      header(cm4end+9+i*4:cm4end+12+i*4) = sepbytes(info.param(i+1),4);
   end
end


MovieSize = (flength+8)*TotalFrames+4;
header(4085:4088) = uint8('LIST');
header(4089:4092) = sepbytes(MovieSize,4);
header(4093:4096) = uint8('movi');

% write header
fwriteu8(filename,header);


% write data

frame_header(1:4) = uint8('00db');			% a code?
frame_header(5:8) = sepbytes(flength,4);

if bytes == 2
   for i=1:size(x,3)
      fwriteu8(filename,frame_header);
      if isa(x,'uint16')
         fwriteu16(filename,uint16(reshape(x(:,:,i),1,Width*Height)));
      else
         % interestingly, we need to round here!
         fwriteu16(filename,uint16(reshape(round(x(:,:,i)*info.avg),1,Width*Height)));
      end
   end         
else
   for i=1:size(x,3)
   	fwriteu8(filename,uint8([frame_header reshape(x(:,:,i),1,Width*Height)]));
   end
end


% need to write index

index = repmat([uint8('00db') sepbytes(16,4) sepbytes(0,4) sepbytes(flength,4)],1,TotalFrames);

for i=1:TotalFrames
   index(i*16-7:i*16-4) = sepbytes((flength+8)*(i-1)+4,4); 
end

index = [uint8('idx1') sepbytes(TotalFrames*16,4) index];
   
fwriteu8(filename,index);

output = flength*TotalFrames;



% ------------------------------------------------------------------------------
% local functions
% ------------------------------------------------------------------------------

function y = sb(x,n)

y = sepbytes(x(1),n);
for i=2:length(x)
   y = [y sepbytes(x(i),n)];
end

function y = sepbytes(x,n)
% sepbytes takes the double scalar x and breaks it into a n-byte representation
% e.g. sepbytes(131073,4) = 1 + 256 * 0 + 256^2 * 2 + 256^3 * 0 = [1 0 2 0]

for i=0:n-1
   y(n-i) = floor(x/(256^(n-i-1)));
   x = x-(y(n-i)*(256^(n-i-1)));
end

