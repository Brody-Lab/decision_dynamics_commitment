close all
figureposition = [100,50,1200 1400];
figure('position', figureposition)
ncolumns = 6;
nrows = 4;
k = 0;
for hypothesis = ["bistable", "DDM1", "RNN", "noncanonical"]
    k = k + 1;
    subplot(ncolumns, nrows, k);
    M23a.plot_flow_field(hypothesis,'intrinsic')
    position = get(gca, 'position');
    position(3) = 0.18;
    set(gca, 'position', position)
end

scriptpath = matlab.desktop.editor.getActiveFilename;
[folderpath, graphicname] = fileparts(scriptpath);
[~, foldername] = fileparts(folderpath);
M23a.savegraphic(graphicname, foldername, 'overwrite', true);