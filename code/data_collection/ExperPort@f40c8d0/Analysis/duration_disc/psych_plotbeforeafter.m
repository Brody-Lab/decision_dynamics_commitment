function [] = psych_plotbeforeafter(in,clr,varargin)
% in should have output of psych_oversession.

pairs = { ...
    'fig', 0 ; ...
    'ylbl_pos', 0.15 ; ...
    'usefig', 0 ; ...
    'patch_bounds', 1 ; ...
    'daily_bin_variability',0 ; ...
    };
parse_knownargs(varargin,pairs);


if usefig == 0
    fig = figure;
end;


fnames=fieldnames(in);
for f=1:length(fnames)
    eval([fnames{f} '= in.' fnames{f} ';']);
end;
mp=sqrt(binmin*binmax);

% beforeColor = 'b';
% afterColor = 'r';
% clr = 'b';


mega_tally = sum(sum(tallies)); % total # trials in psych curve
miniaxis = [bins(1), sqrt(binmin*binmax) bins(end)];

if pitch > 0
    mybins = log2(bins);
    hist__lblfmt = '%1.1f';
    hist__xlbl = 'Bins of frequencies (kHz)';
    psych__xtick = log2(miniaxis);
    psych__xlbl = 'Tone frequency (kHz)';
    %     if flipped > 0
    %         psych__ylbl = 'frequency of reporting "Low" (%)';
    %     else
    psych__ylbl = 'frequency of reporting "High" (%)';
    %     end;
    txtform =  '[%1.1f,%1.1f] kHz';
    unittxt = 'kHz';
    roundmult = 10;
    log_mp = log2(sqrt(binmin*binmax));
    mybase = 2;
    unittxt='kHz';
    unitfmt = '%2.1f';
else
    mybins = log(bins);
    hist__lblfmt='%i';
    hist__xlbl = 'Bins of durations (ms)';
    psych__xtick = log(miniaxis);
    psych__xlbl = 'Tone duration (ms)';
    %     if flipped > 0
    %         psych__ylbl = 'frequency of reporting "Short" (%)';
    %     else
    psych__ylbl = 'frequency of reporting "Long" (%)';
    %     end;
    txtform =  '[%i,%i] ms';
    log_mp = log(sqrt(binmin*binmax));
    roundmult = 1;
    mybase = exp(1);
    unittxt = 'ms';
    unitfmt = '%i';
end;

xlim=[mybins(1) mybins(end)];
mymin = round(binmin*roundmult)/roundmult;
mymax=round(binmax*roundmult)/roundmult;
hist__xtklbl = round(bins*roundmult)/roundmult;
psych__xtklbl = round(miniaxis * roundmult)/roundmult;
fsize=6;

% print to stdout
bias_val = (mybase^(overall_xmid))-(mybase^(mp));
% fprintf(usefid, '%s\n', mfilename);
% fprintf(usefid, '\tPooled Midpoint: %1.1f\n',mybase^(overall_xmid));
% fprintf(usefid, '\tbias_val: %1.1f\n', bias_val);
% fprintf(usefid, '\tPooled weber is: %1.2f\n', overall_weber);


curr_x = 0.05; curr_width = 0.4;

if 0
    % Show histogram of cue parameter
    axes('Position', [curr_x 0.2 curr_width 0.6]);
    bar(mybins, tally, 'stacked');
    lbl = cell(0,0);
    for k = 1:length(bins)
        h = text(mybins(k), tally(k)+3, int2str(tally(k)));
        set(h, 'FontSize',fsize,'FontWeight','bold');
        lbl{k} = sprintf(hist__lblfmt, bins(k));
    end;

    x=xlabel(hist__xlbl);set(x,'FontSize',16,'FontWeight','bold');
    set(gca,'XTick', mybins, 'XTickLabel', hist__xtklbl,...
        'XLim', [mybins(1)*0.99 1.01*mybins(end)], 'YLim', [0 1.1*max(tally)],...
        'FontSize', 16, 'FontWeight','bold');
    y=ylabel('Sample size (n)');set(y,'FontSize',16,'FontWeight','bold');
    t= title(sprintf('%s: %s (%s-%s): \nTone sampling distribution (n=%i)', make_title(ratname), make_title(task), dates{psychdates(1)}, dates{psychdates(end)}, mega_tally));
    set(t, 'FontSize', 16, 'FontWeight','bold');
    curr_x = curr_x + 0.5;
    % axes__format(gca);
end;

% plotting psych curve
% if justgetdata,
    if ~(strcmpi(get(gcf,'Tag'), [ratname '_psych_curve'])) && usefig == 0,
        axes('Position', [0.1 0.15 0.8 0.75]);
    end;
% else
%     axes('Position', [curr_x 0.15 curr_width 0.75]);
% end;

hold on;
perday_replong=replongs;
perday_tally=tallies;
replongs = nansum(perday_replong);
tallies = nansum(perday_tally);

if strcmpi(ratname,'S047')
    2;
end;

if daily_bin_variability > 0
    rowsum = sum(perday_replong'); ne = find(~isnan(rowsum));
    ne_rep = perday_replong(ne,:); ne_tally = perday_tally(ne,:);
    p = ne_rep ./ ne_tally;
    numSess = rows(p);
    if rows(p) == 1
        mu = p;
        errmin = NaN(size(p)); errmax = NaN(size(p));
        dailytxt = '1 session';
    else
        mu = mean(p);      
            stdev = std(p) / sqrt(rows(p));
            errmin = stdev; errmax = stdev;
            dailytxt = 'Mean (SEM)';
    end;
    errmin; errmax;
    p = mu;
    
else
    allreps = sum(replongs,1);
    alltall = sum(tallies,1);
    p = allreps ./ alltall;
    numSess = rows(replongs);
    sigma = (p .* (1-p)) ./ alltall ;
    sigma = sqrt(sigma);

    errmin = sigma; errmax = sigma;

    dailytxt = 'All-pooled(SD)';
end;


% >>>>>>>>>>>>> PLOTTING CODE
if patch_bounds > 0
    patch([min(xx) min(xx) max(xx) max(xx)], [0 0.15 0.15 0], [1 1 0.8],'EdgeColor','none');
    hold on;
    patch([min(xx) min(xx) max(xx) max(xx)], [1 0.85 0.85 1], [1 1 0.8],'EdgeColor','none');
end;

l=plot(xx, yy, '-r','LineWidth',2,'Color',clr);

out.plot_interpol = l;
% plot(mybins, replongs ./ tallies, 'or','Color', clr,'MarkerSize', 10,'LineWidth',2,'Marker', plot_marker);
l=errorbar(mybins, p, errmin, errmax, '.r','Color',clr,'MarkerSize',20);
out.plot_errorbar = l;

line([log_mp log_mp],[0 1], 'LineStyle',':','Color','k','LineWidth',2); % intended midpoint


xm = overall_xmid;
xc = overall_xc;
xf  = overall_xf;
myxc = round((mybase^xc)*roundmult)/roundmult;
myxm = round((mybase^xm)*roundmult)/roundmult;
myxf = round((mybase^xf)*roundmult)/roundmult;

fct=0.04;


set(gca,'XTick',psych__xtick,'XLim', xlim, 'XTickLabel', psych__xtklbl, ...
    'YTick',0:0.25:1, 'YTickLabel', 0:25:100, 'YLim',[0 1], ...
    'FontSize',14,'FontWeight','bold');

if flipped > 0, flptxt = 'Flipped'; else flptxt = 'Unflipped'; end;

text(psych__xtick(end)*0.95, 0.05, flptxt,'FontWeight','bold','Color','k','FontSize', 12);
if numSess>1
text(psych__xtick(end)*0.95, ylbl_pos, sprintf('numSess=%i', numSess), 'Color',clr','FontWeight','bold','FontSize', 14);
end;
text(psych__xtick(end)*0.95, 0.1, dailytxt, 'Color','k','FontWeight','bold','FontSize', 12);

if clr=='b',ypos=0.23; else ypos=0.18; end;
text(psych__xtick(end)*0.95, ypos, sprintf('Wbr=%1.2f', overall_weber), 'Color', clr,'FontSize',14);

    

xlbl=xlabel(psych__xlbl);
ylbl=ylabel(psych__ylbl);
t = title(sprintf(['%s: \n[Min,Max] =' txtform ' (n=%i)'], make_title(ratname), mymin, mymax,sum(tallies)));
set(t, 'FontSize', 14, 'FontWeight', 'bold');

t=title(sprintf('%s: Pooled Psychometric',ratname));
% axes__format(gca);

fsize=10;
% if justgetdata
%     set(xlbl,'FontSize',fsize,'FontWeight','bold');
%     set(ylbl,'FontSize',fsize,'FontWeight','bold');
%     set(t, 'FontSize', fsize, 'FontWeight', 'bold');
%     set(gca,'FontSize', fsize,'FontWeight','bold');
% 
     set(fig, 'Position', [225 279 800 419]);
     set(gcf,'Tag',[ratname '_psych_curve']);
% else
%     set(gcf,'Menubar','none','Toolbar','none','Position',[440   437   794   297]);
% end;
