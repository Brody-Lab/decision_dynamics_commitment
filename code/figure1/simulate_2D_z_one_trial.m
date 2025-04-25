clc
clear
ntimesteps = 1e2;
time_s = (1:ntimesteps)/100;
z = zeros(2,ntimesteps);
A = [0.97, 0; 0, 0.97];
Abound = [1, 0; 0, 1];
sigma2 = 0.05;
bound = 3;
attractor = 3.5;
discriminant = ones(2,1);
discriminant = discriminant/norm(discriminant);
seed = 4;
rng(seed)
noise = randn(2,ntimesteps)*sqrt(sigma2);
inputs = zeros(2,ntimesteps);
inputmag = 2.5;
inputs(:,20) = -inputmag*discriminant;
inputs(:,40) = inputmag*discriminant;
inputs(:,60) = inputmag*discriminant;
for t = 2:ntimesteps
    proj = dot(z(:,t-1), discriminant);
    if (proj < bound) && (proj > -bound)
        z(:,t) = A*z(:,t-1) + noise(:,t) + inputs(:,t);
    else
        dz = sign(proj)*(attractor-abs(proj))*discriminant;
        z(:,t) = z(:,t-1) + 0.5*dz + noise(:,t) + inputs(:,t);
    end
end
close all
figure('position', [1e2,1e2,500,320])
M23a.stylizeaxes
colors = M23a.colors;
set(gca, 'dataaspectratio', [1,1,0.2], ...
         'view', [-135 10], ...
         'fontsize', 18)
xlim([-4.5, 4.5])
ylim([-4.5, 4.5])
zlim([0 1])
xticks([-4.5, 0, 4.5])
yticks([-4.5, 0, 4.5])
xticklabels({'', '', ''})
yticklabels({'', '', ''})
zticks([0 0.5, 1])
zticklabels({'0', '', '1'})
grid on
plot3(z(1,:), z(2,:), time_s, 'k-', ...
    'linewidth', 1, 'markersize', 10)
plot3(z(1,:), z(2,:), time_s, '.', 'color', colors.dStr, 'markersize', 10)
xlabel('z1', 'fontsize', 18)
ylabel('z2','fontsize', 18)
zlabel('time (s)','fontsize', 18)
%%
scriptpath = matlab.desktop.editor.getActiveFilename;
[folderpath, graphicname] = fileparts(scriptpath);
[~, foldername] = fileparts(folderpath);
M23a.savegraphic(graphicname, foldername, 'overwrite', true);