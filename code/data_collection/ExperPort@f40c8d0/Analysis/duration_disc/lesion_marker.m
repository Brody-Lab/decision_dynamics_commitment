function [] = lesion_marker(varargin)

pairs = { ...
    'slice_interval', 0.12 ; ...
    'atlas_beginpos', -3 ; ...
    'tissue_name', 'ACx'; ...
    };
parse_knownargs(varargin,pairs);

global Solo_datadir;
fname = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Histo' filesep tissue_name filesep 'scoring' filesep 'scoring_0806.mat'];
fprintf(1,'%s\n', fname);

load(fname);

tissue = 'ACx';
hem = 'LEFT';
lesion_yesno = eval([tissue '_NXmarked__' hem]);
task = eval([tissue '_task']);
figtitle = ['Lesion score: ' tissue ': ' hem ' hemisphere'];

for k= 1:(length(lesion_yesno)/2),
    name = lesion_yesno{(2*(k-1))+1};
    val = lesion_yesno{2*k};
    fprintf(1,'%s = %i\n', name, length(val));
end;

sub__plotbasic(lesion_yesno, task,slice_interval, atlas_beginpos);
title(figtitle);
set(gca,'Position',[0.07 0.1 0.85 0.8]);

function [] = sub__plotbasic(in,task,slice_interval, atlas_beginpos)

haslesion = [1 0 0];
nolesion  = [0 0 0];
nodata = [1 1 1] * 0.9;
%dur = [1 1 0.8];
dur=group_colour('durlite');
%freq = [0.8 0.8 1];
freq=group_colour('freqlite');

figure;

vallen = 0;
numrats = 0;
ylbls= {};

mycell = {};

colsum = [];
for k= 1:(length(in)/2),
    name = in{(2*(k-1))+1};
    ylbls{end+1} = name;
    val = in{2*k};
    vallen = length(val);
    numrats = numrats+1;
    fprintf(1,'%s = %i\n', name, length(val));
    for m = 1:length(val)
        c = val(m);
        tmp = str2double(c);
        if isnan(tmp) % not a 1 or 0, must be X or N
            mycell{k,m} = 0;
        else
            mycell{k,m} = 1;
        end;

        % rats are rows,
        switch c
            case 'X'
                patch([m m m+1 m+1], [k k+1 k+1 k], nolesion); %'EdgeColor','none');
            case '1'
                if strcmpi(task(k),'d'), clr = dur; else clr = freq; end;
                patch([m m m+1 m+1], [k k+1 k+1 k], clr);  %'EdgeColor','none');
            case 'N'
                patch([m m m+1 m+1], [k k+1 k+1 k], nodata); %'EdgeColor','none');
            otherwise
                error('invalid value - 1, N, or X');
        end;
        hold on;
    end;
end;

mycell = cell2mat(mycell);
colsum = sum(mycell);

duridx = findstr(task, 'd');
dursum = sum(mycell(duridx,:));
freqidx = findstr(task,'p');
freqsum = sum(mycell(freqidx,:));

%sub__clr_a_row(0, abs(dursum-freqsum), length(duridx)); % plot disparity
%sub__mark_a_col(vallen+1, sum(mycell'), vallen);
ratsum = sum(mycell');
for k= 1:length(ratsum)
    text(vallen+1.2, k+0.5, sprintf('%i (%i%%)', ratsum(k), round((ratsum(k)/33)*100)),'FontWeight','bold','FontSize',18);
end;


% now plot coverage for group
mm_interval = ceil(1 / slice_interval);
halfmm = ceil(0.5 / slice_interval);
xtks = 1.5:mm_interval:vallen+0.5;
halftks = 1+halfmm:halfmm:20;
xtklbls = atlas_beginpos:-1: atlas_beginpos - (length(xtks)-1);


%sub__hsvsum(dursum, freqsum, length(duridx), length(freqidx));

% text(1, numrats+1.5, 'Rostral','FontSize', 18,'FontWEight','bold');
% text(vallen+1, numrats+1.5, 'Caudal','FontSize', 18,'FontWEight','bold');
set(gca,'YTick', 1.5:1:numrats+0.5, 'YTickLabel', ylbls,...
'XTick', xtks, 'XTickLabel', xtklbls,'Position',[0.2 0.2 0.75 0.8]);
 %   'XTick',1.5:1:vallen+0.5, 'XTickLabel', 1:vallen);
set(gcf,'Position', [200 200 200+((vallen+1)*30) 200+((numrats+1)*20)]);

xlabel('mm caudal to Bregma');
axes__format(gca);

set(gca,'YLim',[1 numrats+1]);
set(gca,'XLim',[1 vallen+2]);


function [] = sub__clr_a_row(yval, sum2mark, totalval)
colormap hot;
cmap = colormap;
idx=-1;
for k = 1:length(sum2mark)
    if sum2mark(k) == 0, c = cmap(1,:);
    else
        idx = floor((sum2mark(k)/totalval)*length(cmap));
        c = cmap(idx,:);
    end;
    idx
    patch([k k k+1 k+1], [yval-1 yval+1 yval+1 yval-1], c,'EdgeColor','none');
end;

cb=colorbar('EastOutside');
ytk = ((1/totalval):(1/totalval):1);
set(cb, 'YTick', ytk, 'YTickLabel', 1:totalval);


function [] = sub__clr_a_col(xval, sum2mark, totalval)
colormap cool;
cmap = colormap;
for k = 1:length(sum2mark)
    if sum2mark(k) == 0, c = cmap(1,:);
    else
        idx = floor((sum2mark(k)/totalval)*length(cmap));
        c = cmap(idx,:);
    end;
    idx
    patch([xval xval xval+1 xval+1], [k k+1 k+1 k], c,'EdgeColor','none');
end;


function [] =sub__hsvsum(dursum, freqsum, nd, nf)

bfrac = (240/360);
yfrac = (60/360);
num = ((yfrac*dursum)+(bfrac*freqsum));
den = (dursum+freqsum);

clr_hue =(num ./den);                % what the colour is
clr_sat = ((0*dursum)+(1*freqsum)); % how dark/bright the colour is
clr_sat = clr_sat ./ den;
clr_val = ((0*freqsum)+(1*dursum));
clr_val = clr_val ./ den;% --- saturation: how close to grey (0) the colour is
%clr_sat= ones(size(dursum))*0.8;

wt_sum = [clr_hue' clr_sat' clr_val'];

for k = 1:length(wt_sum)
    patch([k k k+1 k+1], [0 0+1 0+1 0], wt_sum(k,:),'EdgeColor','none');
end;

2;




