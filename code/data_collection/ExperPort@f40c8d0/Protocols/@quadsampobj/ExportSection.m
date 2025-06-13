function [] = ExportSection(obj, action)

   GetSoloFunctionArgs;
   
   switch action,      
    case 'init',
      SoloParamHandle(obj, 'myfig', 'value', figure, 'saveable', 0);
      set(value(myfig), ...
          'Position', [100 100 1000 400], ...
          'Visible', 'on', 'MenuBar', 'none', 'Name', mfilename, ...
          'NumberTitle', 'off', ...
          'CloseRequestFcn', ...
          [mfilename '(' class(obj) '(''empty''), ''cancel'')']);
      
      % feval(mfilename, obj, 'cancel');
      
    case 'export',            
      set(value(myfig), 'Visible', 'on');

    case 'cancel',
      set(value(myfig), 'Visible', 'off');

    case 'reinit',
      delete(value(myfig));
      delete_sphandle('handlelist', ...
                get_sphandle('owner', class(obj), 'fullname', mfilename));

      ExportSection(obj, 'init');
      
    otherwise
      fprintf(1, 'Dont know action "%s"!!!\n', action);
   end;
   
   