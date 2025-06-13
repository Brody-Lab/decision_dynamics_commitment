function [outdata] = spl_influence_run(varargin)

% Does batch analysis of duration rats to determine if any of them is
% influenced by tone SPL
% Runs spl_influence for each rat for the given bracket of dates

pairs = { ...
    'action', 'load' ; ... % [save | load]
    'area_filter', 'ACx'; ...
    'array_name', 'duration_psych'; ...
    'typeoftest','twotailed' ; ...
    };

parse_knownargs(varargin,pairs);

ratlist = rat_task_table('','action',['get_' array_name],'area_filter',area_filter);

switch action
    case 'save'
        fprintf(1,'Saving data for %i rats (Set = %s, Filter= %s)\n', length(ratlist),array_name, area_filter);
        for r = 1:length(ratlist)
            ratname = ratlist{r};
            if ~(strcmpi(ratname, 'Jabber') || strcmpi(ratname,'Bilbo'))
                fprintf(1,'\tSaving for %s...\n', ratname);
                spl_influence(ratname, 'action','save','use_dateset','psych_before','typeoftest', typeoftest);
                spl_influence(ratname, 'action','save','use_dateset','psych_after','typeoftest', typeoftest);
            end;
        end;

    otherwise
        before_sig = [];
        after_sig = [];
        for r = 1:length(ratlist)
            ratname = ratlist{r};
            if ~(strcmpi(ratname, 'Jabber') || strcmpi(ratname,'Bilbo'))
                [sl sr]=spl_influence(ratname, 'use_dateset','psych_before',...
                    'action','load','typeoftest',typeoftest);
                title(sprintf('%s:SPL influence BEFORE', ratname));
                before_sig = vertcat(before_sig, [sl sr]);

                [sl sr]=spl_influence(ratname, 'use_dateset','psych_after',...
                    'action','load','typeoftest',typeoftest);
                title(sprintf('%s:SPL influence AFTER', ratname));
                after_sig = vertcat(after_sig,[sl sr]);
            end;
        end;

        ar = strrep(array_name, '_', ' ');
        make_patch(ratlist, before_sig);
        title(sprintf('Set: %s, Area: %s: SPL Influence - BEFORE',ar, area_filter));

        make_patch(ratlist, after_sig);
        title(sprintf('Set: %s, Area: %s: SPL Influence - AFTER', ar, area_filter));
end;

function [] = make_patch(ratlist, sig)
% plot significance
figure; set(gcf,'Position', [400 400 400 250],'Toolbar','none');
rlist = {};
for r = 1:length(ratlist)
    ratname = ratlist{r};
    if ~(strcmpi(ratname, 'Jabber') || strcmpi(ratname,'Bilbo'))
        rlist{end+1} = ratname;
        clr = [0.4 0.4 0.4];
        if sig(r,1) > 0, clr = 'r';end;
        patch([1 1 2 2], [r r+1 r+1 r], clr);
        clr = [0.4 0.4 0.4];
        if sig(r,2) > 0, clr = 'r';end;
        patch([2 2 3 3], [r r+1 r+1 r],clr);
    end;
end;

set(gca,'YTick',1.5:length(rlist)+0.5, 'YTickLabel',rlist, 'XTick',[1.5 2.5], 'XTickLabel', ...
    {'On reporting "LEFT"', 'On reporting "RIGHT"'});
