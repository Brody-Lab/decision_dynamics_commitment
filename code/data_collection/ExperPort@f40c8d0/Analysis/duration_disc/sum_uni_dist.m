function [] = sum_uni_dist
  
  pre = 150 + (600-150) .* rand(5000,1);
 post = 100 + (200-100) .* rand(5000,1);
  %   post = 0 + (400-0) .* rand(1000,1); 
   
   summy=pre+ post;
   figure;
   s=sort(summy);
   %plot(1:1000,s,'.b');
   hist(s);
   