function [cdf] = cumsum_uni(distr, dpdf, x)
  
  % given a discrete pdf, simply add
  idx = find(abs(distr-x) < 0.001);
  if x > max(distr), cdf = 1;
  else cdf = sum(dpdf(1:idx));
    end;