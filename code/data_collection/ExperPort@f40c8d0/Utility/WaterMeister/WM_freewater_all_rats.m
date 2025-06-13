function WM_freewater_all_rats

if datenum(datestr(now,'HH:MM:SS')) > datenum('23:45','HH:MM')
    disp('Sorry but you cannot run this code after 11:45PM');
    disp('Wait until after midnight then try again.');
    return;
end

answer = questdlg('Are you sure you want to free water ALL the rats?','','Yes','No','No');
if strcmp(answer,'No'); return; end
pause(0.1);

name = inputdlg('Enter your name:','',1);

answer = questdlg([name,' are you ABSOLUTELY sure?'],'','Yes','No','No');
if strcmp(answer,'No'); return; end

[E,I] = bdata('select experimenter, initials from ratinfo.contacts where is_alumni=0');
initials = I{strcmp(E,name)};

st = now;

[R,S,E] = bdata(['select rat, starttime, stoptime from ratinfo.water where date="',datestr(now,'yyyy-mm-dd'),'" order by watering']);

RatLists = WM_rat_water_list(1:10,[],'all');
allrats = cell(0);
for i = 1:numel(RatLists)
    temp = unique(RatLists{i});
    temp(strcmp(temp,'')) = [];
    allrats(end+1:end+numel(temp)) = temp;
end

for i = 1:numel(allrats)
    temp = find(strcmp(R,allrats{i})==1,1,'last');
    if ~isempty(temp)
        stemp = S(temp);
        etemp = E(temp);
        
        if strcmp(stemp,etemp)
            continue; 
        end
    end
    
    bdata('INSERT INTO ratinfo.water (date, rat, tech, starttime, stoptime) values ("{S}","{S}","{S}","{S}","{S}")',...
        datestr(st,'yyyy-mm-dd'),allrats{i},initials,datestr(st,'HH:MM:SS'),datestr(st,'HH:MM:SS'));
    
end

