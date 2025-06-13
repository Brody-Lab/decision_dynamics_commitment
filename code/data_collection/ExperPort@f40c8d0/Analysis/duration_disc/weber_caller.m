function [out] = weber_caller(bins, replong, tally, ispitch,binmin,binmax)
% The only interface by which all procedures should compute the weber ratio

% Perform logistic regression and calculate Weber ratio
if ispitch > 0
    x = log2(bins(1:end-1));
    if (x(1) == 0), x(1) = 0.00001; end;
    mp = log2(sqrt(binmin*binmax));
    minx = min(x)-0.5; maxx=max(x)+0.5;
else
    x = log(bins(1:end-1));
    mp = log(sqrt(binmin*binmax));
    minx = min(x)-0.3; maxx=max(x)+0.3;
end;

if length(find(tally == 0)) > 0,
    warning('Psychometric_curve.m: has at least one missing bin; skipping...\n');
    weber=-1; bfit=0; xx=0; yy=0; xmid=0;xcomm=0; xfin=0;
else

    offset =  ones(size(replong))*1;
    b = glmfit(x', [replong; tally]', 'binomial'); bfit = b;
    xx = minx:(maxx-minx)/100:maxx;
    yy = glmval(b, xx, 'logit');

    [xcomm xfin xmid weber] = get_weber(xx,yy, 'pitches', ispitch);
end;

out = {};
out.xcomm = xcomm;
out.xmid = xmid;
out.weber = weber;
out.xfin = xfin;
out.logbins = x;
out.interp_x = xx;
out.interp_y = yy;
out.mp = mp;
out.bfit = bfit;

% used to be in get_weber
% if pitches > 0
%     xfin = 2^(x(fin)) - 2^(x(mid));
%     xcomm = 2^(x(mid)) - 2^(x(comm));
%     xmid = 2^(x(mid));
% 
% else
%     xfin = exp(x(fin)) - exp(x(mid));
%     xcomm = exp(x(mid)) - exp(x(comm));
%     xmid = exp(x(mid));
% end;