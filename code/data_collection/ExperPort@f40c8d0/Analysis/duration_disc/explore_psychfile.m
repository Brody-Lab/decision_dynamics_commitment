function [] = explore_psychfile(varargin)
% reads output file of average_psych_curves and explores it in
% miscellaneous ways


[l h] = calc_pair('p', sqrt(8*16), 1.4,'suppress_out', 1);
pairs = { ...
    % see comments above for fields assigned
    % which data to use? -----------------------------------------------
    'area_filter', 'ACx'; ...
    % binning data -----------------------------------------------------
    'binmin_dur', 200 ; ...
    'binmax_dur', 500 ; ...
    'binmin_pitch', l ; ...
    'binmax_pitch', h ; ...
    'num_bins', 8 ; ...
    % structs filled only when data is being permuted
    'pitch',0;...
    'binmin',0;...
    'binmax',0;...
    'bin_midpoint',0;...
    };
parse_knownargs(varargin,pairs);


group_name = 'pitch';

% endpoints and midpoints
if strcmpi(area_filter,'ACx'),
    [binmin_pitch binmax_pitch] = calc_pair('p', sqrt(8*16), 1.4,'suppress_out', 1);
elseif strcmpi(area_filter,'mPFC')
    [binmin_pitch binmax_pitch] = calc_pair('p', sqrt(8*16), 1,'suppress_out', 1);
else
    error('Please define a value for pitch for this brain region''s data');
end;

% turn on whichever functionality you want -----------------------

% % show # psych trials
if 0
    for f=1:length(fnames)
        t = eval(['rat_after.' fnames{f} ';']);
        fprintf(1,'>>%s\n', fnames{f});
        sub__countpsych(t.psych_on, t.numtrials);
    end;
end;

% plot residuals

% load datafile ------------------
if 1

    global Solo_datadir;
    indir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Set_Analysis' filesep];
    gnames = {'duration','pitch'};
    
    resid_list = cell(size(gnames));

    for g = 1:length(gnames)
        group_name = gnames{g};

        infile = [ group_name '_psych_' area_filter '_psychdata_LAST7FIRST3PSYCH.mat'];

        load([indir infile]);
        fnames = fieldnames(rat_before);

        if strcmpi(group_name,'pitch')
            bin_midpoint = sqrt(binmin_pitch*binmax_pitch);
            binmin = log2(l);
            binmax = log2(h);
            pitch = 1;
        else
            bin_midpoint = sqrt(binmax_dur*binmin_dur);
            binmin = log(binmin_dur);
            binmax = log(binmax_dur);
            pitch = 0;
        end;

        % extrapolate logistic fits beyond stimulus bins
        % to accommodate clipping later on
        [rat_before] = sub__extrapolatebig(rat_before,pitch, bin_midpoint);
        [rat_after] = sub__extrapolatebig(rat_after,pitch, bin_midpoint);

        [normed_before shiftparams] = sub__shiftgraphs(rat_before, ratcolour, 0);
        % sub__plotset(normed_before, ratcolour);
        normed_after = sub__applyshift(rat_after, shiftparams);

        [normed_before normed_after] =  sub__interpolate(normed_before, normed_after);

        resid_list{g} = NaN(size(fnames));
        for f = 1:length(fnames)
            xx_bef = eval(['normed_before.' fnames{f} '.newxx;']);
            yy_bef = eval(['normed_before.' fnames{f} '.newyy;']);

            xx_aft = eval(['normed_after.' fnames{f} '.newxx;']);
            yy_aft = eval(['normed_after.' fnames{f} '.newyy;']);

            resid_list{g}(f) = sub__getresidual(xx_bef, yy_bef, xx_aft, yy_aft);
        end;    
       figure;
        plot(1:length(fnames), resid_list{g}, '.r');
        set(gca,'XTick', 1:length(fnames), 'XTickLabel', fnames, 'XLim', [0 length(fnames)+1]);
    end;

       figure;       
        plot(ones(size(resid_list{1})), resid_list{1}, '.k');
        hold on;
        plot(ones(size(resid_list{1}))*2, resid_list{2}, '.k');
        set(gca,'XLim',[0 3], 'XTick',1:2, 'XTickLabel', gnames);
                title('Both group residuals');
        axes__format(gca);

end;


% plot psych curve binned data
if 0
    posx = 20; posy= 200; wd = 300; ht = 300;

    for f=1:length(fnames)
        t = eval(['rat_before.' fnames{f} ';']);
        t2 = eval(['rat_after.' fnames{f} ';']);

        fprintf(1,'>>>>>>>>\n%s\n', fnames{f});
        fprintf(1,'Set_Analysis dates:\n\tBefore:\n');  t.dates(t.psychdates)
        fprintf(1,'\tAfter\n'); t2.dates(t2.psychdates)

        str = sub__plotpsychdata(eval([logt 't.bins)']), ...
            t.xx, t.yy, t.replongs, t.tallies, ...
            t2.xx, t2.yy, t2.replongs, t2.tallies);
        title([fnames{f} ': ' str]);
        set(gcf,'Position', [posx posy wd ht]);


        %         try
        %             [bd ad] = surgery_effect(fnames{f}, 'psychgraph_only',1, 'lastfew_before',7, 'days_after', [1 3]);
        %             fprintf(1,'surgery_effect dates:\n\tBefore:\n');
        %             %   bd
        %             fprintf(1,'\tAfter\n');
        %             %ad
        %
        %             set(gcf,'Position', [posx posy+ht wd ht],'Tag', 'dummy');
        %         catch
        %             warning('surgery_effect crashed for %s\n', fnames{f});
        %         end;

        posx = posx + wd;
    end;
end;

% ---------------------------------------------------------
% Subroutines

function [res] = sub__getresidual(avg1_x, avg1_y, avg2_x, avg2_y)
if sum(abs(avg1_x - avg2_x)) ~= 0, error ('x-axes for before and after curves should be the same!'); end;
res = sum((avg2_y - avg1_y).^2)*mean(diff(avg1_x));

% -------------------------------------------------------------------------


% tallies # psych trials in each session of dataset
function [] = sub__countpsych(ps,numtrials)
cumtrials = cumsum(numtrials);
pcount = [];
for k  = 1:length(cumtrials),
    if k > 1, sidx = cumtrials(k-1)+1; else sidx=1; end;
    eidx = cumtrials(k); pcount = horzcat(pcount, sum(ps(sidx:eidx)));
end;
pcount

% -------------------------------------------------------------------------

function [str] = sub__plotpsychdata(bn, xx1, yy1, rp1, tl1, xx2, yy2, rp2, tl2)
figure;
clr = 'br';
for k = 1:2

    rp = eval(['rp' num2str(k) ';']); tl = eval(['tl' num2str(k) ';']);
    good = find(rp(:,1) ~= -1);
    rp =rp(good,:); tl = tl(good,:);
    str = ''; for d =1:length(good), str = [str ' ' num2str(good(d))]; end;

    p = mean(rp ./ tl,1); sem=std(rp./tl, 0,1)/sqrt(length(good));
    plot(eval(['xx' num2str(k)]), eval(['yy' num2str(k)]), '.r', 'Color', clr(k)); hold on;
    errorbar(bn, p, sem, sem, '.b', 'Color', clr(k), 'MarkerSize', 20);
end;

set(gca,'XLim', [bn(1) bn(end)],'YLim',[0 1]);

% -------------------------------------------------------------------------

function [hr] = sub__psychhits(n, pflag, hh,val)

cumtrials = cumsum(n);
hr = NaN(size(cumtrials));
for k=1:length(cumtrials)
    if k > 1, sidx = cumtrials(k-1)+1; else sidx = 1;end;
    eidx = cumtrials(k);

    ptrials = pflag(sidx:eidx); htemp = hh(sidx:eidx);
    hr(k) = sum(htemp(ptrials == val)) ./ length(find(ptrials== val));
end;

% -------------------------------------------------------------------------

function [data] = sub__extrapolatebig(data,ispitch, bin_midpoint)
fnames = fieldnames(data);
for f = 1:length(fnames)
    ratname = fnames{f};
    eval(['out = data.' ratname ';']);
    xx = out.xx;
    rangex = max(xx) - min(xx);
    [newxx newyy] = logistic_fitter('get_interpolated', out.bins, ispitch, ...
        out.overall_betahat, NaN, bin_midpoint,...
        min(xx) - (0.5*rangex) : 0.0002 : max(xx) + (0.5*rangex));
    out.xx = newxx;
    out.yy = newyy;
    eval(['data.' ratname ' = out;']);
end;

% -------------------------------------------------------------------------

% given raw before/after data, plots 'before' curves before and after
% scaling. Also returns scale/shift parameters for each rat
function [normeddata shiftparams] = sub__shiftgraphs(data,plotclr, doplot)

shiftparams=0;
normeddata = 0;

if doplot > 0
    f=figure; set(f,'Tag','scalefig');
    subplot(1,2,1);
    set(gca,'Tag','before_scale'); title('Before scaling');
    subplot(1,2,2);
    set(gca,'Tag','after_scale'); title('After scaling');
end;

fnames = fieldnames(data);
for f = 1:length(fnames)
    ratname = fnames{f};
    eval(['out = data.' ratname ';']);

    if doplot > 0
        eval(['currcolour = plotclr.' ratname ';']);
        set(0,'CurrentFigure',findobj('Tag','scalefig'));
        set(gcf,'CurrentAxes', findobj('Tag','before_scale'));
        l=plot(out.xx, out.yy,'-r');
        set(l,'Color',currcolour,'LineWidth',2); hold on;
        set(gca,'Tag','before_scale');
    end;

    % now plot scaled
    mp = sub__stim_at(out.xx,out.yy,0.5);
    mp = out.xx(mp);
    x2 = out.xx - mp; % out.overall_xmid;     % shifted
    tau =sub__getslope(x2, out.yy);
    norm_x = x2 * tau;

    if doplot > 0
        fprintf(1,'%s:\t\tOld slope = %2.2f', ratname,tau);
    end;
    if doplot > 0
        set(gcf,'CurrentAxes', findobj('Tag','after_scale'));
        l=plot(norm_x, out.yy,'-r');
        set(l,'Color',currcolour,'LineWidth',2);   hold on;
        set(gca,'Tag','after_scale');
        fprintf(1,'\t\tNew slope = %2.4f\n', sub__getslope(norm_x, out.yy));
    end;

    tmp = [out.overall_xmid tau];
    eval(['shiftparams.' ratname ' = tmp;']);
    if doplot > 0
        fprintf(1,'\t\t Shift = %2.1f, Scale = %2.1f\n', out.overall_xmid, tau);
    end;

    out2 = out;
    out2.normed_x = norm_x;

    eval(['normeddata.' ratname ' = out2;']);

end;

if doplot > 0
    set(gcf,'CurrentAxes', findobj('Tag','before_scale'));
    title('Before scaling');
    set(gcf,'CurrentAxes', findobj('Tag','after_scale'));
    title('After scaling');
end;

% -------------------------------------------------------------------------

% given shiftparams (translation, scale) from before curves, apply to
% 'after' curves and return transformed graphs
function [shiftedafter] = sub__applyshift(data, shiftparams)
shiftedafter=0;
fnames = fieldnames(data);
for f = 1:length(fnames)
    ratname = fnames{f};
    eval(['out = data.' ratname ';']);
    eval(['shift = shiftparams.' ratname ';']);

    xx = out.xx; yy = out.yy;
    shifted_xx = (xx - shift(1)) * shift(2);

    out2 = out;
    out2.normed_x = shifted_xx;

    eval(['shiftedafter.' ratname ' = out2;']);
end;

% -------------------------------------------------------------------------

% given a collection of xx and yy pairs with disparate x-axes values, find
% an x-axis to which all old xx-yy values can be commonly interpolated
% preparation for averaging
function [data1 data2] =  sub__interpolate(data1, data2)

bufferx = [];
lastx = [];

olddata1=data1;
olddata2=data2;

fnames = fieldnames(data1);

largestofmin = -1000;
smallestofmax = +1000;
minnie = +1000; maxie = -1000;
for f = 1:length(fnames)
    ratname = fnames{f};
    eval(['out = data1.' ratname ';']);
    lastx = out.normed_x; % to get a sense of how many x-values are in any given xx-yy pair
    largestofmin = max(largestofmin, min(lastx));
    smallestofmax = min(smallestofmax, max(lastx));
    minnie = min(minnie, min(lastx));
    maxie = max(maxie, max(lastx));
end;

fnames = fieldnames(data2);
for f = 1:length(fnames)
    ratname = fnames{f};
    eval(['out = data2.' ratname ';']);
    lastx = out.normed_x; % to get a sense of how many x-values are in any given xx-yy pair
    largestofmin = max(largestofmin, min(lastx));
    smallestofmax = min(smallestofmax, max(lastx));
    minnie = min(minnie, min(lastx));
    maxie = max(maxie, max(lastx));
end;

newmin =largestofmin;
newmax = smallestofmax;
stepsize = (newmax-newmin) / length(lastx);
newxx = newmin:stepsize:newmax;
idx=find(abs(newxx - 0) == min(abs(newxx-0)));
if newxx(idx) < 0
    newxx2 = [ newxx(1:idx) 0 newxx(idx+1:end)];
else
    newxx2 = [ newxx(1:idx-1) 0 newxx(idx:end)];
end;
newxx = newxx2;


% now make new interpolated yy values for each xx-yy pair, using newxx
%first for 'before' curves
fnames = fieldnames(data1);
for f = 1:length(fnames)
    ratname = fnames{f};
    eval(['out = data1.' ratname ';']);
    out.newxx = newxx;
    out.newyy = interp1(out.normed_x ,out.yy, out.newxx,'spline','extrap');
    eval(['data1.' ratname ' = out;']);
end;
% then for 'after' curves
fnames = fieldnames(data2);
for f = 1:length(fnames)
    ratname = fnames{f};
    eval(['out = data2.' ratname ';']);
    out.newxx = newxx;
    out.newyy = interp1(out.normed_x ,out.yy, out.newxx,'spline');
    eval(['data2.' ratname ' = out;']);
end;

% -------------------------------------------------------------------------

function [stim] = sub__stim_at(x,y, pt)
if min(y) > pt || max(y) < pt % you're asking for a point that isn't on the curve
    stim=-1;
    return;
end;

stim = find(abs(y - pt) == min(abs(y-pt)));

% -------------------------------------------------------------------------

function [s] = sub__getslopezerotoone(x,y)
s=sub__getslope(x,y,'minval',0.16,'maxval',0.84);

% -------------------------------------------------------------------------

function [s] = sub__getslope(x,y,varargin)
pairs = { ...
    'minval',0.25;...
    'maxval',0.75 ;...
    };
parse_knownargs(varargin,pairs);
stdminus = sub__stim_at(x,y,minval);
stdplus = sub__stim_at(x,y, maxval);
%fprintf(1,'minus = %2.1f, plus %2.1f\n', stdminus, stdplus);

try
    s = (maxval-minval) / (x(stdplus) - x(stdminus));
catch
    if minval == 0.25 && maxval == 0.75
        try
            s=sub__getslope(x,y,'minval',0.4, 'maxval',0.7);
        catch
            error('Original slope way too bad to compute');
        end;
    else
        error('A normalized slope is having trouble finding 16 and 84%');
    end;
end;
