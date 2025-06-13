function [datesused indates] = collect_webers(varargin)
[l h] = calc_pair('p', sqrt(8*16), 1,'suppress_out', 1);
[l2 h2] = calc_pair('d', sqrt(200*500), 0.95,'suppress_out', 1);
[l3 h3] = calc_pair('p', sqrt(8*16), 1.4,'suppress_out', 1);

pairs = { ...
    'infile', 'psych' ; ...
    'psychthresh', 1 ; ... % set to 1 to ignore dates where there are < 2 values in a given bin.
    'experimenter','Shraddha'; ...
    % which sessions to analyze? ----------------------------------------
    'master_dstart', 1 ; ...  %first session to analyze from
    'master_dend', 1000; ...  %last session to analyze to
    'lastfew', 7; ...
    % which rat set?
    'area_filter', 'mPFC' ; ...
    'blocks_use', 1 ; ...
    'isflipped', 1 ; ...
    % binning data -----------------------------------------------------
    'binmin_dur', l2 ; ...
    'binmax_dur', h2 ; ...
    'binmin_pitch', l ; ...
    'binmax_pitch', h ; ...
    'num_bins', 8 ; ...
    'justgetdata', 1 ; ... % if true, doesn't plot anything, just assigns data in caller's namespace
    % see comments above for fields assigned
    'pitch', 0 ; ...% set to 1 if using pitch rats
    'action','plot'; ... % can be 'save', 'plot','or 'plotsingle'
    'singlerat', 'Boogie' ; ...
    'clr_singleavg', [1 1 1]*0; ...
    'clr_singlesession', [1 0 0] ; ...
    };
parse_knownargs(varargin,pairs);

if pitch==1, ratgroup='pitch';else ratgroup='duration';end;

ratlist1 = rat_task_table('','action',['get_' ratgroup '_psych'],'area_filter', 'ACx2'); %{ 'Lascar', 'Pips'};
ratlist2=  rat_task_table('','action',['get_' ratgroup '_psych'],'area_filter', 'mPFC'); %{ 'Lascar', 'Pips'};
%ratlist2 = rat_task_table('','action',['get_' ratgroup
%'_psych'],'area_filter', 'mPFC'); %{ 'Lascar', 'Pips'};

preflipped = [ zeros(size(ratlist1)), ones(size(ratlist2))];
blocks_use = [ones(size(ratlist1)) zeros(size(ratlist2))];
ratlist=[ratlist1 ratlist2];


if ~strcmpi(area_filter,'ACx2')
    % blocks_use=0;
    % isflipped=0;
end;

infile = 'psych_before';
num_bins = 8;
experimenter = 'Shraddha';

weberdata ={};
datesused = {};
indates = {};

global Solo_datadir;
if isempty(Solo_datadir), mystartup; end;
outdir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Set_Analysis' filesep];

switch action
    case 'save'
        for r = 1:length(ratlist)
            fprintf(1,'%s ...\n', ratlist{r});
            dstart = master_dstart;
            dend = master_dend;

            ratname = ratlist{r};

            if strcmpi(ratname,'Evenstar')
                binmin_pitch=8;
                binmax_pitch=16;
            end;

            ratrow = rat_task_table(ratname);
            task = ratrow{1,2};
            if strcmpi(task(1:3), 'dur'),
                binmin = binmin_dur;
                binmax = binmax_dur;
                pitch = 0;
                num_bins = 8;
            else
                %         if blocks_use(r) > 0
                binmin = binmin_pitch;
                binmax = binmax_pitch;
                %         else
                %             binmin = l3; binmax = h3;
                %         end;
                pitch = 1;
                numbins = 9;
            end;

            % get the data
            outdir = [Solo_datadir filesep 'Data' filesep experimenter filesep ...
                ratlist{r} filesep];
            fname = [outdir infile '.mat'];
            try
                load(fname);
            catch
                savepsychinfo(ratname);
                load(fname);
            end;

            % filter which days to use
            % -----------------------------------
            % Variables to filter a range of sessions
            % in your dataset >> BEGIN
            dend = min(dend, rows(dates));
            cumtrials = cumsum(numtrials(1:dend));
            lastidx = cumtrials(end);
            startidx = 1;

            if lastfew < 1000
                lastfew = min(rows(dates), lastfew);
                dstart = rows(dates)-(lastfew-1);
            end;

            if dstart > 1
                startidx= cumtrials(dstart-1) +1;
            end;
            fprintf(1,'*** %s: Date filter: Using Day %i to Day %i (Trials %i to %i)\n', mfilename, dstart, dend, startidx, lastidx);
            % << END filtering session dates

            dates = dates(dstart:dend);
            fprintf(1, '\tDates used in analysis:\n');
            dates

            numtrials = numtrials(dstart:dend);
            rxn= rxn(dstart:dend);

            fnames = {'logdiff','hit_history','logflag','psychflag', 'left_tone', 'right_tone', 'side_list', 'events','timeout_count_var'};
            for f =1:length(fnames)
                if exist(fnames{f},'var')
                    %  fprintf(1,'\t%s\n', fnames{f});
                    eval([fnames{f} ' = ' fnames{f} '(startidx:lastidx);']);
                end;
            end;

            str= [ 'indates.' ratlist{r} '= dates;'];
            eval(str);

            % compute psych_oversessions
            if blocks_use(r) > 0 && exist('blocks_switch','var') && (sum(isnan(blocks_switch)) == 0) % a file created since blocks_switch was created
                try
                    if length(blocks_switch) < cumtrials(end)
                        if exist('psychflag','var')
                            blocks_switch = psychflag(startidx:lastidx);
                        end;
                    else
                        blocks_switch = blocks_switch(startidx:lastidx);
                    end;
                catch
                    error('uh oh, blocks_Switch is throwing an error...');
                end;
                if length(blocks_switch) == length(hit_history) % blocks_switch was implemented for this rat.
                    psychflag = blocks_switch;
                else
                    error('Blocks Switch should have the same dimension as hit_history.');
                end;
            end;

            in={};
            myf = {'hit_history', 'numtrials','binmin','binmax','dates'};
            for f = 1:length(myf)
                eval(['in.' myf{f} ' = ' myf{f} ';']);
            end;

            if preflipped==0
                in.flipped = flipped;
            else
                in.flipped=zeros(size(hit_history));
            end;

            in.ltone=left_tone;
            in.rtone=right_tone;
            in.slist = side_list;
            in.psych_on = psychflag;
            %
            %     out.tallies , out.replongs , out.xcomm , out.xmid , out.xfin
            % out.weber , out.overall_betahat , out.overall_xc , out.overall_xf
            % out.overall_xmid out.overall_weber, out.overall_ci,
            % out.psychdates ,out.logtones,
            % out.bins ,out.failed_dates
            out = psych_oversessions(ratname,in, ...
                'justgetdata',1,'pitch', pitch,'num_bins', num_bins,'noplot',1);
            eval(['weberdata.' ratlist{r} '= out;']);
            tmp = out.psychdates;
            if ~isempty(tmp),
                str= [ 'datesused.' ratlist{r} '= dates(tmp);'];
                eval(str);
            else
                eval(['datesused.' ratlist{r} '= {};']);
            end;
        end;
        save([outdir 'weberout_' ratgroup], 'weberdata','datesused');

    otherwise
        error('unknown action');
end;