%ProRats:
%ratave({'A021', 'A023','A024','A025', 'A028', 'A029', 'A030', 'A033'}, -100,   'varnames', {'SoundInterface_LeftSoundVol$'}, 'vals', [0.02], 'figname', ' (Pro)')
%AntiRats:
%ratave({'A020', 'A022','A026','A027', 'A031', 'A032'}, -100, 'varnames', {'SoundInterface_LeftSoundVol$'}, 'vals', [0.02], 'figname', ' (Anti)')

function [aha]= ratave(ratnames, daterange, varargin)

pairs = { ...
  'figname', ''; ...
  'tau', 30  ; ...
  'fignum', []  ; ...
  'experimenters', {};...
  'protocol', 'ProAnti2' ; ...
  'gotitname' 'hit_history';...
  'usedb',  1 ; ...
  'varnames', {} ; ...
  'vals', []; ...
}; parseargs(varargin, pairs);

%% Load Data

olddir=pwd;
ddir=bSettings('get','GENERAL', 'Main_Code_Directory');
cd(ddir)

nvars = length(varnames); %#ok<USENS>
nrats = length(ratnames);
data = cell(nrats,1);

for r = 1:nrats,
    rat = ratnames{r};
    if ~usedb,
        if ~isempty(experimenters{r}) %#ok<USENS>
                exp = experimenters{r};
        else
            error('~UseDB requires experimenter for all rats');
        end;
        if strcmp(protocol, 'ProAnti2')
        a = recall(rat, exp, ... 
            {'hit_history', 'gotit_history', varnames{1:end}}, ...
            'daterange', daterange, 'protocol', 'ProAnti2', 'history', 1); %#ok<USENS>
        else
        a = recall(rat, exp, ... 
            {'hit_history', gotitname, varnames{1:end}}, ...
            'daterange', daterange, 'protocol', protocol, 'history', 1);
        end;
    else
        % this just uses mysql's built in date/time arithmetic instead of doing it in matlab.
        startdate=bdata(['select date_sub("' datestr(now,29) '" , interval ' num2str(-1*daterange) ' day)']);

        [pd]=bdata(['select protocol_data from bdata.sessions where ratname="' rat '" and sessiondate>="' startdate{1} '" and protocol like "' protocol '%" order by sessiondate']);

        % Translate db-obtained data into what it would look like when read from
        % raw data files:
        a = cell(length(pd), 1, 5);
        if strcmp(protocol, 'ProAnti2'),
            for i=1:length(pd),
                a{i,1,1} = num2cell(pd{i}.hit(:)');
                a{i,1,2} = num2cell(pd{i}.gotit(:)');
            end;
            if nvars~=0,
                for v=1:nvars,
                    a{1,1,v+2} = check_sphDB(varnames{v},'protocol', 'ProAnti2', 'ratname', rat);
                end;
            end;
        else
            error('protocols other than ProAnti2 not yet supported for useDB');
        end;
    end;
    data{r}=a; %#ok<AGROW>
end;
    
cd(olddir);

%% Append variable histories
ntrials        = {};
gotit_history  = {};
hit_history    = {};
day_separators = {};
vars           = {}; %#ok<NASGU>
avg            = {};
nn             = {};
vars           = {};
lastdayend     = 0;
perf           = {};

for r = 1:nrats,
    %reset values for each rat to empty
    a                  = data{r};
    tempntrials        = [];
    temphit_history    = [];
    tempgotit_history  = [];
    tempvars           = cell(nvars,1);
    tempday_separators = [];
    tempavg            = [];

    %Cycle through all days
    for i=1:size(a(:,1,1),1),
        %Append Values
        tempntrials(i)      = length(a{i,1,1});                            %#ok<AGROW>
        temphit_history     = [temphit_history    ; cell2mat(a{i,1,1}')];  %#ok<AGROW>
        tempgotit_history   = [tempgotit_history  ; cell2mat(a{i,1,2}')];  %#ok<AGROW>

        %append variables in a cell array: Note that when read from
        %database, variables are already appended.
        for v = 1:nvars,
            if usedb, tempvars{v} = [tempvars{v} ; a{i,1,2+v}'];%#ok<AGROW>
            else      tempvars{v} = [tempvars{v} ; cell2mat(a{i,1,2+v}')];%#ok<AGROW>
            end;
        end;
        %Append daylength value to list of day separators
        tempday_separators  = [tempday_separators ; length(temphit_history)+0.5];   %#ok<AGROW>

        %Calculate average for the day
        tempnn  = find(~isnan(temphit_history(end-tempntrials(i)+1:end)));
        tempgot = tempgotit_history(end-tempntrials(i)+1:end);
        tempavg = [tempavg ; sum(tempgot(tempnn))/length(tempnn)];           %#ok<AGROW>
    end;

    %store appended values by rat
    ntrials{r}           = tempntrials;                            %#ok<AGROW>
    gotit_history{r}     = tempgotit_history;                %#ok<AGROW>
    hit_history{r}       = temphit_history;                    %#ok<AGROW>
    day_separators{r}    = tempday_separators;              %#ok<AGROW>
    vars{r}              = tempvars;                                  %#ok<AGROW>
    avg{r}               = tempavg;                                    %#ok<AGROW>
    lastdayend           = max(lastdayend, tempday_separators(end)-0.5);
    nn{r}                = find(~isnan(hit_history{r}));               %#ok<AGROW>

    %Calculate exponential average based on gotit of all trials
    perfs = {perf{1:end}; expave(tau,gotit_history{r}(nn{r}))};             %#ok<NASGU,AGROW>
end;

%Vars here
%   ntrials{r}        - vector of ntrials for rat r
%   gotit_history{r}  - entire gotit history of rat r
%   hit_history{r}    - entire hit history of rat r
%   day_separators{r} - vector of values for day breaks
%   vars{r}           - array of length v for rat r, vars{r}{v} 
%   avg{r}            - contains vector of average performance for rat r for each day
%   lastdayend        - value for last day separator for all rats
%   nn{r}             - contains indexes for all non-nan values of hit_history for rat r
%

%% Separate out good trials

%Make a string representing comparison of all vars w/ values
varvals = [];
for v = 1:length(varnames), varvals = strcat(varvals, '(ratvars{', num2str(v), '} == vals(', num2str(v), ')) & '); end; %#ok<AGROW>
findvars = ['find(' varvals(1:end-2) ')' ];

lgdayend = 0;
for r = 1:nrats,
    %get hit and gotit history for this rat
    hith = hit_history{r};
    goth = gotit_history{r};
    
    %find cases where vars meets value reqs for rat r
    ratvars = vars{r}; %#ok<NASGU>
    goodind{r} = eval(findvars); %#ok<AGROW>

    %find new day separators for selected trials of rat r
    [gooddsep{r}, totgdays{r}]= findnewds(goodind{r},day_separators{r}); %#ok<AGROW,AGROW>
    
    %keep track of longest day of all
    lgdayend = max(lgdayend, totgdays{r}(end)-0.5);
    
    %store selected hit history and got it history
    goodhith{r} = hith(goodind{r});                                               %#ok<AGROW>
    goodgoth{r} = goth(goodind{r}); %#ok<AGROW>
    
    %find non-nan trials & appropriate day separators
    nngoodind{r}= find(~isnan(goodhith{r})); %#ok<AGROW>
    [finseps{r}, findays{r}] = findnewds(nngoodind{r}, gooddsep{r}); %#ok<NASGU,AGROW>
    
    %got it history of val req meeting trials without nans
    fingoth{r} = goodgoth{r}(nngoodind{r}); %#ok<AGROW>
    
    %find daily averages for trials where vals meet reqs
    findavg{r}  = dayave(fingoth{r}, finseps{r}); %#ok<AGROW>
    
    %Calculation of exponentially weighted average
    finperfs{r} = expave(tau,fingoth{r}); %#ok<AGROW>
end;

%Vars here
%   goodhith{r} - hit history of trials meeting value reqs for rat r    
%   goodgoth{r} - gotit history of trials meeting value reqs for rat r
%   gooddsep{r} - day separators for trials meeting reqs
%   totgdays{r} - total number of days with good values for rat r
%   goodind{r}  - reference indexes for trial meeting val reqs for rat r
%   nngoodind{r}- indexes of non-nan entries in hh meeting val reqs for rat r
%   nngdsep{r}  - 
%   lgdayend    - gives the value of the last day separator of trials meeting reqs for all rats

%% Average across rats

%Average performance values trial by trial
nanrats = 0;
lastval = 10000000000000;
for r=1:nrats,
    if ~isempty(finperfs{r}),
    lastval = min(length(finperfs{r}),lastval);
    else
        nanrats = nanrats+1;
    end;
end;

allperfs  = zeros(lastval,1);
trialnums = zeros(lastval,1);
totalperfs = zeros(lastval,1);

for i = 1:(lastval),    
    for r=1:nrats,
        if ~isempty(finperfs{r})
            totalperfs(i) = totalperfs(i) + finperfs{r}(i);                    %#ok<AGROW>
        end;
    end;
    trialnums(i) = i;
    allperfs(i) = totalperfs(i)/(nrats-nanrats);
end;

% Average daily values and day separators day by day
lastday = 100000000000000000;
for r = 1:nrats
    if ~isempty(findavg{r}),
        lastday = min(lastday, length(findavg{r}));
    end;
end;

alldaysep   = zeros(lastday,1);
allavg      = zeros(lastday,1);
totaldaysep = zeros(lastday,1);
totalavg    = zeros(lastday,1);

for i = 1 : lastday,
    for r = 1 : nrats,
        if ~isempty(finseps{r})
            totaldaysep(i)= totaldaysep(i)+ finseps{r}(i); %#ok<AGROW>
            totalavg(i)   = totalavg(i)   + findavg{r}(i); %#ok<AGROW>
        end;
    end;
    alldaysep(i)= totaldaysep(i)/(nrats-nanrats);
    allavg(i)   = totalavg(i)/(nrats-nanrats);
end;

%% Stuff for plotting 

%Figure number
if isempty(fignum),   figure; fignum = gcf; end; %#ok<NODEF>
if ~ishandle(fignum), figure(fignum); end;
ch = get(fignum, 'Children');
if ~isempty(ch), delete(ch); end;

ax = axes('Parent', fignum);
handles = zeros(nrats+1,1);


%ind rat color

ratcolor  = [.9 .9 .9];
avgcolor  = [1 0 0];                                                      %#ok<NASGU>

%Plot each rat in a light gray
for r = 1:nrats,
    if ~isempty(finperfs{r})
        l = plot(ax, trialnums, finperfs{r}(1:length(trialnums)), '.-');
        hold(ax, 'on');
        handles = [handles;l];                                                   %#ok<AGROW>
        set(l, 'Color', ratcolor);
    end;
end;

l = plot(ax, trialnums, allperfs(1:length(trialnums)), '.-');
hold(ax, 'on');
handles = [handles;l];                                                     %#ok<NASGU,AGROW>
set(l, 'Color', avgcolor);

yl = get(ax, 'ylim'); set(ax, 'ylim', [yl(1) 1.03]);
xl = get(ax, 'xlim'); set(ax, 'xlim', [0 length(trialnums)*1.01]);         %#ok<NASGU>

for r = 1:nrats,
    if ~isempty(finseps{r})
        set(vlines(ax, finseps{r}), 'Color', ratcolor);
    end;
end;
set(ax, 'Layer', 'top');
set(vlines(ax, alldaysep), 'Color', avgcolor);

set(fignum, 'Name', ['Rat Average,' figname ' n = ' num2str(nrats - nanrats)]);

%% I am here

% 
% S = msegment_finder(current_block);
% yl = get(ax, 'ylim');
% for i=1:size(S,1),
%     if S(i,3)==1,
%         p = patch([S(i,1), S(i,2), S(i,2), S(i,1), S(i,1)], [yl(1) yl(1) yl(2) yl(2) yl(1)], ...
%             -100*ones(1,5), 0.9*[1 1 1], 'Parent', ax);
%         set(p, 'EdgeColor', 'none');
%     end;
% end;
% 
% 
% 
% legend(ax, handles, leg, 'Location', 'Best');
% legend(ax, 'boxoff');
% set(ax, 'YAxisLocation', 'right', 'YGrid', 'on')
% 
% set(fignum, 'Name', rat);

if nargout>0, aha = finperfs; end;

end

%% Function: Find new day separators

    function [newdayseps, totaldays] = findnewds(indexes, olddayseps)
        day = 1;
        newdayseps = zeros(day);
        for i = 1:length(indexes),
            if indexes(i)<= olddayseps(day), newdayseps(day) = newdayseps(day) + 1;   %#ok<AGROW>
            else day = day + 1;              newdayseps(day) = newdayseps(day-1) + 1; %#ok<AGROW>
            end;
        end;
        for i = 1:day,
            newdayseps(i) = newdayseps(i) + 0.5; %#ok<AGROW>
        end;
        totaldays = day;
    end

%% Function: Exponential Average
    function [newgots] = expave(tau, history)
        newgots = zeros(size(history));
        e = exp(-(0:tau*4)/tau); e = e(end:-1:1);
        for i=1:length(history),
            mye = e(end-min(length(e), i)+1:end); mye = mye/sum(mye);
            newgots(i) = sum(history(i-length(mye)+1:i).*mye');
        end;
    end

%% Function: Find Daily averages using day separators

    function [dayaves] = dayave(vector, separators)
       totntrials = length(vector);
       ndays = length(separators);
       total = zeros(ndays);
       ntrials = zeros(ndays);
       dayaves = zeros(ndays); %#ok<NASGU>
       day = 1;
       for i = 1 : totntrials,
            if i > separators(day),
                day = day + 1;
            end;
            ntrials(day) = ntrials(day) + 1;
            total(day)   = total(day)   + vector(i);
       end;
       dayaves = total./ntrials;
    end