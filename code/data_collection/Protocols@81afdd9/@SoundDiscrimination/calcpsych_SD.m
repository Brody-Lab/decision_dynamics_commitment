function [psychvals center] = calcpsych_SD(obj,ed,val,pp,np,varargin)

leftend  = ed(1);
rightend = ed(2);

psychvals = 10.^(log10(leftend):(log10(rightend)-log10(leftend))/9:log10(rightend));

if nargin > 2
    if pp == 1
        psychvals = 10 ^ (log10(leftend) + ((val - 1) * ((log10(rightend) - log10(leftend)) / 9)));
    else
        temp = 10.^(log10(leftend):(log10(rightend)-log10(leftend))/((np*2)-1):log10(rightend));
        psycsounds(1:np)       = temp(1:np);
        psycsounds(10-np+1:10) = temp(np+1:end);
        psychvals = psycsounds(val);
    end
end

center = 10 ^ (log10(leftend) + ((5.5 - 1) * ((log10(rightend) - log10(leftend)) / 9)));

