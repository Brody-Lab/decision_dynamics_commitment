function [out] = cpoke_statistics(action,varargin)
% examine duration/number cpokes that lead to valid trials

if strcmpi(action,'init')
    pairs = { ...
        'use_dateset', 'prepsych'; ... % [prepsych | postpsych| '']
        'from', '000000' ; ...
        'to', '999999'; ...
        };
    parse_knownargs(varargin,pairs);

end;

out = 0;

switch action

    case 'init'

        ratlist = {...
            'Boromir'; ...
            'Gryphon'; ...
            'Sauron'; ...
            'Legolas'; ...
            'Denethor'; ...
            'Hare'; ...
            'Baby'; ...
            'Jabber'; ...
            };

        amasser = {};

        for r = 1:rows(ratlist)
            ratname = ratlist{r};
            ratrow = rat_task_table(ratname);
            eval(['amasser.' ratname ' = {};']);

            switch use_dateset
                case 'prepsych'
                    dates = ratrow{1,rat_task_table('','action','get_prepsych_col')};
                    from = dates{1}; to = dates{2};
                case 'postpsych';
                    dates = ratrow{1,rat_task_table('','action','get_postpsych_col')};
                    from = dates{1}; to = dates{2};
                case ''   % provide own 'from' and 'to' vars
                otherwise
                    error('use_dateset should be one of: [prepsych | postpsych | ]');
            end;

            task = ratrow{1,2};
            if strcmpi(task(1:3),'dur')
                left_tones = 'dur_short';
                right_tones ='dur_long';
                psychf = 'psych';
                ispitch = 0;
            else
                left_tones = 'pitch_low';
                right_tones = 'pitch_high';
                psychf = 'pitch_psych';
                multfactor = 1;
                ispitch = 1;
            end;

            rts=0;
            datafields = {left_tones, right_tones, 'sides','events',psychf};
            get_fields(ratname,'from',from,'to',to,'datafields',datafields);

            sl = sides;
            if strcmpi(task(1:3),'dur')
                left_tones = dur_short;
                right_tones = dur_long;
            else
                left_tones = pitch_low;
                right_tones = pitch_high;
                if psych_only > 0
                    psych = pitch_psych;
                end;
            end;

            tones = zeros(size(sl));
            tones(find(sl > 0)) = left_tones(find(sl > 0));
            tones(find(sl < 1)) = right_tones(find(sl < 1));

            out=cpoke_statistics('analyze',events);
            eval(['amasser.' ratname ' = out;']);
        end;

        out = amasser;

    case 'analyze'
        events = varargin{1};
        drop_ctr = []; % trials without a valid cpoke
        bob_ctr = [];  % trials WITH at least one bob in the trial cpoke
        cpoke_list = {}; % r-by-2; list of cpoke that lasted from the start of the trial to GO signal
        bobbie_list ={}; % r-by-2; list of valid cpokes that are nonetheless 'bobbing' cpokes. They are multiple cpokes with a small enough interpoke interval
        % that they don't evoke a timeout
        for k = 1:rows(events)
            % get the good long poke
            cpoke = get_valid_cpoke(events{k});
            if rows(cpoke) < 1
                drop_ctr = vertcat(drop_ctr,k);
            else
                cpoke_list{end+1} = cpoke;
            end;

            % and characterize the bobbing poke
            bobbie = get_bobbing_poke(events{k});
            if rows(bobbie) > 1
                %                nobob_ctr = vertcat(nobob_ctr,k);
                bob_ctr = vertcat(bob_ctr,k);
                bobbie_list{end+1} = bobbie;
            end;
        end;

        out = {};
        out.events = events;
        out.cpokes = cpoke_list;
        out.bobbie  = bobbie_list;
        out.bob_ctr = bob_ctr;

    case 'show_stats'
        collector = varargin{1}; % output from 'analyze' action
        ratlist = fieldnames(collector);
        x = 5; y = 5; fig_wt = 300; fig_ht = 200;
        x2 = 300; y2 = 5; fig_wt2 = 500; fig_ht2= 200;
        ssize = get(0,'ScreenSize'); sheight = ssize(4); swidth = ssize(3);

        prebob_avg = []; % r-by-2; for each rat (row), mean (col 1) and std (col 2) of pre-bob poke length
        postbob_avg = []; % r-by-2; same measures as prebob_avg, except measurements madeo of post-bob poke length
        bobtime_rel_cue_avg = []; % avg (and sd) time relative to cue onset that bob occurs
        for r = 1:length(ratlist)
            ratname = ratlist{r};
            eval(['out = collector.' ratname ';']);

            events = out.events;
            cpokes = out.cpokes; % each element of the cell array has the bobbing pokes for a given trial
            bobbie = out.bobbie;
            bob_ctr = out.bob_ctr;

            bobtally = []; % each element contains number of cpokes / trial
            dash = '-'; dash = repmat(dash,1,100);
            for k= 1:length(bobbie)
                bobtally = vertcat(bobtally, rows(bobbie{k})-1); % # bobs  = (# of cin-couts) - 1 (a bob needs two poke motions)
            end;

            fprintf(1,'%s\n ',dash);
            fprintf(1,'%s:\n',ratname);

            %   figure; hist(bobtally);

            % Questions:
            % what % of the data have bobs?
            % what is the distribution of bobs?
            % Can # bobs be separated based on trial type (left or right)?
            % What about if you look at a bob as starting from cue ONSET,
            % rather than from basestate_end?
            pct_bobs = length(bobbie) / (length(cpokes) + length(bobbie));

            fprintf(1,'Total # trials = %i\n', length(cpokes) + length(bobbie));
            fprintf(1, '%i%% of the trials have bobbing.\n',round(pct_bobs*100));
            fprintf(1, 'How many times does my rat bob per trial?\n');
            %        un = unique(bobtally);
            %        for k = 1:length(un)
            pct_bobs = length(find(bobtally == 1)) / length(bob_ctr);
            fprintf(1, '\t Exactly once: %1.2f %% of the time\n', round(pct_bobs*100));
            pct_bobs = length(find(bobtally > 1)) / length(bob_ctr);
            fprintf(1, '\t Twice or more: %1.2f %% of the time\n',  round(pct_bobs*100));
            %        end;


            % are the rats bobbing at cue onset?
            bobtime_rel_cueonset = 0; % time that bob starts relative to the cue onset
            %  vals > 0 => bob happened before cue_onset
            %  vals < 0 => bob happened after cue_onset

            for k = 1:length(bob_ctr)
                evs = events{bob_ctr(k)};
                cue_onset = evs.cue(end,1);
                curr_bob = bobbie{k};
                if rows(curr_bob) == 2
                    begin_bob = curr_bob(1,2); % cout that starts a bob
                    end_bob = curr_bob(2,1); % cin that ends a bob
                    bobtime_rel_cueonset = horzcat(bobtime_rel_cueonset, cue_onset - begin_bob);
                end;
            end;

            bobtime_rel_cue_avg = vertcat(bobtime_rel_cue_avg, [ mean(bobtime_rel_cueonset), std(bobtime_rel_cueonset)]);
            if strcmpi(ratname,'Denethor')
                figure('ButtonDownFcn', @double_in_size);
                set(gcf,'Toolbar','none','Position',[x y fig_wt fig_ht]);
                y = y+fig_ht;
                if (y+fig_ht) > sheight,
                    x = x + fig_wt;
                    y=5;
                    if x > swidth,
                        x = 5;
                    end;
                end;

                bins = -1:0.1:1;
                n = hist(bobtime_rel_cueonset,bins);
                maxie=max(bobtime_rel_cueonset);
                patch([0 maxie maxie 0],[0 0 max(n) max(n)],[1 1 0.8],'EdgeColor','none');

                hold on;
                hist(bobtime_rel_cueonset,bins);

                set(gca,'YLim',[0 1.1*max(n)], 'XLim', [-1*maxie maxie]);
                xlabel('Bob time relative to cue onset (seconds); b > 0 => bob BEFORE cue_onset');
                text(+0.2, 1.05*max(n), 'BEFORE cue starts');
                text(-0.5, 1.05*max(n), 'AFTER cue starts');
                title(sprintf('%s: Bob time relative to cue onset', ratname));
            end;


            % is there a unit of poke length?
            prebob_dur = [];
            postbob_dur = [];
            for k = 1:length(bob_ctr)
                if rows(bobbie{k}) == 2
                    curr_bob = bobbie{k};
                    prebob_dur = vertcat(prebob_dur, curr_bob(1,2) - curr_bob(1,1));
                    postbob_dur = vertcat(postbob_dur, curr_bob(2,2) - curr_bob(2,1));
                end;
            end;


            prebob_avg = vertcat(prebob_avg, [mean(prebob_dur) std(prebob_dur)]);
            postbob_avg = vertcat(postbob_avg, [mean(postbob_dur) std(postbob_dur)]);

            if strcmpi(ratname,'Denethor')
                        figure('ButtonDownFcn', @double_in_size);
                        set(gcf,'Toolbar','none','Position',[x2 y2 fig_wt2 fig_ht2]);
                        y2 = y2+fig_ht2;
                        if (y2+fig_ht2) > sheight,
                            x2 = x2 + fig_wt2;
                            y2=5;
                            if x2> swidth,
                                x2 = 5;
                            end;
                        end;
                        subplot(1,2,1); hist(prebob_dur); title(sprintf('%s: Pre-bob duration',ratname));
                        xlabel('seconds');
            
            
                        subplot(1,2,2); hist(postbob_dur);title(sprintf('%s: Post-bob duration',ratname));
                        xlabel('seconds');
            end;
            fprintf(1,'%s\n ',dash);
        end;

        % Plot average duration of pre- and post-bob cpoke durations
        figure; set(gcf,'Menubar','none');
        subplot(1,2,1); plot(prebob_avg(:,1), 1:rows(prebob_avg), '.r');hold on;
        for r = 1:rows(prebob_avg)
            line(prebob_avg(r,1)+[prebob_avg(r,2) -1*prebob_avg(r,2)], [r r],'Color','r');
        end;
        set(gca,'YLim', [0 length(ratlist)+1], 'YTick',[]);
        xlabel('seconds (s.d.)'); ylabel('Individual rats');
        title('Pre-bob cpoke duration: mean & sd');

        subplot(1,2,2); plot(postbob_avg(:,1), 1:rows(postbob_avg), '.g'); hold on;
        for r = 1:rows(postbob_avg)
            line(postbob_avg(r,1)+[postbob_avg(r,2) -1*postbob_avg(r,2)], [r r],'Color','g');
        end;
        set(gca,'YLim', [0 length(ratlist)+1], 'YTick',[]);
        xlabel('seconds (s.d.)'); ylabel('Individual rats');
        title('Post-bob cpoke duration: mean & sd');

        % Plot average bobtime relative to cue onset
        figure; set(gcf,'Menubar','none');
        maxie=max(bobtime_rel_cue_avg(:,1)) + max(bobtime_rel_cue_avg(:,2));
                        patch([0 maxie maxie 0],[0 0 length(ratlist) length(ratlist)],[1 1 0.8],'EdgeColor','none');
                        hold on;
        plot(bobtime_rel_cue_avg(:,1), 1:rows(bobtime_rel_cue_avg), '.g'); 
        for r = 1:rows(bobtime_rel_cue_avg)
            line(bobtime_rel_cue_avg(r,1)+[bobtime_rel_cue_avg(r,2) -1*bobtime_rel_cue_avg(r,2)], [r r],'Color','g');
        end;
                        text(+0.2, 1.05*length(ratlist), 'BEFORE cue starts');
                text(-0.5, 1.05*length(ratlist), 'AFTER cue starts');

        set(gca,'YLim', [0 length(ratlist)+1], 'YTick',[]);
        xlabel('seconds (s.d.)'); ylabel('Individual rats');
        title('Time of bob occurrence relative to cue onset: mean & sd');

    otherwise
        error('invalid action');
end;

% -------------------------------------------------------------------------
% HELPER FUNCTIONS
% -------------------------------------------------------------------------

function [cpokes] = get_valid_cpoke(evs)

basestate_start = evs.wait_for_cpoke(end, 1);
basestate_end = evs.wait_for_cpoke(end,2);
wp1 = evs.wait_for_apoke(end,1);
cue_on = evs.cue(end,1);

lastgo_1 = evs.chord(end,1) + 0.03;
lastgo_2 = evs.chord(end,2);

% "trial" pokes which ended before wait_for_apoke
cond = {...
    'in',   'before',    basestate_end+0.02; ... % rough coincidence with basestate_end
    'out', 'after', lastgo_1; ...
    'out', 'before', lastgo_2};
cpokes = get_pokes_fancy(evs, 'center', cond, 'all');

% cout was made during wait_for_apoke state
if rows(cpokes) < 1
    cpokes = get_pokes_fancy(evs, 'center', ...
        {'in', 'before', basestate_end+0.02; ...
        'in', 'before', wp1 ; ...
        'out', 'after', wp1}, ...
        'all');
end;

if rows(cpokes) > 1,
    error(['There should only be one long valid poke ' ...
        'per trial']);
end;


function [cpokes] = get_bobbing_poke(evs)

basestate_end = evs.wait_for_cpoke(end,2);
lastgo_1 = evs.chord(end,1) + 0.03;
lastgo_2 = evs.chord(end,2);

% bobbing pokes which ended before wait_for_apoke
if rows(evs.wait_for_apoke) < 1
    cond = {...
        'in',   'after',    basestate_end-0.02; ... % rough coincidence with basestate_end
        'out', 'before', lastgo_2};
else
    cond = { ...
        'in','after', basestate_end - 0.02; ...
        'in','before', evs.wait_for_apoke(1,1);...
        'out', 'before', evs.wait_for_apoke(1,2) ; ...
        };
end;
cpokes = get_pokes_fancy(evs, 'center', cond, 'all');
