function [] = iti_view


cannula_dur = {'S005','S014'};
% currently at sharpening or beyond - ITI should be stable
sharpdur = { 'S018','S029', 'S025', 'S039'};
cshldur = {'Adler', 'Hudson'};

cannula_freq = {'S013','S024'};
sharpfreq = {'S028','S027'};
cshlfreq = {'Watson', 'Hound'};


ratset = [cshlfreq cshldur]; %[cannula_freq sharpfreq]; %[cannula_dur sharpdur];
mytitle = 'CSHL rats';

% ratset = [cannula_dur sharpdur];
% mytitle = 'Duration';


itilen = [];
itireinit = [];
extraiti = [];

for r = 1:length(ratset)
    fprintf(1,'%s:', ratset{r});
    sf = sub__settingsfile(ratset{r});
  
   load(sf);
   itilen = horzcat(itilen, saved.TimesSection_ITILength);
   itireinit = horzcat(itireinit, saved.TimesSection_ITIReinitPenalty);
   extraiti = horzcat(extraiti, saved.TimesSection_ExtraITIonError);    
end;

figure;
subplot(3,1,1); plot(itilen,'.k'); ylabel('iti len');title(mytitle); sub__format(gca, ratset);
subplot(3,1,2); plot(itireinit,'.k'); ylabel('itireinit');title(mytitle);sub__format(gca, ratset);
subplot(3,1,3); plot(extraiti,'.k'); ylabel('extraiti');title(mytitle);sub__format(gca, ratset);


% gets name of latest settings file for rat
function [fullname] = sub__settingsfile(ratname)
global Solo_datadir;

rat_dir = [Solo_datadir filesep 'Settings' filesep 'Shraddha' filesep ratname filesep];
u = dir([rat_dir 'settings_*_' 'Shraddha' '_' ratname '*.mat']);

no_settings_flag=1;
if ~isempty(u),
    [filenames{1:length(u)}] = deal(u.name);
    filenames = sort(filenames'); %#ok<UDIM> (can't use dimension argument with cell sort)
    protocol_regex = '%[A-Za-z_]obj';
    fullname = []; myprot = '';
    for i=length(u):-1:1, %     search from the end back
        fdate = filenames{i}(end-10:end-5);
        fver = filenames{i}(end-4);
        if         ~isempty(fdate) &&  str2double(fdate) <= str2double(yearmonthday),
            fullname = [filenames{i}]; %     We've found it.
            no_settings_flag=0;
            b = findstr(filenames{i}, 'obj_');
            myprot = filenames{i}(10:b-1); if strcmpi(myprot(1),'@'), myprot = myprot(2:end); end;
            break;
        end;
    end;
end;

fprintf(1,'%s\n\t%s\n', myprot, fullname);
fullname = [rat_dir fullname];

function [] = sub__format(ax, ratlist)
c = get(ax,'Children'); x = get(c(1),'XData');
set(gca,'XTick', 1:length(x), 'XTickLabel', ratlist, 'XLim',[0 length(x)+1]); 
xlabel('ratname'); 
axes__format(gca);