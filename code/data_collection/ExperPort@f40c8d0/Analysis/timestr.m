function str = timestr(sec)
% takes a number (of sec), for instance the output of toc, and returns a
% string with days, hours, minutes, and seconds.
days=floor(sec/(60*60*12));
sec=sec-days*60*60*12;
hours=floor(sec/(3600));
sec=sec-hours*3600;
minutes=floor(sec/60);
sec=sec-minutes*60;
try
    sec=round(sec,2);
catch
    sec=round(sec);
end
    if days
        str=sprintf('%s days, %s hours, %s minutes and %s seconds',num2str(days),num2str(hours),num2str(minutes),num2str(sec));
    elseif hours
        str=sprintf('%s hours, %s minutes and %s seconds',num2str(hours),num2str(minutes),num2str(sec));
    elseif minutes
        str=sprintf('%s minutes and %s seconds',num2str(minutes),num2str(sec));
    else
        str=sprintf('%s seconds',num2str(sec));
    end
end