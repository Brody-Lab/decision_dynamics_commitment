function [] = criminal_heights()
  
  freqs = [0 1 1 6 23 48 90 175 317 393 462 458 413 264 177 97 46 17 7 4 ...
           0 0 1];
  heights = 55:1:77;
  
  
  plot(heights, freqs,'.r');
  
  mu = (heights * freqs')/sum(freqs);
  fprintf(1, 'Mean is %2.2f\n', mu);
  
  var1 = ( (heights - mu).^2 * freqs') / sum(freqs);
  
  expanded = [];
  for k = 1:length(heights)
    expanded = [expanded repmat(heights(k), 1, freqs(k))];
  end;
  
  var2 = var(expanded);
  fprintf(1, 'My var = %1.2f\n ; Matlab says: %1.2f\n ',var1, var2); 
  
  sqyu =  (((heights - mu).^3 * freqs') / sum(freqs)) / sqrt(var1).^3;
  fprintf(1, 'My skew = %1.3f\n', sqyu); 