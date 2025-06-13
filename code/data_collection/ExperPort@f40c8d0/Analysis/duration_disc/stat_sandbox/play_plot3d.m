function [] = play_plot3d
% [coord_set zvals V xlims ylims zlims] =sub__volumefromcoords_flowstyle('AuV', 4);

loadfromfile = 1;

global Solo_datadir;
histodir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Histo' filesep 'ACx' filesep];

% get rats' coordinates
ratname = 'Gandalf';
indir = [histodir ratname filesep];
infile = [indir  ratname '_interpolcoords.mat'];


if loadfromfile == 0
    [coord_set zvals V xlims ylims zlims xorig yorig zorig] =sub__volumefromcoords_flowstyle('Gandalf', 5);
    zlims = 1:max(zvals);
    % now plot the patches from the original slices and those reconstructed
    % from the volume matrix -- sanity check

    [xm ym zm] = meshgrid(xlims, ylims, zlims);
    fprintf(1,'Beginning interpolation ...');
    VI = interp3(xorig, yorig, zorig, V, xm, ym, zm, 'spline');
    fprintf(1,'done\n');

else
    %    load('Gandalf_sample');
    load(infile);
    % tack on the offset
xorig = xorig + (offsetx-1);
yorig = yorig + (offsety-1);
zorig = zorig + (min(zvals)-1);

% xm = xm + (offsetx-1);
% ym = ym + (offsety-1);
% zm = zm + (min(zvals)-1);

xlims = xlims + (offsetx-1);
ylims = ylims + (offsety-1);

zlims = 1:6;
zlims = zlims + (min(zvals)-1);

    [xm ym zm] = meshgrid(xlims, ylims, zlims);

end;


figure; set(gcf,'Position',[100 100 300 300]);
% plot the brain coordinates
% for q= 1:length(coord_set)
%     curr = coord_set{q}; curr(end+1,:) = curr(1,:); %curr = curr';
%     patch(curr(:,1), curr(:,2), ones(rows(curr),1) * zvals(q),'r');
% end;


% plot original data
%[px py pz] = sub__bruteforceVolView(xorig,yorig,zorig,V);
% alternate way to plot - slow but sanity check
for k = 1:6
    [px py pz] = sub__viewslice(V,xorig,yorig,zorig,k,1);
    hold on;
    plot3(px, py, pz, '.k');
end;

fprintf(1,'Beginning plot of interpolated data....');
ctr = 1;
tset =  [0.1 0.75 1];
clrs = {[1 0.7 0.7], [1 0.3 0.3], [0 0 1]};
for t = tset
    % now plot interpolated volume at thresholded level
    for k = zlims
        [px py pz] = sub__viewslice(VI, xm, ym, zm, k,t);
        hold on;
        %  fprintf(1,'%1.2f: %i points\n', t, length(px));
        plot3(px, py, pz, '+g','Color', clrs{ctr});%cmap(round((ctr/length(tset))*rows(cmap)), :) );
    end;
    ctr = ctr+1;
end;
fprintf(1,'done.\n');

%colorbar;
title(sprintf('threshed at %1.2f', t));
view(-2,20);
set(gcf,'Position',[150   538   470   183]);
%end;


% ------------------------------------------------------------------------
% Subroutines
% ------------------------------------------------------------------------

function [normed_buff newz V x y z xm ym zm] = sub__volumefromcoords_flowstyle(roi,numvals)
%coord_set = sub__get_brcoords(roi);
coord_set = sub__get_ratcoords(roi);
fprintf(1,'Got coords...\n');

[buff, buffpos] = sub__getcoordsubset(coord_set, 'L', numvals);
fprintf(1, 'Extracted subset ...\n');

%converted into points
pminx = Inf; pmaxx = -Inf;
pminy = Inf; pmaxy = -Inf;
pt_set = {};
% get limits on the axis
for k=1:length(buff)
    curr = buff{k};
    p = round(sub__makepoints(curr));
    pt_set{end+1} = p;
    buffx = curr(:,1); buffy = curr(:,2);

    pminx = min(pminx, min(p(:,1)));
    pmaxx = max(pmaxx, max(p(:,1)));
    pminy = min(pminy, min(p(:,2)));
    pmaxy = max(pmaxy, max(p(:,2)));
end;

numxvals = (pmaxx - pminx)+1;
numyvals = (pmaxy - pminy)+1;

x = 1:numxvals;
y = 1:numyvals;
z = buffpos - (min(buffpos)-1);

[xm, ym, zm] = meshgrid(x,y,z);
normed_buff = {};
newz = [];

fprintf(1, 'Converted into points...\n');

% now populate volume array

V = zeros(size(xm));
for k = 1:length(buff)
    currz = buffpos(k);
    currz = currz - (min(buffpos)-1);

    currbuf = buff{k};
    currbuf(:,1) = currbuf(:,1) - (pminx-1); currbuf(:,2) = currbuf(:,2) - (pminy-1);
    normed_buff{end+1} = currbuf;
    newz(end+1) = currz;

    curr = pt_set{k};
    normed = curr;
    normed(:,1) = normed(:,1) - (pminx-1); % start origin at 1,1
    normed(:,2) = normed(:,2) - (pminy-1);

    for p = 1:rows(curr),
        a = find(xm == normed(p,1));b = find(ym == normed(p,2));

        idx = intersect(intersect(a,b), ...
            find(zm == currz) );
        if length(idx) ~= 1
            error('whoops, found either no or multiple points');
        end;
        V(idx) = 1;
    end;
end;
fprintf(1,'Populated volume array ...\n');

z = [min(buffpos):0.2:max(buffpos)] - (min(buffpos)-1);

% takes binary volume 3d matrix, and plot3's them
function [px py pz] = sub__bruteforceVolView(x,y,z,V)
idx = find(V > 0);

px = [];py = [];pz = [];
for k = 1:length(idx)
    px = horzcat(px, x(idx(k)));
    py = horzcat(py, y(idx(k)));
    pz = horzcat(pz, z(idx(k)));
end;

% returns all the point locations at a given z-slice of a volume array only
function [px py pz] = sub__viewslice(V, x,y,z, zval,thresh)
idx = find(z == zval);
idx2 = find(V >= thresh);
idx = intersect(idx, idx2);
px = [];py = [];pz = [];
for k = 1:length(idx)
    px = horzcat(px, x(idx(k)));
    py = horzcat(py, y(idx(k)));
    pz = horzcat(pz, z(idx(k)));
end;


% make a binary 3D volume array for coordinates of a given brain ROI.
function [normed_buff newz V x y z] = sub__volumefromcoords_binary(roi, numvals)
coord_set = sub__get_brcoords(roi);
[buff, buffpos] = sub__getcoordsubset(coord_set, 'L', numvals-1);

pminx = Inf; pmaxx = -Inf;
pminy = Inf; pmaxy = -Inf;

pt_set = {};

% get limits on the axis
for k=1:length(buff)
    curr = buff{k};
    p = round(sub__makepoints(curr));
    pt_set{end+1} = p;
    buffx = curr(:,1); buffy = curr(:,2);

    pminx = min(pminx, min(p(:,1)));
    pmaxx = max(pmaxx, max(p(:,1)));
    pminy = min(pminy, min(p(:,2)));
    pmaxy = max(pmaxy, max(p(:,2)));
end;

numxvals = (pmaxx - pminx)+1;
numyvals = (pmaxy - pminy)+1;

V = nan(numxvals, numyvals, numvals);
x = 1:numxvals;
y = 1:numyvals;
z = 1:1:numvals;

normed_buff = {};
newz = [];
% now populate matrix with 1's and 0's
for k = 1:length(buff)
    currz = buffpos(k);
    currz = currz - 2;
    if currz ~= 3
        currbuf = buff{k};
        currbuf(:,1) = currbuf(:,1) - (pminx-1);
        currbuf(:,2) = currbuf(:,2) - (pminy-1);
        normed_buff{end+1} = currbuf;
        newz(end+1) = currz;

        curr = pt_set{k};
        normed = curr;
        normed(:,1) = normed(:,1) - (pminx-1); % start origin at 1,1
        normed(:,2) = normed(:,2) - (pminy-1);

        for p = 1:rows(curr), V(normed(p,1), normed(p,2), currz) = 1; end;
    end;
end;

% ------------------------------------------------------------------------
% Helper of helpers

function [rtcoords] = sub__get_ratcoords(ratname)
% load files
global Solo_datadir;
histodir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Histo' filesep 'ACx' filesep];

% get rats' coordinates
indir = [histodir ratname filesep];
infile = [indir  ratname '_coords.mat'];
try
    load(infile);
catch
    error('Error *** !\nCheck ratname: **%s**\nCheck fname: **%s**\n', ratname, infile);
end;

rtcoords = lesion_coords;



% loads files and get brain coordinates all in one struct
function [brcoords] = sub__get_brcoords(roi)
% load files
global Solo_datadir;
histodir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Histo' filesep 'ACx' filesep];
% get brain area coordinates
infile = [histodir 'polymark' filesep];
infile = [infile 'polygon_coords__' roi '.mat'];
try
    load(infile)
catch
    error('Error *** !\nCheck ROI: **%s**\nCheck fname: **%s**\n', roi, infile);
end;
brcoords = eval([roi '_coords;']);

function [buff, buffpos] = sub__getcoordsubset(coord_set, hem, maxval)
fnames = fieldnames(coord_set);
%figure;
ctr=1;
buff={}; buffpos = [];

threedeecoords = [];
for f = 1:length(fnames)
    if strcmpi(fnames{f}(1), hem)
        tmp = eval(['coord_set.' fnames{f} ';']);
        if ctr ~= 2
            buff{end+1} = tmp;
            tmp(end+1,:) = tmp(1,:);
            buffpos = horzcat(buffpos, str2double(fnames{f}(2:end)));
        end;
        if ctr > maxval, return;
        else ctr = ctr+1; end;
    end;
end;


% gets 2D point coordinates when given polygon vertex coordinates for an
% ROI
function [pts_array] = sub__makepoints(br)
pt_side = 1;
min_br = [ min(br(:,1)) min(br(:,2))]; max_br = [max(br(:,1)) max(br(:,2))];

msize=3;
lwdth = 1;

minx = min_br(:,1);miny = min_br(:,2);
maxx = max_br(:,1);maxy = max_br(:,2);

% placement of first point must be random.
rand('twister', sum(100*clock)); % new seed
st_rnd = rand(1,2) .* pt_side;

pts_x = (minx-pt_side)+st_rnd(:,1):pt_side:(maxx+pt_side)+st_rnd(:,1);
pts_y = (miny-pt_side)+st_rnd(:,2):pt_side:(maxy+pt_side)+st_rnd(:,2);

pts_array = [];
for k = 1:length(pts_y)
    currrow(:,1) = pts_x;
    currrow(:,2) = ones(size(pts_x)) * pts_y(k);
    pts_array = vertcat(pts_array, currrow);
end;

% find points in brain area
try
    idx_ba = inpoly(pts_array,br);
catch
    addpath('Analysis/duration_disc/poly_stuff/');
    idx_ba = inpoly(pts_array,br);
end;

pts_in_ba = find(idx_ba == 1);
pts_array = pts_array(pts_in_ba,:);



% junk code from early playing around
% ------------------------------------------------------------------------
function [V]  = sub__usetoyexample()

numslices = 2;
minX = 1;maxX = 2; xRes = 0.2;
minY = 1;maxY = 2; yRes = 0.2;
minZ = 1; maxZ = numslices; zRes = 0.2;

V = zeros(3,3,2);
% polygon 1
% p1(1:4,1:4,:) =[1 1; 1 2; 2 2; 2 1];
V(1,1,1) = 1;
V(1,3,1) = 1;
V(3,3,1) = 1;
V(3,1,1) = 1;

% p2 =[1 1 ;  1.5 1.5 ; 1 2;  2 2 ; 2 1];
V(1,1,2) = 1;
V(2,2,2) = 1;
V(1,3,2) = 1;
V(3,3,2) = 1;
V(3,1,2) = 1;

x = 1:0.2:3;
y = 1:0.2:3;
z = 1:0.2:2;
[xm ym zm] = meshgrid(x,y,z);