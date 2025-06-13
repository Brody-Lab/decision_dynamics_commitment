function [sets] = show_vanilla_sets(shortest, longest, varargin)

pairs = {'good_diff', [] ; ...
    'bad_diff', []  ; ...
    'header', ''; ...
    'unclear', [] ; ...
    'pitches', 0 ; ...
    'base2', 0 ; ...
    'plotme', 1 ; ...
    'diffset_wide', [1 0.9 0.8 0.7 0.5 0.45 0.4 0.3 0.25 0.2] ; ...
    'diffset_zoom',  [1 0.5 0.3 0.25 0.2 0.15 0.1 0.05]; ...
    'diffset_pitches', [3 2.5 1.5 1 0.8 0.7 0.6 0.5]; ...
    'diffset_all', 1:-0.05:0.05; ...
    'diffset_all_pitches', 2:-0.1:0.1;
    'gimme_all', 0 ; ...
    };
parse_knownargs(varargin, pairs);

if base2, 
    if gimme_all, diffset = diffset_all_pitches;
    else
        diffset = diffset_pitches;
    end;
elseif gimme_all, diffset = diffset_all;
else diffset = diffset_wide;
end;

if base2
    logdiff = log2(longest) - log2(shortest);
    mp = log2(sqrt(shortest*longest));
else
    logdiff = log(longest) - log(shortest);
    mp = log(sqrt(shortest*longest));
end;

if plotme, diffset = [logdiff diffset]; end;

maxie = (2*(length(diffset)+1))+1;
if plotme
    y_val = 3.1;
    figure('Position',[100 100 900 150], 'Toolbar', 'none', 'Menubar', 'none');

    line([1 maxie], [3 3]);
    mid = length(diffset)+2;
    line([mid mid], [3 y_val]);

    if pitches, fmt = '%2.1f'; hdr = 'pitches'; else, fmt = '%3.0f'; hdr = 'durations'; end;
    text(mid-(1/length(diffset)), y_val+0.2, sprintf(fmt, exp(mp)), 'FontWeight','bold', 'FontSize',14);
    text(0.2, y_val+0.2, hdr,'FontAngle','Italic','FontSize',14);
end;

xticks = [];

for k = 1:length(diffset)
    if base2
        lower = 2^(mp-(diffset(k)/2)); higher = 2^(mp+(diffset(k)/2));
    else
        lower = exp(mp-(diffset(k)/2)); higher = exp(mp+(diffset(k)/2));
    end;

    if plotme
        back = length(diffset)-(k-1);
        line([mid-k mid-k], [3 y_val]);
        xticks = [xticks mid-k];
        t= text(mid-back-(1/length(diffset)), y_val+0.1, sprintf(fmt, lower));
        set(t, 'FontSize',14);

        line([mid+k mid+k], [3 y_val]);
        xticks = [xticks mid+k];
        t2 = text(mid+back-(1/length(diffset)), y_val+0.1, sprintf(fmt, higher));
        set(t2, 'FontSize',14);

        if k==1,
            set(t, 'Color','b', 'FontWeight','bold', 'FontSize',12);
            set(t2,'Color','b', 'FontWeight','bold', 'FontSize',12);
        end;
        if ismember(diffset(k),good_diff)
            set(t, 'Color',[0.2 0.4 0], 'FontWeight','bold', 'FontAngle','italic', 'FontSize',14);
            set(t2, 'Color',[0.2 0.4 0], 'FontWeight','bold','FontAngle','italic', 'FontSize',14);
        elseif ismember(diffset(k), bad_diff)
            set(t, 'Color',[0.6 0 0], 'FontWeight','bold', 'FontAngle','italic', 'FontSize',14);
            set(t2, 'Color',[0.6 0 0], 'FontWeight','bold','FontAngle','italic', 'FontSize', 14);
        elseif ismember(diffset(k), unclear)
            text(mid-back-(1/(2*length(diffset))), y_val+0.2, '?', 'FontSize',11, 'FontWeight','bold', 'Color', [0.6 0 0]);
            text(mid+back-(1/(2*length(diffset))), y_val+0.2, '?', 'FontSize', 11, 'FontWeight','bold', 'Color', [0.6 0 0]);
        end;

    end;
    sets(k,1:3) = [lower higher diffset(k)];
end;

if plotme
    xticks = sort(xticks);
    xticklbls = [diffset diffset(end:-1:1)];
    xtcell = cell(0,0);
    for k=1:length(xticklbls), xtcell{k} = sprintf('%1.2f',xticklbls(k)); end;
    axis([0 maxie 2.8 y_val+0.3]);
    set(gca, 'YTick', [], 'XTickLabel', xtcell, 'XTick', xticks, 'FontSize', 12)
    if base2, lbl = 'Log2 Difference'; else, lbl = 'Log difference'; end;
    if pitches, ylbl = 'Pitches (KHz)'; else ylbl = 'Duration values (ms)'; end;
    t = xlabel(lbl); set(t, 'FontSize', 12, 'FontWeight', 'bold');
    t = ylabel(ylbl); set(t, 'FontSize', 12, 'FontWeight','bold');

    %t = text(1, 2.95, '80+%');
    %set(t,'Color', [0.2 0.4 0], 'FontSize',12, 'FontWeight', 'bold','FontAngle','italic');
    %t2 = text(3, 2.95, '<80%', 'FontSize',12, 'FontWeight', 'bold','FontAngle','italic');
    %set(t2, 'Color', [0.6 0 0]);

    if ~strcmp('header','')
        title(header);
    end;

end;




