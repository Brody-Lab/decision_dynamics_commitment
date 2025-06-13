function [] = qval_test
% do variety of tests to ensure Q-value computation for assessing merit of
% fits works as expected. 
% See Numerical Recipes in C (2ed), Chapter 15 for mathematical background
% to chi2 assessment of fits and Q-value definition.
%
% N.B. This script has hard-coded values suitable for pitch data (uses
% base 2, stimulus range for frequency rats, pitches flags have been set). 

sub__makeratdatanoisy('S044')



% --------------------------------------------------------------
% Subroutines
% --------------------------------------------------------------

function [] = sub__noisylinesimulation
bins= generate_bins(8,16, 8, 'pitches', 1);
nse_array=0.00001:0.00005:0.1;
%nse_array = 0.1:0.05:0.5;
%nse_array=0.01;
qlin=NaN(size(nse_array));
qsig=NaN(size(nse_array));

for k=1:length(nse_array)
[tones reps p sigma linfit sigfit xx yy] = sub__randerrfromline(bins, 100, nse_array(k));
[s ql qs] = comparefits(log2(bins), p, sigma, sigfit, linfit, 0);
qlin(k)=ql;
qsig(k)=qs;
end;

figure;
msize=20;
plot(nse_array,qlin, '.k','MarkerSize',8,'Marker','o'); hold on;
plot(nse_array,qsig, '.b', 'MarkerSize',msize);

set(gcf,'Position',[188   542   857   288]);


function [] = sub__makeratdatanoisy(ratname)
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
    
% replongs, tallies
% linearfit, sigmoidfit
% xx,yy
% bins

% compute error from data set
allreps=sum(replongs);
alltall=sum(tallies);
p= allreps ./ alltall;

sigma = (p.*(1-p)) ./ alltall;
sigma = sqrt(sigma);

% now artificially increase
sigma_array =5;%1.1:0.5:5;
qlin=NaN(size(sigma_array));
qsig=NaN(size(sigma_array));
for k=1:length(sigma_array)
    [s ql qs] = comparefits(log2(bins), p, sigma * sigma_array(k), sigmoidfit, linearfit, 1,xx, yy);
    qlin(k)=ql;
    qsig(k)=qs;    
end;

% figure;
% msize=20;
% plot(sigma_array,qlin, '.k','MarkerSize',8,'Marker','o'); hold on;
% plot(sigma_array,qsig, '.b', 'MarkerSize',msize);
% 
% set(gcf,'Position',[188   542   857   288]);
% 2;  
% 


% generate noisy data from a line.
function [tones reps p sigma linfit sigfit xx yy]=sub__randerrfromline(bins,tperbin,nse)
m=1; c=-3;

% make tones list
% tones=repmat(bins,1,tperbin);
% tones=sort(tones);
tones=sub__makects(log2(8),log2(16),tperbin*length(bins));

% >> uncomment to put generate [0,1] (cts) responses
%
% perfect=(m*tones) + c; % right on the line

% reps=perfect + (randn(size(tones)) * nse) ;
% reps=abs(reps); % can't be < 0
%
% [bins replong tally] = bin_side_choice(8, 16, length(bins), 1, 2.^tones, reps);
% p = replong ./ tally;
% <<
randn('state',sum(100*clock));
perfect =(m*log2(bins))+c;
n=randn(size(bins))*nse;
p = perfect + n;
p(p>=1)=0.99999; p(p<=0)=0.00001;             % floor and ceiling at 0 and 1.
reps=sub__p2reps(p,tperbin);    % convert probs into appropr. # of 0/1 values

tally=ones(size(bins))*tperbin;
sigma = (p .* (1-p)) ./tally;
sigma = sqrt(sigma);

[linfit sigfit xx yy]=sub__rawfit(2.^tones, reps, sqrt(8*16), 1); % does fitting




% generates purely linear dataset
function [tones reps p sigma linfit sigfit xx yy] = sub__linearnoerr(bins, tperbin)
pvals = 0.1:0.1:length(bins);
tperbin = 100; % simulate 100 trials per bin

reps=[];
tones=[];
p=NaN(size(bins));
for b=1:length(bins)
    r=rand(tperbin,1);
    currb = r < pvals(b);
    %currb=[ones(10*b,1); zeros(100-(10*b), 1)];
    if length(currb) ~=100,
        error('oops');
    end;
    fprintf(1,'%i: %i LONG\n', b, sum(currb));
    reps=vertcat(reps, currb);
    tones=vertcat(tones, ones(tperbin,1)*bins(b));
    p(b)=sum(currb)/tperbin;
end;
tallies = ones(size(bins)) * tperbin;

sigma= sqrt((p .* (1-p)) ./ tallies);
[linfit sigfit xx yy]=sub__rawfit(tones, reps, sqrt(8*16), 1);


% calls logistic fitter and returns selected outputs
function [lfit sfit x y]=sub__rawfit(tones, reps, mp, pitches)
if rows(reps)>1, reps=reps';end;
f=logistic_fitter('init',tones,reps, mp, pitches);
lfit=f.linearfit;
sfit=f.sigmoidfit;
x=f.interp_x;
y=f.interp_y;


% generates continuous stimulus set between given endpoints
function [cts] = sub__makects(bmin,bmax, total)
rng=bmax-bmin;
stp=rng/total;
cts=bmin:stp:bmax;
cts=cts(1:end-1);


% given prob, converts to binary array with matching number of 1's
% if p=0.2 ,tperbin=100, returns [ones(20,1) zeros(80,1)]
function [reps]= sub__p2reps(p, tperbin)
reps=[];
for k=1:length(p)
    rnum=floor(p(k)*tperbin);
    r = [ones(rnum,1); zeros(tperbin-rnum,1)];
    reps=vertcat(reps, r);
end;