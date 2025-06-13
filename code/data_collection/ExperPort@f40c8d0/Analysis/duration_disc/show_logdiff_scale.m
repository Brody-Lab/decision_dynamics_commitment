function [] = show_logdiff_scale(type)
  
 durs = [];
 d_logdiffs = 1.0:-0.05:0.2;
 
 for d = 1:length(d_logdiffs)
    [lhs rhs] = calc_pair(type, sqrt(300*800), d_logdiffs(d));
    durs = [durs; lhs rhs];
    fprintf(1, '%1.2f:\t%3.0fms and %3.0fms\t\t%3.0fms\n', d_logdiffs(d), lhs, ...
            rhs, rhs-lhs);
 end;
 
 
 
 