function [] = add_entry(obj)
   
   GetSoloFunctionArgs;
   % SoloFunctionAddVars('add_entry', 'ro_args',{'right_time','left_time', ...
   %                 'right_dispense', 'left_dispense', 'initials'}, ...
   %                 'rw_args', {'table', 'list_table'});
   

   if isempty(value(initials)),
      errordlg(['Please enter your initials before trying to add an ' ...
                'entry']);
      return;
   end;
   

   if right_time~=0 && right_dispense~=0;
      right_str = sprintf('%s:  %.3f secs -->  %.1f ul', 'right1water', ...
                     value(right_time), value(right_dispense));
   else
      right_str = '';
   end;
   
   if left_time~=0 && left_dispense~=0;
      left_str = sprintf('%s:    %.3f secs -->  %.1f ul', 'left1water', ...
                     value(left_time), value(left_dispense));
   else
      left_str = '';
   end;
      
   if isempty(right_str) & isempty(left_str), return; end;
   
   bn = questdlg({'Are you SURE you want to permanently add this entry?'; ...
                  ' ' ; ...
                  ['Did you FLUSH the valves before measuring, to make ' ...
                   'sure there were no bubbles? Did you weigh the water ' ...
                   'CAREFULLY?'] ;  
                  ' ' ; ...                  
                  left_str; ...
                  right_str}, ...
                 'Adding entry', 'OK', 'Cancel', 'OK');

   if ~strcmp(bn, 'OK'), return; end;

   if ~isempty(right_str),
      [table.value, offside] = ...
          add_entry(value(table), value(initials),'right1water', ...
                    value(right_time), value(right_dispense));
      if ~isempty(offside),
         helpmessage('right1water', offside);
      end;
   end;                              
   
   if ~isempty(left_str),
      [table.value, offside] = ...
          add_entry(value(table), value(initials), 'left1water', ...
                    value(left_time), value(left_dispense));
      if ~isempty(offside),
         helpmessage('left1water', offside);
      end;
   end;                              

   ctable = cellstr(value(table));
   set(get_ghandle(list_table), 'string', ctable);
   list_table.value = length(ctable);
   
   save_table(value(table), 'commit', 1);
   return;
   
   
% --------

function [] = helpmessage(valve, offside)
   
   h = helpdlg([{ ...
     sprintf(['WARNING!! There are entries for "%s" with ' ... 
              'either lower dispense times yet higher ' ...
              'volumes, or higher dispense times yet lower ' ...
              'volumes!!!'], valve) ; ...
     ' ' ; ...
     'You should DELETE these.'; ...
     ' '} ; ...
     cellstr(offside)], [valve ' inconsistency warning']);
   
   
   pos = get(h, 'Position');
   set(h, 'Position', [pos(1:2) pos(3)*1.5 pos(4)]);
   set(findobj(h, 'Type', 'text'), 'FontName', 'Courier', 'FontSize', 12);   
   