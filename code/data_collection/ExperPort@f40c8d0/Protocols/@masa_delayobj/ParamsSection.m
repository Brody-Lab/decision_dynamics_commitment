function [x, y, ...
    ValveRightLarge, ValveRightSmall, ValveLeftLarge, ValveLeftSmall, DelayToReward, ...
    RewardSide, TrialLength, RewardAvailPeriod, CinTimeOut, Jitter] ...
    = ParamsSection(obj, action, x, y);

GetSoloFunctionArgs;
%SoloFunction('ParamsSection', 'rw_args', {}, 'ro_args', {});

switch action,
 case 'init',
     
   fig=gcf;
   MenuParam(obj, 'BasicParams', {'view', 'hidden'},1,x,y);next_row(y);
   set_callback(BasicParams, {'ParamsSection', 'basic_param_view'});
   
   oldx=x; oldy=y; x=5; y=5;
   SoloParamHandle(obj, 'myfig', 'value', figure, 'saveable',0);

   EditParam(obj, 'ValveRightLarge',  0.05, x, y);  next_row(y);
%    set_callback(ValveRightLarge, {'ParamsSection', 'valverightlarge'});
   EditParam(obj, 'ValveRightSmall',  0.05, x, y);  next_row(y);
%    set_callback(ValveRightSmall, {'ParamsSection', 'valverightsmall'});
   EditParam(obj, 'ValveLeftLarge', 0.05, x, y);  next_row(y);
%    set_callback(ValveLeftLarge, {'ParamsSection', 'valveleftlarge'});
   EditParam(obj, 'ValveLeftSmall', 0.05, x, y);  next_row(y);
%    set_callback(ValveLeftSmall, {'ParamsSection', 'valveleftsmall'});
   MenuParam(obj, 'RewardSide',{'Left','Right'},1,x,y);next_row(y);
   
   EditParam(obj, 'Jitter', 0, x, y); next_row(y);
   set_callback(Jitter, {'BeginnerSection', 'c_reenter'});
   
   EditParam(obj, 'DelayToReward', 0.5, x, y); next_row(y);
   
   EditParam(obj, 'TrialLength', 3, x, y); next_row(y);
   
   EditParam(obj, 'CinTimeOut', 0.001, x, y); next_row(y);

   MenuParam(obj, 'RewardAvailPeriod', {1, 2, 3, 5, 10, 20}, 20, x, y);next_row(y);
   next_row(y, 1.5);
   
   set(value(myfig), ...
      'Visible', 'on', 'MenuBar', 'none', 'Name', 'Basic Parameters', ...
      'NumberTitle', 'off', 'CloseRequestFcn', ...
      ['ParamsSection(' class(obj) '(''empty''), ''basic_param_hide'')']);
  
  screen_size = get(0, 'ScreenSize');
  set(value(myfig),'Position',[670 screen_size(4)-700, 210 205]); 
   
  x=oldx; y=oldy; figure(fig);
  
    case 'jitter0',
        Jitter.value =0;

    case 'basic_param_view',
        switch value(BasicParams)
            case 'hidden',
                set(value(myfig), 'Visible', 'off');

            case 'view',
                set(value(myfig), 'Visible', 'on');
        end;
        
    case 'basic_param_hide',
        BasicParams.value='hidden';
        set(value(myfig), 'Visible', 'off');
        
    case 'delete'
        delete(value(myfig));
        
 otherwise,
   error(['Don''t know how to deal with action ' action]);
   
end;