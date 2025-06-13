function out = mergegfp(gfpimage,cutoff,range)
global exper

% syntax:   mergegfp(gfpimage,cutoff,range)
% MERGEGFP takes in a gfp image scales it using CUTOFF (0-1) and 
% overlays it on the default experimental image (exper.opt.ratio)
% which is scaled by RANGE

if nargin < 2, error ('Please enter Intrinsic, GFP and Threshold (optional) as arguements'); end

if nargin < 3
    msk = makemask(gfpimage);
else
    msk = makemask(gfpimage, cutoff);
end

intimage=exper.opt.ratio;

intimage(find(intimage > range)) = range;
intimage(find(intimage < -range)) = -range;

scaleintimage = (intimage-min(min(intimage)))./((max(max(intimage))-min(min(intimage))));

out = msk.*scaleintimage;

figure, 
subplot(2,2,1), imshow(out,[])
subplot(2,2,2), imshow(scaleintimage,[])
subplot(2,2,3), imshow(msk,[])
subplot(2,2,4), imshow(gfpimage,[])