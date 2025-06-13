function [] = metric_daily_save(action, varargin)

% Examples of use:
%%% To save data
% metric_daily_save('compute', 'save_flag',1,'outcomment', 'All rats (except S038) on 22 Sep, till end of 2-4pm shift')
%%% To plot data for single rat
% metric_daily_save('plot_singlerat', 'outfile','metric_daily_save_080922_5','rat2plot','S023')
%%% To plot data from a certain file
% metric_daily_save('plot', 'outfile','metric_daily_save_080922_5')
%%% Get total time spent on any one metric for ALL rats
% metric_daily_save('verbose', 'outfile', 'metric_daily_save_080923_3', 'metric2total', 'drk_len')

pairs ={ ...
    'save_flag', 0 ; ... % set to 1 to save data
    'data2save', {} ; ... % fill with content to save to datafile
    'ratlist', {}; ... % list of rats for which data is computed/loaded/saved
    'dateset', {}; ... % dates for which data is collected
    'outfile', [mfilename '_' yearmonthday '_1']; ... % file to which data to be saved
    'outcomment', 'None.'; ... % put comment about why this set of data was put into a file.
    'rat2plot', ''; ... % use for 'plot_singlerat' option
    'metric2total', 'drk_len' ;... X from data2save.ratname.X ; works with 'verbose' flag
    };
parse_knownargs(varargin,pairs);

% rats from 8-10am to 2-4pm shift

% eight2four_dur = {'S022', 'S021','S023','S039', 'S025','S029','S018','S019'};
% eight2four_freq = {'S026', 'S036','S040','S034', 'S035','S027','S030','S028','S032'};
% ratlist = [ eight2four_dur eight2four_freq ];
ratlist = { ...
    'S033','S026','S022','S021', ... % 8-10 shift
    'S032', 'S023','S019','S040','S025', ... % 10-12 shift
    'S035','S034','S036','S039', ... % 'S038',12-2 shift
    'S029','S018','S027','S030','S028'... % 2-4 shift
    'S041','S042','S043','S044','S045',...        % 4-6 shift
    'S046','S047', 'S031','S016' ...              % 6-8 shift
    };                


dateset = '081001a';

% durlist = {'S023','S039', 'S033', 'S025','S022','S029','S018','S019','S021'};
% freqlist = {'S036','S040','S034', 'S035','S027','S030','S028','S032','S026'};
% ratlist = [durlist freqlist];
% dateset = '080922a';

% rats from 4-6 and 6-8 shift
% ratlist = {'S041','S042','S043','S044','S045','S046','S047','S031','S016'};
% dateset = '080924a';
% % ratlist = {'S033','S026','S022','S021'};
% % dateset = '080924a';

switch action
    case 'compute'
        data2save = 0;
        for r = 1:length(ratlist)
            fprintf(1,'%s...\n', ratlist{r});
            out = sub__storemetric(ratlist{r}, dateset);
            eval(['data2save.' ratlist{r} '= out;']);
        end;

        if save_flag > 0
            metric_daily_save('save', 'ratlist', ratlist, 'data2save', data2save, ...
                'dateset', dateset, 'outcomment', outcomment);
        end;

    case 'save'
        global Solo_datadir;
        outdir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Set_analysis' filesep];

        n= sub__getlastsavedfile(outdir, [mfilename '_' yearmonthday '_']);

        save([outdir mfilename '_' yearmonthday '_' num2str(n+1)], 'ratlist', 'dateset', ...
            'data2save', 'outcomment');
    case 'load'
        global Solo_datadir;
        outdir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Set_analysis' filesep];
        load([outdir outfile]);
        fprintf(1,'Comment:\n\t%s\n', outcomment);
        fnames = {'ratlist', 'dateset','data2save'};
        for f = 1:length(fnames)
            assignin('caller', fnames{f}, eval(fnames{f}));
        end;        
    case 'verbose'
        metric_daily_save('load','outfile', outfile);
        
        ratties = fieldnames(data2save);
        secstr = ''; minstr = ''; idealminstr = '';
        fprintf(1,'Verbose print for %s:\n', metric2total);
        
        for r = 1:length(ratties)
            ratname = ratties{r};        
            v = eval(['data2save.' ratname '.' metric2total ';']);        
            hh = eval(['data2save.' ratname '.hh;']);        
            fprintf(1,'\t%s\t%3.1f\n', ratname, nansum(v) ./60);
            secstr = [secstr sprintf('%3.1f  ', nansum(v) ) ];
            minstr = [minstr sprintf('%3.1f  ', nansum(v)./60) ];
            idealminstr = [idealminstr sprintf('%3.1f  ', (nansum(v)./60) - ((sum(hh)*8)./60)) ];
        end;
        fprintf(1,'secstr:\n%s\nminstr\n%s\ndeviance from ideal (min):\n%s\n', secstr, minstr, idealminstr);    

    case 'plot'
        metric_daily_save('load','outfile', outfile);

        bs_len = []; bs_min = []; bs_max = [];
        to_num = []; 
        to_len = [];
        drk_tm = []; drk_min = []; drk_max =[];
        dd_tm =[];   dd_min = []; dd_max = [];
        isdur = [];
        tr = [];       

        left_lick_cell = {};
        right_lick_cell = {};
        for r = 1:length(ratlist)
            ratname = ratlist{r};
            b = eval(['data2save.' ratname '.basestate_len;']);
            t = eval(['data2save.' ratname '.timeout_count;']);
            d = eval(['data2save.' ratname '.dead_time_len;']);
            k = eval(['data2save.' ratname '.drk_len;']);
            
            [left_licks, right_licks] = sub__sidelicks(eval(['data2save.' ratname '.licks']), ...
                eval(['data2save.' ratname '.sides']),...
                eval(['data2save.' ratname '.hh']));
            left_lick_cell{r} = left_licks;
            right_lick_cell{r} = right_licks;

            bs_len = horzcat(bs_len,mean(b));
            bs_min = horzcat(bs_min, min(b)); bs_max = horzcat(bs_max, max(b));
            
            to_num = horzcat(to_num, length(find(t == 0)) ./ length(t));
            
            dd_tm = horzcat(dd_tm, nanmean(d));
            dd_min = horzcat(dd_min, min(d)); dd_max = horzcat(dd_max, max(d));
            
            isdur = horzcat(isdur, eval(['data2save.' ratname '.isdur;']));
            tr = horzcat(tr, eval(['data2save.' ratname '.n_done_trials;']));
            
            drk_tm = horzcat(drk_tm, nanmean(k));
            drk_min = horzcat(drk_min, min(k)); drk_max =horzcat(drk_max, max(k));
        end;

        figure; r = length(ratlist);

                subplot(5,1,1);
        for y = 100:100:200
            line([0 length(ratlist)+1], [y y], 'LineStyle',':','Color',[1 1 1]*0.5,'LineWidth',2);
            hold on;
        end;
        sub__plotval(tr, ratlist, 'numtr', isdur,...
            'markred', 'val<100');
        ratties = fieldnames(data2save);
        for r = 1:length(ratties)
            myh = eval(['data2save.' ratties{r} '.rig_hostname;']); myh = myh{1}; myh = myh(end);
            text(r, 170, myh, 'Color','r','FontSize',16,'FontWeight','bold');
        end;
        
        title(strrep(outfile,'_',' '));
        
        subplot(5,1,4); sub__plotval(bs_len ./60, ratlist, 'base(min)', isdur, ...
            'range_min', bs_min ./ 60, 'range_max', bs_max ./60);
        
        subplot(5,1,2); sub__plotval(to_num, ratlist, '% no Timeout', isdur, ...
            'markred', 'val < 0.5'); 
        set(gca,'YLim',[0 1],'YTick',0:0.25:1, 'YTickLabel',0:25:100);
        for y = 0.25:0.25:1
            line([0 length(ratlist)+1], [y y], 'LineStyle',':','Color',[1 1 1]*0.5,'LineWidth',2);
            hold on;
        end;
        
        subplot(5,1,3); sub__plotval(dd_tm, ratlist, 'dd-tm (s)', isdur,...
            'range_min', dd_min, 'range_max', dd_max, ...
            'markred', 'val > 30' ...
        );
    
        % Drinking behaviour

        subplot(5,1,5); 
   %  figure; 
     
        flg__showdrinklen =0;
        if flg__showdrinklen > 0
        for y = [30 60]
            line([0 length(ratlist)+1], [y y], 'LineStyle',':','Color',[1 1 1]*0.5,'LineWidth',1.5);
            hold on;
        end;
        sub__plotval(drk_tm, ratlist, 'drktm(s)', isdur,...
            'range_min', drk_min, 'range_max', drk_max, ...
            'markred', 'val > 16');
        set(gca,'YLim',[0 60]); 
        idx = find(drk_max > 120); 
        plot(idx,ones(size(idx))*118, '*r','MarkerSize',20);
        else % show side lick range
            
        left_licks =left_lick_cell;
        right_licks = right_lick_cell;
        
        line([0 length(ratlist)+1],[10 10], 'LineStyle',':','LineWidth',2,'Color', [1 1 1]*0.3);
        
        for r = 1:length(ratlist)
            lft_mean = mean(left_licks{r}); lft_sd = std(left_licks{r});
            rt_mean = mean(right_licks{r}); rt_sd = std(right_licks{r});          
            
            patch([r-0.2 r-0.2 r r], [0 lft_mean lft_mean 0], 'b'); hold on;
            plot(ones(size(left_licks{r}))*(r-0.1), left_licks{r}, '.r','Color', [0.5 0.5 1]); 
            line([r-0.1 r-0.1], [lft_mean - lft_sd, lft_mean+lft_sd], 'LineWidth',2);            
            
            patch([r r r+0.2 r+0.2], [0 rt_mean rt_mean 0], 'r'); hold on;
            plot(ones(size(right_licks{r}))*(r+0.1), right_licks{r}, '.r', 'Color', [1 0.5 0.5]);            
            line([r+0.1 r+0.1], [rt_mean - rt_sd, rt_mean+rt_sd], 'LineWidth',2);            
        end;
        set(gca,'XTick', 1:length(ratlist), 'XTickLabel', ratlist);
%        min(yl(2), 120) 
        yl = get(gca,'YLim'); set(gca,'YLim',[0 30],'XLim',[0 length(ratlist)+1]); 
        
        end;
            

        set(gcf,'Position', [-70 60 1500 650]);

    case 'plot_singlerat'
        metric_daily_save('load','outfile', outfile);
        figure;
        ratname = rat2plot;

        subplot(4,1,1);
        blen = eval(['data2save.' ratname '.basestate_len;']);
        plot(blen,'.r');ylabel('base (s)');
        t=title(sprintf('%s:%s', ratname, eval(['data2save.' ratname '.dates{1};'])));      
        set(gca,'XLim',[0 length(blen)]);
        set(t,'FontSize',14,'FontWeight','bold');

        subplot(4,1,2);
        to = eval(['data2save.' ratname '.timeout_count;']);
        plot(to,'.k'); ylabel('TO#');
                set(gca,'XLim',[0 length(blen)]);

        subplot(4,1,3);
        dt = eval(['data2save.' ratname '.dead_time_len;']); plot(dt,'.r');
        set(gca,'XLim',[0 length(dt)]);
        ylabel('ded-tm (s)');

        subplot(4,1,4);
        dk = eval(['data2save.' ratname '.drk_len;']); plot(dk,'.g'); ylabel('drk-tm (s)');
        set(gca,'YLim',[0 65]);
        line([0 length(dk)+1], [30 30], 'LineStyle',':');
        idx = find(dk > 60); hold on;
        plot(idx, ones(size(idx))*60, '*r');
        set(gca,'XLim',[0 length(dk)]);
        
        tr = eval(['data2save.' ratname '.n_done_trials;']);
        
        to_len = eval(['data2save.' ratname '.timeout_len;']);
        num_correct = eval(['data2save.' ratname '.hh;']); num_correct = sum(num_correct);
        
        % Verbose reckoning of time
        bstotal = sum(blen); dttotal = nansum(dt); dktotal = nansum(dk);
        to_total = 0; for k = 1:length(to_len), to_total = to_total + sum(to_len{k}); end; 
        fprintf(1,'%s: Accounting for session:\n', ratname);
        fprintf(1,'\tBase state = %1.1f min (%1.0f s)\n', bstotal ./60, bstotal);
        fprintf(1,'\tDrink time = %1.1f min (%1.0f s; ideally %1.1f min)\n', dktotal ./60, dktotal, (8*num_correct)./60);
        fprintf(1,'\tDead time  = %1.1f min (%1.0f s; ideally %1.1f min)\n', dttotal ./60, dttotal, (2*tr)./60);
        fprintf(1,'\tTO = %1.1f min (%i s) \n', to_total ./60, to_total);
        fprintf(1,'\tTOTAL = %1.2f min\n\n', (bstotal+dktotal+dttotal+to_total) ./60);

    otherwise
        error('Sorry, unknown action');
end;

% -----------------------------------------------------------------------
% Subroutines

function [out] = sub__storemetric(ratname, indate)

% metricsa are:
% n_done_trials (1x1 double) Number of trials done on this session
% timeout array (1xn double) # occurrences of timeout state
% base_state_len (1xn double): Time (in s) of length of basestate (state
% where rat initializes trial)
% drink time (1xn double): How long rat licked side port on reward delivery
% (reward trials only)

datafields = {'pstruct','sides','rig_hostname'};

get_fields(ratname, 'use_dateset', 'given', 'given_dateset', {indate},...
    'datafields', datafields, 'suppress_out', 1);

lft = 1; rt = 0;
sl = sides; hh = hit_history;

lc = intersect(find(sl==lft), find(hh==1));
lw = intersect(find(sl==lft), find(hh==0));
rc = intersect(find(sl==rt), find(hh==1));
rw = intersect(find(sl==rt), find(hh==0));


to = NaN(size(pstruct));
to_len = cell(size(pstruct));
basestate = NaN(size(pstruct));
drk_time = NaN(size(pstruct));
dead_time = NaN(size(pstruct));
lick_cell = cell(size(pstruct));

for k = 1:rows(pstruct)    
    curr = pstruct{k};
    % store timeout
    to(k) = rows(curr.timeout);

    % duration of timeout states
    if ~isempty(curr.timeout)
        to_len{k} = curr.timeout(:,2) - curr.timeout(:,1);
    else
        to_len{k} = [];
    end;

    % basestate
    basestate(k) = mean(curr.wait_for_cpoke(:,2) - curr.wait_for_cpoke(:,1));

    % drink time
    if k < rows(pstruct)
        if ismember(k, lc)
            l=sub__rewardlicks(pstruct(k:k+1));
            drk_time(k) = l.left(end,2) - l.left(1,1);
            lick_cell{k} = l;
        elseif ismember(k,rc)
            l=sub__rewardlicks(pstruct(k:k+1));
            drk_time(k) = l.right(end,2) - l.right(1,1);
            lick_cell{k} = l;
        end;
    else
        if ismember(k, lc)
            l=sub__rewardlicks(pstruct(k));
            drk_time(k) = l.left(end,2) - l.left(1,1);
            lick_cell{k}= l;
        elseif ismember(k,rc)
            l=sub__rewardlicks(pstruct(k));
            drk_time(k) = l.right(end,2) - l.right(1,1);
            lick_cell{k} = l;
        end;
    end;
    
    if isnan(drk_time(k)) && (hh(k) == 1)
        error('%s:%i:Sorry, drink time cannot be NaN for a correct trial', ratname, k);
    end;

    % dead time
    if k < rows(pstruct)
        tmp = pstruct{k+1}.dead_time;
        dead_time(k) = tmp(1,2) - tmp(1,1);
    end;
end;

ratrow = rat_task_table(ratname); task = ratrow{1,2};
if strcmpi(task(1:3),'dur')
    out.isdur = 1;
else
    out.isdur =0;
end;
out.dates = dates;
out.n_done_trials = numtrials;
out.timeout_count = to;
out.timeout_len = to_len;
out.basestate_len = basestate;
out.drk_len =drk_time;
out.dead_time_len = dead_time;
out.hh = hh;
out.rig_hostname = rig_hostname; 
out.sides = sl;
out.licks = lick_cell;

function [maxnum] = sub__getlastsavedfile(dir2chk, fname_prfx)

u = dir(dir2chk);

[filenames{1:length(u)}] = deal(u.name);
filenames = sort(filenames'); %#ok<UDIM> (can't use dimension argument with cell sort)
plen = length(fname_prfx);

maxnum = 0;
for i=1:length(filenames) %
    curr = filenames{i};
    if length(curr) >= (length(fname_prfx) + 1)
        if strcmpi(curr(1:plen), fname_prfx)
            %     fprintf(1,'%s\n', curr);
            therest = curr(plen+1:end);
            ext = strfind(therest,'.');
            currnum = str2double(therest(1:ext));
            maxnum = max(maxnum, currnum);
        end;
    end;
end;

fprintf(1,'Maxnum is:%i\n', maxnum);


function [] = sub__plotval(val, ratlist, ylbl, isdur, varargin)
pairs = { ...
    'markred', ''; ...
    'range_min', []; ...
    'range_max', []; ...
    };
parse_knownargs(varargin,pairs);

durclr = [1 0.5 0];
freqclr = 'b';

r = length(ratlist);
plot(val,'.b','MarkerSize',20); hold on;
plot(find(isdur==1), val(isdur == 1), '.b', 'Color', durclr,'MarkerSize', 20);

if ~isempty(range_min)
    for k = 1:length(ratlist)
        if isdur(k) == 1, clr = durclr; else clr =freqclr; end;
        line([k-0.2 k+0.2], [range_min(k) range_min(k)], 'Color', clr); 
    end;
end;

if ~isempty(range_max)
    for k = 1:length(ratlist)
        if isdur(k) == 1, clr = durclr; else clr =freqclr; end;
        line([k-0.2 k+0.2], [range_max(k) range_max(k)], 'Color', clr); 
    end;
end;

if ~strcmpi(markred,'')
idx = find(eval(markred));
plot(idx, val(idx),'*r', 'MarkerSize', 15);
end;

set(gca,'XLim',[0 r+1], 'XTick', 1:r, ...
    'XTickLabel',ratlist);
ylabel(ylbl);
axes__format(gca);

% licks during a reward state (everything from reward state of current
% state to wait_for_cpoke of next trial
function [lickies] = sub__rewardlicks(p)

curr = p{1};
if isempty(curr.left_reward), rwd_state = curr.right_reward;
else rwd_state = curr.left_reward; end;

st1 = rwd_state(1,1); % start of current reward time
cond = {'in', '>=', st1};
try
lickies.left = get_pokes_fancy(p{1}, 'left', cond, 'all');
catch
    addpath('Analysis/duration_disc/Event_Analysis/');
    lickies.left = get_pokes_fancy(p{1}, 'left', cond, 'all');
end;
lickies.right = get_pokes_fancy(p{1}, 'right', cond, 'all');
lickies.center = get_pokes_fancy(p{1}, 'center', cond, 'all');

if length(p) > 1
st2 = p{2}.wait_for_cpoke(1,1);
cond = {'in', '<=', st2};
lickies.left = [lickies.left; get_pokes_fancy(p{2}, 'left', cond, 'all')];
lickies.right = [lickies.right; get_pokes_fancy(p{2}, 'right', cond, 'all')];
lickies.center = [lickies.center; get_pokes_fancy(p{2}, 'center', cond, 'all')];
end;
%lick_cell{end+1} = tmp;

function [l r] = sub__sidelicks(licks, sides,hh)

lc = intersect(find(sides == 1), find(hh==1));
rc = intersect(find(sides == 0), find(hh==1));

l=NaN(size(lc));
r=NaN(size(rc));
for k = 1:length(lc)
    tmp = licks{lc(k)}.left;
    l(k) = tmp(end,2) - tmp(1,1); % total lick time for this reward
end;

for k = 1:length(rc)
    tmp = licks{rc(k)}.right;
    r(k) = tmp(end,2) - tmp(1,1);    
end;


