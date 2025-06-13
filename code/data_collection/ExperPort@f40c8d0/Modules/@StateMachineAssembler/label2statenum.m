function [num] = label2statenum(sma, label)
   
   if isa(label, 'cell')
      label = label(:);
      num = zeros(1, length(label));
      for i=1:length(label), 
         num(i) = label2statenum(sma, label{i});
      end;
      return;
   end;
   
   
   u = find(strcmpi(label, sma.state_name_list(:,1)));
   
   if isempty(u), 
      num = NaN; 
      fprintf(1, 'label2statenum couldn''t resolve "%s"\n', label);
   else           
      num = sma.state_name_list{u,2};
      if sma.state_name_list{u,3} == 1,
         num = num + rows(sma.states);
      end;
   end;