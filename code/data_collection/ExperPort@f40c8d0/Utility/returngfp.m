function [scalegfp, gfpc] = returngfp()
global exper;

% RETURNGFP takes the default gfp image, makes a mask and displays them.
% it also returns the images
% syntax: [gfpimage, gfpmask] = returngfp()


gfp = exper.opt.grab;
threshold = exper.orca.param.thresh.value;

gfpm = makemask(gfp,threshold);

scalegfp = (gfp-min(min(gfp)))./((max(max(gfp))-min(min(gfp))));

red = scalegfp;
green = scalegfp;
blue = scalegfp;

red(find(gfpm == 0)) = 1;
green(find(gfpm == 0)) = 0;
blue(find(gfpm == 0)) = 0;


gfpc = cat(3, red, green, blue);


figure, 
    subplot(2,1,1), imshow(gfp,[]);
    subplot(2,1,2), imshow(gfpc,[]);
