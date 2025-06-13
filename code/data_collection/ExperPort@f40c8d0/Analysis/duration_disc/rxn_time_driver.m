function  [sig_struct] = rxn_time_driver(varargin)
% Driver file to collect and analyze reaction time data across rats

pairs =  { ...
    'action', 'load' ; ... % one of:|save|load]
    'ratlist', ''; ...     % list of rats for which to aggregate data
    'outfile', 'rxntime_with_sides'; ... % file to save data to / load from
    'experimenter','Shraddha'; ...
    % -------- Filters & params which affect the data calculation -------------------
    'rxntime_measure', 'offset2cout' ; ... % one of [offset2cout | onset2cout | cin2cout ]; see tone_rxntime.m for meaning of different options.
    'psych_only', 1 ; ... % when set, only stores data for psychometric trials
    'filter_by_task', ''; ... % set to ONE of: 1) 'd' for duration only, 2) 'p' for pitch only, 3) '' (blank) for both
    'filter_trialtype', 'hit'; ... % set to ONE of: 1) '' (blank) hits and misses, 2) 'hit': correct trials only, 3) 'miss': incorrect trials only
    'compare_firstlast', 1; ... % when set, does significance test to compare first bin to last
    'remove_bobs', 1 ; ... % when set, removes those trials where animal bobbed once during the trial.
    'numbins', 16 ; ...
    'LEFT_SIDE', 1 ; ... % value for "left" side in protocols
    'RIGHT_SIDE', 0 ; ... % value for "right" side in protocols
    %--------  Which plots to show -----------------------
    'show_difference_plot', 0 ; ... % graph where each point is the average DIFFERENCE in adjacent bins of binned reaction time
    'show_average_rxntime', 0 ; ... % graph where each point is the average BINNED REACTION TIME
    'show_individual_rxntimes', 1 ; ... % graph showing ALL reaction times for ALL tones
    'show_sig_chart', 0 ; ... % graph showing significance value of reaction times in adjacent bins ~= 0.
    'show_side_dependence', 0 ; ... % plots rxntime versus side choice
    'show_cpoke_dependence', 0 ; ...% plots rxntime versus center poke length
    'show_rxntime_sidechoice', 0 ; ... % plots "% left" as fn of rxn time
    % ------- Appearance --------
    'duration_colour', [153 214 227] ./255; ...
    'pitch_colour', [245 194 219] ./255 ; ...
    'duration_mp', sqrt(200*500); ...
    'pitch_mp', sqrt(8*16) ; ...
    };
parse_knownargs(varargin,pairs);

global Solo_rootdir;
global Solo_datadir;
if isempty(Solo_rootdir), mystartup; end;
stat_dir = [Solo_rootdir filesep 'Analysis' filesep 'duration_disc' filesep 'stat_sandbox'];
event_analysis_dir = [Solo_rootdir filesep 'Analysis' filesep 'duration_disc' filesep 'Event_Analysis'];

if ~is_in_path(stat_dir)
    fprintf(1,'Adding stat_sandbox to path ...\n');
    addpath(stat_dir);
    addpath(event_analysis_dir);
end;


outdir = [Solo_datadir filesep 'Data' filesep experimenter filesep];
%fname = [outdir 'logdiff_data_' from '_' to '.mat'];
fname = [outdir outfile '.mat'];

switch action
    case 'save'

        sig_struct = {}; % key = rat, value = sig array

        for r = 1:1%length(ratlist)
            ratname = ratlist{r};
            fprintf(1,'%s:', ratname);
            ratrow = rat_task_table(ratname);
            if strcmpi(ratname, 'Jabber')
                prepsych = { '070410','070418'};
            else
                %prepsych = {'070725','070728'};
                prepsych = ratrow{1,4};
            end;
            %    tone_rxntime(ratname,'from','070801', 'to','070808','separate_hit_miss',1,'numbins',0);
            [binned_tones binned_rxn tone_indie rxn_indie sides_indie cpoke_indie sig ...
                dropped_bobs too_many_bobs is_bob] = tone_rxntime(ratname,'from',prepsych{1}, 'to',prepsych{2}, ...
                'psych_only',psych_only,'separate_hit_miss',1, 'rxntime_measure', rxntime_measure, ...
                'compare_firstlast',compare_firstlast,'remove_bobs',remove_bobs);

            tmp = {binned_tones binned_rxn tone_indie rxn_indie sides_indie cpoke_indie dropped_bobs ...
                too_many_bobs is_bob sig};
            eval(['sig_struct.' ratname ' = tmp;']);
            fprintf(1,'\n');
        end;

        column_header = {'Bin centers for tones', 'Binned reaction times', 'Individual tones', ...
            'Individual reaction times', 'Individual side choice', 'Individual valid center pokes', ...
            'Trials with no valid or bobbed pokes', 'Trials with too many bobs', 'Trials with 1 bob', 'Bob trial?', ...
            'Significance test results'};
        save(fname, 'sig_struct', 'column_header');

        %    save sig_struct.mat sig_struct column_header;

    case 'load'

        % Print options used
        dash = '-'; dash = repmat(dash,1,100);
        fprintf(1,'%s\nOptions:\n ',dash);
        fprintf(1,'\tTones are binned into:\t%i bins\n', numbins);
        fprintf(1,'\tTask filter:\t%s\n', filter_by_task);
        fprintf(1,'\tTrial type filter:\t%s\n', filter_trialtype);
        fprintf(1,'\tPsychometric-only filter:\t%i\n', psych_only);
        fprintf(1,'\tRemoving trials with bobs\t%i\n', remove_bobs);
        fprintf(1,'\tSig chart: Comparing first and last bins?:\t%i\n',compare_firstlast);
        fprintf(1,'%s\n\n ',dash);



        if show_average_rxntime
            if ~strcmpi(filter_by_task,'p')
                figure;
                set(gcf,'Tag', 'duration_binned_tones');
            end;
            if ~strcmpi(filter_by_task, 'd')
                figure;
                set(gcf,'Tag', 'pitch_binned_tones');
            end;
        end;
        if show_sig_chart
            figure;
            set(gcf,'Tag','sig_chart');
        end;

        % struct which collect data:
        [sig_struct indie_tones_allrats, indie_rxns_allrats, indie_sides_allrats, indie_cpokes_allrats,...
            duration_tally, pitch_tally, ...
            dropped_bobs, too_many_bobs bob_trials] = ...
            sub_getdata(fname,show_sig_chart,compare_firstlast, remove_bobs);

        % describe bob data
        tmp = indie_sides_allrats.duration; numtrials = length(tmp.hit) + length(tmp.miss);
        fprintf(1,'Bobbing happens in %i of %i duration trials\n', bob_trials+length(too_many_bobs), numtrials);


        % ---------------------------------------------------------
        % Initialize all the figures
        % ---------------------------------------------------------
        if show_sig_chart
            % format sig_chart
            set(0,'CurrentFigure',findobj('Tag','sig_chart'));
            set(gcf,'Position',[22 470 474 257],'Toolbar','none');
            xlabel('Logdiffs');
            ylabel('Rats');
            set(gca,'YTick',0.5:rows(ratlist)-0.5, 'YTickLabel',fieldnames(sig_struct),'YLim',[0 rows(ratlist)]);
            hold on;
        end;

        % format bin figures
        if show_average_rxntime

        end;

        % individual reaction times with graph of averages superimposed
        % thereon
        if show_individual_rxntimes
            rxngraph__show_individual_rxntimes(filter_by_task, filter_trialtype, indie_tones_allrats, indie_rxns_allrats, numbins,...
                duration_tally, pitch_tally, duration_mp, pitch_mp,duration_colour, pitch_colour);
        end;

        % show tone-versus reaction split into series of 'Left choice' and
        % 'Right choice'
        if show_side_dependence
            rxngraph__show_side_dependence(filter_by_task, filter_trialtype, indie_tones_allrats, indie_sides_allrats, indie_rxns_allrats, numbins, ...
                duration_tally, pitch_tally,duration_mp, pitch_mp,duration_colour, pitch_colour,LEFT_SIDE, RIGHT_SIDE);
        end;

        if show_cpoke_dependence
            rxngraph__show_cpoke_dependence(filter_by_task, indie_tones_allrats, indie_cpokes_allrats, indie_rxns_allrats, numbins, ...
                duration_tally, pitch_tally,duration_mp, pitch_mp,duration_colour, pitch_colour);
            cpokes_tmp = indie_cpokes_allrats;
            ch = cpokes_tmp.duration.hit;
            cpokes_tmp.duration.hit = ch(:,2)-ch(:,1);
            ch = cpokes_tmp.duration.miss;
            cpokes_tmp.duration.miss = ch(:,2)-ch(:,1);

            rxngraph__show_rxntime_sidechoice(indie_tones_allrats, cpokes_tmp, indie_sides_allrats, ...
                numbins, duration_tally, duration_mp, duration_colour, LEFT_SIDE, RIGHT_SIDE,outfile);
        end;

        % show '% left' as function of rxntime
        if show_rxntime_sidechoice
            rxngraph__show_rxntime_sidechoice(indie_tones_allrats, indie_rxns_allrats, indie_sides_allrats, ...
                numbins, duration_tally, duration_mp, duration_colour, LEFT_SIDE, RIGHT_SIDE,outfile)
        end;

    otherwise
        error('Invalid action');
end;


% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% Helper functions
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------


% given the array of hit & miss tones, returns the average hit rate for
% each binned tone
function [x means sem] = get_bin_perf(indie_tones, numbins)

mega_tones = vertcat(indie_tones.hit, indie_tones.miss);
mega_hh = vertcat(ones(size(indie_tones.hit)), zeros(size(indie_tones.miss)));

[x means sem] = bin_hits(mega_tones, numbins, mega_hh,'multfactor',1);


% loads data into a number of structs that are then used for plotting
function [sig_struct, indie_tones_allrats, indie_rxns_allrats, indie_sides_allrats, indie_cpokes_allrats, ...
    duration_tally, pitch_tally, dropped_bobs_all, too_many_bobs_all, bob_trials is_bob_all] = sub_getdata(fname,...
    show_sig_chart,compare_firstlast, remove_bobs)

% struct which collect data:
% rxn_differences:
% rxn_cum
% tones_allrats
% rxns_allrats
% with 'duration' and 'pitch' as keys. The values have arrays
% pertaining only to the corresponding task type (duration_disc or
% dual_Disc)
rxn_differences.duration = []; % row i is set of (rxn_J - rxn_J-1) for all rats
rxn_differences.pitch = [];

rxn_cum.duration = []; % average reaction time for each tone bin; each row per rat
rxn_cum.pitch =[];

duration_tally = 0;
pitch_tally = 0;

% binned_data = { ...
%     'rxn_differences', ...
%     'rxn_cum', ...
%     'binned_tones', ...
%     'binned_rxn', ...
%     };
% for d = 1:length(binned_data)
%     eval([binned_data{d} '.duration = [];');
%     eval([binned_data{d} '.duration.hit = [];');
%     eval([binned_data{d} '.duration.miss = [];');
%     eval([binned_data{d} '.pitch = [];');
%     eval([binned_data{d} '.pitch.hit = [];');
%     eval([binned_data{d} '.pitch.miss = [];');
% end;

datatypes = {
    'tones',... % tone param (duration/pitch)
    'rxns',...  % rxn time
    'sides',... % side choice (1 - left, 0 -right)
    'cpokes'... % valid cpokes
    };
for d = 1:length(datatypes)
    eval(['indie_' datatypes{d} '_allrats.duration = [];']);
    eval(['indie_' datatypes{d} '_allrats.duration.hit = [];']);
    eval(['indie_' datatypes{d} '_allrats.duration.miss = [];']);
    eval(['indie_' datatypes{d} '_allrats.pitch = [];']);
    eval(['indie_' datatypes{d} '_allrats.pitch.hit = [];']);
    eval(['indie_' datatypes{d} '_allrats.pitch.miss = [];']);
end;

load(fname);
fnames = fieldnames(sig_struct);

bob_trials = 0;
dropped_bobs_all = [];
too_many_bobs_all=[];
is_bob_all = [];
% compile data - iterating over rats - into
for r = 1:length(fnames)
    rnum = r;
    eval(['mystruct = sig_struct.' fnames{r} ';']);

    % buffer saved data into variables
    %         tmp = {binned_tones binned_rxn tone_indie ...
    % rxn_indie sides_indie cpoke_indie
    % dropped_bobs too_many_bobs bob_trial ...
    % sig};
    binned_tones = mystruct{1};
    binned_rxns = mystruct{2};
    indie_tones = mystruct{3};
    indie_rxns = mystruct{4};
    indie_sides = mystruct{5};
    indie_cpokes = mystruct{6};
    dropped_bobs_all = horzcat(dropped_bobs_all, mystruct{7});
    too_many_bobs_all = horzcat(too_many_bobs_all,mystruct{8});
    
    is_bob = mystruct{9}; 
    bob_trials = bob_trials + sum(is_bob.hit) + sum(is_bob.miss);
    tmp = horzcat(is_bob.hit, is_bob.miss);
    is_bob_all = horzcat(is_bob_all, tmp);
    fprintf(1,'\t\t #is_bob_count =%i\n', length(find(tmp > 0)));
    
    sig = mystruct{10};

    datatypes = {'tones','rxns','sides'};
    for d = 1:length(datatypes)
        eval(['if cols(indie_' datatypes{d} '.hit) > 1, indie_' datatypes{d} '.hit = indie_' datatypes{d} '.hit'';end;']);
        eval(['if cols(indie_' datatypes{d} '.miss) > 1, indie_' datatypes{d} '.miss = indie_' datatypes{d} '.miss'';end;']);
    end;
    if cols(indie_cpokes.hit) > 2, indie_cpokes.hit = indie_cpokes.hit';end;
    if cols(indie_cpokes.miss) > 2, indie_cpokes.miss = indie_cpokes.miss';end;

    % now filter by task
    ratrow = rat_task_table(fnames{r});
    tasktype = ratrow{1,2}; 
    if strcmpi(tasktype(1:3), 'dur'), tasktype = 'd'; else tasktype ='p';end;

    %     if (~strcmpi(filter_by_task,'p') && strcmpi(tasktype,'d')) || ...
    %             (~strcmpi(filter_by_task,'d') && strcmpi(tasktype,'p'))
    %
    fprintf(1,'\tinc. %s...\n', fnames{r});

    % Filter data based on rat's task and filter_tasktype
    if strcmpi(tasktype,'p')        % pitch
        figname = 'pitch_binned_tones';

        %             binned_data = {'binned_tones','binned_rxns'};
        %             for d = 1:length(binned_data)
        %                 eval([binned_data{d} '.pitch.hit = ' binned_data{d} '.hit;']);
        %                 eval([binned_data{d} '.pitch.miss = ' binned_data{d} '.miss;']);
        %             end;
        pitch_tally = pitch_tally + 1;

        % individual trial data
        datatypes = {'tones','rxns','sides','cpokes'};
        for d = 1:length(datatypes)
            eval(['indie_' datatypes{d} '_allrats.pitch.hit = vertcat(indie_' datatypes{d} '_allrats.pitch.hit,' ...
                'indie_' datatypes{d} '.hit);']);

            eval(['indie_' datatypes{d} '_allrats.pitch.miss = vertcat(indie_' datatypes{d} '_allrats.pitch.miss,' ...
                'indie_' datatypes{d} '.miss);']);
        end;

    else
        figname ='duration_binned_tones';
        duration_bins = binned_tones;
        duration_tally = duration_tally + 1;
        %
        %             binned_tones.duration.hit = binned_tones.hit * 1000;
        %             binned_tones.duration.miss = binned_tones.miss * 1000;
        %             binned_rxns.duration.hit = binned_tones.hit;
        %             binned_rxns.duration.miss = binned_tones.miss;
        %
        %
        % individual trial data
        datatypes = {'tones','rxns','sides','cpokes'};
        for d = 1:length(datatypes)
            if remove_bobs
                if strcmpi(datatypes{d},'cpokes')
                    tmp = indie_cpokes.hit;
                    tmp = tmp(find(is_bob.hit == 0),:);
                    indie_cpokes.hit = tmp;

                    tmp = indie_cpokes.miss;
                    tmp = tmp(find(is_bob.miss == 0),:);
                    indie_cpokes.miss = tmp;
                else
                    tmp = eval(['indie_' datatypes{d} '.hit;']);
                    tmp = tmp(find(is_bob.hit == 0));
                    eval(['indie_' datatypes{d} '.hit = tmp;']);

                    tmp = eval(['indie_' datatypes{d} '.miss;']);
                    tmp = tmp(find(is_bob.miss == 0));
                    eval(['indie_' datatypes{d} '.miss = tmp;']);
                end;
            end;

            eval(['indie_' datatypes{d} '_allrats.duration.hit = vertcat(indie_' datatypes{d} '_allrats.duration.hit,' ...
                'indie_' datatypes{d} '.hit);']);

            eval(['indie_' datatypes{d} '_allrats.duration.miss = vertcat(indie_' datatypes{d} '_allrats.duration.miss,' ...
                'indie_' datatypes{d} '.miss);']);
        end;
    end;

    %         eval(['binned_rxn = binned_rxn.' filter_trialtype ';']); % look only at reaction times for correct trials
    %         tmp_rxn = binned_rxn(:,1);
    %         binned_diffs = diff(binned_rxn(:,1));
    %         if rows(binned_diffs) > 1, binned_diffs = binned_diffs';end;
    %         if rows(tmp_rxn) > 1, tmp_rxn = tmp_rxn';end;

    if strcmpi(tasktype,'d'), ttype = 'duration'; else ttype = 'pitch'; end;

    %         eval(['rxn_differences.' ttype ' = vertcat(rxn_differences.' ttype ', binned_diffs);']);
    %         eval(['rxn_cum.' ttype ' = vertcat(rxn_cum.' ttype ', tmp_rxn);']);

    % ---------------------------------------------------------
    % Rat-specific graphs
    % -------------------------------------------------------
    % first plot binned_tones for each rat
    %         if show_average_rxntime
    %             set(0,'CurrentFigure',findobj('Tag',figname));
    %             hold on;
    %             eval(['mybins = binned_tones.' filter_trialtype ';']);
    %             plot(mybins, ones(size(mybins)) * r, '.b');
    %         end;

    % now plot the coloured view of significance (sig_chart)
    if show_sig_chart > 0
        set(0,'CurrentFigure',findobj('Tag','sig_chart'));
        for j = 2:length(sig)
            if sig(j) == 0, c = [0 0 0];
            else
                c = [1 0 0]; %cmap(floor(sig(idx)*length(cmap)),:);
            end;

            p=patch([j-1 j-1 j j], [r-1 r r r-1], c);
            set(p,'EdgeColor','w');
        end;
        if compare_firstlast
            if sig(end) == 0, c = [ 0 0 0];
            else
                c = [0 0 1];
            end;
            lent = length(sig);

            p=patch([lent-1 lent-1 lent lent], [r-1 r r r-1], c);
        end;
    end;
end;


function [] = rxngraph__show_averages()
if ~strcmpi(filter_by_task,'p')
    set(0,'CurrentFigure',findobj('Tag','duration_binned_tones'));
    mp = sqrt(200*500);
    line([mp mp], [0 rows(ratlist)+1],'LineStyle',':');
    xlabel('Bin centers (milliseconds)'); ylabel('Individual rats');
    set(gca,'XTickLabel', round(duration_bins*100)/100);
    title('Duration bins');
    set(gcf,'Position',[22  1   407   206],'Toolbar','none','Color', duration_colour);
end;

if ~strcmpi(filter_by_task,'d')
    set(0,'CurrentFigure',findobj('Tag','pitch_binned_tones'));
    mp = sqrt(8*16);
    line([mp mp], [0 rows(ratlist)+1],'LineStyle',':');
    xlabel('Bin centers (KHz)'); ylabel('Individual rats');
    set(gca,'XTickLabel', round(pitch_bins * 100)/100);
    title('Pitch bins');
    set(gcf,'Position',[22  210   407   206],'Toolbar','none','Color',pitch_colour);
end;






function [] = rxngraph__show_individual_rxntimes(filter_by_task, filter_trialtype, indie_tones_allrats, indie_rxns_allrats, numbins, ...
    duration_tally, pitch_tally,duration_mp, pitch_mp,duration_colour, pitch_colour)
ttype_array = {}; % which tasks to plot
if ~strcmpi(filter_by_task,'p') && duration_tally > 0, ttype_array{end+1} = 'duration'; figure; set(gcf,'Tag','indiv_duration');end;
if ~strcmpi(filter_by_task,'d') && pitch_tally > 0, ttype_array{end+1} = 'pitch'; figure; set(gcf,'Tag', 'indiv_pitch'); end;

if strcmpi(filter_trialtype,'')
    htype_array = {'hit','miss'};
elseif strcmpi(filter_trialtype,'hit')
    htype_array = {'hit'};
else
    htype_array = {'miss'};
end;

% individual plots for duration and pitch
for r = 1:length(ttype_array)
    eval(['sub_tones_tmp = indie_tones_allrats.' ttype_array{r} ';']);
    eval(['sub_rxns_tmp = indie_rxns_allrats.' ttype_array{r} ';']);

    set(0,'CurrentFigure', findobj('Tag',['indiv_' ttype_array{r}]));
    axes('Position',[0.1 0.1 0.8 0.5]);

    for h = 1:length(htype_array)
        filter_trialtype = htype_array{h};

        eval(['tones_tmp = sub_tones_tmp.' filter_trialtype ';']);
        eval(['rxns_tmp = sub_rxns_tmp.' filter_trialtype '*1000;']);

        [x idx] = sort(tones_tmp);


        if strcmpi(ttype_array{r},'duration')
            tones_tmp = tones_tmp * 1000;
        end;
        [x means sems] = bin_hits(tones_tmp, numbins, rxns_tmp,'multfactor',1);

        % plot individual trial data
        fprintf(1,'Plotting for %s\n', htype_array{h});
        l=plot(tones_tmp(idx), rxns_tmp(idx), '.r');
        set(l, 'Color',[0.7 0.7 0.7]);
        hold on;

        % plot average data
        lstyle = '.r';
        if strcmpi(filter_trialtype,'hit'), lstyle = '.g'; end;
        l=errorbar(x, means,sems, sems,lstyle);
        set(l,'MarkerSize',20);

        mybins = x;
        if strcmpi(ttype_array{r},'duration'), mybins = round(x);
        else mybins = round(x*10)/10; end;
        max_y = percentile(rxns_tmp, 99.5);
    end;

    % plot midpoint
    hold on;
    eval(['mp = ' ttype_array{r} '_mp;']);
    line([mp mp],[0 max_y], 'LineStyle', ':','Color','k','LineWidth',2);

    set(gca,'XTickLabel',mybins, 'XTick',x, 'YLim',[min(0,min(rxns_tmp)), max_y], 'XLim',[mybins(1)*0.85 mybins(end)*1.05]);
    set(gcf,'Toolbar','none','Color',eval([ttype_array{r} '_colour']));
    if strcmpi(ttype_array{r},'duration'),
        xlabel('Tone duration (ms)');
        set(gcf,'Position',[ 932  0   560   420]);
    else
        xlabel('Tone frequency (KHz)');
        set(gcf,'Position',[937   310   560   420]);
    end;
    ylabel('Reaction time (milliseconds)');

    % now plot performance stacked on top of the individual
    % reaction time graph

    f=findobj(gcf,'Tag','perf_view');
    if isempty(f),
        axes('Position',[0.1 0.68 0.8 0.25]);
        set(gca,'Tag','perf_view');
    else
        set(gcf,'CurrentAxes', f);
    end;
    [x means sems] = get_bin_perf(eval(['indie_tones_allrats.' ttype_array{r}]), numbins);
    l=errorbar(mybins, means,sems, sems,'.r');
    hold on;
    line([mp mp],[0 max_y], 'LineStyle', ':','Color','k','LineWidth',2);
    set(l,'MarkerSize',20);

    if strcmpi(ttype_array{r},'duration'), x = x*1000; end;
    if isempty(f)
        set(gca,'XTick',[],'XLim', [x(1)*0.85 x(end)*1.05], 'XGrid','off',...
            'YLim', [0.4 1],'YTick',0.5:0.2:1,'YTickLabel',50:20:100);
        ylabel('% correct');
    end;

    title(sprintf('Success rate (top) and\nreaction time versus tone (bottom) for %s rats', ttype_array{r}));
    %  legend({'Individual',sprintf('Averaged over %i bins',
    %  numbins)});
  
end;


function [] = rxngraph__show_side_dependence(filter_by_task, filter_trialtype, indie_tones_allrats, indie_sides_allrats, indie_rxns_allrats, numbins, ...
    duration_tally, pitch_tally,duration_mp, pitch_mp,duration_colour, pitch_colour,LEFT_SIDE, RIGHT_SIDE)

ttype_array = {}; % which tasks to plot
if ~strcmpi(filter_by_task,'p') && duration_tally > 0, ttype_array{end+1} = 'duration'; end;
if ~strcmpi(filter_by_task,'d') && pitch_tally > 0, ttype_array{end+1} = 'pitch'; end;

% individual plots for duration and pitch
for r = 1:length(ttype_array)
    eval(['sides_tmp = indie_sides_allrats.' ttype_array{r} ';']);
    eval(['tones_tmp = indie_tones_allrats.' ttype_array{r} ';']);
    eval(['rxns_tmp = indie_rxns_allrats.' ttype_array{r} ';']);

    if filter_trialtype
        eval(['tones_tmp = tones_tmp.' filter_trialtype ';']);
        eval(['rxns_tmp = rxns_tmp.' filter_trialtype '*1000;']);
        eval(['sides_tmp = sides_tmp.' filter_trialtype ';']);
    end;

    if strcmpi(ttype_array{r},'duration')
        tones_tmp = tones_tmp * 1000;
    end;

    figure;
    % first plot "went left";
    left_tone = tones_tmp(find(sides_tmp == LEFT_SIDE));
    left_rxn = rxns_tmp(find(sides_tmp == LEFT_SIDE));
    [x idx] =  sort(left_tone);
    [x means sems] = bin_hits(left_tone, numbins, left_rxn,'multfactor',1);

    l=plot(left_tone(idx), left_rxn(idx), '.b'); % individual
    set(l, 'Color',[0.7 0.7 1]);
    hold on;
    l=errorbar(x, means,sems, sems,'.b');        % with mean superimposed
    set(l,'MarkerSize',20);

    % then plot "went right";
    right_tone = tones_tmp(find(sides_tmp == RIGHT_SIDE));
    right_rxn = rxns_tmp(find(sides_tmp == RIGHT_SIDE));
    [x idx] =  sort(right_tone);
    [x means sems] = bin_hits(right_tone, numbins, right_rxn,'multfactor',1);

    l=plot(right_tone(idx), right_rxn(idx), '.r'); %individual
    set(l, 'Color',[1 0.7 0.7]);
    hold on;
    l=errorbar(x, means,sems, sems,'.r');          % with mean superimposed
    set(l,'MarkerSize',20);

    legend({'L(indiv)','L(avg)', 'R(indiv)','R(avg)'});


    hold on;                                       % plot midpoint
    max_y = percentile(rxns_tmp, 99.5);
    eval(['mp = ' ttype_array{r} '_mp;']);
    line([mp mp],[0 max_y], 'LineStyle', ':','Color','k','LineWidth',2);

    % format axes appearance
    [x means sems] = bin_hits(tones_tmp, numbins, rxns_tmp,'multfactor',1);
    mybins = x;
    if strcmpi(ttype_array{r},'duration'), mybins = round(x);
    else mybins = round(x*10)/10; end;

    set(gca,'XTickLabel',mybins, 'XTick',x,'YLim', [0 max_y]);
    set(gcf,'Toolbar','none','Color',eval([ttype_array{r} '_colour']));
    if strcmpi(ttype_array{r},'duration'),
        xlabel('Tone duration (ms)');
        set(gcf,'Position',[ 932  0   560   420]);
    else
        xlabel('Tone frequency (KHz)');
        set(gcf,'Position',[937   310   560   420]);
    end;
    ylabel('Reaction time (milliseconds)');
    title(sprintf('Reaction times separated by side choice (%s)',ttype_array{r}));
    %  legend({'Individual',sprintf('Averaged over %i bins', numbins)});
end;


function [] =  rxngraph__show_cpoke_dependence(filter_by_task, indie_tones_allrats, indie_cpokes_allrats, indie_rxns_allrats, numbins, ...
    duration_tally, pitch_tally,duration_mp, pitch_mp,duration_colour, pitch_colour)

ttype_array = {}; % which tasks to plot
if ~strcmpi(filter_by_task,'p') && duration_tally > 0, ttype_array{end+1} = 'duration'; end;
% individual plots for duration and pitch
for r = 1:length(ttype_array)
    eval(['cpokes_tmp = indie_cpokes_allrats.' ttype_array{r} ';']);
    eval(['tones_tmp = indie_tones_allrats.' ttype_array{r} ';']);
    eval(['rxns_tmp = indie_rxns_allrats.' ttype_array{r} ';']);

    th = tones_tmp.hit; tones_tmp = vertcat(th, tones_tmp.miss); tones_tmp = tones_tmp*1000;% ignore hits and misses
    rh = rxns_tmp.hit; rxns_tmp = vertcat(rh, rxns_tmp.miss); rxns_tmp = rxns_tmp * 1000;% ignore hits and misses
    ch = cpokes_tmp.hit; cpokes_tmp = vertcat(ch, cpokes_tmp.miss); % ignore hits and misses

    clen = cpokes_tmp(:,2) - cpokes_tmp(:,1);

    % show clen based on 'short' or 'long' tones
    short_idx = find(tones_tmp < duration_mp);
    long_idx = find(tones_tmp > duration_mp);


    % graph 1: show cpoke vs rxn time
    figure;
    set(gcf,'Toolbar','none');
    % now on the same graph, show clen for short, versus those for long.
    l=plot(clen(short_idx), rxns_tmp(short_idx), '.b'); % individual
    set(l,'Color',[0.8 0.8 1]);
    hold on;
    l=plot(clen(long_idx), rxns_tmp(long_idx), '.r'); % individual
    set(l,'Color',[1 0.8 0.8]);
    [x means sems] = bin_hits(clen, min(numbins, length(clen)), rxns_tmp,'multfactor',1);
    l=errorbar(x, means,sems, sems,'.k');        % with overall average superimposed

    pct = percentile(rxns_tmp,99);
    set(l,'MarkerSize',20);
    hold on;
    set(gca,'XTick',0:0.2:max(clen)+0.2,'XLim',[0 max(clen)+0.2], 'YLim', [0 pct]);
    xlabel('Center poke length (seconds)');
    ylabel('Reaction time (milliseconds)');
    legend({'tones < mp','tones > mp','Overall avg'});
    title('Reaction time versus center poke');

    if 0
        % Look at cpoke length for missed trials on each side - does there seem
        % to be a dependency of cpoke on side choice?
        cpokes_miss = indie_cpokes_allrats.duration.miss; cpokes_miss = cpokes_miss(:,2)-cpokes_miss(:,1);
        tones_miss = indie_tones_allrats.duration.miss; tones_miss = tones_miss * 1000;
        short_idx = find(tones_miss < duration_mp);
        long_idx = find(tones_miss > duration_mp);

        short_cpokes_miss =cpokes_miss(short_idx);
        long_cpokes_miss =cpokes_miss(long_idx);
        figure;
        l=plot(ones(size(short_cpokes_miss)), short_cpokes_miss, '.b');
        %    set(l,'Color',[0.8 0.8 1]);
        hold on;
        l=plot(ones(size(long_cpokes_miss))*2, long_cpokes_miss, '.r');
        %   set(l,'Color',[1 0.8 0.8]);
        title('Center poke length for MISSED trials');
        legend({'Tones < MP', 'Tones > MP'});
        set(gcf,'Toolbar','none');set(gca,'XTick',[1 2], 'XLim',[0 3], 'XTickLabel', {'"Short" Miss', '"Long" Miss'});
    end;


end;

% shows "% left" as function of rxn time
% currently works only for duration
function [] = rxngraph__show_rxntime_sidechoice(indie_tones_allrats, indie_rxns_allrats, indie_sides_allrats, ...
    numbins, duration_tally, duration_mp, duration_colour, LEFT_SIDE, RIGHT_SIDE,fname)

rxns_tmp = indie_rxns_allrats.duration;
rh = rxns_tmp.hit;
rxns_tmp = vertcat(rh,rxns_tmp.miss);

sides_tmp = indie_sides_allrats.duration;
sh = sides_tmp.hit;
sides_tmp = vertcat(sh, sides_tmp.miss);

tones_tmp = indie_tones_allrats.duration;
th = tones_tmp.hit;
tones_tmp = vertcat(th, tones_tmp.miss);

tones_tmp = tones_tmp*1000;
short_idx = find(tones_tmp < duration_mp);
long_idx = find(tones_tmp > duration_mp);

rxns_tmp = rxns_tmp * 1000; % convert to ms

pctl = [50 75 99];
pct_array = percentile(rxns_tmp, pctl);
pctl_color = {[0.5 0.5 0.5],'w',[0.5 0.5 0.5]};

% calculate % left. Note that since LEFT_SIDE == 1
[xshort means_short sems_short] = bin_hits(rxns_tmp(short_idx), numbins, sides_tmp(short_idx),'multfactor',1);
[xlong means_long sems_long] = bin_hits(rxns_tmp(long_idx), numbins, sides_tmp(long_idx),'multfactor',1);

nlong =     hist(rxns_tmp(long_idx));
nshort =     hist(rxns_tmp(short_idx));
maxie = max(max(nlong), max(nshort));
minnie = -0.1*maxie;
figure;

% plot data percentiles
text(10, -0.05*maxie, 'Percentiles');
for idx =1:length(pct_array)-1
    p=patch([pct_array(idx) pct_array(idx+1) pct_array(idx+1) pct_array(idx)], [minnie minnie 0 0], pctl_color{idx});
    t=sprintf('pct%i', pctl(idx));
    set(p,'Tag',t);
    text(pct_array(idx), -0.05*maxie,sprintf('%i',pctl(idx)),'FontSize',12,'FontWEight','bold');
end;
p=patch([pct_array(end) max(rxns_tmp) max(rxns_tmp) pct_array(end)], [minnie minnie 0 0], pctl_color{end});
set(p,'Tag','pct99');
text(pct_array(end), -0.05*maxie,sprintf('%i',pctl(end)),'FontSize',12,'FontWEight','bold');

% now show the extremes
smallest = min(rxns_tmp);
largest = max(rxns_tmp);
l=line([smallest smallest], [minnie 0], 'Color','g');set(l,'LineWidth',2);
l=line([largest largest], [minnie 0], 'Color','g');set(l,'LineWidth',2);

hold on;
% see overlap between reaction times for 'short' and 'long' trials
% plot histograms showing distribution of reaction times
hist(rxns_tmp(long_idx));
p=findobj(gca,'Type','patch');
for idx=1:length(pct_array)
    t=sprintf('pct%i', pctl(idx));
    p=setdiff(p,findobj(gca,'Tag',t));
end;
set(p,'FaceColor', [1 0 0],'EdgeColor',[1 0 0],'facealpha',0.75);
hold on;
hist(rxns_tmp(short_idx));
p=findobj(gca,'Type','patch');
set(p,'facealpha',0.25, 'EdgeColor','none');
title('Distribution of rxn times for short and long trials');

hold on;

% plot separate series for short and long trials
means_short = means_short *maxie;% stretch up the '% left' trace to superimpose it on the histogram
sems_short = sems_short * maxie;
means_long = means_long*maxie;
sems_long = sems_long*maxie;
l=errorbar(xshort, means_short, sems_short, sems_short,'.b'); % plot % left for short trials
set(l,'MarkerSize',20);
l=errorbar(xlong, means_long, sems_long, sems_long,'.r'); % plot % left for long trials
set(l,'MarkerSize',20);

% mark 25 and 75% points
r=max(rxns_tmp);
line([0 r],[0.25*maxie 0.25*maxie],'Color','k','LineStyle',':');
line([0 r],[0.75*maxie 0.75*maxie],'Color','k','LineStyle',':');

set(gca,'YLim',[-0.1*maxie maxie], 'YTick', 0:0.2*maxie:maxie,'YTickLabel',0:20:100);

xlabel('Reaction time (seconds)');
ylabel('% responding ''Left''');
title('% left as function of rxn time');
uicontrol(gcf,'Position',[20 5 140 20],'String',fname,'Style','text','FontSize',12)




%
%         % ---------------------------------------------------------
%         % mean differences in reaction times between adjacent BINS (binned data)
%         % ---------------------------------------------------------
%         if show_difference_plot
%             ttype_array = {}; % which tasks to plot
%             if ~strcmpi(filter_by_task,'p') && duration_tally > 0, ttype_array{end+1} = 'duration'; end;
%             if ~strcmpi(filter_by_task,'d') && pitch_tally > 0, ttype_array{end+1} = 'pitch'; end;
%             % individual plots for duration and pitch
%             for r = 1:length(ttype_array)
%                 figure;set(gcf,'Toolbar','none','Color',eval([ttype_array{r} '_colour']));
%                 eval(['rdiff_tmp = rxn_differences.' ttype_array{r} '*1000;']);
%                 mean_rxn = mean(rdiff_tmp);
%                 sem_rxn = std(rdiff_tmp) / rows(rdiff_tmp)-1;
%                 l=errorbar(1:length(mean_rxn), mean_rxn,sem_rxn, sem_rxn,'.r');
%
%                 set(l,'MarkerSize',20);
%                 set(gca,'XTickLabel',2:1:length(mean_rxn)+1, 'XTick',1:1:length(mean_rxn));
%                 xlabel('Bin K (of (BinK - BinK-1)');
%                 ylabel('milliseconds');
%                 title(sprintf('Mean adjacent differences in reaction time (%s)', ttype_array{r}));
%             end;
%         end;
%
%         % ---------------------------------------------------------
%         % mean reaction times in BINNED (binned data)
%         % ---------------------------------------------------------
%         if show_average_rxntime
%             ttype_array = {}; % which tasks to plot
%             if ~strcmpi(filter_by_task,'p') && duration_tally > 0, ttype_array{end+1} = 'duration'; end;
%             if ~strcmpi(filter_by_task,'d') && pitch_tally > 0, ttype_array{end+1} = 'pitch'; end;
%             % individual plots for duration and pitch
%             for r = 1:length(ttype_array)
%                 figure; set(gcf,'Toolbar','none','Color',eval([ttype_array{r} '_colour']));
%                 eval(['rcum_tmp = rxn_cum.' ttype_array{r} '*1000;']);
%                 mean_rxn = mean(rcum_tmp); sem_rxn = std(rcum_tmp) / rows(rcum_tmp)-1;
%                 l=errorbar(1:length(mean_rxn), mean_rxn,sem_rxn, sem_rxn,'.r');
%
%                 set(l,'MarkerSize',20);
%                 eval(['mybins = round(' ttype_array{r} '_bins*100)/100;']);
%                 set(gca,'XTickLabel',1:1:length(mean_rxn), 'XTick',1:1:length(mean_rxn), 'XTickLabel', mybins);
%                 if strcmpi(ttype_array{r},'duration'),
%                     xlabel('Bins (milliseconds)');
%                     set(gcf,'Position',[430  10   651   280]);
%                 else
%                     xlabel('Bins (KHz)');
%                     set(gcf,'Position',[428   319   651   280]);
%                 end;
%                 ylabel('milliseconds');
%                 title(sprintf('Mean reaction time for each bin (%s)', ttype_array{r}));
%             end;
%         end;

