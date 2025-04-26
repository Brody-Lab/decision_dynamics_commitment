function psth = simulate_choice_dynamics()
% simulate the choice dynamics of single neuron
%
% Related to Figure 2
%
%=RETURN
%
%   psth
%       a structure containing the filtered responses

seed = 2;
rng(seed)
dt = 0.01;
ntrials = 3e2;
maxduration_s = 1.2;
maxstimulusduration = 1;
minduration_s = 0.2;
durations_s = minduration_s + rand(ntrials,1)*(maxduration_s-minduration_s);
maxtimesteps = ceil(maxduration_s/dt);
ntimesteps = ceil(durations_s/dt);
dv = zeros(ntrials,maxtimesteps);
sigma2_a = 0.01;
sigma_s = 5;
sigma_i = 5;
dv(:,1) = sigma_i*randn(ntrials,1);
bound = 20;
diffusionnoise = randn(ntrials,maxtimesteps)*sqrt(sigma2_a);
gammaset = -3.5:3.5;
totalhz = 40;
gammas = gammaset(randi(numel(gammaset), ntrials,1));
timebinedges = 0:dt:maxduration_s;
latency_s = 0.05;
choices = nan(ntrials,1);
for i = 1:ntrials
    stimulusduration = min(durations_s(i), maxstimulusduration);
    righthz = totalhz*exp(gammas(i))./(1+exp(gammas(i)));
    lefthz = totalhz-righthz;
    lefttimes = cumsum(exprnd(1/lefthz, 2*ceil(lefthz), 1));
    lefttimes = lefttimes(lefttimes >= latency_s & lefttimes<=stimulusduration);
    righttimes = cumsum(exprnd(1/righthz, 2*ceil(righthz), 1));
    righttimes = righttimes(righttimes >= latency_s & righttimes<=stimulusduration);
    inputs = histcounts(righttimes, timebinedges) - histcounts(lefttimes, timebinedges);
    for t = 2:ntimesteps(i)
        if abs(dv(i,t-1)) < bound
            dv(i,t) = dv(i,t-1) + diffusionnoise(t) + inputs(t) + sigma_s*randn;
            dv(i,t) = sign(dv(i,t))*min(abs(dv(i,t)), bound);
        else
            dv(i,t:ntimesteps(i)) = sign(dv(i,t-1))*bound;
            break
        end
    end
    dv(i,ntimesteps(i)+1:end) = nan;
    choices(i) = sign(dv(i,ntimesteps(i)));
end
baseline = 20*rand(ntrials,1);
dv_weight = -4;
lambdas = M23a.softplus(dv_weight*dv/bound+baseline);
spiketrain = poissrnd(lambdas);
filteredresponse = nan(size(spiketrain));
for i = 1:ntrials
    filteredresponse(i,1:ntimesteps(i)) = M23a.convolve_counts_causalgaussian(spiketrain(i,1:ntimesteps(i)), 40, 10);
end
time_s = dt:dt:1;
psth = struct;
psth.leftchoice.time_s = time_s;
ci = bootci(1e3, @(x) mean(x,'omitnan'), filteredresponse(choices==-1, 1:100));
psth.leftchoice.lowerconfidencelimit = ci(1,:);
psth.leftchoice.upperconfidencelimit = ci(2,:);
psth.rightchoice.time_s = time_s;
ci = bootci(1e3, @(x) mean(x,'omitnan'), filteredresponse(choices==1, 1:100));
psth.rightchoice.lowerconfidencelimit = ci(1,:);
psth.rightchoice.upperconfidencelimit = ci(2,:);