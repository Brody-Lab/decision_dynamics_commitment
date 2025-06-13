function [] = psych_curve_overlay(ratname, dateset,varargin)
% superimposes logistic fits for psychometric data from different dates

fnames = {'weber', 'bfit' , 'bias', 'xx', 'yy', 'xmid', 'xcomm', 'xfin',...
    'replong', 'tally', 'bins'};
varnames = {'wb', 'bf' ,'bs', 'xx', 'yy', 'xmid', 'xcomm', 'xfin', 'repl', 'tal',...
    'bns'};


psych_params = {};

for d = 1:length(dateset)
    [wb bf bs xx yy xmid xcomm xfin repl tal bns] = psychometric_curve(ratname, 0,...
        'usedate', dateset{d},'noplot',1);
    
    eval(['psych_params.date' num2str(d) ' = 0;']);
    for x = 1:length(fnames)
            eval(['psych_params.date' num2str(d) '.' fnames{x} ' = ' varnames{x} ';']);
    end;       
end;

ratrow = rat_task_table(ratname, 'get_rat_row');
task  = ratrow{1,2};

% Begin plotting ----------------
figure;
for d = 1:length(dateset)
    clr = rand(1,3);
    xx = eval(['psych_params.date' num2str(d) '.xx;']);
    yy = eval(['psych_params.date' num2str(d) '.yy;']);
    bins = eval(['psych_params.date' num2str(d) '.bins;']);
    plot(xx,yy,'.r', 'Color',clr);
    hold on;
end;
legend(dateset,'Location','SouthEast');

if strcmpi(task(1:3),'dur')
    xlbl = 'Tone duration (ms)';
    ylbl = '% reported "Long"';
    mybase = exp(1);
    xmid = log(sqrt(200*500));
    logbins = log(bins);
    xtk= [logbins(1) xmid logbins(end)];
    xtklbl = round(exp(xtk));
    
else
    xlbl = 'Tone frequency (kHz)';
    ylbl = '% reported "High"';
    mybase = 2;
    xmid = log2(sqrt(8*16));
    logbins = log2(bins);
    xtk= [logbins(1) xmid logbins(end)];
    xtklbl = round((2.^(xtk))*10)/10;
end;

set(gca,'XTick',xtk, 'XTickLabel',xtklbl, ...
    'YLim',[0 1],'XLim', [logbins(1) logbins(end)], ...
    'FontSize', 18,'FontWeight','bold');
t=xlabel(xlbl); set(t,'FontSize', 20, 'FontWeight','bold');
t=ylabel(ylbl); set(t,'FontSize', 20, 'FontWeight','bold');


sign_fname(gcf,mfilename);