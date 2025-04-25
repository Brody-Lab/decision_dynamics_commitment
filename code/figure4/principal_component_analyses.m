PSTHs = M23a.gather_PSTHs_for_PCA;
%%
Score = struct;
conditions = ["leftchoice", "rightchoice"];
Score.observed = M23a.pca_on_psths(PSTHs.dynamic, 'observed', true, 'conditions', conditions);
Score.dynamic = M23a.pca_on_psths(PSTHs.dynamic, 'observed', false, 'conditions', conditions);
Score.static = M23a.pca_on_psths(PSTHs.static, 'observed', false, 'conditions', conditions);
%%
Specs = M23a.specify_PSTH_PCA;
figure('position', Specs.figureposition)
panels = 'abc';
datatypes = string(fieldnames(Score)');
for d = 1:numel(datatypes)
    subplot(1,numel(datatypes),d)
    M23a.stylizeaxes
    set(gca, 'dataaspectratio', [1,1,1], ...
        'outerposition', [Specs.axes_outerposition_left+Specs.axes_outerposition_width*(d-1), ...
        0, Specs.axes_outerposition_width, 1])
    datatype= datatypes(d);
    conditions = string(fieldnames(Score.(datatype))');
    for k = 1:2
        if sum(Score.(datatype).leftchoice(:,k)) > 0 && ...
           sum(Score.(datatype).rightchoice(:,k)) < 0
            Score.(datatype).leftchoice(:,k) = Score.(datatype).leftchoice(:,k)*-1;
            Score.(datatype).rightchoice(:,k) = Score.(datatype).rightchoice(:,k)*-1;
        end
    end
    for condition = conditions
        plot(Score.(datatype).(condition)(:,1), Score.(datatype).(condition)(:,2), ...
            'linewidth', 2, 'color', colors.(condition))
        for i = 1:numel(timemarkers)
            t = timemarkers(i);
            plot(Score.(datatype).(condition)(t,1), Score.(datatype).(condition)(t,2), Specs.markers{i}, ...
                'markersize', 10, 'linewidth', 1, 'color', Specs.colors.(condition))
        end
    end
    title(char(datatype))
    limx = 250;
    limy = 75;
    xlim([-limx, limx])
    ylim([-limy, limy])
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
    annotation("textbox", [0.03+(d-1)*Specs.outerpositionx*1.07 0.55 .3 .3], 'string', panels(d), ...
        'edgecolor', 'none', 'fontsize', get(gca, 'fontsize')*1.5)
end
handles = get(gca, 'Children');
hlegend = legend(handles([8,4,7,6,5]), {'left choice', 'right choice', 't = 0 s', 't = 0.33 s', 't = 1 s'}) ;
set(hlegend, 'position', [0.65 0.45, 0.1, 0.12]);
scriptpath = matlab.desktop.editor.getActiveFilename;
[folderpath, graphicname] = fileparts(scriptpath);
[~, foldername] = fileparts(folderpath);
M23a.savegraphic(graphicname, foldername);
