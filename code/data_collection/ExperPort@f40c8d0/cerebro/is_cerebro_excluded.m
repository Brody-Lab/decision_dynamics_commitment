function exclude = is_cerebro_excluded(ratname,date)
    ratnames = bdata(['select ratname from ratinfo.cerebro_sessions',...
        ' where date = "',date,'"']);
    if ismember(ratname,ratnames)
        exclude=true;
    else
        exclude=false;
    end
    if ~exclude
        runrats_message = tech_instruction_was(ratname,date);
        if length(runrats_message)>1
            error('');
        end
        if isempty(strfind(lower(runrats_message{1}),'plug in')) %does not contain the string 'plug in'
            exclude=true;
        elseif ~isempty(strfind(lower(runrats_message{1}),'not plug in')) % contains the string 'not plug in'
            exclude=true;
        end
    end
    if ~exclude
        ratnames = bdata(['select ratname from ratinfo.technotes',...
            ' where datestr = "',date,'"']);   
        if ismember(ratname,ratnames)
            exclude=true;
        end
    end 
end