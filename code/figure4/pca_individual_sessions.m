sessions = M23a.tabulate_recording_sessions;
sessionindices = [1, 26, 28];
conditions = ["leftchoice", "rightchoice"];
figure('position', Specs.figureposition)
Specs = M23a.specify_PSTH_PCA;
for s = 1:numel(sessionindices)
    PSTHs = M23a.gather_PSTHs_for_PCA('sessionindices', sessionindices(s));
    Score = struct;
    Score.observed = M23a.pca_on_psths(PSTHs.dynamic, 'observed', true, 'conditions', conditions);
    Score.dynamic = M23a.pca_on_psths(PSTHs.dynamic, 'observed', false, 'conditions', conditions);
    Score.static = M23a.pca_on_psths(PSTHs.static, 'observed', false, 'conditions', conditions);
    clf
    panels = 'abc';
    datatypes = string(fieldnames(Score)');
    ax = nan(numel(datatypes),1);
    for d = 1:numel(datatypes)
        ax(d) = subplot(1,numel(datatypes),d);
        M23a.stylizeaxes
        set(gca, 'dataaspectratio', [1,1,1], ...
            'outerposition', [Specs.axes_outerposition_left+Specs.axes_outerposition_width*(d-1), ...
            0, Specs.axes_outerposition_width, 1])
        pos = get(gca, 'position');
        pos(2) = 0.15;
        pos(3) = 0.18;
        datatype= datatypes(d);
        conditions = string(fieldnames(Score.(datatype))');
        for condition = conditions
            set(gca, 'dataaspectratio', [1,1,1])
            plot(Score.(datatype).(condition)(:,1), Score.(datatype).(condition)(:,2), ...
                'linewidth', 2, 'color', Specs.colors.(condition))
            for i = 1:numel(Specs.timemarkers)
                t = Specs.timemarkers(i);
                plot(Score.(datatype).(condition)(t,1), Score.(datatype).(condition)(t,2), Specs.markers{i}, ...
                    'markersize', 10, 'linewidth', 1, 'color', Specs.colors.(condition))
            end
        end
        title(char(datatype))
        linkaxes(ax)
    limx = max(abs(xlim));
    xlim([-limx, limx])
    limy = max(abs(ylim));
    ylim([-limx/3, limx/3])
    
        xticks(0)
        yticks(0)
        if d == 1
            xlabel('                             projections onto first principal component (PC 1)')
            ylabel('PC 2 proj.')
        else
            xlabel(' ')
            ylabel(' ')
            xticklabels({' '})
            yticklabels({' '})
        end
    end
    handles = get(gca, 'Children');
    hlegend = legend(handles([8,4,7,6,5]), {'left choice', 'right choice', 't = 0 s', 't = 0.33 s', 't = 1 s'}) ;
    set(hlegend, 'position', [0.65 0.45, 0.1, 0.12]);
    scriptpath = matlab.desktop.editor.getActiveFilename;
    [folderpath, graphicname] = fileparts(scriptpath);
    [~, foldername] = fileparts(folderpath);
    M23a.savegraphic(graphicname, foldername);
    recording_id = char(sessions.recording_id(sessionindices(s)));
    M23a.savegraphic([graphicname '_' recording_id], foldername);
end