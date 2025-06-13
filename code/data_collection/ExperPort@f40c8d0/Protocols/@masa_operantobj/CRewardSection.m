function [x, y, CRewardList] = CRewardSection(obj, action, x, y);    
%  
%
%          obj                  A masa_operant_testobj object
%
% returns: x, y                 updated UI pos
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

GetSoloFunctionArgs;
%SoloFunction('CRewardSection', 'rw_args', {}, ...
%               'ro_args', {'n_started_trials', 'maxtrials'});

switch action,
 case 'init',
     
   fig=gcf;
   MenuParam(obj, 'CRewardParams', {'hidden','view'},1,x,y);next_row(y);
   set_callback(CRewardParams, {'CRewardSection', 'creward_param_view'});
   
   oldx=x; oldy=y; x=5; y=5;
   SoloParamHandle(obj, 'myfig', 'value', figure, 'saveable',0);
   
   SoloParamHandle(obj, 'CRewardList', 'value', zeros(1, maxtrials));
   
   MenuParam(obj, 'NumCRewTrial', {50,60,80,100,120,150,200}, 100, x, y);next_row(y);
   EditParam(obj, 'StartTrialMax', 100, x, y); next_row(y);
   EditParam(obj, 'StartTrialMin', 60, x, y); next_row(y);
   MenuParam(obj, 'CReward', {'OFF', 'ON'}, 1, x, y); next_row(y);
   MenuParam(obj, 'AutoChange', {'OFF', 'ON'}, 1, x, y); next_row(y);
   set_callback({NumCRewTrial,StartTrialMax,StartTrialMin,CReward,AutoChange}, ...
       {'CRewardSection', 'change'});
      
   set(value(myfig), ...
      'Visible', 'off', 'MenuBar', 'none', 'Name', 'CReward Parameters', ...
      'NumberTitle', 'off', 'CloseRequestFcn', ...
      ['CRewardSection(' class(obj) '(''empty''), ''creward_param_hide'')']);
  set(value(myfig), 'Position', [200 30 210 110]);
  x=oldx; y=oldy; figure(fig);
  
    case 'change',
        creward_list=value(CRewardList);
        if strcmp(value(AutoChange), 'OFF'),
           if strcmp(value(CReward), 'OFF'),
               creward_list(1,n_started_trials+1:maxtrials)=0;
           else, %CReward 'ON'
               creward_list(1,n_started_trials+1:maxtrials)=1;
           end;
        else, %AutoChange 'ON'
            templist=zeros(1,maxtrials);
            start_crew=ceil(rand*(value(StartTrialMax)-value(StartTrialMin)))+ ...
                value(StartTrialMin)-1;
            end_crew=start_crew+value(NumCRewTrial)-1;
            templist(1, start_crew:end_crew)=1;
            creward_list(1,n_started_trials+1:maxtrials)= ...
                templist(1, n_started_trials+1:maxtrials);
        end;
        
        CRewardList.value=creward_list;
        VpdsSection(obj, 'center_reward');
%         ChoiceSection(obj, 'center_reward');
    
    case 'creward_param_view',
        switch value(CRewardParams)
            case 'hidden',
                set(value(myfig), 'Visible', 'off');
                
            case 'view',
                set(value(myfig), 'Visible', 'on');
        end;
        
    case 'creward_param_hide',
        CRewardParams.value='hidden';
        set(value(myfig), 'Visible', 'off');
        
    case 'delete'
        delete(value(myfig));
        
 otherwise,
   error(['Don''t know how to deal with action ' action]);
   
end;

    
     
