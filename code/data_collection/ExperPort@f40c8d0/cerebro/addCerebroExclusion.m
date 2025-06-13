function addCerebroExclusion(rat,date,reason,comment)
    date = datestr(datenum(date),'yyyy-mm-dd');
    ratList = bdata('select ratname from ratinfo.rats');
    if ~ismember(rat,ratList)
        error('%s not an extant or dead rat in the Brody lab database.',rat);
    end
    mysql_command = sprintf('select ratname from ratinfo.cerebro_sessions where date="%s"',date);
    rats_for_date = bdata(mysql_command);
    if ismember(rat,rats_for_date)
        answer=questdlg('That rat already has an entry for that date. Make a duplicate entry?','Duplicate entry request','yes','no','no');
    else
        answer='yes';
    end
    if strcmp(answer,'no')
        return
    end
    next_primary_key = max(bdata('select cerebro_session_id from ratinfo.cerebro_sessions')) +1;
    if nargin<4
        mysql_command = sprintf('insert into ratinfo.cerebro_sessions (ratname,cerebro_session_id,exclude_reason,date,exclude) value ("%s",%g,"%s","%s",1)',rat,next_primary_key,reason,date);
    else
        mysql_command =sprintf('insert into ratinfo.cerebro_sessions (ratname,cerebro_session_id,exclude_reason,date,exclude,comments) value ("%s",%g,"%s","%s",1,"%s")',rat,next_primary_key,reason,date,comment);        
    end
    bdata(mysql_command)    
end
