k = zeros(size(p)); 
for i=1:length(p), 
   for j=1:rows(p{i}.timeout), 
      if rows(p{i}.right_reward)>0, 
         correct_act = 'r'; hit = 1; 
      elseif rows(p{i}.left_reward)>0, 
         correct_act = 'l'; hit = 1; 
      else 
         hit = 0; error_start = p{i}.extra_iti(1,1)-0.001; 
         first_left = p{i}.left1(p{i}.left1(:,1)>error_start); 
         first_right = p{i}.right1(p{i}.right1(:,1)>error_start); 
         if isempty(first_left) & ~isempty(first_right), 
            correct_act = 'l'; 
         elseif isempty(first_right) & ~isempty(first_left), 
            correct_act = 'r'; 
         elseif ~isempty(first_right) & ~isempty(first_left), 
            if first_right < first_left, correct_act = 'l'; 
            else correct_act = 'r'; 
            end; 
         else error('Wot? error but no poke??'); 
         end;
      end;
      
      timeout_start = p{i}.timeout(j,1);
      timeout_end   = p{i}.timeout(j,2);
      first_left =  p{i}.left1(p{i}.left1(:,1) > timeout_start & ...
                              p{i}.left1(:,2) < timeout_end); 
      first_right = p{i}.right1(p{i}.right1(:,1) > timeout_start & ...
                              p{i}.right1(:,2) < timeout_end); 

      tout_poke = [];
      if isempty(first_left) & ~isempty(first_right), 
         tout_poke = 'r'; 
      elseif isempty(first_right) & ~isempty(first_left), 
         tout_poke = 'l'; 
      elseif ~isempty(first_right) & ~isempty(first_left), 
         if first_right < first_left, tout_poke = 'r'; 
         else tout_poke = 'l'; 
         end; 
      end;

      if ~isempty(tout_poke) & tout_poke == correct_act,
         k(i) = 1;
      end;
   end;
end;
