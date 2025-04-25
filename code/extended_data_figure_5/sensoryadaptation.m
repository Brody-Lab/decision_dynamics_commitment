[analysispath, analysisname] = fileparts(matlab.desktop.editor.getActiveFilename);
[~, foldername] = fileparts(analysispath);
folderpath = fullfile(M23a.locateassets, foldername);
if ~isfolder(folderpath)
    mkdir(folderpath)
end
figurepath = fullfile(folderpath, [analysisname '.svg']);
%%
rng(1)
phi = 0.001; % adaptation strength
k = 100; % adaptation recovery rate
lambda = 40; % clicks per second
duration_s = 1;
Deltat = 0.001;
T = 0;
while max(T) <= duration_s
    T = [T; max(T)+exprnd(1/lambda)];
end
T = T(2:end-1);
n = length(T);
C = nan(n,1); % C(t_{click})
t = Deltat:Deltat:duration_s; % timesteps
Ct = nan(size(t)); % latent adaptation dynamics
for i = 1:n
    if i == 1
        T_prev = 0;
        C_prev = 1;
    else
        T_prev = T(i-1);
        C_prev = C(i-1);
    end
    Delta_t = T(i) - T_prev;
    C(i) = 1 - (1 - phi*C_prev) * exp(-k*Delta_t);
    
    indices = t > T_prev & t <= T(i);
    Ct(indices) = 1 - (1 - phi*C_prev) * exp(-k*(t(indices)-T_prev));
end
indices = t > T(i);
Ct(indices) = 1 - (1 - phi*C(i)) * exp(-k*(t(indices)-T(i)));

Ct(ceil(T/Deltat)) = C;
close all
figure('pos', [100 100 1600 400])
M23a.stylizeaxes
xlim([0 1])
ylim([0 1])
yticks(ylim)
xticks(xlim)
yticklabels({'(no input) 0', '(no adaptation) 1'})
h(1) = plot(ceil(T/Deltat)*Deltat, C, 'ko', 'markerfacecolor', 'k');
h(2) = plot(t,Ct, 'k--');
xlabel('time from first click (s)')
set(gca, 'outerposition', [0 0 0.8 1])
legend(h, {'click input magnitude', 'sensory adaptation dynamics'}, 'position', [0.8 0.4 0.15 .3])
saveas(gcf, figurepath)