function [output,rate] = aviread(filename, range, mode, o1, p1, o2, p2)

%-------------------------------------------------------------------------
% result = AVIread(filename)
% result = AVIread(filename,range)
% result = AVIread(filename,range,mode,option,param,...) 
%
% Read sections of an AVI movie and return frames or operations on frames
% such as averaging or timelines
%
% This version is more efficient than old version because it only reads 
% the frames that are actually used. It also does less checking and skips
% some header info because we are only interested in MIL output.
%
% Useage:
% result = AVIread(filename)   
%			  	prints header information from the AVI file in FILENAME
%				and returns the frame range
%				e.g., if there are 150 image, the result = 1:150
%				returns -1 if no file is found
%
% result = AVIread(filename,range)
% 				reads a stack of images specified by the array RANGE
% 				RANGE can be used to return a single frame or any given subset 
%				(only the specified frames are read in, so the function is efficient). 
%				A range value of 'all' reads in the whole movie.
%				e.g.
% 				result = AVIread(filename,frame)
% 				result = AVIread(filename,[f_start:f_end])
% 				result = AVIread(filename,[f1 f2 f3 f4])
%				result = AVIread(filename,'all')
%				
%
% There are several different modes for this function:
%
% result = AVIread(filename,range,'read')
% 				returns a 3D array with all specified frames (the default)
% result = AVIread(filename,range,'avg')
%  			returns a 2D array produced by averaging specified frames together
% result = AVIread(filename,range,'time')
%				returns a 1D array produced by averaging spatially each frame\
% result = AVIread(filename,range,'info')
%				returns the various header information
%
% For each mode there are several optional parameters:
%
% result = AVIread(filename,range,mode,'bin',z)
% result = AVIread(filename,range,mode,'bin',[x y])
% result = AVIread(filename,range,mode,'bin',[x y z])
%				the optional parameter 'bin', averages blocks of pixels,
%				reducing the image size and/or the number of frames. 
%				If the 'bin' parameter is a scalar, x, frames are averaged,
%				while for a 2 element array, [x y], spatial binning on each
%				frame is performed, and [x y z] is a combination of spatial
%				and temporal binning. Note, when binning is used, the result
%				is returned as type DOUBLE, to preserve precision
%				('bin' is available in 'read', 'avg', and 'time' modes)
% result = AVIread(filename,range,mode,'roi',bw)
%				the optioinal parameter 'roi' species a region of interest, 
%				BW, which is a matrix with same size as the movie frame, with
%				1's inside the ROI and 0's outside (as returned by the ROIPOLY 
%				function and others in the Matlab Image Processing toolbox)
%				('roi' is available in the 'time' mode)
%				
% 
% NOTE: supports only uncompressed plain avi(RIFF) files
%
% Modified by Zach Mainen (using Matlab 5.3)
% zach@cshl.org
% 1/25/2000
%
% Based on a function by 
% (c) by Rainer Rawer (using Matlab 5.2)
% rrawer@gmx.de
% 10/09/1999 
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
% checking if files is existing and a valid RIFF/AVI file
%-------------------------------------------------------------------------

  if nargin == 0; 
     disp(['-------------------------------']);  
     disp([' aviread v',version])
     disp(['-------------------------------']);
     disp([' usage: x = aviread(filename)'])
     disp(['        x = aviread(filename, range)']);
     disp(['        		where frames is a vector containing the frames to avg']);
     disp(['        x = aviread(filename, range, mode)']);
     disp(['            where mode is ''read'', ''avg'', ''time'' or ''info''']);
     disp(['		  optional parameters are: ']);
     disp(['		      ''bin'', [x y z]']);
     disp(['		      ''roi'', bw']);
     % error(['### no parameters']); 
  end
    
  fid = fopen(filename, 'r');
  if fid < 3
     output = fid;
     return
  end
  
  header = freadu8(filename, 0, 5000)';		% read header
  code = char(header(9:12));
  if ~strcmp(code,'AVI ') 	% check for 'AVI '
     		fclose(fid);
         error(['### aviread: ', filename, ...
                ' is not a valid AVI file.']); 
  end        
  
  
%-------------------------------------------------------------------------
% Extracting AVI header information
%-------------------------------------------------------------------------

h = 25;
if ~strcmp(char(header(h:h+3)),'avih') % find frames and columns following 'avih'
   h = findstr(char(header),'avih')			
end

frames		=mulbytes(header(h+24:h+27));
% hmmm... frames also seems to be wrong for Matrox MIL output
columns     =mulbytes(header(h+40:h+43));
%lines      =mulbytes(xx(h2+44:h2+47));
% definition of lines is not correct for Matrox MIL output, 
% so we later compute lines from the frame size

rate = mulbytes(header(33:36));				% microsec/frame

h = 165;
if ~strcmp(char(header(h:h+3)),'strf')
   h = findstr(char(header),'strf')			% find pixel depth following 'strf'
end
color_depth=mulbytes(header(h+22:h+23));
bytes = color_depth/8;

if bytes == 2
   type = 'u16';
else
   type = 'u8';
end

avg = mulbytes(header(149:152));		% how many frames to assume were averaged
if avg == 0
   avg = 1;
end
info.avg = avg;

% extrat vec array
cm = reshape(header(213:1236),4,256);
info.vec = cm(4,:);

% extract parameter array
for i=0:255
   info.param(i+1) = mulbytes(header(1236+9+i*4:1236+12+i*4));
end

% ok, we've got the goods...
if nargin >= 3
   if strcmp(mode,'info')
      output = info;
      return
   end
end



h = 4093;
if ~strcmp(char(header(h:h+3)),'movi')
   h = findstr(char(header),'movi')			% find frame length following 'movi'
end

flength=mulbytes(header(h+8:h+11))/bytes;
ptr_offset = h+3+8;
% SLM 12/08/99
% lines is now equal to frame_length / columns so that non-square AVIs are possible
lines = flength / columns;

% the real size of a frame in bytes, including the 8-byte header
fsize= flength*bytes + 8;
   
if nargin == 1 
   %display header information:
   range = [1:frames];
% 	disp('---------------------------------------------------------');
% 	disp(['aviread V',version,' by Z. Mainen `00']);
%    disp('---------------------------------------------------------');
%    disp(sprintf('   filename		: "%s"',filename));
% 	disp(sprintf('   number frames	: %d',frames));
% 	disp(sprintf('   frame size		: %d x %d (%d)',columns,lines,flength));
% 	disp(sprintf('   pixel depth		: %d (%d byte)',color_depth,bytes));
%    disp('---------------------------------------------------------');
%    %output = header;
   output = range;
   return
end   
   
if nargin < 3 
   mode = 'read';
end

bin = [1 1 1];
tempbin = bin;
if nargin > 3 
 %  if ~mod(nargin,2)
 %		fclose(fid);
 %     error(['### aviread: parameter needs a value']);
 %  end
   if o1=='bin' tempbin = p1; end
   if o1=='roi' bw = p1; end
   
   if (nargin > 5) 
      if o2=='bin' tempbin = p2; end
      if o2=='roi' bw = p2; end
   end
   
   if length(tempbin) < 2 
      	bin = [1 1 tempbin];
	elseif length(tempbin) <3
   	   bin = [tempbin 1];
	else
   	   bin = tempbin;
   end
end

if strcmp(range,'all')
   range = 1:frames;
end

if bin(3) > 1 
   if sum(range) ~= sum(range(1):range(end))
    	warning(['### aviread: range should probably be contiguous with z binning']);
   end
   if mod(length(range),bin(3))
      fclose(fid);	
      error(['### aviread: frames not divisible by bin(3)']);
   end
end

   
if sum(range < 1)+sum(range > frames)
   disp(sprintf('   number frames	: %d',frames)); 
	fclose(fid);
   error(['### aviread: ', filename, ...
          ' requested range not valid']); 
end    

switch mode
	case 'avg'
   	xxx(columns,lines) = 0;		
   	for i=range	   
   		ptr = ptr_offset + (i-1)*fsize;
         switch type
         case 'u8'
            xxx = xxx + double(reshape(freadu8(filename,ptr,flength),columns,lines));
         case 'u16'
            xxx = xxx + double(reshape(freadu16(filename,ptr,flength),columns,lines))/avg;
         case 's8'
            xxx = xxx + double(reshape(fread8(filename,ptr,flength),columns,lines));
         otherwise
            fclose(fid);
            error(['### aviread: currently supporting 8 and 16 bit pixel depth only']);
         end
      end
      if bin(1:2) ~= [1 1] 	% bin by factor of parameter
      	output = bin2(xxx,bin(1:2))/double(length(range));	
      else
         output = xxx/double(length(range));
      end
   case 'time'
      j=1;
      for i=range	    
         ptr = ptr_offset + (i-1)*fsize;
         switch type
         case 'u8'
            xx = double(reshape(freadu8(filename,ptr,flength),columns,lines));
         case 'u16'
            xx = double(reshape(freadu16(filename,ptr,flength),columns,lines))/avg;
         case 's8'
            xx = double(reshape(fread8(filename,ptr,flenght),columns,lines));
         otherwise
            fclose(fid);
            error(['### aviread: currently supporting 8 and 16 bit pixel depth only']);
         end
         
         if exist('bw')
         	xxx(j) = mean2(xx(find(bw)));
         else
            xxx(j) = mean(xx);
         end 
         j=j+1;
      end
      output = xxx;
   otherwise			% just read
      
      if bin == [1 1 1]
         j = 1;
         switch type
         case 'u8'
            xxx = uint8(zeros(columns,lines,length(range)));
         case 'u16'
            if avg > 1
               xxx = zeros(columns,lines,length(range));
            else
               xxx = uint16(zeros(columns,lines,length(range)));
            end
         case 's8'
            xxx = int8(zeros(columns,lines,length(range)));
         otherwise
            fclose(fid);
            error(['### aviread: currently supporting 8 and 16 bit pixel depth only']);
         end
     		for i=range	   
   			ptr = ptr_offset + (i-1)*fsize;
        		switch type
         	case 'u8'
            	xxx(:,:,j) = reshape(freadu8(filename,ptr,flength),columns,lines);
            case 'u16'            
               if avg > 1
                  xxx(:,:,j) = double(reshape(freadu16(filename,ptr,flength),columns,lines))/avg;
               else
                  xxx(:,:,j) = reshape(freadu16(filename,ptr,flength),columns,lines);
               end
            case 's8'
               xxx(:,:,j) = reshape(fread8(filename,ptr,flength),columns,lines);
            otherwise
               fclose(fid);
         	   error(['### aviread: currently supporting 8 and 16 bit pixel depth only']);
         	end
				j=j+1;
   		end
         output = xxx;
      else
               
         xxx = zeros(columns/bin(1),lines/bin(2),length(range)/bin(3));  
         xx2 = zeros(columns/bin(1),lines/bin(2),bin(3));
         
         j = 1;
			for i=1:length(range)/bin(3)
            for k = 1:bin(3)
               z = range(j);
		   		ptr = ptr_offset + (z-1)*fsize;
           		switch type
         		case 'u8'
            		xx = double(reshape(freadu8(filename,ptr,flength),columns,lines));
		         case 'u16'
                  xx = double(reshape(freadu16(filename,ptr,flength),columns,lines))/avg;
               case 's8'
                  xx = reshape(fread8(filename,ptr,flength),columns,lines);
               otherwise
                  fclose(fid);
         		   error(['### aviread: currently supporting 8 and 16 bit pixel depth only']);
         		end
	
               if bin(1:2) ~= [1 1]
         	   	xx2(:,:,k) = bin2(double(xx),bin(1:2));	
		         else
                  xx2(:,:,k) = double(xx);
               end
               j = j+1;
   	      end
            if bin(3) > 1
 			      xxx(:,:,i) = mean(xx2,3);
            else
               xxx(:,:,i) = xx2;
            end
   	   end
         output = xxx;
      end     
   end
	fclose(fid);

%-------------------------------------------------------------------------
% local functions
%-------------------------------------------------------------------------
  
function y = mulbytes(x)
% mulbytes takes the vector x of length n which is a multi-byte
% representation of a larger number (ordered from low to high), 
% and returns this single number
% e.g. mulbytes([1 0 2 0]) = 1 + 256 * 0 + 256^2 * 2 + 256^3 * 0 = 131073

y = 0;
for i=1:length(x)
   y = y + double(x(i))*(256^(i-1));
end



