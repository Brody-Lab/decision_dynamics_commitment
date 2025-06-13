function [] = add_entry(obj,varargin)
   
   GetSoloFunctionArgs;
   % SoloFunctionAddVars('add_entry', 'ro_args',{'right_time','left_time', ...
   %                 'right_dispense', 'left_dispense', 'initials'}, ...
   %                 'rw_args', {'table', 'list_table'});

   
   %     Determine whether or not we should be using the new calibration's
   %       policy of deleting old offside data automatically. This is part
   %       of the new behaviors attached to the "calibrating" flag.
   if length(varargin) > 1 && ischar(varargin{1}) && strcmpi('calibrating',varargin{1}) && ismember(varargin{2},[0 1]),
       optDeleteOffsides = varargin{2};
   else
       optDeleteOffsides = 0;
   end;
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
   
   if center_time~=0 && center_dispense~=0;
      center_str = sprintf('%s:  %.3f secs -->  %.1f ul', 'center1water', ...
                     value(center_time), value(center_dispense));
   else
      center_str = '';
   end;
   
   if left_time~=0 && left_dispense~=0;
      left_str = sprintf('%s:    %.3f secs -->  %.1f ul', 'left1water', ...
                     value(left_time), value(left_dispense));
   else
      left_str = '';
   end;
      
   if isempty(right_str) && isempty(left_str) && isempty(center_str), return; end;
   
   bn = questdlg({'Are you SURE you want to permanently add this entry?'; ...
                  ' ' ; ...
                  ['Did you FLUSH the valves before measuring, to make ' ...
                   'sure there were no bubbles? Did you weigh the water ' ...
                   'CAREFULLY?'] ;  
                  ' ' ; ...                  
                  left_str; ...
                  center_str; ...
                  right_str}, ...
                 'Adding entry', 'OK', 'Cancel', 'OK');

   if ~strcmp(bn, 'OK'), return; end;

   if ~isempty(right_str),
      [table.value, offside] = ...
          add_entry(value(table), value(initials),'right1water', ...
                    value(right_time), value(right_dispense));
      if ~isempty(offside),
          if optDeleteOffsides,
              table.value = deleteOffsides(value(table),offside);
          else
              helpmessage('right1water', offside);
          end;
      end;
   end;                              
   
   if ~isempty(center_str),
       [table.value, offside] = ...
           add_entry(value(table), value(initials),'center1water', ...
           value(center_time), value(center_dispense));
       if ~isempty(offside),
           if optDeleteOffsides,
               table.value = deleteOffsides(value(table),offside);
           else
               helpmessage('center1water', offside);
           end;
       end;
   end;
   
   if ~isempty(left_str),
      [table.value, offside] = ...
          add_entry(value(table), value(initials), 'left1water', ...
                    value(left_time), value(left_dispense));
      if ~isempty(offside),
          if optDeleteOffsides,
              table.value = deleteOffsides(value(table),offside);
          else
              helpmessage('left1water', offside);
          end;
      end;
   end;                              

   ctable = cellstr(value(table));
   set(get_ghandle(list_table), 'string', ctable);
   list_table.value = length(ctable);
   
   save_table(value(table), 'commit', 1);
   return;
   
   
end %     End of function add_entry


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
   
end     %     End of function helpmessage

% --------

function table = deleteOffsides(table, offside)

%     Find the offside elements in table using newly overloaded eq()
lOs     = length(offside);
display('Deleting the following calibration data points that conflict (offsides) with new data:');
for i = 1:lOs,
    isMatch     = offside(i)==table;
    nMatches    = sum(isMatch);
    if nMatches==0,
        warning('In deleting old offside calibration data, failed to find a match for one of the offside entries.... This is odd. Check Modules/@WaterCalibrationTable/eq.m and Protocols/@Calibration_WaterDelivery/add_entry.m.'); 
        continue;
    elseif nMatches > 1,
        warning('In deleting old offside calibration data, found multiple entries in the water calibration table matching a single offside entry. This, I think, should be impossible. Check Modules/@WaterCalibrationTable/eq.m and Protocols/@Calibration_WaterDelivery/add_entry.m.');
    end;
    iMatchToDelete = find(isMatch,1,'first');
    display(table(iMatchToDelete));
    table = remove_entry(table, iMatchToDelete); %     Remove the match to the offside element in the water calibration table.
end; %     end for each offside element
    
end %     End of function deleteOffsides
