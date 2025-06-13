% [] = plot_rat_mass(ratname, {'max_days'  180}, {'do_plot' 1})   Brings up a plot of rat
%                             mass as a function of days.
% PARAMETERS:
% -----------
%
%   ratname      The id of the rat, for example 'K071'
%
%
% OPTIONAL PARAMETERS:
% --------------------
%
%   'max_days'     Default 180.  Plot will go back at most this far in time
%                  from today.
%
%   'do_plot'      Default is 1. Will plot the data.
%
%
% OUTPUT:
% -------
%
%   output     This is a struct containing 3 fields:
%
%              days - is the dates the mass was taken in format yyyy-mm-dd
%              mass - is the mass values excluding anomalous readings
%              anomalous - are the mass values on days determined to be anomalous
%              
%


function output = plot_rat_mass(ratname, varargin)

pairs = { ...
   'max_days'    180  ; ...
   'do_plot'       1  ; ...
}; parseargs(varargin, pairs);

[mass DAYS tech] = bdata(['select mass, date, tech from ratinfo.mass where ratname="',ratname,'" order by date']);
mass(mass == 0) = nan;

if length(mass) > max_days; 
    mass = mass(end-(max_days-1):end); 
    DAYS = DAYS(end-(max_days-1):end); 
    tech = tech(end-(max_days-1):end);
end
MASS = mass;

anomalous = [];
for m = 2:length(mass)-1
    if sum(isnan(mass(m-1:m+1))) == 0
        temp = mean([mass(m-1) mass(m+1)]);
        if abs(mass(m-1) - mass(m+1)) / temp < 0.02
            if abs(mass(m) - temp) / temp > 0.04
                mass(m) = nan;
                anomalous (end+1) = m; %#ok<AGROW>
            end
        end
    end
end

days = [1:length(DAYS)]';
gooddata = ~isnan(mass);
goodmass = mass(gooddata);
gooddays = days(gooddata);
weight_declining = zeros(size(mass));
for m = 10:length(goodmass) 

    onedaychange   = (goodmass(m) - goodmass(m-1)) / mean(goodmass(m-9:m));
    multidaychange = (mean(goodmass(m-2:m)) - mean(goodmass(m-9:m-7))) / mean(goodmass(m-9:m));
    [rr pp]        = corr(gooddays(m-9:m),goodmass(m-9:m));
    slope          = polyfit(gooddays(m-9:m),goodmass(m-9:m),1);

    if onedaychange < -0.05 || multidaychange < -0.08 || (rr < 0 && pp < 0.05 && slope(1) < -1);  
        weight_declining(gooddays(m)) = 1; 
    end
end

if do_plot == 1
    figure('color','w'); hold on
end
good = mass; good(weight_declining == 1) = nan;
bad  = mass; bad( weight_declining == 0) = nan;
wrong = zeros(size(mass)); wrong(:) = nan; wrong(anomalous) = MASS(anomalous);

if do_plot == 1
    plot(good,'-ok','markerfacecolor','k','markersize',6);
    plot(bad, '-or','markerfacecolor','r','markersize',6);
    plot(wrong,'ob','markerfacecolor','b','markersize',6);
end
    
output.days      = DAYS;
output.mass      = mass;
output.anomalous = wrong;
output.tech      = tech;

MM = []; MS = []; MD = []; MN = cell(0);
oldm = nan; cnt = 0;
for d = 1:length(DAYS); 
    MD(end+1,:) = [str2num(DAYS{d}(6:7)) str2num(DAYS{d}(9:10))]; %#ok<AGROW,ST2NM>
    if isnan(oldm); 
       oldm = MD(end,1); 
       MM(1,:) = [d MD(end,1)];
    end
    if MD(end,1) ~= oldm 
        MS(end+1,:) = d;  %#ok<AGROW>
        oldm = MD(end,1);
        cnt = 0;
    else
        cnt = cnt + 1;
        if cnt == 15;
           MM(end+1,:) = [d MD(end,1)];  %#ok<AGROW>
        end
    end 
end

if do_plot == 1
    for m = 1:size(MM,1); 
        if     MM(m,2) ==  1; MN{end+1} = 'Jan'; %#ok<AGROW>
        elseif MM(m,2) ==  2; MN{end+1} = 'Feb'; %#ok<AGROW>
        elseif MM(m,2) ==  3; MN{end+1} = 'Mar'; %#ok<AGROW>
        elseif MM(m,2) ==  4; MN{end+1} = 'Apr'; %#ok<AGROW>
        elseif MM(m,2) ==  5; MN{end+1} = 'May'; %#ok<AGROW>
        elseif MM(m,2) ==  6; MN{end+1} = 'Jun'; %#ok<AGROW>
        elseif MM(m,2) ==  7; MN{end+1} = 'Jul'; %#ok<AGROW>
        elseif MM(m,2) ==  8; MN{end+1} = 'Aug'; %#ok<AGROW>
        elseif MM(m,2) ==  9; MN{end+1} = 'Sep'; %#ok<AGROW>
        elseif MM(m,2) == 10; MN{end+1} = 'Oct'; %#ok<AGROW>
        elseif MM(m,2) == 11; MN{end+1} = 'Nov'; %#ok<AGROW>
        elseif MM(m,2) == 12; MN{end+1} = 'Dec'; %#ok<AGROW>
        end
    end
    ylm = get(gca,'ylim');
    for m = 1:size(MS,1)
        plot([MS(m,1) MS(m,1)],ylm,':','color',[0.5 0.5 0.5]);
    end
    plot(good,'-ok','markerfacecolor','k','markersize',6);
    plot(bad, '-or','markerfacecolor','r','markersize',6);
    plot(wrong,'ob','markerfacecolor','b','markersize',6);

    set(gca,'fontsize',20,'xtick',MM(:,1),'xticklabel',MN,'xlim',[0 length(days)+1],'ylim',ylm);
    ylabel('Mass, grams');
    title(ratname,'fontsize',24);
end






