function p=getProtocol(exprmtr,rat)

olddir=cd;



p='';
try
    
    dd=bSettings('get','GENERAL','Main_Data_Directory');

    if isnan(dd)
        dd='../SoloData';
    end
    
    if dd(end)~=filesep
        dd(end+1)=filesep;
    end
    
    dd=[dd 'Settings/'];
    cd([dd exprmtr filesep rat]);
    fn=dir('settings_*_*_*_*.mat');
    for xi=1:numel(fn)
        s=fn(xi).name;
        tc=textscan(s,'%s','Delimiter','_');
        prt{xi}=tc{1}{2};         %#ok<AGROW>
        r=tc{1}{end};
        % Must have had 5 fields (settings, prot, exprtr, rat, date), the
        % date must be 11 chars long (7 of date plus '.mat'), the first six
        % of those must be numbers, not letters:
        if length(tc{1}) == 5 && length(r) == 11 && all(~isletter(r(1:6))), 
          setdate{xi}=r(1:7); %#ok<AGROW>
        else % not a file we want, give it a really early date, 2000:          
          setdate{xi}='000101a'; %#ok<AGROW>
        end;
    end
    
    [srtdsets, sdi]=sort(setdate);

    % Look only at settings that are not later than today
    ymd = str2double(yearmonthday); keeps = ones(size(sdi)); 
    for i=1:length(sdi), if str2double(srtdsets{i}(1:6)) > ymd, keeps(i) = 0; end; end;
    srtdsets = srtdsets(find(keeps)); sdi = sdi(find(keeps)); %#ok<FNDSB,NASGU>
    
    p=prt{sdi(end)};
    if p(1)=='@'
        p=p(2:end);
    end
catch
   
end
cd(olddir)
    
        