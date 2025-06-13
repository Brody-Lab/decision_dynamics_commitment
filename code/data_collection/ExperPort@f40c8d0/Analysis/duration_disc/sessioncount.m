function [] = sessioncount(ratlist, varargin)
% compares session #s before and after lesion
pairs = { ...
    'infile_before', 'psych_before' ; ...
    'infile_after', 'psych_after' ; ...
    };

parse_knownargs(varargin, pairs);

if isstr(ratlist)
    ratlist = {ratlist};
end;

wt = 300;
ht = 200;
xStart = 100;
yStart = 100;

for r = 1:length(ratlist)
    [t_pre from_pre to_pre]= session_tally(ratlist{r}, 'infile', infile_before);
    [t_post from_post to_post] = session_tally(ratlist{r}, 'infile', infile_after);

    figure; set(gcf,'Menubar','none','Toolbar','none');
    l=plot([1 2], [t_pre t_post], '.b'); set(l,'MarkerSize',20);
    title(sprintf('%s: Pre: (%s-%s)\nPost: (%s-%s)', ratlist{r}, from_pre, to_pre, ...
        from_post, to_post));
    set(gcf,'Position', [xStart yStart wt ht]);
    set(gca,'XLim',[0 3], 'XTick', [1 2], 'XTickLabel',{'before','after'},'YLim', [0 30]);
    xStart = xStart + (wt*1.1);
end;