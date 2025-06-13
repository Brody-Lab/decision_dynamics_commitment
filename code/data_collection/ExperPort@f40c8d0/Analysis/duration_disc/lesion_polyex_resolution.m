function [] = lesion_polyex_resolution(ratname, roi, currSlice, currHem, mkover,varargin)

pairs = { ...
    'tissue_name', 'ACx'; ...
    % Parameters for algorithms
    'pt_side', 1 ; ...
    % output flags
    'graphic', 0 ; ...
    'verbose', 0 ; ...
    'hemstr', 0  ; ...
    };
parse_knownargs(varargin,pairs);

if mkover > 0
    
    hemstr.L = 'Left';
    hemstr.R = 'Right'; 
    
    if ~isstr(currSlice)
        currSlice = num2str(currSlice);
    end;
    global Solo_datadir;
    histodir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Histo' filesep tissue_name filesep];

    % get rats' coordinates
    indir = [histodir ratname filesep];
    infile = [indir 'polygon_coords.mat'];
    load(infile);

    rtcoords = eval([ratname '_lesioncoords;']);

    % get brain area coordinates
    infile = [histodir 'polymark' filesep];
    infile = [infile 'polygon_coords_' roi '.mat'];
    try
        load(infile)
    catch
        error('Error *** !\nCheck ROI: **%s**\nCheck fname: **%s**\n', roi, infile);
    end;
    brcoords = eval([roi '_lesioncoords;']);


    cvg = []; % % coverage computed
    tm = []; % time it takes to nongraphically run code

    numloops = 5;
    avgs = [];
    sds = [];
    tavgs = [];
    tsds = [];
    krange = [0.5:0.5:2 3:10];
    ctr = 1;

    for k = krange % point sides
        for p = 1:numloops
               fstr = [currHem currSlice];

        % either there is no lesion here or the brain area simply doesn't
        % exist at this slice location
        if (~isfield(rtcoords, fstr) || ~isfield(brcoords, fstr))
            c = NaN; t = NaN;
        else
            rt = eval(['rtcoords.' fstr]);
            br = eval(['brcoords.' fstr]);
            [c t] = lesion_slice_gruntwork(rt, br, k, graphic, verbose, currSlice, eval(['hemstr.' currHem]));
        end;
        
            cvg(ctr,p) = c*100;
            tm(ctr,p) = t;
        end;

        avgs = horzcat(avgs, mean(cvg(ctr,:)));
        sds = horzcat(sds, std(cvg(ctr,:)));

        tavgs = horzcat(tavgs, mean(tm(ctr,:)));
        tsds = horzcat(tsds, std(tm(ctr,:)));

        ctr= ctr+1;
    end;
    save('polyexcover.mat', 'krange','numloops','cvg','tm','avgs','sds','tavgs','tsds');
else
    load('polyexcover.mat');
end;

% final plot --------

% view of variation in % coverage
figure;
errorbar(krange, avgs, sds, '.r');
hold on;
ctr = 1;
for k = krange
    plot(ones(numloops,1)*k, cvg(ctr,:),'.b','Color', [1 1 1]*0.5); hold on;
    ctr=ctr+1;
end;

title('How grid resolution affects coverage computation');
xlabel('grid side (in points)');
ylabel('% coverage');
axes__format(gca);
set(gcf,'Position',[141         527        1091         308]);
set(gca,'XTick', krange, 'XLim',[0, max(krange)+0.5]);
2;

% view of error
figure;
for ymk = [0.25 0.5 1]
    line([0 length(krange)+1], [ymk ymk], 'LineStyle',':','Color', [0.5 0.5 1],'LineWidth',2);hold on;
end;
plot(krange, sds / sqrt(numloops), '.k');


t=title('How grid resolution affects SEM'); set(t,'FontSize',14, 'FontWeight','bold');
t=xlabel('grid side (in points)'); set(t,'FontSize',14, 'FontWeight','bold');
t=ylabel('SEM of 5 runs (% coverage)'); set(t,'FontSize',14, 'FontWeight','bold');
set(gcf,'Position',[141         227        1091*0.7         308*0.7]);
set(gca,'XTick', krange,'FontSize', 14,'FontWEight','bold', 'XLim',[0, max(krange)+0.5]);
ylim = get(gca,'YLim'); set(gca,'YTick',0:0.25:ylim(2));
2;

% plot time
figure;
for ymk = [0.05 0.1:0.1:0.5]
    line([0 length(krange)+1], [ymk ymk], 'LineStyle',':','Color', [1 1 1]*0.8,'LineWidth',2); hold on;
end;
errorbar(krange, tavgs, tsds, '.r','Color',[1 0.5 0]);
ctr = 1;
% for k = krange
%     ctr
% plot(ones(numloops,1)*k, tm(ctr,:),'.b','Color', [1 1 1]*0.5);
% ctr=ctr+1;
% end;

t=title('How grid resolution affects time'); set(t,'FontSize',14, 'FontWeight','bold');
t=xlabel('grid side (in points)'); set(t,'FontSize',14, 'FontWeight','bold');
t=ylabel('Time for the run (seconds)'); set(t,'FontSize',14, 'FontWeight','bold');
set(gca,'XTick', krange,'FontSize', 14,'FontWEight','bold', 'XLim',[0, max(krange)+0.5]);
set(gcf,'Position',[360   637   761   221]);
