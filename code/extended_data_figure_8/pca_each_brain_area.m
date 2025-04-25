[PSTHs, brainareas] = M23a.gather_PSTHs_for_PCA;
%%
Specs = M23a.specify_PSTH_PCA;
conditions = ["leftchoice", "rightchoice"];
for a = 1:numel(Specs.brainareas)
    neuronindices = brainareas == Specs.brainareas(a);
    Score.observed = M23a.pca_on_psths(PSTHs.dynamic(neuronindices), 'observed', true, 'conditions', conditions);
    Score.dynamic = M23a.pca_on_psths(PSTHs.dynamic(neuronindices), 'observed', false, 'conditions', conditions);
    Score.static = M23a.pca_on_psths(PSTHs.static(neuronindices), 'observed', false, 'conditions', conditions);
    datatypes = string(fieldnames(Score)');
    figure('position', Specs.figureposition)
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
        set(gca, 'position', pos);
            if a == 1 && d == 1
                annotation("textbox", [0.03+(d-1)*Specs.axes_outerposition_width*1.07 0.6 .3 .3], 'string', 'a', ...
                    'edgecolor', 'none', 'fontsize', get(gca, 'fontsize')*1.5)
            end
        datatype= datatypes(d);    
        for condition = conditions
            plot(Score.(datatype).(condition)(:,1), Score.(datatype).(condition)(:,2), ...
                'linewidth', 2, 'color', Specs.colors.(condition))
            for i = 1:numel(Specs.timemarkers)
                t = Specs.timemarkers(i);
                plot(Score.(datatype).(condition)(t,1), Score.(datatype).(condition)(t,2), Specs.markers{i}, ...
                    'markersize', 10, 'linewidth', 1, 'color', Specs.colors.(condition))
            end
        end
        title(' ')
        xlabel(' ')
        ylabel(' ')
        if a == 1
            title(char(datatype))
            if d == 1
                ylabel('PC 2 proj.')
            end
        elseif a== numel(Specs.brainareas) &&  d== 1
            xlabel('                             projections onto first principal component (PC 1)')            
        end
        xticks(0)
        yticks(0)
        if a > 1 || d > 1
            xticklabels({' '})
            yticklabels({' '})
        end
    end    
    linkaxes(ax)
    limx = max(abs(xlim));
    xlim([-limx, limx])
    limy = max(abs(ylim));
    ylim([-limx/3, limx/3])
    if a == 1
        handles = get(gca, 'Children');
        hlegend = legend(handles([8,4,7,6,5]), {'left choice', 'right choice', 't = 0 s', 't = 0.33 s', 't = 1 s'}) ;
        set(hlegend, 'position', [0.8 0.45, 0.1, 0.12]);
    end
    annotation("textbox", [0.67 0.3 .3 .3], 'string', char(Specs.brainareas(a)), ...
                'color', Specs.colors.(Specs.brainareas(a)), ...
                    'edgecolor', 'none', 'fontsize', get(gca, 'fontsize'))
    scriptpath = matlab.desktop.editor.getActiveFilename;
    [folderpath, graphicname] = fileparts(scriptpath);
    [~, foldername] = fileparts(folderpath);
    M23a.savegraphic([graphicname '_' char(Specs.brainareas(a))], foldername);
end
close all