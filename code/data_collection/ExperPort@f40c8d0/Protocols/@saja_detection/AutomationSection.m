function [x, y] = AutomationSection(obj, action, varargin)
   
GetSoloFunctionArgs;
%%% Imported objects (see protocol constructor):
%%% 'AutomationCommands'

switch action
  case 'init',
    % Save the figure and the position in the figure where we are
    % going to start adding GUI elements:
    x = varargin{1};
    y = varargin{2};
    SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);

    MenuParam(obj, 'AutoCommandsMenu',...
              {'none'}, 1, x, y,...
              'label','Auto Commands',...
              'TooltipString', 'Commands to run after every trial (see AutoCommands.m)');
    set_callback(AutoCommandsMenu,{mfilename, 'run_autocommands'});
    next_row(y);

    PushbuttonParam(obj, 'LoadAutoCommands', x,y, 'label', 'LoadAutoCommands',...
                    'position', [x y 200 20]);
    set_callback(LoadAutoCommands,{mfilename, 'update_commandstring'});
    
    SoloParamHandle(obj,'AutoActionsList','value',{'none'});

    AutomationSection(obj,'update_menu');
    
    next_row(y);
    

  case 'update_menu'
    AutomationSection(obj,'update_commandstring');
    AutomationSection(obj,'run_autocommands');
    AutoCommandsMenuGHandle = get_ghandle(AutoCommandsMenu);
    set(AutoCommandsMenuGHandle,'String',value(AutoActionsList));
    
  case 'update_commandstring'
    FilePath = fileparts(mfilename('fullpath'));
    CommandsFileName = fullfile(FilePath,'AutoCommands.m');
    if(exist(CommandsFileName,'file'))
        AutomationCommands.value = fileread(CommandsFileName);
        fprintf('\nNew auto commands file read: %s\n',CommandsFileName);
    else
        fprintf('\nWARNING: File %s does not exist.\n\n',CommandsFileName);
    end
    
    
  case 'run_autocommands'
    try,
        eval(value(AutomationCommands));
    catch,
        fprintf('\n\n *** WARNING: there was an error in the automatic commands. ***\n');
        disp(lasterr); fprintf('\n\n'); %%% Using disp because sometimes lasterr is a struct        
    end
    
    
  case 'reinit',
    currfig = gcf;

    % Get the original GUI position and figure:
    x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));

    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);

    % Reinitialise at the original GUI position and figure:
    [x, y] = feval(mfilename, obj, 'init', x, y);

    % Restore the current figure:
    figure(currfig);
end;


