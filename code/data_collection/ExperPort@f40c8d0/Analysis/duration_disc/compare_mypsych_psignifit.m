function [] = compare_mypsych_psignifit(ratname, indate)
ratrow=rat_task_table(ratname);
task = ratrow{1,2};

if strcmpi(task(1:3),'dur')
    bintrans = 'log(';
    pitches = 0;
    [l h]= calc_pair('d',sqrt(200*500),0.95);
    binmin =l; % 5.1
    binmax =h;%18.4; %17.6
    %  binmin=196.6401;
    %  binmax=508.4541;
    %  binmin = 300;
    %  binmax = 800;
    mybase = exp(1);
    mp = sqrt(200*500);

    taskylbl = 'Long';
    unittxt = 'ms';
    unitfmt = '%i';
    roundmult = 1;
else
    pitches = 1;
    mm = indate(3:4);
    yy = indate(1:2);
    if (str2double(yy) < 8) && (str2double(mm) < 29)
        [l h] = calc_pair('p',11.31,1.4);
    else
        [l h]= calc_pair('p',11.31,1);
    end;
    binmin =l; % 5.1
    binmax =h;%18.4; %17.6
    mybase = 2;
    bintrans = 'log2(';
    mp = sqrt(8*16);

    taskylbl = 'High';
    unittxt='kHz';
    unitfmt = '%2.1f';
    roundmult  = 10;
end;

% first show my fit ---------------
[weber bfit bias xx yy xmid xcomm xfin replong tally bins] = psychometric_curve(ratname,indate,'nodist',1);
set(gcf,'Position',[34   404   485   435]);

xtk = [bins(1) mp bins(end)];
logxtk = eval([bintrans 'xtk);']);

% now show psignifit-----------------
dat = [];
mybins = eval([bintrans 'bins);']);

dat(:,1) = mybins;
dat(:,2) = replong ./ tally;
dat(:,3) = tally;
sub__psignifitplot(dat)

miniaxis = [bins(1), sqrt(binmin*binmax) bins(end)];
% now pretty up the axis
if pitches > 0
    mybins = log2(bins);
    hist__lblfmt = '%1.1f';
    hist__xlbl = 'Bins of frequencies (kHz)';
    psych__xtick = log2(miniaxis);
    psych__xlbl = 'Tone frequency (kHz)';
   % if flipped > 0
   %         psych__ylbl = 'frequency of reporting "Low" (%)';
   % else
        psych__ylbl = 'frequency of reporting "High" (%)';
  %  end;
    txtform =  '[%1.1f,%1.1f] kHz';
    unittxt = 'kHz';
    roundmult = 10;
    log_mp = log2(sqrt(binmin*binmax));
else
    mybins = log(bins);
    hist__lblfmt='%i';
    hist__xlbl = 'Bins of durations (ms)';
    psych__xtick = log(miniaxis);
    psych__xlbl = 'Tone duration (ms)';
%     if flipped > 0
%         psych__ylbl = 'frequency of reporting "Long" (%)';
%     else
         psych__ylbl = 'frequency of reporting "Long" (%)';
%     end;
    txtform =  '[%i,%i] ms';
    log_mp = log(sqrt(binmin*binmax));
    roundmult = 1;
end;

xlim=[mybins(1) mybins(end)];
mymin = round(binmin*roundmult)/roundmult;
mymax=round(binmax*roundmult)/roundmult;
hist__xtklbl = round(bins*roundmult)/roundmult;
psych__xtklbl = round(miniaxis * roundmult)/roundmult;

title(sprintf('%s: %s -- psignifit curve', ratname, indate));
    set(gca,'XTick',psych__xtick,'XLim', xlim, 'XTickLabel', psych__xtklbl, ...
            'YTick',0:0.25:1, 'YTickLabel', 0:25:100, 'YLim',[0 1], ...
            'FontSize',18,'FontWeight','bold');
        xlabel(psych__xlbl);
        ylabel(psych__ylbl);

axes__format(gca);
set(gcf,'Menubar','none','Toolbar','none','Position', [541   404   485   435]);



% adapted from psych_tool_demo.m in psignifit package.
% Read a sample data set from a text file in this directory, and plot the data.

function [] = sub__psignifitplot(dat)
%dat = readdata('example_data2.txt');
colordef white, figure

try
plotpd(dat)
catch
    addpath('Analysis/duration_disc/psignifit/');
    plotpd(dat)
end;
hold on

% Make a batch string out of the preferences: 999 bootstrap replications
% assuming 2AFC design. All other options standard.
% Type "help psych_options" for a list of options that can be specified for
% psignifit.mex. Type "help batch_strings" for an explanation of the format.
shape = 'logistic';
prefs = batch(  'shape', shape, ...
    'n_intervals', 1, ...
    'runs', 1e4, ...
    'cuts',[0.25 0.5 0.75], ...
    'lambda_limits',[0 0.3]...
    )
outputPrefs = batch('write_pa', 'pa', 'write_th', 'th');

% Fit the data, according to the preferences we specified (999 bootstraps).
% The specified output preferences will mean that two structures, called
% 'pa' (for parameters) and 'th' (for thresholds) are created.
psignifit(dat, [prefs outputPrefs]);

% Plot the fit to the original data
plotpf(shape, pa.est);

% Draw confidence intervals using the 'lims' field of th, which
% contains bias-corrected accelerated confidence limits.
drawHeights = psi(shape, pa.est, th.est);
line(th.lims, ones(size(th.lims,1), 1) * drawHeights, 'color', [0 0 1])
hold off

% wait for key press
figure(gcf);