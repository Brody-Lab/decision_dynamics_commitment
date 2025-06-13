% gaussian2 filter function
function y = gaussian2(sd,x)
   if sd > 0 
      f=fspecial('gaussian',ceil(sd*3),sd);
      y = filter2(f,x);
   else
      y = x;
   end