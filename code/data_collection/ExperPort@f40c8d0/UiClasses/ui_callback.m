function [] = ui_callback(obj, eventdata, uph)

   switch lower(get(obj, 'Style')),
       case 'edit',
           val = str2num(get(obj, 'String'));
           if ~isempty(val), 
               val = val(1);
           else
               warning('Didn''t understand the value you are trying to enter-- keeping old one.');
               val = getvalue(uph);
           end;
           uph.value = val;
           
       case 'popupmenu',
           string = get(obj, 'String');
           val    = get(obj, 'Value');
           numval = str2num(string{val});
           if isempty(numval), uph.value = string{val};
           else                uph.value = numval;
           end;
   end;
  

  % fprintf(1, 'I''m going to call %s(''%s'').\n', get(uph, 'param_owner'), get(uph, 'param_name'));
  
  eval(sprintf('%s(''%s'');', get(uph, 'param_owner'), get(uph, 'param_name')));
  
  
  

