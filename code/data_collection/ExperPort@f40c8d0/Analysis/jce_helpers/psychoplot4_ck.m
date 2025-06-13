function varargout=psychoplot4_ck(x_vals,went_right,rev,DSP)
% [stats]=psychoplot4(x_vals, went_right)
% [stats]=psychoplot4(x_vals, hits, sides)
%
% Fits a 4 parameter sigmoid to psychophysical data
%
% x_vals        the experimenter controlled value on each trial.
% went_right    a vector of [0,1]'s the same length as x_vals describing
%               the response on that trials
% DSP           0 to turn display off, 1 to turn it on
%
% The sigmoid is of the form
% y=y0+a./(1+ exp(-(x-x0)./b));
% 
% y0=beta(1)    sets the lower bound
% a=beta(2)     a+y0 is the upper bound  
% x0=beta(3)    is the bias
% b=beta(4)     is the slope

warning('off','all');

trial_types = unique(x_vals);
for tx = 1:numel(trial_types),
	meanD(tx) = mean(went_right(x_vals == trial_types(tx))); %#ok<AGROW>
end

if rev == 1; y0 = meanD(1);
else         y0 = meanD(end);
end

[beta,resid,jacob,sigma,mse] = nlinfit(x_vals,went_right,@sig4,[y0 rev*range(meanD) mean(x_vals) 0.1*range(x_vals)]);

x_s=linspace(min(x_vals), max(x_vals), 100);
[y_s,delta] = nlpredci(@sig4,x_s,beta,resid,'covar',sigma);
betaci = nlparci(beta,resid,'covar',sigma);

if size(y_s,1) > size(y_s,2); y_s = y_s'; end

S.beta=beta;
S.betaci=betaci;
S.resid=resid;
S.mse=mse;
S.sigma=sigma;
S.ypred=y_s;
S.y95ci=delta;
S.xvals = x_s;

if y_s(1) > 0.5 || y_s(end) < 0.5
    bisection = nan;
    weber     = nan;
    DL        = nan;
else
    %ends = [min(x_vals) max(x_vals)];
    %x_rng = x_s; %ends(1):(ends(2)-ends(1))/(length(x_s)-1):ends(2);
    %bisection = mean(x_rng(abs(y_s - 0.5) == min(abs(y_s - 0.5))));
    
    if y_s(1) > 0.5 || y_s(end) < 0.5
        p = polyfit(x_vals,went_right,1);
        bisection = (0.5 - p(2)) / p(1);
    else
        bisection = rev_sig4(beta,0.5);
    end
    
    if y_s(1) > 0.25 || y_s(end) < 0.75
        p = polyfit(x_vals,went_right,1);
        DL = ((0.75 - p(2)) / p(1)) - ((0.25 - p(2)) / p(1));
        weber = DL / bisection;
    else
        upr = rev_sig4(beta,0.75); %mean(x_rng(abs(y_s - 0.75) == min(abs(y_s - 0.75))));
        lwr = rev_sig4(beta,0.25); %mean(x_rng(abs(y_s - 0.25) == min(abs(y_s - 0.25))));
        DL    = upr - lwr;
        weber = DL / bisection;
        S.x         = [lwr bisection upr];
    end
end
S.bisection = bisection;
S.weber     = weber;
S.DL        = DL;


if DSP == 1
    fig_h=figure('Color','w');

    trial_types = unique(x_vals);
    if numel(trial_types) > numel(went_right)*0.1,
        sortedM=sortrows([x_vals(:) went_right(:)]);
        rawD=jconv(normpdf(-10:10, 0, 2), sortedM(:,2)');
        plot(sortedM(:,1), rawD,'o');
    else
        for j = 1:numel(trial_types),
            meanD(j) = mean(went_right(x_vals == trial_types(j)));
        end;
        plot(trial_types, meanD, 'r.', 'MarkerSize', 15);
    end;
    hold on

    plot(x_s, y_s,'k');
    plot(x_s,y_s-delta,'k:');
    plot(x_s,y_s+delta,'k:');
end

if nargout>=1
    varargout{1}=S;
end

function y=sig4(beta,x)

y0=beta(1);
a=beta(2);
x0=beta(3);
b=beta(4);

y=y0+a./(1+ exp(-(x-x0)./b));

function x=rev_sig4(beta,y)

y0=beta(1);
a=beta(2);
x0=beta(3);
b=beta(4);

x = x0 - (b .* log((a ./ (y - y0)) - 1));




