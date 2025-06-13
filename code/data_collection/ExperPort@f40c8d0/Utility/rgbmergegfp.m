function out = mergegfp(gfpimage,cutoff,range)
global exper

% syntax:   mergegfp(gfpimage,cutoff,range)
% MERGEGFP takes in a gfp image scales it using CUTOFF (0-1) and 
% overlays it on the default experimental image (exper.opt.ratio)
% which is scaled by RANGE

if nargin < 2, error ('Please enter GFP image, mask threshold and scaling (optional) as arguements'); end

if nargin < 3
    msk = makemask(gfpimage);
else
    msk = makemask(gfpimage, cutoff);
end

intimage=exper.opt.ratio;

intimage(find(intimage > range)) = range; % scales intrinsic image to + and - range
intimage(find(intimage < -range)) = -range;

scaleintimage = (intimage-min(min(intimage)))./((max(max(intimage))-min(min(intimage)))); 
% scales image from 0 to 1


rgbint(:,:,1)=scaleintimage;
rgbint(:,:,2)=scaleintimage;
rgbint(:,:,3)=scaleintimage;

combine(:,:,1)=msk.*rgbint(:,:,1);
combine(:,:,2)=msk.*rgbint(:,:,2);
combine(:,:,3)=msk.*rgbint(:,:,3);

out = combine;

%figure, 
%subplot(1,2,1), imshow(out,[])
%subplot(1,2,2), imshow(scaleintimage,[])
%subplot(2,2,3), imshow(msk,[])
%subplot(2,2,4), imshow(gfpimage,[])