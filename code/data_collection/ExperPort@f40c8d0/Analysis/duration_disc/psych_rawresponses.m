function [tones sc] = psych_rawresponses(ratname, varargin)
% Simply plots the side choice (went left or right) against tone duration, without binning.
% Can do this for an aggregated dataset or across a range of dates
pairs =  { ...
    'from', '000000'; ...
    'to', '999999'; ...
    'given_dateset', {} ; ...
    'use_dateset',''; ... % [before | after | given | '']
    'infile', 'psych' ; ... % name for output file. Default is: psych.mat
    'experimenter','Shraddha'; ...
    };
parse_knownargs(varargin, pairs);

ratrow = rat_task_table(ratname);

psychf='psych';left_stim ='dur_short';
right_stim ='dur_long';
mp = sqrt(200*500);

task = ratrow{1,2};
if strcmpi(task(1:3),'dua')
    psychf='pitch_psych';
    left_stim = 'pitch_low';
   right_stim = 'pitch_high';
   mp = sqrt(5*17.5);
end;
        

datafields = {psychf,'sides',left_stim right_stim,'tone_spl'};

switch use_dateset
    case 'before'
        infile = 'psych_before';

        global Solo_datadir;
        if isempty(Solo_datadir), mystartup; end;
        outdir = [Solo_datadir filesep 'Data' filesep experimenter filesep ratname filesep];
        fname = [outdir infile '.mat'];

        load(fname);
    
        psych = psychflag;
        sides = side_list;
      %  dur_short = left_tone;
      %  dur_long = right_tone;
    case 'after'
        infile = 'psych_after';

        global Solo_datadir;
        if isempty(Solo_datadir), mystartup; end;
        outdir = [Solo_datadir filesep 'Data' filesep experimenter filesep ratname filesep];
        fname = [outdir infile '.mat'];

        load(fname);

        psych = psychflag;
        sides = side_list;
      %  dur_short = left_tone;
      %  dur_long = right_tone;
        
    case 'given'

        get_fields(ratname,'use_dateset','given', 'given_dateset', given_dateset,'datafields',datafields);
        left_tone = eval(left_stim);
        right_tone = eval(right_stim);
        psych = eval(psychf);
        
    case ''
        get_fields(ratname,'from',from,'to',to,'datafields',datafields);
        left_tone = eval(left_stim);
        right_tone = eval(right_stim);
        psych = eval(psychf);
    otherwise
        error('invalid use_dateset');
end;

% also have tone_spl
tone_list = zeros(size(hit_history));
lefttr = find(sides == 1);
righttr = find(sides == 0);
tone_list(lefttr) = left_tone(lefttr);
tone_list(righttr) = right_tone(righttr);

if strcmpi(task(1:3),'dur'), tone_list = tone_list*1000; end;

idx = find(psych > 0);
hh=hit_history ;% hh = hit_history(idx);
sl=sides;% sl = sides(idx);
spl = tone_spl% tone_list=tone_list(idx);
% spl = tone_spl(idx);

sc = zeros(size(sl)); % 1 = went left, 0 went right.
went_left = intersect(find(sl > 0), find(hh > 0)); % went L correctly
went_left = union(went_left, intersect(find(sl < 1), find(hh < 1))); % answered L incorrectly
sc(went_left) = 1;
went_right = setdiff(1:length(sc), went_left);

tones = log(tone_list);


little_tones = find(tone_list < 9);
right4little = intersect(went_right, little_tones);


figure;
plot(tone_list, sc,'.k');
hold on; line([mp mp],[0 2], 'Color','r','LineStyle',':');
set(gca,'YLim',[-1 2],'YTick', [0 1], 'YTickLabel',{'Went R', 'Went L'});
title('Side choice as function of tone duration');

2;
