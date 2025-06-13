function duration = timediff(time1,time2,X,varargin)

if nargin == 2; X = 1; end

if (~ischar(time1) && isnan(time1)) || (~ischar(time2) && isnan(time2)); duration = nan; return; end

T1 = (3600 * str2num(time1(1:2))) + (60 * str2num(time1(4:5))) + str2num(time1(7:8)); %#ok<ST2NM>
T2 = (3600 * str2num(time2(1:2))) + (60 * str2num(time2(4:5))) + str2num(time2(7:8)); %#ok<ST2NM>
diff = T2 - T1;

if X == 2; duration = diff;
else       
    duration = '00:00:00';
    h = floor(diff / 3600); diff = diff - (3600 * h);
    m = floor(diff / 60);   diff = diff - (60   * m);
    s = floor(diff);
    
    if   h < 10; duration(2)   = num2str(h);
    else         duration(1:2) = num2str(h);
    end
    if   m < 10; duration(5)   = num2str(m);
    else         duration(4:5) = num2str(m);
    end
    if   s < 10; duration(8)   = num2str(s);
    else         duration(7:8) = num2str(s);
    end
end