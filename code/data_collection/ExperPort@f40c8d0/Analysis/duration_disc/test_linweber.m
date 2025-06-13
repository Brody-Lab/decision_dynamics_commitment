function [] = comparefits()
% compares fit of before/after psych curve to linear or sigmoid fit.
% returns q-values of each fit.
% see Numerical Recipes 1992 edition for definition of q-value (section 15.2 and 6.2)
% and merit chi2 metric (section 15.1)

webers=[];
ratlist = {'S044'};

ttype = 'aft';

bef=[];
aft=[];

alist={'betahat', 'overall_betahat',...
    'xx','yy','overall_weber',...
    'bins','replongs','tallies',...
    'overall_xc','overall_xmid','overall_xf','sigmoidfit','linearfit'};

for r=1:length(ratlist)
    ratname=ratlist{r};
    ratrow=rat_task_table(ratname); task=ratrow{1,2};

    loadpsychinfo(ratname, 'infile', 'psych_before', ...
        'justgetdata',1,...
        'preflipped', 0, ...
        'psychthresh',1,...
        'dstart',1, 'dend',3 , ...
        'eliminate_Mondays', 0,...
        'daily_bin_variability', 0, ...
        'graphic', 0,...
        'postpsych', 1, ...
        'ACxround1', 0);

    if strcmpi(task(1:3),'dur')
        bins=log(bins);        
    else
        bins=log2(bins);
    end;
    
    for a=1:length(alist)
        eval(['bef.' alist{a} '=' alist{a} ';'])
    end;
    bef.p = sum(replongs) ./ sum(tallies);
    tmp = replongs ./tallies;
    bef.sdp=std(tmp);
    

    loadpsychinfo(ratname, 'infile', 'psych_after', ...
        'justgetdata',1,...
        'preflipped', 0, ...
        'psychthresh',1,...
        'dstart',1, 'dend',3 , ...
        'eliminate_Mondays', 0,...
        'daily_bin_variability', 0, ...
        'graphic', 0,...
        'postpsych', 1, ...
        'ACxround1', 0);
    if strcmpi(task(1:3),'dur')
        bins=log(bins);        
    else
        bins=log2(bins);
    end;
    for a=1:length(alist)
        eval(['aft.' alist{a} '=' alist{a} ';'])
    end;     
      
    aft.p = sum(replongs) ./ sum(tallies);
    tmp = replongs ./tallies;
    aft.sdp=std(tmp);

end;

%     sub__comparefits(bef.bins, bef.p, bef.sdp, bef.sigmoidfit,bef.linearfit,...
%         bef.xx,bef.yy);
    sub__comparefits(eval([ttype '.bins'], [ttype '.p'], ...
        [ttype '.sdp'], [ttype '.sigmoidfit'] ,[ttype '.linearfit'],...
        [ttype '.xx'] ,[ttype '.yy']);


function [] = sub__comparefits(bins, p, sdp, sigmoidfit, linearfit,xx,yy)
close all;
	ylin = linear(linearfit.betahat,bins);
    qlin = logistic_fitter('goodness_of_fit', p, ylin, sdp, 'linear');
    
    ysig = sigmoid4param(sigmoidfit.betahat, bins);
    qsig = logistic_fitter('goodness_of_fit', p, ysig, sdp, 'sigmoid');
    
    
    % plot expected-lin/sigmoid versus observed.
    figure;
    subplot(1,2,1);
    plot(xx,yy,'-k','Color',[1 1 1]*0.5);
    hold on;
    plot(bins, p,'.k','MarkerSize',20); 
    plot(bins, ylin,'.r','MarkerSize',20); 
    set(gca,'YLim',[0 1]);
    text(bins(1), 0.9, sprintf('Q=%2.3f', qlin));
    title('Linear');
    
    subplot(1,2,2);
    plot(xx,yy,'-k','Color',[1 1 1]*0.5);
    hold on;
    plot(bins, p,'.k','MarkerSize',20); 
    plot(bins, ysig,'.b', 'MarkerSize',20);
    set(gca,'YLim',[0 1]);
        text(bins(1), 0.9, sprintf('Q=%2.3f', qsig));
    title('Sigmoidal');
    
    set(gcf,'Position',[124   501   888   363]);    
    
    fig=figure; 
    subplot(1,2,1);
    sub__pp_plot(ylin-p,fig);
    title('linear');
   
    subplot(1,2,2);
    sub__pp_plot(ysig-p,fig);
    title('sigmoid');              

function [] = sub__pp_plot(x,fig)
set(0,'CurrentFigure',fig);

x=sort(x);
plot(x,x,'-k');
hold on;
mu=mean(x); sigma=std(x);

probs=(1:length(x))/length(x);
normx = norminv(probs, mu, sigma);
plot(x,normx,'.b','MarkerSize',20);

if cols(x)>1, x=x';end;
h=kstest(x, [x probs']);

if h>0, txt='NOT Normal'; else txt='Normal'; end;
text(mean(x(1:2)), max(x)*0.9, txt,'FontWeight','bold');    

set(gca,'XLim',[min(x)-(0.1*min(x)) max(x)+(0.1*max(x))]);
set(gca,'YLim', get(gca,'XLim'));