function [newbuff newbuffpos] = interp_shape_test(ratname)

maxslices = 33;
shrink_factor = 0.2; % by how much does a lesion shrink between two slices?

global s1_set;
global s2_set;

s1_set = {};
s2_set = {};

coord_set = sub__get_ratcoords(ratname);
[buff, buffpos] = sub__getcoordsubset(coord_set, 'L');

newbuff = {};
newbuffpos = [];

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

% interpolate on the start end
firstpos = buffpos(1);
for i = firstpos-1:-1:1
   fac = max(0,1-(shrink_factor * (firstpos-i)));
 
    if fac > 0
        out = resize_polygon(buff{1}, fac);
        figure;
        plot(buff{1}(:,1), buff{1}(:,2), '-r'); hold on;
        plot(out(:,1), out(:,2),'-g');
        title(sprintf('Endpoint %i shrunk to %2.1f%%', i, fac*100));
        fprintf(1,'#%i: Lesion shrinks at endpoint\n',i);
        newbuff{end+1} = out;
    else
        fprintf(1,'#%i: Lesion doesn''t extend this far\n',i);
        newbuff{end+1} = [];

    end;
     newbuffpos(end+1) = i;
end;

% now interpolate in all cases where there exist data in flanking slices
idx = find(diff(buffpos) > 1);
for i = 1:length(idx)
    currslice = buffpos(idx(i));
    nextslice = buffpos(idx(i)+1);
    
    for j = currslice+1:nextslice-1
        fprintf(1,'Interpolating at #%i (%i and %i)\n', j, currslice, nextslice);
        newbuff{end+1} = interpolate_slice(buff{idx(i)}, currslice, buff{idx(i)+1}, nextslice, j);    
        newbuffpos(end+1) = j;
    end;        
end;

% interpolate on the other end
lastpos = buffpos(end);
for i = lastpos+1:1:maxslices
   fac = max(0,1-(0.2 * (i-lastpos)));
 
    if fac > 0
        out = resize_polygon(buff{end}, fac);
        figure;
        plot(buff{end}(:,1), buff{end}(:,2), '-r'); hold on;
        plot(out(:,1), out(:,2),'-g');
        title(sprintf('Endpoint %i shrunk to %2.1f%%', i, fac*100));
        fprintf(1,'#%i: Lesion shrinks at endpoint\n',i);
       newbuff{end+1} = out;
    else
        fprintf(1,'#%i: Lesion doesn''t extend this far\n',i);
        newbuff{end+1} = [];

    end;
     newbuffpos(end+1) = i;
end;

newbuffpos(end+1:end+length(buffpos)) = buffpos;
for k = 1:length(buff)
    newbuff{end+1} = buff{k};
end;

% now rearrange the output to contain all the data in order
tmpbuff = newbuff;
tmppos = newbuffpos;
for j = 1:maxslices
    idx = find(tmppos == j);
    if isempty(idx)
        idx
        error(sprintf('Whoops, should not be missing slice at %i', idx));
    end;
    newbuffpos(j) = j;
    newbuff{idx} = tmpbuff{idx};
end;



function [out] = interpolate_slice(coords1, pos1, coords2, pos2, interp_at)

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

figure; plot(s1(2,:), s1(1,:), '-r');
hold on; plot(s2(2,:), s2(1,:), '-b');

s1_set{end+1} = s1;
s2_set{end+1} = s2;

out = averageshape(s1(:,1:end-1),s2(:,1:end-1), wt_s1, wt_s2);
out(end+1,:)= out(1,:);
hold on; plot(out(:,2), out(:,1),'-g');
hold on; plot(out(:,2), out(:,1), '-k');
title(sprintf('interpolating between at #%i using #%i (%1.2f) and #%i (%1.2f)', interp_at, pos_s1, wt_s1, pos_s2, wt_s2));

2;

% -----------------------------------------------------------------------
% Subroutines


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

function [buff, buffpos] = sub__getcoordsubset(coord_set, hem)
fnames = fieldnames(coord_set);
%figure;

buff={}; buffpos = [];

threedeecoords = [];
for f = 1:length(fnames)
    if strcmp(fnames{f},'L31')
        2;
    end;
    
    if strcmpi(fnames{f}(1), hem)
        tmp = eval(['coord_set.' fnames{f} ';']);
        buff{end+1} = tmp;
        tmp(end+1,:) = tmp(1,:);
        buffpos = horzcat(buffpos, str2double(fnames{f}(2:end)));
    end;
end;


