function [] = rampdurvalue(rat, task, varargin)
pairs = { ...
    'from', '000000'; ...
    'to', '999999'; ...
    };
parse_knownargs(varargin,pairs);

dates = get_files(rat, 'fromdate', from, 'todate', to);

megard = [];
for d = 1:rows(dates)
    load_datafile(rat,task,dates{d});
    megard = [megard saved.ChordSection_RampDur];
end;

figure;
plot(1:length(megard), megard*1000,'.b');
set(gca,'XTickLabel', dates,'XTick', 1:rows(dates),'XLim', [0 rows(dates)+1],'YTick',0:2:60,'YTickLabel',0:2:60,'YLim',[0 60]);
xlabel('Session date');
ylabel('Ramp duration value (s)');

title(sprintf('Ramp duration for %s',rat));