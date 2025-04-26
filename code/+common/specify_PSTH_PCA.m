function Specs = specify_PSTH_PCA()
    Specs = struct;
    Specs.colors = M23a.colors;
    Specs.timemarkers = [1, 33, 100];
    Specs.markers = {'o', 'd', 'pentagram'};
    Specs.outputfolder = 'X:\tzluo\analysis_data\analysis_2023_05_23a_cv';
    Specs.figureposition = [1e2, 1e2, 2400 500];
    Specs.axes_outerposition_left = 0.05;
    Specs.axes_outerposition_width = 0.2;
    Specs.settingsname = '2023_05_06';
    Specs.brainareas = ["mPFC", "dStr", "dmFC", "vStr", "M1", "FOF"];
end