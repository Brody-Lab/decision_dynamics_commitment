function [xcomm xfin xmid weber] = get_weber(x,y, varargin)

% Calculates the weber ratio (stdev normalized by mean) for the given
% signal (x)-response (y) pair
% Also computes signals for which response :
% a) deviates 1 stdev from the mean: +1SD (xcomm) and -1SD(xfin)
% b) is at the mean (xmean)


pairs = { ...
    'pitches', 0 ; ...
    'graphic', 0 ; ... % when set, plots the original graph and the stretched graph. Also 
                       % gives xcomm, xmid and xfin values as output.                       
    'use_Church_calc', 1;... (x75-x25)/x50, instead of (x84-x16)/x50, which assumes Gaussian percept
    'stretch_before_computing' , 0 ; ... % if true, curve will be stretched to fit between 0 and 1 before calculating weber
   
    };
parse_knownargs(varargin, pairs);

% first "stretch" the curve between 0 and 1.
a = min(y); b = max(y);
if stretch_before_computing > 0
stretched = (y- a) ./ (b-a);
else
    stretched = y;
end;

if graphic > 0
    figure;
    l=plot(x,y); set(l,'LineWidth',2);
    hold on;
    plot(x,stretched,'-r');
    rangex = max(x) - min(x);
    figaxis =  min(x):0.1*rangex:max(x);
    if pitches > 0
        xlbls = (2.^ figaxis);
    else
        xlbls = exp(figaxis);
    end;
    
    xlbls = round(xlbls * 10)/ 10;
    set(gca,'XLim',[min(x) max(x)], 'XTick',figaxis,'XTickLabel', xlbls);
end;

% Finally, plot threshold limits and calculate Weber ratio
plus_sd = normcdf(1); minus_sd = normcdf(-1);
% comm = find(abs(y - minus_sd) == min(abs(y-minus_sd)));
% fin = find(abs(y - plus_sd) == min(abs(y-plus_sd)));
% mid = find(abs(y - 0.5) == min(abs(y-0.5)));

% updating Weber calculation to match Russ Church's 1984 calc
% weber = (x75-x25)/x50;
if use_Church_calc > 0
    upper_point = 0.75;
    lower_point = 0.25;
    mid_point = 0.5;
else
    upper_point=plus_sd;
    lower_point=minus_sd;
    mid_point=0.5;
end;
    
comm = sub__stim_at(x,stretched,lower_point);
fin = sub__stim_at(x,stretched,upper_point);
mid=sub__stim_at(x,stretched,mid_point);

if length(fin) > 1, fin=fin(1);end;
if length(mid) > 1, mid=mid(1);end;
if length(comm)>1, comm=comm(1); end;

if comm == -1 || mid == -1 || fin == -1
    xcomm = -1;
    xfin = -1;
    xmid = -1;
    weber = -1;
    return;
end;

if use_Church_calc>0
xfin = x(fin);
xcomm = x(comm);
xmid = x(mid);

if pitches >0, mybase=2; else mybase= exp(1);end;
weber = ((mybase^xfin)-(mybase^xcomm))/(mybase^xmid);

else
    xfin = x(fin) - x(mid); xcomm = x(mid)-x(comm);
xmid = x(mid);  
weber = ((xcomm+xfin)/2)/xmid;

xfin = x(fin); 
xcomm = x(comm);

end;


if graphic > 0
    line([x(comm) x(comm)],[0 1],'Color','k','LineStyle',':');
    line([x(mid) x(mid)],[0 1],'Color','k','LineStyle',':','LineWidth',2);
    line([x(fin) x(fin)],[0 1],'Color','k','LineStyle',':');
    
    if pitches > 0
        commlbl = 2^x(comm);
        midlbl = 2^x(mid);
        finlbl = 2^x(fin);
    else
        commlbl = exp(x(comm));
        midlbl = exp(x(mid));
        finlbl = exp(x(fin));
    end;
    fprintf(1,'-1SD point %2.1f (%2.1f)\nMid point %2.1f (%2.1f)\n+1SD point %2.1f (%2.1f)\n',...
        commlbl, x(comm), midlbl, x(mid), finlbl, x(fin));
    xfin = x(fin); xcomm = x(comm); xmid = x(mid);
end;



function [stim] = sub__stim_at(x,y, pt)
if min(y) > pt || max(y) < pt % you're asking for a point that isn't on the curve
    stim=-1;
    return;
end;

stim = find(abs(y - pt) == min(abs(y-pt)));