function [] = lesion_interpolate(ratname, action,varargin)

pairs = { ...
    'tissue_name', 'mPFC' ; ...
    'maxslices', 33 ; ... % slices in ACx set
    'swap2and3', 0 ; ... % use only for original ACx ibo lesion scoring
    'graphic', 1 ; ... % set to 1 to see original and interpolated figures in each case
    'save2file', 1 ; ... % set to true to save original and interpolated coordinates to a file
    'shrink_factor', 0.2;  ... % incremental pct by which a polygon shrinks in adjacent slices
    };
parse_knownargs(varargin,pairs);

switch action
    % uses averageshape
    case 'averageshape_interp'

        dashes = repmat('-',1,100);
        fprintf(1,'LEFT:\n%s', dashes);
        [lesion_coords newbuff newbuffpos] = sub__interp_a_hem(ratname, tissue_name, 'L', graphic, maxslices, shrink_factor,swap2and3);
        lstruct = sub__coord2struct(newbuff, newbuffpos,'L');

        rstruct.blah = 0;
        %
                 fprintf(1,'RIGHT:\n%s', dashes);
                 [lesion_coords newbuff newbuffpos] = sub__interp_a_hem(ratname, tissue_name, 'R', graphic,maxslices, shrink_factor, swap2and3);
                 rstruct = sub__coord2struct(newbuff, newbuffpos,'R');
            pause(5); close all;


        interpol_coords = lstruct; fnames = fieldnames(rstruct);
        for f = 1:length(fnames)
            eval(['interpol_coords.' fnames{f} ' = rstruct.' fnames{f} ';']);
        end;

        if save2file > 0
            global Solo_datadir;
            histodir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Histo' filesep tissue_name filesep];
            outdir = [histodir ratname filesep];

            outfile = [outdir  ratname '_interpolcoords.mat']
            save(outfile, 'lesion_coords', 'interpol_coords');
        end;

        % converts vertices into points which then populate a 3d volume matrix
    case '3D_point_interp'

        [lesion_coords ...
            coord_set zvals ...
            V xlims ylims zlims ...
            xorig yorig zorig ...
            offsetx offsety] = sub__volumefromcoords_flowstyle(ratname);

        global Solo_datadir;
        histodir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Histo' filesep 'ACx' filesep];

        % get rats' coordinates
        indir = [histodir ratname filesep];
        infile = [indir  ratname '_interpolcoords.mat'];
        save(infile, 'coord_set','zvals', ...
            'V','xorig','yorig','zorig', ...
            'xlims','ylims','zlims', ...
            'offsetx','offsety');

        [xm ym zm] = meshgrid(xlims, ylims, zlims);

        clear lesion_coords xlims ylims zlims coord_set zvals;

        fprintf(1,'Beginning interpolation ...');
        VI = interp3(xorig, yorig, zorig, V, xm, ym, zm, 'spline');
        fprintf(1,'done\n');

        % get rats' coordinates
        load(infile);
        save(infile, 'lesion_coords','coord_set','zvals', ...
            'V','xorig','yorig','zorig', ...
            'VI','xlims','ylims','zlims', ...
            'offsetx','offsety');

    otherwise
        error('Action can only be one of: vertex_interp or 3D_point_interp');
end;

% ------------------------------------------------------------------------
% Subroutines
% ------------------------------------------------------------------------

function [out] = sub__coord2struct(newbuff, newbuffpos,hem)
out = 0;
for k = 1:length(newbuffpos)
    mystr = ['out.' hem num2str(newbuffpos(k)) ' = newbuff{' num2str(newbuffpos(k)) '};'];
    eval(mystr);
end;


function [coord_set newbuff newbuffpos] = sub__interp_a_hem(ratname, tissue_name, hem, graphic, maxslices, shrink_factor, swap2and3)

global s1_set;
global s2_set;

s1_set = {};
s2_set = {};

coord_set = sub__get_ratcoords(ratname, tissue_name);
[buff, buffpos] = sub__getcoordsubset(coord_set, hem);

if strcmpi(ratname, 'Moria')
    2;
end;
if swap2and3 > 0
    [buff, buffpos] = sub__swap2and3(buff,buffpos);
end;

newbuff = cell(maxslices,1);
newbuffpos = NaN(maxslices,1);

% interpolate on the start end
if isempty(buffpos)
    newbuffpos=1:maxslices;
else
        firstpos = buffpos(1);
    for i = firstpos-1:-1:1
        fac = max(0,1-(shrink_factor * (firstpos-i)));

        if fac > 0
            try
                out = resize_polygon(buff{1}, fac);
            catch
                addpath('Analysis/duration_disc/lesioninterpol/');
                out = resize_polygon(buff{1}, fac);
            end;
            if graphic > 0
                figure;
                plot(buff{1}(:,1), buff{1}(:,2), '-r'); hold on;
                plot(out(:,1), out(:,2),'-g');
                title(sprintf('Endpoint %i shrunk to %2.1f%%', i, fac*100));
            end;

            fprintf(1,'#%i: Lesion shrinks at endpoint\n',i);
            newbuff{i} = out;
        else
            fprintf(1,'#%i: Lesion doesn''t extend this far\n',i);
            newbuff{i} = [];

        end;
        newbuffpos(i) = i;
    end;

    % now interpolate in all cases where there exist data in flanking slices
    idx = find(diff(buffpos) > 1);
    for i = 1:length(idx)
        currslice = buffpos(idx(i));
        nextslice = buffpos(idx(i)+1);

        for j = currslice+1:nextslice-1
            shrinkbef = max(0,1-(shrink_factor * (j-currslice)));
            shrinkaft = max(0,1-(shrink_factor * (nextslice-j)));
            if shrinkbef == 0
                if shrinkaft == 0 % no lesion here
                    fprintf(1,'#%i -- No lesion here -----!!! \n', j, currslice);
                    newbuff{j} = [];
                else % polygon should match aft-polygon
                    fprintf(1,'#%i -- %i only -----!!! \n', j, nextslice);
                    newbuff{j} = resize_polygon(buff{idx(i)+1}, shrinkaft);
                end;
            else % bef-polygon exists at this point
                if shrinkaft == 0
                    fprintf(1,'#%i -- %i only -----!!! \n', j, currslice);
                    newbuff{j} = resize_polygon(buff{idx(i)}, shrinkbef);
                else % both are around - interpolate
                    fprintf(1,'Interpolating at #%i (%i and %i)\n', j, currslice, nextslice);
                    newbuff{j} = sub__avg_twixt_2slices(resize_polygon(buff{idx(i)}, shrinkbef), currslice, ...
                        resize_polygon(buff{idx(i)+1}, shrinkaft), nextslice, ...
                        j, graphic);
                end;
            end;

            newbuffpos(j) = j;
        end;
    end;

    % interpolate on the other end
    lastpos = buffpos(end);
    for i = lastpos+1:1:maxslices
        fac = max(0,1-(0.2 * (i-lastpos)));

        if fac > 0
            out = resize_polygon(buff{end}, fac);
            if graphic > 0
                figure; set(gcf,'Position',[200 200 400 400]);
                plot(buff{end}(:,1), buff{end}(:,2), '-r'); hold on;
                plot(out(:,1), out(:,2),'-g');
                title(sprintf('Endpoint %i shrunk to %2.1f%%', i, fac*100));
            end;
            fprintf(1,'#%i: Lesion shrinks at endpoint\n',i);
            newbuff{i} = out;
        else
            fprintf(1,'#%i: Lesion doesn''t extend this far\n',i);
            newbuff{i} = [];

        end;
        newbuffpos(i) = i;
    end;

    % sanity check.
    b=find(isnan(newbuffpos)); if sum(abs(buffpos' - b)) > 0, error('NaN spots in newbuffpos should be exactly the contents of buffpos'); end;


    % tack on old buff/buffpos data
    for k = buffpos
        newbuff{k} = buff{buffpos == k};
        newbuffpos(k) = k;
    end;
end;


% swap slice #2 and 3
function [buff buffpos] = sub__swap2and3(buff,buffpos)

idx2 = find(buffpos == 2);
idx3 = find(buffpos == 3);
if idx3 < idx2,
    bufftmp = buff;
    buff{idx2} = bufftmp{idx3};
    buff{idx3} = bufftmp{idx2};
    postmp = buffpos;
    buffpos(idx2) = postmp(idx3);
    buffpos(idx3) = postmp(idx2);

    clear postmp bufftmp;
end;


% uses averageshape.m to interpolate between two slices
function [out] = sub__avg_twixt_2slices(coords1, pos1, coords2, pos2, interp_at, graphic)

global s1_set;
global s2_set;

shape1 = round(coords1); shape2=round(coords2);
pos_s1 = pos1;
pos_s2 = pos2;

dist_twixt = (pos_s2 - pos_s1);

% assumes s1 comes before s2 (ie buffpos(s1) < buffpos(s2))
wt_s2 = (interp_at - pos_s1) / (dist_twixt);
wt_s1 = (pos_s2 - interp_at) / (dist_twixt);

s1(1,:) = shape1(:,2)'; s1(2,:) = shape1(:,1)';
s2(1,:) = shape2(:,2)'; s2(2,:) = shape2(:,1)';

s1tmp = s1; s1(1,:) = s1tmp(2,:); s1(2,:) = s1tmp(1,:);
s2tmp = s2; s2(1,:) = s2tmp(2,:); s2(2,:) = s2tmp(1,:);

if graphic > 0
    figure; set(gcf,'Position',[200 200 400 400]);

    plot(s1(1,:), s1(2,:), '-r');
    hold on; plot(s2(1,:), s2(2,:), '-b');
end;

s1_set{end+1} = s1;
s2_set{end+1} = s2;
try
    out = averageshape(s1(:,1:end-1),s2(:,1:end-1), wt_s1, wt_s2);
catch
    addpath('Analysis/duration_disc/lesioninterpol/');
    out = averageshape(s1(:,1:end-1),s2(:,1:end-1), wt_s1, wt_s2);
end;


out(end+1,:)= out(1,:);
if graphic > 0
    hold on; plot(out(:,1), out(:,2),'-g');
    hold on; plot(out(:,1), out(:,2), '-k');
    title(sprintf('interpolating between at #%i using #%i (%1.2f) and #%i (%1.2f)', interp_at, pos_s1, wt_s1, pos_s2, wt_s2));
end;


function [coord_set normed_buff newz V x y z xm ym zm pminx pminy] = sub__volumefromcoords_flowstyle(roi,hem)
%coord_set = sub__get_brcoords(roi);
coord_set = sub__get_ratcoords(roi);
fprintf(1,'Got coords...\n');

[buff, buffpos] = sub__getcoordsubset(coord_set, hem);
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

z = [min(buffpos):1:max(buffpos)] - (min(buffpos)-1);

% converts struct data to input format for volume array
function [buff, buffpos] = sub__getcoordsubset(coord_set, hem)
fnames = fieldnames(coord_set);
buff={}; buffpos = [];
for f = 1:length(fnames)
    if strcmpi(fnames{f}(1), hem)
        tmp = eval(['coord_set.' fnames{f} ';']);
        buff{end+1} = tmp;
        tmp(end+1,:) = tmp(1,:);
        buffpos = horzcat(buffpos, str2double(fnames{f}(2:end)));
    end;
end;

% takes binary volume 3d matrix, and plot3's them
function [px py pz] = sub__bruteforceVolView(x,y,z,V)
idx = find(V > 0);

px = [];py = [];pz = [];
for k = 1:length(idx)
    px = horzcat(px, x(idx(k)));
    py = horzcat(py, y(idx(k)));
    pz = horzcat(pz, z(idx(k)));
end;

% returns lesion coordinates from rat's input file
function [rtcoords] = sub__get_ratcoords(ratname, tissue_name)
% load files
global Solo_datadir;
histodir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Histo' filesep tissue_name filesep];

% get rats' coordinates
indir = [histodir ratname filesep];
infile = [indir  ratname '_coords.mat'];
try
    load(infile);
catch
    error('Error *** !\nCheck ratname: **%s**\nCheck fname: **%s**\n', ratname, infile);
end;

rtcoords = lesion_coords;

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

