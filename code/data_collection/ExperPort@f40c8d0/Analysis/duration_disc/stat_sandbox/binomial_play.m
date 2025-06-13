function [] = binomial_play()


% Does # boys in a family follow a binomial distribution
% Dataset from p89 of Bulmer's "Principles of Statistics"
numboys = 0:1:8;
freqs = [215 1485 5331 10649 14959 11929 6678 2092 342];

totalkids = sum(freqs) * 8; % each family has 8 kids
totalboys = numboys * freqs'; % all the boys in all the families

p = totalboys/totalkids;

if 0
    fprintf(1,'P(boys) = %1.3f\n', p);
    figure;
    subplot(1,2,1);
    plot(numboys, freqs, '.r');
end;


n=50;  % # coin flips per experiment
p=0.5; % null hypothesis: rat making decision randomly & independently
hrate = 0.5:0.05:1;

% prob getting over 90% trials correct

if 0

    figure;

    % Simulate a binomial experiment
    subplot(2,1,1);
    numExper=1000;

    mega = rand(numExper,n); % row is a simulation of 300 coin flips
    mega2 = zeros(size(mega));
    mega2(find(mega < p)) = 1;
    mega2 = sum(mega2'); % sum across each row
    hist(mega2/n);
    xlabel('f(heads)');
    title(sprintf('Simulating binomial: %i experiments with %i coin flips each', numExper, n));

    % Now plot p(hit rate > p) from two sources of data:
    % Matlab's internal binomial distro, and simulated data above

    matlabsbino = [];
    simbino = [];
    for h = 1:length(hrate)
        matlabsbino = horzcat(matlabsbino, 1- (binocdf(hrate(h) * n, n, p)));
        simbino = horzcat(simbino, length(find(mega2 > hrate(h)*n))/length(mega2));
    end;


    subplot(2,1,2);
    plot(hrate, matlabsbino,'.b');
    hold on;
    plot(hrate, simbino, '.r');
    legend({'binocdf', 'From simulation'});
    xlabel('"Heads" rate');
    t=ylabel('p(x > "Heads" rate)');
    set(t,'FontSize',14,'FontWeight','bold');

end;

% now do this over for many different values of n
n = [30 50 80 100];
chance_vals =[];
vals_75=[];
for nk = 1:length(n)
    [mc m7 pfor_random pfor_75] = sig_for_given_n(hrate, n(nk));
    chance_vals =horzcat(chance_vals, mc);
    vals_75 = horzcat(vals_75, m7);

    fprintf(1,'Got %1.2f & %1.2f\n', mc, m7);

%     figure;
%     % Plot p-values for performance if null model is : a) chance, b) 75%
%     %subplot(2,1,1);
%     plot(hrate, pfor_random,'.b'); hold on;
%     plot(hrate, pfor_75, '.r');
%     line([min(hrate) max(hrate)],[0.05 0.05],'LineStyle',':','COlor','r');
%     legend({'50%','75%'});
%     title(sprintf('p-value of different hit rates\nNull is chance performance (n=%i)',n(nk)));
%     t=xlabel('Rat''s hit rate');set(t,'FontSize',14,'FontWeight','bold');
%     t=ylabel('p-value for one-tailed t-test');set(t,'FontSize',14,'FontWeight','bold');
%     set(gca,'YLim',[0 0.2],'YTick', 0:0.05:0.2);

end;

figure;
plot(n, chance_vals,'.b');hold on;
plot(n,vals_75,'.r');
t=xlabel('Session size (n)');set(t,'FontSize',14, 'FontWeight','bold');
t=ylabel('Smallest hit rate with p-value < 0.05');set(t,'FontWeight','bold','FontSize',14);
legend({'Chance','75%'});
set(gca,'YLim',[0.5 1]);


% Returns the small hit rate for which p value is < 0.05
% for a) null model is chance (p=0.5)
% b) null model is 75%
function [min_chance min_75 pfor_random pfor_75] = sig_for_given_n(hrate, n)
pfor_random = []; % contains p-values for rats of different performance when null is chance performance
pfor_75 = []; % Same as above except null model is 75% correct
for h = 1:length(hrate)
    rattie = rand(n,1);
    rattie_bi = zeros(size(rattie)); rattie_bi(find(rattie < hrate(h))) = 1;
    pfor_random = horzcat(pfor_random, ttest(rattie_bi, n, 0.5));
    pfor_75 = horzcat(pfor_75, ttest(rattie_bi, n, 0.75));
end;

min_chance = find(pfor_random < 0.05);
min_chance = hrate(min(min_chance));

min_75 = find(pfor_75 < 0.05);
min_75 = hrate(min(min_75));


function [p_value] = ttest(rattie_bi, n,p)
% Now do a t test on a random rat with success rate 0.5
% [h p] = ttest(rattie_bi)
% This test returns a significant result ... obviously cannot apply ttest to out-of-the-box binomial

% compute t-statistic
% Null hypothesis is random selection: p=0.5
t_num = (sum(rattie_bi) - (n*p));
rattie_var = (sum(rattie_bi) * (n-sum(rattie_bi)))/n;
t_den = sqrt(rattie_var + (p*(1-p)*n));
t_statistic = t_num/t_den;

p_value = 1- tcdf(t_statistic, (2*n)-2);