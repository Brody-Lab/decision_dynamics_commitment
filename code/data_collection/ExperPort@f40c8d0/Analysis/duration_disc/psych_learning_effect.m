function [] = psych_learning_effect(ratname, varargin)

pairs = { ...
    'use_dateset', 'psych_before' ;...  % [psych_before | psych_after | '']
    'fromdate', '000000'; ...
    'todate', '999999';...
    'experimenter','Shraddha';...
    'first_few', 10; ... % only use first_few sessions in dataset; ignore rest
    'binmin_dur', 200;...
    'binmax_dur', 500;...
    'binmin_pitch', 8;...
    'binmax_pitch', 16; ...
    'octave_sep_for_psych', 1; ...    
    'numblocks', 4;...
    };
parse_knownargs(varargin,pairs);

close all;
%load_datafile(ratname, date);

ratrow = rat_task_table(ratname);
task = ratrow{1,2};

if strcmpi(task(1:3),'dur')
    leftf = 'dur_short'; rightf ='dur_long'; psychf = 'psych';
    binmin = binmin_dur; binmax=binmax_dur;
else
    leftf = 'pitch_low'; rightf='pitch_high'; psychf = 'pitch_psych';
    [l h] = calc_pair('p',sqrt(binmin_pitch* binmax_pitch), octave_sep_for_psych);
    binmin=l;binmax =h;
end;

datafields = {leftf, rightf, 'sides','blocks_switch', psychf};

% ----------------------------------------------------------
% BEGIN Date set retrieving module: Use this piece of code to get either
% a pre-buffered date set, a range, or a specified date_set.
% To use this, have four switches in your 'pairs' cell array:
% 1 - 'vanilla_task' - binary; indicates whether rat was lesioned during
% vanilla task (1) or not (0)
% 2 - 'use_dateset' - specifies how to obtain dates to analyze
% 3 - infile - file from which to buffer (if different from psych_before
% and psych_after)
% 4 - experimenter - Shraddha

last_few_pre=NaN; % how many days pre-surgery in this dataset?

switch use_dateset
    case 'psych_before'
        psychd = ratrow{1, rat_task_table({}, 'action','get_prepsych_col')};
        files = get_files(ratname, 'fromdate', psychd{1},'todate',psychd{2});
        first_few = min(first_few, length(files));
        get_fields(ratname,'from',files{1}(1:6),'to',files{first_few}(1:6),'datafields',datafields);
        
    case 'psych_after'
        files = get_files(ratname, 'fromdate', psychd{1},'todate',psychd{2});
        first_few = min(first_few, length(files));
        lastfile = files(first_few);
        get_fields(ratname,'from',files(1),'to',files(first_few),'datafields',datafields);
    case 'given'
        get_fields(ratname,'use_dateset','given', 'given_dateset', given_dateset,'datafields',datafields);
    case ''
        get_fields(ratname,'from',fromdate,'to',todate,'datafields',datafields);
    case 'span_surgery'
        error('Sorry, this script doesn''t have the span_surgery option');
    otherwise
        error('invalid use_dateset');
end;
% END Date set retrieving module
% ---------------------------------------------------------

first_few= min(first_few, length(numtrials));

b = blocks_switch;
t1 = eval(leftf); t2=eval(rightf);
psych = eval(psychf);
hh = hit_history;
sl = sides;

datatype = 'uses_blocks';
if isnan(blocks_switch) % hasn't been implemented at the time of this rat
    b = psych;
    datatype = 'uses_psychflag';    
end;

cumtrials = cumsum(numtrials);
hrate_blocks = [];
weber_blocks = [];

raw_hrate = [];
for k = 1:first_few
    sidx = 1; if k > 1, sidx = cumtrials(k-1)+1;end;
    eidx = cumtrials(k);

    fprintf(1,'%s....\n', dates{k});
    [hrates wbr]=     sub__oneday(t1(sidx:eidx), t2(sidx:eidx), ...
        sl(sidx:eidx), hh(sidx:eidx), numtrials(k),...
        b(sidx:eidx), task,datatype,...
         binmin, binmax, numblocks);

    diff_hrates = diff(hrates); diff_wbr = diff(wbr);
    try
    raw_hrate = vertcat(raw_hrate, hrates(1:numblocks));
    catch
        2;
    end;
    hrate_blocks = vertcat(hrate_blocks, diff_hrates(1:numblocks-1));
    weber_blocks=vertcat(weber_blocks, diff_wbr(1:numblocks-1));
end;

% --- Plotting begins here ----------
figure;

sumhh = sum(hrate_blocks');
notnanrows = find(~isnan(sumhh));
nanrows = length(sumhh) - length(notnanrows);

if length(notnanrows) > 1
    fprintf(1,'\n\n\n\n%i sessions ignored *****', nanrows);
end;
[barh xpos] =barweb(nanmean(hrate_blocks), nanstd(hrate_blocks) ./ length(notnanrows));
set(gca,'FontSize',18,'FontWeight','bold',...
    'XTick',[], ...
   'Position', [0.1 0.1 0.35 0.75]);
%    'YLim',[0.5 1], 'YTick', 0.5:0.1:1, 'YTickLabel',50:10:100);
hold on;
for k = 1:cols(hrate_blocks)
   l=plot(ones(size(hrate_blocks(:,k))) * xpos(k), hrate_blocks(:,k),'.r'); 
   set(l,'MarkerSize',20,'Color',[0.7 0.7 0.7]);
end;
t=ylabel('% correct'); set(t,'FontSize',18,'FontWeight','bold');
t=xlabel('Block #'); set(t,'FontSize',18,'FontWeight','bold');
t=title(sprintf('%s (%s to %s):\n %% Correct across blocks', ratname, dates{1}, dates{first_few})); set(t,'FontSize',14);

if strcmpi(task(1:3),'dur'), 
    clr = [1 0.8 0];
else
    clr = [1 0 0.8];
end;

barweb_change_colour(gca, clr,'none');

sumhh = sum(weber_blocks');
notnanrows = find(~isnan(sumhh));
nanrows = length(sumhh) - length(notnanrows);

axes('Position',[0.55 0.1 0.4 0.75]);
barweb(nanmean(weber_blocks), NaN(size(nanmean(weber_blocks))));
set(gca,'FontSize',18,'FontWeight','bold','XTick',[]);
t=ylabel('Weber fraction'); set(t,'FontSize',18,'FontWeight','bold');
t=xlabel('Block #'); set(t,'FontSize',18,'FontWeight','bold');
title('Weber through blocks within a session');
barweb_change_colour(gca, clr,'none');

set(gcf,'Color',[0.8 0.8 0.8],'Position',[245   418   837   367],'Menubar','none','Toolbar','none');
sign_fname(gcf,mfilename);
uicontrol('Tag', 'figname', 'Style','text', 'String', ['psychlearn_' ratname], 'Visible','off');


% -------------------------------------------------------------
% Subroutines
% -------------------------------------------------------------
% left tone
% right tone
% sl -side list
%  hh - hit history
% n - numtrials
% b - blocks_switch
function [block_hrate weberlist] = sub__oneday(t1,t2,sl,hh, n, b, task,datatype,binmin, binmax,numblocks)
if strcmpi(task(1:3), 'dur')
    multfactor = 1000;
    isfreq = 0;
else
    multfactor = 1;
    isfreq = 1;
end;

binmp = sqrt(binmin*binmax);

bs = 32;
idx = find(b > 0);
bon = find(b>0);

sc = side_choice(hh,sl);
firstidx = min(bon); % first psychometric trial of session

% figure;
weberlist=[];
block_hrate = [];
block_replongpct = [];
totalblocks = floor(length(bon)/bs);
lastidx = (firstidx+ (bs*totalblocks))-1;

left_t = find(sl == 1);
rep_long = hh;
rep_long(intersect(left_t, find(hh == 0))) = 1;
rep_long(intersect(left_t,find(hh==1))) = 0;

blocks = {};
ctr=1;
% do logistic fit block-by-block
for k=firstidx:bs:lastidx
    tmpsl = sl(k:(k+bs)-1);
    if strcmpi(datatype,'uses_blocks')
        tones = t1(k:(k+bs)-1) + t2(k:(k+bs)-1);
    elseif strcmpi(datatype,'uses_psychflag')
        tones = zeros(1,bs);
        tones(find(tmpsl==1)) = t1(find(tmpsl==1));        
        tones(find(tmpsl==0)) = t2(find(tmpsl==0));
    else
        error('datatype can either be ''uses_blocks'' or ''uses_psychflag''');
    end;
       

%    fprintf(1,'Block %i: %i to %i\n', ctr, k, (k+bs)-1);
    ctr=ctr+1;
%    fprintf(1,'\n\n');
    %     plot(tones, '.k'); hold on;
    blocks{end+1} = 0;
    blocks{end}.tones=tones;

    [rbins replong tally]  = bin_side_choice(binmin, binmax, 8, isfreq, tones*multfactor, ...
        sc);
    block_hrate = horzcat(block_hrate, mean(hh(k:(k+bs)-1)));
    out = logistic_fitter('init',tones*multfactor, rep_long(k:(k+bs)-1), sqrt(binmin*binmax),0);
    wbr = out.weber; if (wbr == -1), wbr = NaN; end;
    weberlist = horzcat(weberlist, wbr);
end;

if length(block_hrate) < numblocks
    block_hrate=nan(1,numblocks);
    weberlist = nan(1,numblocks);
else   
    block_hrate = block_hrate(1:numblocks);
    weberlist = weberlist(1:numblocks);
end;
