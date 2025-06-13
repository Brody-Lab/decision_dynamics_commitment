
    function [x]=loc2numCM32(s,e)
    % [s,e]=num2loc(x)
    % Given a site number x, gives the location of that site on the 4x8
    % shank
    
    
    emap=[1 8 2 7 3 6 4 5];
    xe=emap(e);
    
   x=(s-1)*8+xe;
    
    
    