close all
figure('position', [100,50,275 300])

subplot(2, 1, 2)
colorbar_handle = M23a.plot_flow_speed('bistable','difference');
set(colorbar_handle, 'location', 'westoutside')
position = get(gca, 'position');
position(1) = 0.3;
position(3) = 0.6;
set(gca, 'position', position)
scriptpath = matlab.desktop.editor.getActiveFilename;
[folderpath, graphicname] = fileparts(scriptpath);
[~, foldername] = fileparts(folderpath);
M23a.savegraphic(graphicname, foldername, 'overwrite', true);