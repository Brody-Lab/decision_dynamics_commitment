function [] = show_detailed_hits(rat, task, date, start, fin, varargin)

%close all;

pairs = { ...
    'rt_color', [0 0.8 0] ; ...
    'lt_color', [0 0 0.8] ; ...
    'binmin', 0           ; ...
    'binmax', 0           ; ...
%    'closer', [0.8 0.4 0]    ; ...
    'closest', [0.8 0 0 ] ; ...
    'win_width', 400 ; ...
    };

parse_knownargs(varargin, pairs);

if binmin == 0 || binmax == 0
    error('Bins should be positive!');
end;

trials = (fin-start)+1;

fig = findobj('Tag', 'tone_details');
if isempty(fig), fig = figure; else, fig = clf(fig); end;
set(0,'CurrentFigure', fig);
ssize = get(0,'ScreenSize');
set(fig,'Position', [ssize(3)-win_width 0 win_width 600],'Menubar','none', 'Toolbar', 'none', 'Tag', 'tone_details');
lbl = 0:floor(0.2*trials):trials-1; lbl = start + lbl;

axes('Position', [0.07 0.05 0.25 0.9], 'XTick', [1 2 3],'YTick',1:floor(0.2*trials):trials, ...
        'XTickLabel', {'Tone', 'Hit?', 'Bin'}, ...
        'YTickLabel', num2str(lbl') ...
        );

% LHS axis
axis([0.75 3.5 -1 trials+2]);

load_datafile(rat, task, date(1:end-1), date(end));

hh = eval(['saved.' task '_hit_history']);

t1 = saved.ChordSection_tone1_list;
t2 = saved.ChordSection_tone2_list;

left = 1; right = 1-left;
tones = zeros(size(t1));

sides = saved.SidesSection_side_list;
tones(find(sides == left)) = t1(find(sides == left));
tones(find(sides == right)) = t2(find(sides == right));
tones = tones*1000;

leftie = find(sides == left); rightie = find(sides == right);
long_short = cell(size(hh));
long_short(intersect(rightie, find(hh==1))) = {'LONG'};
long_short(intersect(rightie, find(hh==0))) = {'short'};
long_short(intersect(leftie, find(hh==1))) = {'short'};
long_short(intersect(leftie, find(hh==0))) = {'LONG'};
hh = eval(['saved.' task '_hit_history;']); %rep_long = hh;
%rep_long(intersect(leftie, find(hh == 0))) = 1;
%rep_long(intersect(leftie,find(hh==1))) = 0;

p = get(fig, 'Position');
bar_width = p(4)/trials;

[dummy bins] = generate_bins(binmin, binmax, 8);
mp = sqrt(binmin*binmax);
bin_mp = bin_data(1, mp, bins);

tones = tones(start:fin); 
%rep_long = rep_long(start:fin);
hh = hh(start:fin);
long_short = long_short(start:fin);

[bin_nos, tally, replong] = bin_data(hh, tones, bins);

% generate LHS graph: Tones
hold on;
for k = 1:trials
%    if sides(k) == left, tcolor = lt_color; else, tcolor = rt_color; end;
    text(1, k, sprintf('%3.0f',tones(k)), 'FontWeight','bold', 'FontSize', 11);
    if strcmpi(long_short{k},'short'), scolor = lt_color; else, scolor = rt_color; end;
  %  text(2, k, long_short{k}, 'Color', scolor);
    if hh(k) > 0, hcolor = [0 0.8 0]; else, hcolor = [0.8 0 0]; end;
    plot(2, k, '.', 'Color', hcolor);
    if within(bin_nos(k), bin_mp, 1)
        bcolor = closest; fw = 'bold';
%     elseif within(bin_nos(k), bin_mp, 2)
%         bcolor = closer; fw = 'normal';
    else
        bcolor = 'k'; fw = 'normal';
    end;
    text(3, k, sprintf('#%i', bin_nos(k)), 'Color', bcolor, 'FontSize', 11, 'FontWeight',fw);
end;

% generate RHS graph: summary tally
axes('Position', [0.4 0.6 0.53 0.3],'YTick',[]);
p = replong ./ tally;
bar(bins(1:end-1), tally, 'stacked');
set(gca,'YTick',[]); y_max = 1.5*max(tally);
for k = 1:length(bins)-1
    if isnan(p(k)), p(k) = 0;end;
    h = text(bins(k)-10, tally(k)+2, sprintf('%2.0f%%\n(%i/%i)', p(k)*100, replong(k), tally(k)));   
    if tally(k) == max(tally), set(h, 'FontWeight', 'bold', 'FontSize',11); end;
end;
xlabel('Bins of tone duration (milliseconds)');
ylabel('Sample size (n)');
axis([binmin-25 binmax+15 0 y_max]);

t = title(sprintf('%s: %s (%s)\nTrials %i to %i', make_title(rat), make_title(task), date, start, fin));
set(t, 'FontSize', 12, 'FontWeight', 'bold');

function [r] = within(d, target, slack)
    r =  (d <= target+slack) && (d >= target-slack);

