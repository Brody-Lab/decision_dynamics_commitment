function [x, y, ...
    ValveRight, ValveLeft, DelayToRewardRight, DelayToRewardLeft, ...
    RewardAvailPeriod, CPokeNecessary] ...
    = ParamsSection(obj, action, x, y);

GetSoloFunctionArgs;
%SoloFunction('ParamsSection', 'rw_args', {}, 'ro_args', {});

switch action,
 case 'init',
     
   %make gui
     
   HEIGHT = 20; %default height of gui menus

   EditParam(obj, 'ValveRight',  0.5, x, y);  y=y+HEIGHT;
   EditParam(obj, 'ValveLeft', 0.5, x, y);  y=y+HEIGHT;
   
   EditParam(obj, 'DelayToRewardRight', 0.5, x, y); y=y+HEIGHT;
   EditParam(obj, 'DelayToRewardLeft', 0.5, x, y); y=y+HEIGHT;
   
   EditParam(obj, 'RewardAvailPeriod', 5, x, y); y=y+HEIGHT;
   MenuParam(obj, 'CPokeNecessary', {'Yes','No'}, 2, x, y); y=y+HEIGHT;
        
 otherwise,
   error(['Don''t know how to deal with action ' action]);
   
end;