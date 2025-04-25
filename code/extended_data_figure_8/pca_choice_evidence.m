PSTHs = M23a.gather_PSTHs_for_PCA;
%%
conditions = ["leftchoice_weak_leftevidence", "leftchoice_strong_leftevidence", ...
    "rightchoice_weak_rightevidence", "rightchoice_strong_rightevidence"];
Score = struct;
Score.observed = M23a.pca_on_psths(PSTHs.dynamic, 'observed', true, 'conditions', conditions);
Score.dynamic = M23a.pca_on_psths(PSTHs.dynamic, 'observed', false, 'conditions', conditions);
Score.static = M23a.pca_on_psths(PSTHs.static, 'observed', false, 'conditions', conditions);
%%
Specs = M23a.specify_PSTH_PCA;
figure('position', Specs.figureposition)
datatypes = string(fieldnames(Score)');
for d = 1:numel(datatypes)
    subplot(1,numel(datatypes),d)
    M23a.stylizeaxes
    set(gca, 'dataaspectratio', [1,1,1], ...
        'outerposition', [Specs.axes_outerposition_left+Specs.axes_outerposition_width*(d-1), ...
        0, Specs.axes_outerposition_width, 1])
    datatype= datatypes(d);
    conditions = string(fieldnames(Score.(datatype))');
    for condition = conditions
        set(gca, 'dataaspectratio', [1,1,1])
        plot(Score.(datatype).(condition)(:,1), Score.(datatype).(condition)(:,2), ...
            'linewidth', 2, 'color', colors.(condition))
        for i = 1:numel(timemarkers)
            t = timemarkers(i);
            plot(Score.(datatype).(condition)(t,1), Score.(datatype).(condition)(t,2), markers{i}, ...
                'markersize', 10, 'linewidth', 1, 'color', colors.(condition))
        end
    end
    title(char(datatype))
    limx = 300;
    limy = 125;
    xlim([-limx, limx])
    ylim([-limy, limy])
    xticks(0)
    yticks(0)
    if d == 1
        xlabel('                             projections onto first principal component (PC 1)')
        ylabel('PC 2 proj.')
        annotation("textbox", [0.03+(d-1)*outerpositionx*1.07 0.6 .3 .3], 'string', 'c', ...
        'edgecolor', 'none', 'fontsize', get(gca, 'fontsize')*1.5)
    else
        xlabel(' ')
        ylabel(' ')
        xticklabels({' '})
        yticklabels({' '})
    end
end
handles = get(gca, 'Children');
hlegend = legend(handles([12,16,8,4,11,10,9]), {'strong left evidence', 'weak left evidence', ...
'strong right evidence', 'weak right evidence', 't = 0 s', 't = 0.33 s', 't = 1 s'}) ;
set(hlegend, 'position', [0.68 0.45, 0.1, 0.15]);
scriptpath = matlab.desktop.editor.getActiveFilename;
[folderpath, graphicname] = fileparts(scriptpath);
[~, foldername] = fileparts(folderpath);
M23a.savegraphic(graphicname, foldername);
