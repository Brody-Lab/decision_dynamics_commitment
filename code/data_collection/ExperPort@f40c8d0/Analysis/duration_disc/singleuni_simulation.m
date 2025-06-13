function [best_matrix]  = poke_duration_simulation
  
 best_matrix = []; % best p(short correct), best p(long correct), poke duration
  
  for a = 0.15:0.05:0.6
   fprintf(1,'%1.2f ...',a);
    for b = a+0.2:0.05:1
        for other_a = 0.15:0.05:0.6
          for other_b = other_a+0.2:0.05:1
                [thresh both_tog] = cueonset2go_perf(0.2,0.5, a, b, 'other_a', ...
                                           other_a, 'other_b', other_b);
                best_matrix =[ best_matrix; a b other_a other_b thresh both_tog];   
          end;
        end;
    end;
  end;
  