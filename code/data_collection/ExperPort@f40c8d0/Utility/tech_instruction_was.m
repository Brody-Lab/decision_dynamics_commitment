function tech_instruction = tech_instruction_was(ratname,date)
    % reconstructs from the scheduler what the message would have been that
    % appeared in runrats to the technician for a given rat and date
    % (could be a day-specific message that RunRats parsed)
    is_past_tomorrow = datetime(date)>datetime(datestr(now+1));
    if is_past_tomorrow
        error('No schedule exists yet for %s.',date);
    end
    daycodes = {'u','m','t','w','r','f','s'};
    dayltr = daycodes(weekday(date));
    instruction = bdata(['select instructions from ratinfo.schedule',...
        ' where ratname="',ratname,'" and date="',date,'"']); 
    if isempty(instruction)
        error('Rat %s was not on the schedule for %s.',ratname,date);
    end
    % the code below is taken directly from 
    % the code used by RunRats to display the tech instruction
    for i=1:length(instruction)
        ti=instruction{i};
        if sum(ti=='#') >= 2 && rem(sum(ti=='#'),2)==0
            %This may be a day specific message. Let's try to parse it
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
            tech_instruction{i} = TI;
        else
           tech_instruction{i}=instruction{i};
        end
    end
end