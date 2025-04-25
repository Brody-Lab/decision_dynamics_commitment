phi = 0.001;
k = 100;
lambda = 40; % clicks per second
duration_s = 1;
T = 0;
while max(T) <= duration_s
    T = [T; max(T)+exprnd(1/lambda)];
end
T = T(2:end-1);
n = length(T);
C = nan(n,1); % C(t_{click})
t = 0.001:0.001:1; % time
Ct = nan(size(t)); %C(t)
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
figure('pos', [100 100 800 400])
FHMDDM.prepareaxes
xlim([0 1])
plot(xlim, [1,1], 'k-', 'linewidth', 0.5)
h(1) = plot(T, C, 'o');
h(2) = plot(t,Ct);
legend(h, {'C(t_{click})', 'C(t)'}, 'location', 'best')
ylabel('Click magnitude')
xlabel('Time from stereoclick (s)')
% save_analysis_plot(mfilename, gcf, 'main_figure')