function [hostlist] = show_hosts(ratlist, varargin)

% Shows which rig a rat was trained on, for a list of rats.
% Expects hostname to be cnmcXX where XX is the number

pairs = { ...
    'show_all', 0 ; ...
    'from', '000000'; ...
    'to', '999999' ; ...
    'quiet', 0 ; ...% if true, suppresses stdout output.
   
    };
parse_knownargs(varargin,pairs);

% Row for rat
% col 1: ratname
% col 2: host # for date range (array)
hostlist = {};

if isstr(ratlist),
    ratlist = {ratlist};
end;

if show_all > 0

    tlist = rat_task_table('blah', 'get_current',1);
    ratlist = tlist(:,1);
    if strcmpi(from,'000000') && strcmpi(to,'999999')
        from = yearmonthday(now);
        to = yearmonthday(now);
    end;
else
    tlist = rat_task_table(ratlist);
end;

for r = 1:length(ratlist)
    task = tlist{r,2};
    if strcmpi(task(1:3), 'dur'), fname = 'host_duration'; else fname = 'host_pitch'; end;
    get_fields(ratlist{r}, 'from', from, 'to', to, 'datafields', {fname});

    fname = eval(fname); fname = fname{1};
    %     stripped = [];
    %     for k = 1:length(fname),
    %         str = fname{k};
    %         stripped = horzcat(stripped, str2num(str(5:end)));
    %     end;

    hostlist = vertcat(hostlist, {ratlist{r}, fname});
end;

if show_all >0
    if isempty(strfind(pwd,'Princeton'))
        [idx sidx] = sort(cell2mat(hostlist(:,2)));
        hostlist2 = hostlist(sidx, :);
        hostlist = hostlist2;

    end;

    if quiet < 1
        for r = 1:rows(hostlist)
            tmp = hostlist{r,2};
            fprintf(1,'#%i\t%s:\t%i\n', r, ratlist{r}, tmp);
        end;
    end;

else
    
    if quiet < 1
        for r = 1:rows(hostlist)
            tmp = hostlist{r,2};
            fprintf(1,'#%i\t%s:\t%i\n', r, ratlist{r}, tmp);
        end;
    end;
    
%     figure;
%     for r = 1:rows(hostlist)
%         tmp = hostlist{r,2};
%         l=plot(1:length(tmp), tmp, '.r');
%         set(l,'Color', rand(1,3)); hold on;
%     end;
% 
%     set(gca, 'XTickLabel', dates,'YTick', 1:1:20,'YLim',[1 20]);
%     legend(ratlist);
end;