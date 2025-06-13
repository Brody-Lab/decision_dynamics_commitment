
    function [s,e]=num2locCM32(x)
    % [s,e]=num2loc(x)
    % Given a site number x, gives the location of that site on the 4x8
    % shank
    
    mf=floor((x-0.1)/8);
    s=mf+1;
    ex=x-mf*8;
    
    emap=[1 3 5 7 8 6 4 2];
    e=emap(ex);
    
    