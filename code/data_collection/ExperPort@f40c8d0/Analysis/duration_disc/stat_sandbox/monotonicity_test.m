function [real_slope dist sig] = monotonicity_test(x,y,varargin)

% Determines level of monotonicity of data (y) as function of x.
% Does a linear fit to data getting slope M.
% Does Monte Carlo simulations (numsim of them) and gets slope for each sim.
% Say distribution of these slopes is D.
% Finally, determines how many standard deviations our real slope is from
% the center of D.
%

pairs = { ...
    'figpos', [500 100 400 200] ; ...
    'width', 400 ; ...
    'height', 200 ; ...
    'figtitle', 'No title' ; ...
    'newfig', 1; ...
    'numsim', 500 ; ...
    'graphic', 1; ...
    'alphaval', 0.05; ... % 95% CI
    'typeoftest','twotailed';... [ twotailed | upper_only | lower_only]
    };
parse_knownargs(varargin, pairs);

p = polyfit(x,y,1);
real_slope = p(1);

slopes = [];
for s = 1:numsim
    newy = y(randperm(length(y)));
    p = polyfit(x,newy,1);
    slopes = [slopes p(1)];
end;

if graphic > 0
    if newfig > 0
        figure;
        figpos = [figpos(1) figpos(2) width height];
        set(gcf,'Position',figpos);
    end;

    [n x]=hist(slopes);
    hist(slopes);
    hold on;
    line([mean(slopes) mean(slopes)], [0 30], 'Color','r','LineWidth',2);
    line(mean(slopes)+[-1*std(slopes) std(slopes)], [15 15], 'Color','r','LineWidth',2);
    line([real_slope real_slope], [0 30], 'COlor','g','LineWidth',2);


    xlabel('Simulation slope distribution');
    if isempty(find(~isnan(slopes))), minX = -10; maxX = 10;
    else
        minX = min(real_slope, min(slopes))*1.1; maxX = max(real_slope, max(slopes))*1.1;
    end;
    set(gca,'XLim',[minX maxX]);
    if max(n) > 0
    set(gca,'YLim', [0 max(n)]);
    end;

    text(-9, (numsim/4)-5, sprintf('%i sims', numsim));
    title(figtitle);
end;

dist = abs(real_slope - mean(slopes)) / std(slopes);


mu = mean(slopes);
sigma = std(slopes);


% standardize slopes
z_slopes = (slopes - mu) ./ sigma;
idx = find(z_slopes >= -2); ci_min = min(z_slopes(idx));
idx = find(z_slopes <= 2); ci_max = max(z_slopes(idx));
ci = ([ ci_min ci_max ] .* sigma) + mu;

if graphic > 0
    line([ci(1) ci(1)], [0 max(n)], 'Color','r');
    line([ci(2) ci(2)], [0 max(n)], 'Color','r');
end;
fprintf(1,'%s:  %s\n', mfilename, typeoftest);
switch typeoftest
    case 'twotailed'
        if real_slope < ci(1) || real_slope > ci(2), sig = 1; else sig= 0;end;
    case 'upper_only'
        fprintf(1,'Paranoia\n');
        if real_slope > ci(2), sig =1; else sig = 0; end;
    case 'lower_only'
        if real_slope < ci(1), sig=1; else sig=0; end;
    otherwise
        error('invalid test');
end;
