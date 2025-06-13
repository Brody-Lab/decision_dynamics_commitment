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
    
    dd=[dd 'Data/'];
    cd([dd exprmtr filesep rat]);
    fn=dir('*.mat');
    for xi=1:numel(fn)
        s=fn.name;
        tc=textscan(s,'%s','Delimiter','_');
        prt{xi}=tc{1}{2};
        r=tc{1}{end};
    setdate{xi}=r(1:7);
    end
    
    [srtdsets, sdi]=sort(setdate);
    p=prt{sdi(end)};
    if p(1)=='@'
        p=p(2:end);
    end
catch
   
end
cd(olddir)
    
        