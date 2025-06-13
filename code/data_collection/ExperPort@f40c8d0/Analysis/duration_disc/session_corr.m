function [] = session_corr(ratname, date,varargin)
% show bbspl correction and lprob value for session

if length(varargin) > 0
    from = varargin{1};
else
    from = 1;
end;

load_datafile(ratname, date);
ratrow = rat_task_table(ratname);
task = ratrow{1,2};

lp = cell2mat(saved_history.SidesSection_LeftProb);

% Bad Boy SPL
bbspl = saved_history.TimesSection_BadBoySPL;

bb = zeros(length(bbspl), 1);
i = find(strcmpi(bbspl, 'normal'));
bb(i) = 1;
i = find(strcmpi(bbspl, 'Louder'));
bb(i) = 2;
i = find(strcmpi(bbspl,'Loudest'));
bb(i) = 3;


% ---------------------------------
% Plotting
figure;
subplot(2,1,2);

plot(from:length(lp), lp(from:end), '-b');
set(gca,'XLim', [from max(2,length(lp))],'YLim',[0 1],'YTick', [0 0.2 0.5 0.8 1]);
s = sprintf('%s: %s (%s)\n Value of LProb', make_title(ratname), make_title(task), ...
    date);
t =  title(s);
set(t,'FontSize',14);
xlabel('Trial #');
ylabel('LProb (from 0 to 1)');


% badboyspl
subplot(2,1,1);
set(gcf,'Position',[1082  100 360 280] , 'Menubar', 'none','Toolbar','none')
plot(1:length(bb), bb, '.r');
ylabel('BadboySPL');
set(gca,'YTick', 1:3, 'YTickLabel', {'normal','Louder','LOUDEST'}, 'XLim', ...
    [1 max(2,length(bb))], 'YLim', [0 4]);
xlabel('Trial #');
s = sprintf('%s: %s (%s)\nBadBoySPL', make_title(ratname), make_title(task), date);
t = title(s); set(t,'FontSize',14);

