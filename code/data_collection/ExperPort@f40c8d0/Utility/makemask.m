function out = makemask(inimage, cutoff)

% MAKEMASK takes a uint16 tif image and converts it into a binary bitmap
% where brightest values are set to zero
% cutoff is 0 to 1

dimage = double(inimage)/255;  % converto uint16 to double

scaledimage = (dimage-min(min(dimage)))./((max(max(dimage))-min(min(dimage))));

if nargin > 1   
    out = -(double(im2bw(scaledimage,cutoff))-1);
else
    out = -(double(im2bw(scaledimage,0.7))-1);
end
