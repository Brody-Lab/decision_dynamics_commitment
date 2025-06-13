function output = perimdirection(p,c,direction)

ang = zeros(size(p,1),1);
temp(:,1) = p(:,1) - c(1);
temp(:,2) = p(:,2) - c(2);

for i = 1:size(p,1) 
   ang(i) =  atand(abs(temp(i,2)) / abs(temp(i,1)));
   
   if     temp(i,1) <  0 && temp(i,2) <= 0; ang(i) = ang(i) + 180;
   elseif temp(i,1) >= 0 && temp(i,2) <  0; ang(i) = 360 - ang(i);
   elseif temp(i,1) <= 0 && temp(i,2) >  0; ang(i) = 180 - ang(i);
   end
   
   if i > 1; ad(i-1) = ang(i) - ang(i-1); end %#ok<AGROW>
   
end
ad(ad<0) = -1;
ad(ad>0) = 1;
if     sum(ad) >= 0; d = 'ccw';
elseif sum(ad) < 0; d = 'cw';
end

if ~exist('d','var')
    2;
end;

if strcmp(direction,d) == 1
    output = p; 
else
    output = p(end:-1:1,:);
end
    

    
    