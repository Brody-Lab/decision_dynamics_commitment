function [] = examine_weber_params(varargin)
% loads data from psychometric sessions both before and after lesion and
% plots weber as a function of different parameters on which it depends
% (xcomm, xmid, xfin, bfit, etc.,).
% Use this script to examine any concerns with weber ratio calculation.

pairs = { ...
'ratname','Hare' ;...    
'before_file', 'psych_before'; ...
'after_file', 'psych_after'; ...
'psychthresh',1 ; ...
'BEFORE_COL',1;...
'AFTER_COL',2;...
'firstfew',1000;...
};

parse_knownargs(varargin,pairs);

fnames = {'discriminability_points','overall_webers','webers','bfits','bias_cell','proportions','cpoke_dur','apoke_dur',...
    'sessdates','means_hh_cell','sem_hh_cell','lds_cell', 'vanilla_cell','psych_cell','vanilla_hits','psych_hits','pdates'};
for f = 1:length(fnames)
    eval([ fnames{f} ' = {[] []};']);
end;

   loadpsychinfo(ratname, 'infile', before_file, 'justgetdata',1,'psychthresh',psychthresh);
    f=gcf;

    % ---------------------------------------------------------------------
    % Collect data from before
    % ---------------------------------------------------------------------

    weber = weber';
    bias_val = bias_val';
    means_hh = means_hh';
    sem_hh = sem_hh';

    discriminability_points{:,BEFORE_COL} = horzcat(xcomm', xmid', xfin');
    bfits{:,BEFORE_COL} = bfit;
    webers{:,BEFORE_COL} = weber;
    means_hh_cell{:,BEFORE_COL} = means_hh;
    sem_hh_cell{:,BEFORE_COL} = sem_hh;
    lds_cell{:,BEFORE_COL} = lds;
    sessdates{:,BEFORE_COL} = dates;
    overall_webers{:,BEFORE_COL}=overall_weber;
    pdates{:,BEFORE_COL}=psychdates;

    
     loadpsychinfo(ratname, 'infile', after_file, 'justgetdata',1,'psychthresh',psychthresh,'firstfew',firstfew);
    set(gcf,'Position',[250 250 800 600],'Tag','psych');
    weber = weber';
    bias_val = bias_val';
    means_hh = means_hh';
    sem_hh = sem_hh';

        % ---------------------------------------------------------------------
    % Collect data from after
    % ---------------------------------------------------------------------

    
%     discriminability_points{:,AFTER_COL} = horzcat(xcomm', xmid', xfin');
%     bfits{:,AFTER_COL} = bfit;
%     webers{:,AFTER_COL} = weber;
%     bias_cell{:,AFTER_COL} = bias_val;
%     cpoke_dur{:,AFTER_COL} = cpoke_stats;
%     apoke_dur{:,AFTER_COL} = apoke_stats;
%     means_hh_cell{:,AFTER_COL} = means_hh;
%     sem_hh_cell{:,AFTER_COL} = sem_hh;
%     lds_cell{:,AFTER_COL} = lds;
%     sessdates{:,AFTER_COL} = dates;
%     overall_webers{:,AFTER_COL} = overall_weber;
%    pdates{:,AFTER_COL}=psychdates;
    
    figure;
    tmp = pdates{:,BEFORE_COL}; short={};
    for t =1:length(tmp), blah= tmp{t}; short{end+1} = blah(end-3:end-1);end;
    plot(1:length(webers{:,BEFORE_COL}),webers{:,BEFORE_COL},'or');
    set(gca, 'XTick',1:length(webers{:,BEFORE_COL}),'XTickLabel', short);
 
    
    
    