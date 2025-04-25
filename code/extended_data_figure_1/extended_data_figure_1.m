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

for hypothesis = ["bistable", "DDM1", "RNN", "noncanonical"]
    k = k + 1;
    subplot(ncolumns, nrows, k);
    M23a.plot_flow_speed(hypothesis,'intrinsic')
    position = get(gca, 'position');
    position(3) = 0.18;
    set(gca, 'position', position)
    if hypothesis ~= "noncanonical"
        colorbar off
    end
end

for component = ["leftinput", "rightinput"]
    for hypothesis = ["bistable", "DDM1", "RNN", "noncanonical"]
        k = k + 1;
        subplot(ncolumns, nrows, k);
        M23a.plot_flow_field(hypothesis,component)
        position = get(gca, 'position');
        position(3) = 0.18;
        set(gca, 'position', position)
    end
end

for hypothesis = ["bistable", "DDM1", "RNN", "noncanonical"]
    k = k + 1;
    subplot(ncolumns, nrows, k);
    M23a.plot_flow_speed(hypothesis,'input')
    position = get(gca, 'position');
    position(3) = 0.18;
    set(gca, 'position', position)
    if hypothesis ~= "noncanonical"
        colorbar off
    end
end

for hypothesis = ["bistable", "DDM1", "RNN", "noncanonical"]
    k = k + 1;
    subplot(ncolumns, nrows, k);
    M23a.plot_flow_speed(hypothesis,'difference')
    position = get(gca, 'position');
    position(3) = 0.18;
    set(gca, 'position', position)
    if hypothesis ~= "noncanonical"
        colorbar off
    end
end
scriptpath = matlab.desktop.editor.getActiveFilename;
[folderpath, graphicname] = fileparts(scriptpath);
[~, foldername] = fileparts(folderpath);
M23a.savegraphic('panels_a_to_f', foldername, 'overwrite', true);
%% panels g
figure('position', [100,50,1200 1400])
k = 0;
for hypothesis = ["bistable", "DDM1", "RNN", "noncanonical"]
    k = k + 1;
    subplot(ncolumns, nrows, k);
    M23a.plot_flow_speed_difference_over_time(hypothesis)
    position = get(gca, 'position');
    position(3) = 0.18;
    position(4) = 0.08;
    set(gca, 'position', position)
end
scriptpath = matlab.desktop.editor.getActiveFilename;
[folderpath, graphicname] = fileparts(scriptpath);
[~, foldername] = fileparts(folderpath);
M23a.savegraphic('panelg', foldername, 'overwrite', true);