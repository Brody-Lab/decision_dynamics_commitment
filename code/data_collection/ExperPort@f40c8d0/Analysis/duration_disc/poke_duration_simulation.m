function [best_matrix]  = poke_duration_simulation
  
 best_matrix = []; % best p(short correct), best p(long correct), poke duration
  
  for pre_min = 0.15:0.05:0.6
   fprintf(1,'%1.2f ...',pre_min);
    for pre_max = pre_min+0.2:0.05:0.8
        for post_min = 0.1:0.05:0.2
          for post_max = post_min+0.05:0.05:0.35
            for s1 = 0.3:0.05:0.4
              for s2 = 0.6:0.05:0.8
                [s l p] = poke_Duration_performance(pre_min, pre_max, post_min, ...
                                          post_max, s1, s2);
                best_matrix =[ best_matrix; pre_min pre_max post_min ...
                               post_max s1 s2 s l p];
              end;
            end;
            
          end;
        end;
    end;
  end;
  