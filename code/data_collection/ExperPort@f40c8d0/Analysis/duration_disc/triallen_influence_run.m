function [outdata] = triallen_influence_run(varargin)

% Does batch analysis of duration rats to determine if any of them is
% influenced by trial length
% Runs triallen_influence for each rat for the given bracket of dates

%outdata = {'ratname', 'logdiff', 'Short_corrcoef', 'Long_corrcoef', 'S_slope', 'S_monoton_dist', 'L_slope','L_monoton_dist'};

pairs = { ...
    'action', 'load' ; ... % [save | load]
    'area_filter', 'ACx'; ...
    'array_name', 'duration_psych'; ...
    };...
parse_knownargs(varargin,pairs);

ratlist = rat_task_table('','action',['get_' array_name],'area_filter',area_filter);

switch action
    case 'save'
        fprintf(1,'Saving data for %i rats (Set = %s, Filter= %s)\n', length(ratlist),array_name, area_filter);
        for r = 1:length(ratlist)
            ratname = ratlist{r};
            fprintf(1,'\tSaving for %s...\n', ratname);
            triallen_influence(ratname, 'action','save','use_dateset','psych_before');
            triallen_influence(ratname, 'action','save','use_dateset','psych_after');
        end;
    case 'rename'
        
global Solo_datadir;
     for r = 1:length(ratlist)
            ratname = ratlist{r};
            fprintf(1,'\tRenaming for %s...\n', ratname);
            outdir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep ratname filesep ];
            if ~exist(outdir, 'dir'), error('Directory does not exist!:\n%s\n', outdir); end;
            
            % BEFORE
            fname = [outdir 'psych_before'];
            load(fname);
            
            new_fname = [outdir 'triallen_psych_before.mat'];
                save(new_fname, 'MinValidPokeDur','MaxValidPokeDur', 'Min_2_GO',...%'VPDSetPoint', ...
            'Max_2_GO', 'dur_short','dur_long',...
            'psych','vpd','prechord','logdiff', ...
            'sides', 'numtrials','hit_history','dates');
        
            % AFTER
            fname = [outdir 'psych_after'];
            load(fname);
            
            new_fname = [outdir 'triallen_psych_after.mat'];
                save(new_fname, 'MinValidPokeDur','MaxValidPokeDur', 'Min_2_GO',...%'VPDSetPoint', ...
            'Max_2_GO', 'dur_short','dur_long',...
            'psych','vpd','prechord','logdiff', ...
            'sides', 'numtrials','hit_history','dates');
        
        end;

    
    otherwise
        for r = 1:length(ratlist)
            ratname = ratlist{r};
            triallen_influence(ratname, 'use_dateset','psych_before','action','load');
            title(sprintf('%s: Trial length influence BEFORE', ratname));

            triallen_influence(ratname, 'use_dateset','psych_after','action','load');
            title(sprintf('%s: Trial length influence AFTER', ratname));

        end;
end;