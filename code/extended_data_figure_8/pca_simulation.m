clear
close all
rng(1)
nneurons = 100;
signal_dimension1 = cos(0:pi/24:pi)*0.3;
signal_dimension2 = -sin(0:pi/12:2*pi)*0.1;
signal = [signal_dimension1;signal_dimension2];
theta = pi/12;
R = [cos(theta), -sin(theta); sin(theta), cos(theta)];
signal= R*signal;
signalweights = randn(nneurons,2);
X = signalweights*signal;
[coeff, score, latent] = pca(X);
figure('pos', [1e2,1e2,1600,400])
ax1 = subplot(1,3,1);
M23a.stylizeaxes
set(gca, 'DataAspectRatio', [1,1,1], 'pos', [0.1    0.1    0.2    0.8])
plot(signal(1,:),signal(2,:), 'k-', 'linewidth', 1.5)
xlabel('dimension 1')
ylabel('dimension 2')
title('generative signal')
xlim([-0.32,0.32])
xticks([-0.3,0,0.3])
ylim([-0.1,0.1])
yticks([-0.1,0,0.1])
subplot(1,3,2)
M23a.stylizeaxes
set(gca, 'DataAspectRatio', [1,1,1])
plot(coeff(:,1), coeff(:,2), 'k-', 'linewidth', 1.5)
xlabel('PC 1')
ylabel('PC 2')
title('unscaled')
set(gca, 'Position', [0.4418    0.4    0.2    0.4])
xlim([-0.5, 0.5])
ax3 = subplot(1,3,3);
M23a.stylizeaxes
set(gca, 'DataAspectRatio', [1,1,1], 'pos', [0.7    0.1    0.2    0.8])
h = plot(coeff(:,1), coeff(:,2)*sqrt(latent(2)/latent(1)), 'k-', 'linewidth', 1.5);
title('scaled')
xlabel('PC 1')
ylabel('PC 2')
xlim([-0.32,0.32])
xticks([-0.3,0,0.3])
ylim([-0.1,0.1])
yticks([-0.1,0,0.1])
scriptpath = matlab.desktop.editor.getActiveFilename;
[folderpath, graphicname] = fileparts(scriptpath);
[~, foldername] = fileparts(folderpath);
M23a.savegraphic('pca_simulation', foldername);