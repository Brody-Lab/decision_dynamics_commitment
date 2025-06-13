function populate_tech_schedule(DT,varargin)

%Adds tech names to the tech schedule between dates defined by DT according to their shifts
%which are defined in the contacts page. Any dates already populated are
%skipped.
%Written by Chuck

TS = [];
[E,S] = bdata('select experimenter, tech_shifts from ratinfo.contacts where is_alumni=0');
for i = 1:numel(E)
    if ~isempty(S{i}) && isempty(str2num(S{i})) %#ok<ST2NM>
        %The tech_shifts now also includes rigs experimenters are assigned
        %to fix. This will only be numbers. str2num will return empty if it
        %finds any characters. 2019-07-24 -Chuck
        eval(['TS.',E{i},'={};']);
        x = S{i};
        b = [0,find(x == ',' | x == ' '),numel(x)+1];
        for j = 1:numel(b)-1;
            eval(['TS.',E{i},'{end+1} = x(b(j)+1:b(j+1)-1);']);
        end
    end
end

T = fields(TS);

if     nargin == 0;  dt1 = now+1;                       dt2 = now+1; 
elseif ~iscell(DT);  dt1 = datenum(DT,   'yyyy-mm-dd'); dt2 = datenum(DT,'yyyy-mm-dd');
else                 dt1 = datenum(DT{1},'yyyy-mm-dd'); dt2 = datenum(DT{2},'yyyy-mm-dd');
end

dt = dt1 - 1;
L = 'abc';

while dt ~= dt2;
    dt = dt + 1;

    dstr = datestr(dt,'yyyy-mm-dd');
    dltr = datestr(dt,'D');
    dday = datestr(dt,'dddd');

    if strcmp(dday,'Sunday');   dltr = 'U'; end
    if strcmp(dday,'Thursday'); dltr = 'R'; end
    
    sa = ''; sb = ''; sc = '';
    for i = 1:3
        for t = 1:numel(T)
            S = eval(['TS.',T{t},';']);
            for s = 1:numel(S)
               if strcmp(S{s},[dltr,L(i)])
                   eval(['s',L(i),' = [s',L(i),','' '',T{t}];']);
               end
            end
        end
    end
    
    temp = find(sa ~= ' ',1,'first');
    if ~isempty(temp) && temp > 1; sa = sa(temp:end); end 
    
    temp = find(sb ~= ' ',1,'first');
    if ~isempty(temp) && temp > 1; sb = sb(temp:end); end 
    
    temp = find(sc ~= ' ',1,'first');
    if ~isempty(temp) && temp > 1; sc = sc(temp:end); end 
    
    x = bdata(['select day from ratinfo.tech_schedule where date="',dstr,'"']);
    if isempty(x)
        disp([dstr,' ',dday,'  A:',sa,'  B:',sb,'  C:',sc]);
        
        bdata(['INSERT INTO ratinfo.tech_schedule (date, day, overnight, morning, evening)',...
           ' values ("{S}","{S}","{S}","{S}","{S}")'],dstr,dday,sa,sb,sc);
    end
end
