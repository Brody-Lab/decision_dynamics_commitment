rng(1)
close all
figure('position', [1e2,1e2,150,100])
M23a.stylizeaxes
plot(randn(100,1), 'color', 0.5*[1,1,1])
xticks([])
yticks([])
scriptpath = matlab.desktop.editor.getActiveFilename;
[folderpath, graphicname] = fileparts(scriptpath);
[~, foldername] = fileparts(folderpath);
M23a.savegraphic(graphicname, foldername, 'overwrite', true);