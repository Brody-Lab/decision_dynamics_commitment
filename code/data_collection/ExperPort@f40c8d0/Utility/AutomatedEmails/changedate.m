function new = changedate(old,dif)

y = str2num(old(1:2)); %#ok<ST2NM>
m = str2num(old(3:4)); %#ok<ST2NM>
d = str2num(old(5:6)); %#ok<ST2NM>

%yr = 0:99;
mr = 1:12;
dr = finddr(m,y);

for i = 1:abs(dif)
    
    if dif > 0; d = d + 1;
    else        d = d - 1;
    end
    
    if     d > dr(end); d = 1; m = m + 1;
    elseif d == 0;             
        m  = m - 1;
        dr = finddr(m,y);
        d  = dr(end);
    end
    
    if m > mr(end); m = 1;  y = y+1;
    elseif m == 0;  m = 12; y = y-1;
    end
end

c = [y + 2000, m, d, 0, 0, 0];
new = datestr(c,25);
new = new([1 2 4 5 7 8]);


function dr = finddr(m,y)

    if m==1 || m==3 || m==5 || m==7 || m==8 || m==10 || m==12
        dr = 1:31;
    elseif m==4 || m==6 || m==9 || m==11
        dr = 1:30;
    elseif m==2
        if rem(y,4) == 0
            dr = 1:29;
        else
            dr = 1:28;
        end
    elseif m==13 || m==0
        dr = 1:31;
    end