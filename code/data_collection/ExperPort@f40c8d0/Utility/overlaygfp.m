function [compout, introut] = overlaygfp()
global exper;

% OVERLAY takes in a greyscale image GFPIMAGE of type UINT16
% and returns an RGB image with a red overlay where MASK = 0.
% The image is scaled by the default range, exper.opt.param.range.value
% THRESHOLD (0-1) is used to set cutoff of MASK.



intimage = exper.opt.ratio;
range = exper.opt.param.range.value;
gfpimage = exper.opt.grab;
threshold = exper.orca.param.thresh.value;
msk = makemask(gfpimage,threshold);

intimage(find(intimage > range)) = range;
intimage(find(intimage < -range)) = -range;

scaleintimage = (intimage-min(min(intimage)))./((max(max(intimage))-min(min(intimage))));

red=scaleintimage;
green=scaleintimage;
blue=scaleintimage;

red(find(msk == 0))=1;
%green(find(msk == 0))=0;
%blue(find(msk == 0))=0;


compout = cat(3, red, green, blue);
introut = scaleintimage;


figure, 
    subplot(2,1,1), imshow(compout);
    subplot(2,1,2), imshow(scaleintimage,[]);

