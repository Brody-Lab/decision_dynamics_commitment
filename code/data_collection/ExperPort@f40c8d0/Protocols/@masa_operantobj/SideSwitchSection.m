function [x, y, SideSwitchList] = SideSwitchSection(obj, action, x, y);    
%  
%
%          obj                  A masa_operant_testobj object
%
% returns: x, y                 updated UI pos
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

GetSoloFunctionArgs;
%SoloFunction('SideSwitchSection', 'rw_args', {}, ...
%               'ro_args', {'n_started_trials', 'maxtrials'});

switch action,
 case 'init',
     
   fig=gcf;
   MenuParam(obj, 'SideSwitchParams', {'hidden','view'},1,x,y);next_row(y);
   set_callback(SideSwitchParams, {'SideSwitchSection', 'side_switch_param_view'});
   
   oldx=x; oldy=y; x=5; y=5;
   SoloParamHandle(obj, 'myfig', 'value', figure, 'saveable',0);
   
   SoloParamHandle(obj, 'SideSwitchList', 'value', zeros(1, maxtrials));
   
   MenuParam(obj, 'NumSSwtTrial', {50,60,80,100,120,150,200}, 100, x, y);next_row(y);
   EditParam(obj, 'StartTrialMax', 100, x, y); next_row(y);
   EditParam(obj, 'StartTrialMin', 60, x, y); next_row(y);
   MenuParam(obj, 'SideSwitch', {'OFF', 'ON'}, 1, x, y); next_row(y);
   MenuParam(obj, 'AutoChange', {'OFF', 'ON'}, 1, x, y); next_row(y);
   set_callback({NumSSwtTrial,StartTrialMax,StartTrialMin,SideSwitch,AutoChange}, ...
       {'SideSwitchSection', 'change'});
      
   set(value(myfig), ...
      'Visible', 'off', 'MenuBar', 'none', 'Name', 'SideSwitch Parameters', ...
      'NumberTitle', 'off', 'CloseRequestFcn', ...
      ['SideSwitchSection(' class(obj) '(''empty''), ''side_switch_param_hide'')']);
  set(value(myfig), 'Position', [200 30 210 110]);
  x=oldx; y=oldy; figure(fig);
  
    case 'change',
        side_switch_list=value(SideSwitchList);
        if strcmp(value(AutoChange), 'OFF'),
           if strcmp(value(SideSwitch), 'OFF'),
               side_switch_list(1,n_started_trials+1:maxtrials)=0;
           else, %SideSwitch 'ON'
               side_switch_list(1,n_started_trials+1:maxtrials)=1;
           end;
        else, %AutoChange 'ON'
            templist=zeros(1,maxtrials);
            start_sswt=ceil(rand*(value(StartTrialMax)-value(StartTrialMin)))+ ...
                value(StartTrialMin)-1;
            end_sswt=start_sswt+value(NumSSwtTrial)-1;
            templist(1, start_sswt:end_sswt)=1;
            side_switch_list(1,n_started_trials+1:maxtrials)= ...
                templist(1, n_started_trials+1:maxtrials);
        end;
        
        SideSwitchList.value=side_switch_list;
        VpdsSection(obj, 'side_switch');
    
    case 'side_switch_param_view',
        switch value(SideSwitchParams)
            case 'hidden',
                set(value(myfig), 'Visible', 'off');
                
            case 'view',
                set(value(myfig), 'Visible', 'on');
        end;
        
    case 'side_switch_param_hide',
        SideSwitchParams.value='hidden';
        set(value(myfig), 'Visible', 'off');
        
    case 'delete'
        delete(value(myfig));
        
 otherwise,
   error(['Don''t know how to deal with action ' action]);
   
end;

    
     
