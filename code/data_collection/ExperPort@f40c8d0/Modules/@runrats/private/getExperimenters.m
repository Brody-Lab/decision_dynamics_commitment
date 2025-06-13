function [x]=getExperimenters

    try
        sqlstr=sprintf('select distinct(experimenter) from ratinfo.rats where extant=1 order by experimenter');
        x=bdata(sqlstr);
    catch
        x={''};
    end


if isempty(x)
        x={''};
end
