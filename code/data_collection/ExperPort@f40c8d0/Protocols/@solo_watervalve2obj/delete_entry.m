function [] = delete_entry(obj),
   
   GetSoloFunctionArgs;
   
   remid = get(get_ghandle(list_table), 'value')-1;
   if remid < 1, return; end;

   bn = questdlg(['Are you SURE you want to permanently delete the ' ...
                  'highlighted entry?'],  'Deleting entry', 'OK', ...
                 'Cancel', 'OK');
   
   if strcmp(bn, 'Cancel'), return; end;

   
   table.value = remove_entry(value(table), remid);

   ctable = cellstr(value(table));
   set(get_ghandle(list_table), 'string', ctable);
   list_table.value = length(ctable);
   
   save_table(value(table));
   
   