duration_s = 1;
dt = 0.01;
ntimesteps = ceil(duration_s/dt);
ntrials = 1e3;
dv = zeros(ntrials,ntimesteps);
sigma2 = 0.01;
bound = 12;
noise = randn(ntrials,ntimesteps)*sqrt(sigma2);
inputs = zeros(ntrials,ntimesteps);
gammaset = [-4; -0.8; 0.8; 4];
totalhz = 40;
gammas = gammaset(randi(numel(gammaset), ntrials,1));
timebinedges = 0:dt:duration_s;
latency_s = 0.05;
rng(2)
for i = 1:ntrials
    righthz = totalhz*exp(gammas(i))./(1+exp(gammas(i)));
    lefthz = totalhz-righthz;
    lefttimes = cumsum(exprnd(1/lefthz, 2*ceil(lefthz), 1));
    lefttimes = lefttimes(lefttimes >= latency_s & lefttimes<=duration_s);
    righttimes = cumsum(exprnd(1/righthz, 2*ceil(righthz), 1));
    righttimes = righttimes(righttimes >= latency_s & righttimes<=duration_s);
    inputs = histcounts(righttimes, timebinedges) - histcounts(lefttimes, timebinedges);
    for t = 2:ntimesteps
        if abs(dv(i,t-1)) < bound
            dv(i,t) = dv(i,t-1) + noise(t) + inputs(t);
            dv(i,t) = sign(dv(i,t))*min(abs(dv(i,t)), bound);
        else
            dv(i,t:end) = sign(dv(i,t-1))*bound;
            break
        end
    end
end
dvmean = nan(numel(gammaset), ntimesteps);
for i = 1:numel(gammaset)
    dvmean(i,:) = mean(dv(gammas==gammaset(i),:));
end
Colors = M23a.colors;
figure('pos', [1e2,8e2,250,250])
M23a.stylizeaxes
plot(timebinedges(2:end), dvmean(1,:), 'color', Colors.leftchoice_strong_leftevidence, 'linewidth', 2.5)
plot(timebinedges(2:end), dvmean(2,:), 'color', Colors.leftchoice_weak_leftevidence, 'linewidth', 2.5)
plot(timebinedges(2:end), dvmean(3,:), 'color', Colors.rightchoice_weak_rightevidence, 'linewidth', 2.5)
plot(timebinedges(2:end), dvmean(4,:), 'color', Colors.rightchoice_strong_rightevidence, 'linewidth', 2.5)
xlabel('time (s)')
ylabel('accum. evidence')
ylim([-bound,bound]*1.2)
yticks(0)
xticks(0:1)
title('simulation')
scriptpath = matlab.desktop.editor.getActiveFilename;
[folderpath, graphicname] = fileparts(scriptpath);
[~, foldername] = fileparts(folderpath);
M23a.savegraphic(graphicname, foldername);