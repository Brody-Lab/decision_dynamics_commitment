function [out] = lesion_slice_coverage(ratname, roi, varargin)
% Computes pct. coverage of 'roi' for each slice in a given set of slices
% for a given rat (ratname).
% Example use:
% lesion_slice_coverage('Eaglet','AuD','slices', 1:3, 'graphic',1)

% output
% -------------º
% out - a struct with key/values
% out.pctcvg__L = s-by-1 array of % coverage for each slice for left hem
% out.pctcvg__R - same for R hemisphere
% out.cvgpts__L = s-by-1 array with intersecting point counts
% out.cvgpts__R
% out.areapts__L = s-by-1 array with # points in roi
% out.areapts__R
% out.lesionpt__L = s-by-1 array with # lesion points (lesion size)
% out.lesionpt__R
%
% When a lesion is not found for a hem/slice, pctcvg and cvgpts at that point = NaN.
% When ROI is not found for a hem/slice,
%           pctcvg, cvgpts, and areapts at that point = NaN.

pairs = { ...
    % Which data to use? -----------------
    'tissue_name', 'ACx3'; ...
    'ACx3_setsize',47; ...
    'ACx2_setsize', 47 ; ...
    'ACx_setsize', 33 ; ... % number slices in ACx template
    'mPFC_setsize', 21 ; ... % number slices in mPFC template
    'valid_rois', {} ; ... % the caller should provide this
    'slices', 1:100; % default is all
    'hem', 'B'; % L | R | B(oth)
    % What to return? --------------------
    'get_lesionsize_only', 0 ; ... % when true, the only field populated in out would be lesionpt__*
    % How to treat points where no lesion data is available?
    'use_NX_knowledge', 0 ; ... % when false, treats all points with no lesion polygons as NaN.
    % when true, uses the file scoring_0806.mat
    % to determine whether coverage value is
    % NaN or zero
    'use_interpolated_coords', 0 ; ... % when true, loads pre-interpolated lesion points and uses these
    % to compute coverage
    'scoring_file', 'scoring_0806' ; ...
    % Parameters for algorithms
    'pt_side', 1 ; ...
    % output flags --------------------------------------
    'graphic', 0 ; ...
    'graphic_gruntwork', 0 ; ...
    'verbose', 0 ; ...
    'verbose_gruntwork', 0 ; ...
    'usefig_gruntwork', [] ; ...
    'hemstr', 0  ; ...
    };
parse_knownargs(varargin,pairs);

if length(slices) == 100 % default of doing all slices
    slices = eval(['1:' tissue_name '_setsize;']);
end;

if ~ismember(valid_rois, roi)
    fprintf(1, 'Invalid roi - should be one of the following:\n');
    for k = 1:length(valid_rois), fprintf(1,'\t%s\n', valid_rois{k});end;
    return;
end;

% strings to denote hemisphere in question
hemstr=[];
hemstr.L = 'Left';
hemstr.R = 'Right';

% output struct
out = [];
out.pctcvg__L = zeros(length(slices),1);
out.pctcvg__R = zeros(length(slices),1);
out.cvgpts__L =zeros(length(slices),1);
out.cvgpts__R = zeros(length(slices),1);
out.areapts__L = zeros(length(slices),1);
out.areapts__R = zeros(length(slices),1);
out.lesionpt__L = zeros(length(slices),1);
out.lesionpt__R = zeros(length(slices),1);

% load files
global Solo_datadir;
%histodir = [Solo_datadir '..' filesep 'Histo' filesep tissue_name filesep];
histodir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Histo' filesep tissue_name filesep];

% get rats' coordinates
%indir = [histodir ratname filesep];
indir=histodir;
if use_interpolated_coords > 0
    infile = [indir  ratname '_interpolcoords.mat'];
    load(infile);
    lesion_coords = interpol_coords;
else
    infile = [indir 'rat_coords' filesep ratname '_coords.mat'];
    %  infile = [indir ratname '_coords.mat'];
    load(infile);

    %    rtinterpol_V = []; rtinterpol_Vx = []; rtinterpol_Vy = []; rtinterpol_Vz = [];
end;

rtcoords = lesion_coords;


% get brain area coordinates
infile = [histodir 'polymark' filesep];
infile = [infile 'polygon_coords__' roi '_reordered.mat'];
try
    load(infile)
catch
    error('Error *** !\nCheck ROI: **%s**\nCheck fname: **%s**\n', roi, infile);
end;
brcoords = eval([roi '_coords;']);


% get NX scoring data if flag is set
if use_NX_knowledge > 0
    % now load file which distinguishes ND (no data) from X (no lesion)
    infile = [histodir 'scoring' filesep scoring_file];
    load(infile);
    % variables of interest are only ACx_NXmarked__LEFT and
    % ACx_NXmarked__RIGHT. Delete all others
    clear ACx_lesionyesno__LEFT ACx_lesionyesno__RIGHT ACx_task PFC_lesion_yesno PFC_task ACx_lesion_coverage_scriptgen;

    % get this particular rat's NXmarked array
    for k = 1:2:length(ACx_NXmarked__LEFT)
        currat = ACx_NXmarked__LEFT{k};

        if strcmpi(ratname, currat)
            NXmarked__L = ACx_NXmarked__LEFT{k+1};
        end;
    end;

    for k = 1:2:length(ACx_NXmarked__RIGHT)
        currat = ACx_NXmarked__RIGHT{k};

        if strcmpi(ratname, currat)
            NXmarked__R = ACx_NXmarked__RIGHT{k+1};
        end;
    end;

end;

% begin computation ---------------------------------------

%sub__volumeview(brcoords, 'L')

%return;

if strcmpi(hem, 'B'), hemlist = {'R','L'}; else hemlist = {hem}; end;
newslicelist = [];

for s = 1:length(slices)
    currSliceNum = slices(s);
    %    if currSliceNum == 2, currSliceNum = 3; elseif currSliceNum == 3, currSliceNum = 2; end;
    newslicelist = horzcat(newslicelist, currSliceNum);
    currSlice = num2str(currSliceNum);

    for h = 1:length(hemlist)
        currHem = hemlist{h};
        polynum=1; % number lesions at this hem/slice
        bfstr = [currHem currSlice];
        rfstr = [currHem currSlice '_' num2str(polynum)];

        % multiple polys per hem/slice not implemented for mPFC -- check to
        % ensure code OK
        otherhem_fstr = [hemlist{3-h} currSlice];

        morepolys=1;

        while morepolys > 0
            % either there is no lesion here or the brain area simply doesn't
            % exist at this slice location

            if get_lesionsize_only == 0
                if (~strcmpi(tissue_name, 'mPFC') && (~isfield(rtcoords, rfstr))) || ...
                        (strcmpi(tissue_name,'mPFC') && ~isfield(rtcoords, rfstr) && ~isfield(rtcoords, otherhem_fstr))% rat doesn't have data
                    % mPFC has lesions spanning the midline,so even if
                    % something is categorized as being on the left, it may
                    % span an area on the right (And vice versa)

                    if isfield(brcoords, bfstr) % brain area exists, so rat was probably just not covered.
                        if isfield(brcoords, bfstr),    br = eval(['brcoords.' bfstr]);
                        else    br = [];
                        end;

                        if use_interpolated_coords > 0
                            error('This should never happen. You should not be here.');
                        end;
                        rt = [];

                        [c t numpt areapt] = lesion_slice_gruntwork(rt, br, pt_side, ...
                            graphic_gruntwork, verbose_gruntwork, currSlice,...
                            eval(['hemstr.' currHem]), ratname, roi,'usefig', usefig_gruntwork);

                        if  use_NX_knowledge > 0
                            error('sorry, I''ve removed this code for legibility. please see another version to get it if you want to use this flag');
                        else
                            c = 0; % coverage is not a valid measure here
                            numpt = 0;
                        end;

                    else % brain area simply doesn't exist at this point
                        c = NaN; numpt = NaN; areapt = NaN;
                    end;

                else
                    if strcmpi(tissue_name,'mPFC') && ~isfield(rtcoords, rfstr)
                        rt = eval(['rtcoords.' otherhem_fstr]);
                    else
                        rt = eval(['rtcoords.' rfstr]);
                    end;

                    if isfield(brcoords, bfstr)
                        br = eval(['brcoords.' bfstr]);
                    else
                        br = [];
                    end;

                    [c t numpt areapt] = lesion_slice_gruntwork(rt, br, pt_side, ...
                        graphic_gruntwork, verbose_gruntwork, currSlice, ...
                        eval(['hemstr.' currHem]), ratname,roi,'usefig', usefig_gruntwork);

                end;
                % store coverage
                tmp = eval(['out.pctcvg__' currHem ';']);
                if isnan(c), tmp(s)=c; else tmp(s) = tmp(s)+c; end;
                %                tmp = horzcat(tmp, c);
                eval(['out.pctcvg__' currHem ' = tmp;']);
%                                 fprintf(1,'(%s) polynum=%i, pctcvg now=%2.1f\n', currHem, polynum, tmp(s)*100);

                % store numpts
                tmp = eval(['out.cvgpts__' currHem ';']);
                %   tmp = horzcat(tmp, numpt);
                if isnan(numpt), tmp(s)=numpt; else tmp(s)=tmp(s)+numpt;end;
                eval(['out.cvgpts__' currHem ' = tmp;']);                
%                 fprintf(1,'(%s) polynum=%i, cvgpts=%i\n', currHem, polynum, numpt);
                
                                % store areapts -- areapts should not be added since they
                % reflect the size of the ROI and not of an additional
                % lesion
                tmp = eval(['out.areapts__' currHem ';']);
                tmp(s) = areapt;
%                 if isnan(areapt), tmp(s)=areapt; else
%                 tmp(s)=tmp(s)+areapt;end;
                eval(['out.areapts__' currHem ' = tmp;']);
            end;

            polynum=polynum+1;
            rfstr = [currHem currSlice '_' num2str(polynum)];
            if ~isfield(rtcoords, rfstr)
                morepolys=-1;
            end;

        end;
        
        tmp = eval(['out.cvgpts__' currHem ';']);
        %fprintf(1,'** (%s) # polys=%i, total coverage=%i\n', currHem, polynum-1, tmp(s));

        %  fprintf(1,'%i%s:', currSliceNum, currHem);

        if ~isfield(rtcoords, rfstr)    % rat doesn't have data
            currtmp = 0;
        else
            currtmp = sub__makepoints(rt,pt_side, graphic, use_interpolated_coords);
        end;
        eval(['tmp = out.lesionpt__' currHem ';']);
        if isnan(currtmp), tmp(s)=NaN; else tmp(s)=tmp(s)+currtmp;end;

        eval(['out.lesionpt__' currHem ' = tmp;']);
    end;
end;


if graphic > 0
    % % now plot coverage for AuD for first 10 slices
    msize = 20;
    figure;
    hemlist={'L','R'};
    for h = 1:length(hemlist)
        %subplot(length(hemlist),1,h);
        if length(hemlist) > 1
            if h == 1
                axes('Units','normalized', 'Position', [0.07 0.1 0.89 0.3]);
            else
                axes('Units', 'normalized', 'Position', [0.07 0.6 0.89 0.3]);
            end;
        else
            axes('Units','normalized','Position', [0.07 0.1 0.89 0.85]);
        end;
        currHem = hemlist{h};

        x = eval(['out.pctcvg__' currHem ';']);
        plot(slices, x, '.b', 'MarkerSize', msize, 'Color', [0.5 0 0.5]);

        if 0
            empt = findstr(eval(['NXmarked__' currHem ]), 'N');
            hold on;
            plot(slices(empt), x(empt), '.b', 'MarkerSize', msize, 'Color', [1 0.5 0]);
        end;

        ylabel(sprintf('%% in %s hem.', eval(['hemstr.' currHem]) ));
        xlabel('Slice #');
        title(sprintf('Coverage of %s for rat %s', roi, ratname));

        set(gca,'YLim',[0 1.05],'YTick',0:0.2:1, 'YTickLabel',0:20:100, ...
            'XLim', [min(slices)-1 max(slices)+1],'XTick', slices);

        axes__format(gca, 14);
    end;

    set(gcf,'Position',[255 476 844 410]);
    sign_fname(gcf,mfilename);
end;


function [] = sub__volumeview(coord_set, hem,maxval)

buff = {};
buffpos = [];
fnames = fieldnames(coord_set);
figure;

ctr=1;

threedeecoords = [];
for f = 1:length(fnames)
    %   if strcmpi(fnames{f}(1), hem)
    tmp = eval(['coord_set.' fnames{f} ';']);
    buff{end+1} = tmp;
    tmp(end+1,:) = tmp(1,:);
    buffpos = horzcat(buffpos, str2double(fnames{f}(2:end)));
    h=patch(ones(rows(tmp),1)*buffpos(end), tmp(:,1),tmp(:,2),'r'); hold on;
    threedeecoords = vertcat(threedeecoords, [tmp(:,1) tmp(:,2) ones(rows(tmp),1)*buffpos(end)]);

    set(h,'FaceColor', 'r', 'EdgeColor','none','FaceAlpha', 0.2);
    %colormap hot
    %shading interp
    %set(h,'EdgeColor','k')
    ctr = ctr+1;
    % end;
end;

set(gca,'XGrid','on','YGrid','on','ZGrid','on');

% returns all the point locations at a given z-slice of a volume array only
function [px py pz] = sub__viewslice(V, x,y,z, zval, thresh)
idx = find(z == zval);
idx2 = find(V >= thresh);
idx = intersect(idx, idx2);
px = [];py = [];pz = [];
for k = 1:length(idx)
    px = horzcat(px, x(idx(k)));
    py = horzcat(py, y(idx(k)));
    pz = horzcat(pz, z(idx(k)));
end;

function [lesionpt] = sub__makepoints(rt,pt_side, graphic, use_interpolated_coords)

lesionpt = 0;
msize=3;
lwdth = 1;

% get extreme points for points mesh
if ~isempty(rt)
    min_rt = [ min(rt(:,1)) min(rt(:,2))]; max_rt = [max(rt(:,1)) max(rt(:,2))];
else
    return;
    %         if use_interpolated_coords > 0
    %             min_rt = [ min(interpx), min(interpy) ] ;
    %             max_rt = [ max(interpx), max(interpy) ];
    %         else
    %             return;
    %         end;
end;

minx = min_rt(:,1);
miny = min_rt(:,2);

maxx = max_rt(:,1);
maxy = max_rt(:,2);

% now set up mesh
rand('twister', sum(100*clock)); % new seed
st_rnd = rand(1,2) .* pt_side;
%
%     if use_interpolated_coords > 0, error('SOrry, not implemented.'); end;
%
%     % add the offset to fed-in points
%     if use_interpolated_coords > 0
%         interpx =interpx + st_rnd(:,1);
%         interpy =interpy + st_rnd(:,2);
%     end;

pts_x = (minx-pt_side)+st_rnd(:,1):pt_side:(maxx+pt_side)+st_rnd(:,1);
pts_y = (miny-pt_side)+st_rnd(:,2):pt_side:(maxy+pt_side)+st_rnd(:,2);

pts_array = [];
for k = 1:length(pts_y)
    currrow(:,1) = pts_x;
    currrow(:,2) = ones(size(pts_x)) * pts_y(k);
    pts_array = vertcat(pts_array, currrow);
end;

idx_rt = inpoly(pts_array,rt);

lesionpt = sum(idx_rt);

if graphic > 0
    figure;
    % Plot points for each domain
    % visualize points
    plot(pts_array(:,1),pts_array(:,2),'+k','Color', [1 1 1]*0.85,'MarkerSize',msize,'LineWidth',lwdth);
    % in lesion
    plot(pts_array(idx_rt,1), pts_array(idx_rt,2),'+r','MarkerSize',msize,'LineWidth',lwdth);

    % resize figure to make it square
    xlim = get(gca,'XLim'); ylim = get(gca,'YLim');
    set(gcf,'Position',[200 200 diff(xlim)*3 diff(ylim)*3]);
    set(gca,'Position',[0.07 0.05 0.9 0.9]);

    axes__format(gca,12);
    fprintf(1,'Point count = %i\n', lesionpt);
end;
