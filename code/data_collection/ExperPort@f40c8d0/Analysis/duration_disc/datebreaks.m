function [isbreak] = datebreaks(datelist)
% Given cell of dates (d-by-1), returns b=d-by-1 binary array where b(i)=1 where if d(i)-d(i-1) > 1 day.
isbreak = nan(size(datelist));

prevd = datelist{1}(1:6);
for d=2:length(datelist);
    currd = datelist{d}(1:6);
 datediff = str2double(currd) - str2double(prevd);
 isbreak(d) = (datediff ~= 1);
 
 prevd = currd;
end;
