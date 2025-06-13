function [] = metric_beforeafter(ratname, mymetric,action)

if nargin < 3
    action='load';
end;

mset={'numtrials', 'hitrate'};
if ~ismember(mymetric, mset)
    error('invalid metric');
end;

global Solo_datadir;
if isempty(Solo_datadir), mystartup; end;

indir= [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Set_Analysis'];

fprintf(1,'\n>>>>>>>>>>>\n%s: %s\n\n', ratname, mymetric);
infile=[indir filesep ratname '_' mymetric];
switch action
    case 'save'
        ratrow = rat_task_table(ratname);
        befdate = ratrow{1,4};
        bdates = get_files(ratname, 'fromdate', befdate{1}, 'todate', befdate{2});
        bdates= bdates(sub__whichdates2use(bdates, 1, 1000, 7));

        aftdate = ratrow{1,5};
        adates = get_files(ratname, 'fromdate', aftdate{1}, 'todate', aftdate{2});
        adates= adates(sub__whichdates2use(adates, 1,3, 1000));

        if strcmpi(mymetric, 'numtrials')
            bmetric=numtrials_oversessions(ratname, 'use_dateset', 'given', 'given_dateset', bdates, ...
                'graphic',0);
            ametric=numtrials_oversessions(ratname,'use_dateset','given','given_dateset', adates, ...
                'graphic',0);
        else
            bmetric=session_hrate_oversessions(ratname, 0,0,'use_dateset','given', 'given_dateset', bdates, ...
                'graphic',0);
            ametric=session_hrate_oversessions(ratname, 0,0, 'use_dateset','given','given_dateset', adates, ...
                'graphic',0);
        end;
        save(infile, 'bmetric','ametric');

    case 'load'
        try
            load(infile);
        catch
            fprintf('*** %s:%s:File not found - resaving... ***');
            metric_beforeafter(ratname, mymetric,'save');
            load(infile);
        end;

        [xpos mlist slist]= makebargroups({bmetric, ametric}, [0 0 1; 1 0 0]);
        [sig p] = permutationtest_diff(bmetric, ametric, 'typeoftest','onetailed_gt0');
        fprintf(1,'Significance (onetailed_gt0): %i (p=%1.4f)\n', sig, p);

        yval = mlist+slist;

        joinwithsigline(gca,xpos(1),xpos(2),yval(1)*1.2,yval(2)*1.3,max(yval)*1.3);
        if p < 0.001, stars='***';
        elseif p < 0.01, stars='**';
        elseif p < 0.05, stars='*';
        else stars='ns'; end;
        text(1, max(yval)*1.32, stars,'FontSize',20,'FontWeight','bold');


        if strcmpi(mymetric,'numtrials')
            set(gca,'YLim',[0 max(yval)*1.5], 'YTick',0:50:max(yval)*1.5, 'XTick',[]);
            ylabel('# trials');
        else
            set(gca,'YLim',[0 1.5],'YTick',0:0.25:1, 'YTickLabel',0:25:100,'XTick',[]);
            ylabel('Accuracy rate (%)');
            bmetric=bmetric*100;
            ametric=ametric*100;
        end;
        set(gca,'XLim',[-1 3]);
        axes__format(gca);
        title(sprintf('%s: %s', ratname, mymetric));

        fprintf(1,'Before = %2.1f%% (%2.1f)\nAfter = %2.1f%% (%2.1f)\n', ...
            mean(bmetric), std(bmetric)/sqrt(length(bmetric)), ...
            mean(ametric), std(ametric)/sqrt(length(ametric)));

        uicontrol('Tag','figname','Style','text','String',sprintf('%s_avg%s', ratname, mymetric), 'Visible','off');

        fprintf(1,'\n\n<<<<<<<\n');

    otherwise
        error('invalid action');
end;



% determines subset of sessions wanted using arg 2,3,4
function [useidx] = sub__whichdates2use(dateset, dstart, dend, lastfew)
useidx=1:length(dateset);

str=sprintf('both ''lastfew'' and ''dend'' have been set. dstart=%i,dend=%i,lastfew=%i\n', dstart,dend,lastfew);
if lastfew < 1000 && dend<1000
    error(str);
elseif lastfew < 1000
    if dstart > 1
        error('sorry, dstart must be 1 if using lastfew');
    end;
    lastfew = min(lastfew, length(dateset));
    dstart=length(useidx)-(lastfew-1);
    dend = length(useidx);
    %    useidx = useidx(end-(lastfew-1):end);
elseif dend < 1000 % first few X sessions
    dstart=1;
    % useidx=useidx(1:i);
else
    dstart=1; dend=length(dateset); % use whole set
end;

d2use=dstart:dend;
% base case - dateset isn't long enough; must use all dates therein
if length(dateset) < length(d2use)
    fprintf(1,'\t%s:Not enough dates to filter; using whole set\n', mfilename);
    useidx = 1:length(dateset);
else
    useidx=useidx(dstart:dend);
end;
