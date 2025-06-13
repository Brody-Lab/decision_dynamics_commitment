function Instructions = MM_get_tech_instructions(ratname,session)


ti = bdata(['select instructions from ratinfo.schedule where ratname="',ratname,'" and date="',...
    datestr(now,'yyyy-mm-dd'),'" and timeslot=',num2str(session)]);
if iscell(ti) && ~isempty(ti); ti = ti{1};
else                           ti = '';
end
try
    if sum(ti=='#') >= 2 && rem(sum(ti=='#'),2)==0
        %This may be a day specific message. Let's try to parse it

        if     strcmp(datestr(now,'ddd'),'Mon'); dayltr = 'm';
        elseif strcmp(datestr(now,'ddd'),'Tue'); dayltr = 't';
        elseif strcmp(datestr(now,'ddd'),'Wed'); dayltr = 'w';
        elseif strcmp(datestr(now,'ddd'),'Thu'); dayltr = 'r';
        elseif strcmp(datestr(now,'ddd'),'Fri'); dayltr = 'f';
        elseif strcmp(datestr(now,'ddd'),'Sat'); dayltr = 's';
        else   strcmp(datestr(now,'ddd'),'Sun'); dayltr = 'u';
        end

        p = find(ti == '#');

        TI = ti(1:p(1)-1);

        for i = 1:2:numel(p)-1
            d = ti(p(i)+1:p(i+1)-1);
            if ~isempty(strfind(lower(d),dayltr))
                %This portion of the instructions should be
                %displayed today
                msg = '';
                if i+1==numel(p)
                    if numel(ti)>p(end); msg = ti(p(end)+1:end); end
                else
                    msg = ti(p(i+1)+1:p(i+2)-1);
                end

                TI = [TI,' ',msg]; %#ok<AGROW>
            end
        end

        fstltr = find(TI ~= ' ',1,'first');
        if fstltr > 1; TI(1:fstltr-1) = ''; end
        ti = TI;

    end
catch %#ok<CTCH>
    disp('Error while parsing tech instructions. Displaying everything.')
end

%Now let's check the instructions for the safety code
d = find(ti == '$');
s = '';
if numel(d) > 1
    for i = 1:2:numel(d) - 1
        temp = ti(d(i)+1:d(i+1)-1);
        s(end+1:end+numel(temp)) = temp;
    end
end
if     ~isempty(strfind(s,'A')) && ~isempty(strfind(s,'B')) >  0; SafetyMode = 'AB'; 
elseif ~isempty(strfind(s,'A')) &&  isempty(strfind(s,'B')) == 0; SafetyMode = 'A'; 
elseif  isempty(strfind(s,'A')) && ~isempty(strfind(s,'B')) >  0; SafetyMode = 'B'; 
else                                                              SafetyMode = ''; 
end

bad = [];
if numel(d) > 1
    for i = 1:2:numel(d) - 1
        bad(end+1:end+numel(d(i):d(i+1))) = d(i):d(i+1);
    end
end
ti(bad) = [];

%if ~isempty(SafetyMode)
    Instructions = ti;
%else
%    Instructions = '';
%end