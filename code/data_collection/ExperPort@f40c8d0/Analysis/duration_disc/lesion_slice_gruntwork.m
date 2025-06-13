function [cvg tm numpts areapts] = lesion_slice_gruntwork(rt, br, pt_side, graphic, verbose, ...
    slicenum, hem,ratname, brainarea, varargin)
% Does the actual work of computing # points overlapping between the lesion
% extent and roi extent in a given slice.
% input params:
% 1 - rt: coordinates of lesion - px2 array of (x,y) vertices of polygon
% 2 - br: coordinates of roi - px2 array of (x,y) vertices of polygon
% 3 - pt_side: grid resolution (usually 1)
% 4 - graphic: yes/no - show overlap?
% 5 - verbose: yes/no - print output params to stdout?
% 6 - slicenum: slice # in set (used for display)
% 7 - hem: hemisphere (L or R) (used for display)
% 8 - ratname: (used for display)
% 9 - brainarea: (used for display)
% 10 - varargin{1}: optional -- handle for figure on which graphic is to be
% displayed
%
% Output params:
% 1: cvg: A value between 0 and 1 indicating % coverage of roi by lesion
% 2. tm: time (in seconds) taken by operations
% 3. numpts: # points overlapping between lesion and roi
% 4. areapts: # points that roi has

pairs = { ...
    'usefig', []; ... % which figure to plot points in?
    'use_interpolated_coords', 0 ; ...
    'interpx',  []; ...
    'interpy' , [] ; ...
    };
parse_knownargs(varargin,pairs);

tic
msize=3;
lwdth = 1;

% Base case: Brain area doesn't exist at this point
if isempty(br)
    cvg = NaN;
    tm=toc;
    numpts = NaN;
    areapts = NaN;
    return;
end;

min_br = [ min(br(:,1)) min(br(:,2))]; max_br = [max(br(:,1)) max(br(:,2))];

    if ~isempty(rt)
        min_rt = [ min(rt(:,1)) min(rt(:,2))]; max_rt = [max(rt(:,1)) max(rt(:,2))];
    else
        if use_interpolated_coords > 0
            min_rt = [ min(interpx), min(interpy) ] ;
            max_rt = [ max(interpx), max(interpy) ];
        else
        min_rt = [inf inf]; max_rt = [-inf -inf];
        end;
    end;

    minx = min(min_br(:,1), min_rt(:,1));
    miny = min(min_br(:,2), min_rt(:,2));

    maxx = max(max_br(:,1), max_rt(:,1));
    maxy = max(max_br(:,2), max_rt(:,2));

    % placement of first point must be random.
    rand('twister', sum(100*clock)); % new seed
    st_rnd = rand(1,2) .* pt_side;
    
    % add the offset to fed-in points
    if use_interpolated_coords > 0
        interpx =interpx + st_rnd(:,1);
        interpy =interpy + st_rnd(:,2);
    end;        

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
% now find points in lesion area


    if ~isempty(rt)
        idx_rt = inpoly(pts_array,rt);
        % now show the intersection in green
        both = intersect(find(idx_ba == 1), find(idx_rt == 1));
    else
        if use_interpolated_coords > 0            
            if cols(interpx) > 1, interpx = interpx'; end;
            if cols(interpy) > 1, interpy = interpy'; end;
            
            mypts =[interpx interpy];
            idx_rt = zeros(rows(pts_array), 1);
            
            for p = 1:length(mypts)
                tmp = intersect(find(pts_array(:,1) == mypts(p,1)),find(pts_array(:,2) == mypts(p,2)));
                if ~isempty(tmp), idx_rt(tmp) = 1;end;
            end;
           
                        idx_rt = find(idx_rt==1);
            both = intersect(find(idx_ba == 1), idx_rt);
        else
        idx_rt = [];
        both = [];
        end;
    end;


numpts = length(both);
areapts = length(pts_in_ba);
cvg =  (length(both) ./ length(pts_in_ba));
tm = toc;

if graphic > 0
    % ----------
    % Graphics begin here
    % Plot lesion & brain area polygons

    if ~isempty(usefig)
        set(0,'CurrentFigure', usefig);
    else
        figure;
    end;

    %plot brain area polygon
    patch(br(:,1), br(:,2), 'r' ,'FaceColor','none','EdgeColor', 'b' ,'LineWidth',2,'LineStyle',':');
    %now plot lesion polygon from rat
    hold on;
    if ~isempty(rt)
        patch(rt(:,1), rt(:,2),'r','FaceColor','none','EdgeColor', 'r' ,'LineWidth',2,'LineStyle',':');
    end;

    % Plot points for each domain
    % visualize points
    plot(pts_array(:,1),pts_array(:,2),'+k','Color', [1 1 1]*0.85,'MarkerSize',msize,'LineWidth',lwdth);
    % in brain area
    plot(pts_array(idx_ba,1), pts_array(idx_ba,2),'+b','MarkerSize',msize,'LineWidth',lwdth);
    % in lesion    
    plot(pts_array(idx_rt,1), pts_array(idx_rt,2),'+r','MarkerSize',msize,'LineWidth',lwdth);
    plot(pts_array(both,1), pts_array(both,2),'+g','MarkerSize',msize,'LineWidth',lwdth);

    % resize figure to make it square
    xlim = get(gca,'XLim'); ylim = get(gca,'YLim');
    set(gcf,'Position',[200 200 diff(xlim)*3 diff(ylim)*3]);
    set(gca,'Position',[0.07 0.05 0.9 0.9]);

    t=title(sprintf('%s: Lesion overlap for %s: %s%s', ratname, brainarea,slicenum, hem));
    axes__format(gca,12);
end;

area_per_pt = pt_side ^ 2;
if verbose > 0
    % ----------
    % Verbose output
    dashes = repmat('-',1,50);
    fprintf(1,'%s\n',dashes);
    fprintf(1,'Base information:\n\tRat %s\n\tAtlas ROI = %s\n\tSlice = %i\n\tHem = %s\n', ratname, brainarea, slicenum, hem);
    fprintf(1, 'Point-count:\n\tIn %s: %i\n\t# intersecting points = %i\n\t%% Coverage for this slice = %2.1f\n', ...
        brainarea, length(pts_in_ba), length(both), (length(both) ./ length(pts_in_ba))*100);
    %  fprintf(1, 'Area:\n\t%s = %2.1f pts^2 \n\tLesioned=%2.1f pts^2\n', ...
    %       brainarea, sub__area(length(pts_in_ba), area_per_pt), sub__area(length(both), area_per_pt));
    fprintf(1,'Time taken = %2.3f seconds\n', tm);
    fprintf(1,'%s\n',dashes);
end;
