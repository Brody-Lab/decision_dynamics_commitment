function [x, y, Beginner1, BeginnerTup, C_ReEnter] = ...
    BeginnerSection(obj, action, x, y);
%
%
% args:    x, y                 current UI pos, in pixels
%          obj                  A masa-operant_obj object
%
% returns: x, y                 updated UI pos
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

GetSoloFunctionArgs;
% SoloFunction('BeginnerSection', ...
%     'rw_args', {'TrialLength', 'RewardAvailPeriod', 'CinTimeOut'...
%     'VpdSmall', 'VpdLargeMin', 'VpdLargeMean'}, ...
%     'ro_args', {'TrialData', 'n_done_trials'});

switch action,
    case 'init',
        fig=gcf;
        MenuParam(obj, 'BeginnerParams', {'view', 'hidden'}, 1, x,y); next_row(y);
        set_callback(BeginnerParams, {'BeginnerSection', ...
            'beginner_param_view'});
        oldx=x; oldy=y; x=1; y=1;
        SoloParamHandle(obj, 'myfig', 'value', figure, 'saveable',0);

        screen_size = get(0, 'ScreenSize');
        set(value(myfig),'Position',[670 screen_size(4)-250, 210 125]);
        set(value(myfig), ...
            'Visible', 'on', 'MenuBar', 'none', 'Name', 'Beginner Parameters', ...
            'NumberTitle', 'off', 'CloseRequestFcn', ...
            ['BeginnerSection(' class(obj) '(''empty''), ''beginner_param_hide'')']);
        MenuParam(obj, 'Adaptive', {'On', 'Off'}, 1, x, y);next_row(y); %valid for non-beginner
        MenuParam(obj, 'Beginner2', {'Yes', 'No'}, 1, x, y);next_row(y);
        MenuParam(obj, 'Beginner1', {'Yes', 'No'}, 1, x, y);next_row(y);
        set_callback(Beginner1, {'BeginnerSection', 'beginner1'});
        MenuParam(obj, 'C_ReEnter',  {'Go2Cpks', 'NBurst', 'NoReward'}, 1, x, y);next_row(y);
        set_callback(C_ReEnter, {'BeginnerSection', 'c_reenter'});
        EditParam(obj, 'BeginnerTup', 0.001, x, y);next_row(y);
        EditParam(obj, 'RewardCounter', 0, x, y);next_row(y);

        figure(fig);x=oldx;y=oldy;
        
        %end of case 'init'

    case 'check_and_change', %trial_finished_action
        if strcmp(value(Beginner2),'No'),
            if strcmp(value(Adaptive), 'Off'),
                %if non-beginner adaptive-off, there is nothing to do here
                return
            end;
        end;
        
        %%%check reward, and change Tup, TrialLength,RewardAvail...
%         TrialLength.value=7; %for Beginner2
        if strcmp(value(Beginner2), 'Yes'),
            RewardAvailPeriod.value=2; %for Beginner2
            CinTimeOut.value=2; %for Beginner2
            C_ReEnter.value='NBurst'; %for Beginner2
        end;
        
        if strcmp(value(Beginner1), 'Yes'),
            %%if Beginner1, no time out and minimum penalty for c-reenter
            TrialLength.value=3;
            CinTimeOut.value=0.001;
            
            %%check rewarded or not
            reward_counter=value(RewardCounter);
            g_reward=TrialData.get_reward;
            if g_reward(n_done_trials)==2|g_reward(n_done_trials)==3, %got reward
                reward_counter = reward_counter+1;
                reward_counter = min(reward_counter,60);
            elseif g_reward(n_done_trials)==1, %did not get reward
                reward_counter = reward_counter-1;
                reward_counter = max(reward_counter,0);
            end;
            RewardCounter.value=reward_counter;

            %%change BeginnerTup.value
            if reward_counter>=30,
                BeginnerTup.value=100;
            elseif reward_counter>=25,
                BeginnerTup.value=50;
            elseif reward_counter>=20,
                BeginnerTup.value=20;
            elseif reward_counter>=15,
                BeginnerTup.value=10;
            elseif reward_counter>=10,
                BeginnerTup.value=6;
            elseif reward_counter>=5,
                BeginnerTup.value=3;
            else,
                BeginnerTup.value=0.001;
            end;
        end;
        
        %check trial_type and change vpds
        t_type      = TrialData.trial_type(n_done_trials);
        
        vpd_sm      = value(VpdSmall);
        if vpd_sm==0.001,
            vpd_sm=0;
        end;
        vpd_la_min  = value(VpdLargeMin);
        vpd_la_mean = value(VpdLargeMean);
        
        if (t_type==1|t_type==2|t_type==11), %11 is fake cin (add Nov13)
            if vpd_la_mean>0.71,
                vpd_sm=0.4;
                vpd_la_mean=vpd_la_mean-0.02;   %change on Dec17/07
                vpd_la_min=min(0.7,vpd_la_mean);%change on Dec17/07                   
            elseif vpd_la_min>0.5,
                vpd_sm=0.4;
                vpd_la_min=vpd_la_min-0.01;
                vpd_la_mean=vpd_la_min;
            else, %vpd_la_min<=0.5
                vpd_sm=vpd_sm-0.01;
                vpd_sm=max(vpd_sm,0);
                vpd_la_min=vpd_sm+0.1;
                vpd_la_mean=vpd_la_min;
            end;
        elseif t_type==3,
            if vpd_sm<0.4,
                vpd_sm=vpd_sm+0.02;
                vpd_la_min=vpd_sm+0.1;
                vpd_la_mean=vpd_la_min;
            elseif vpd_la_min<0.7,
                vpd_sm=0.4;
                vpd_la_min=vpd_la_min+0.02;
                vpd_la_mean=vpd_la_min;
            else, %vpd_la_min=0.7
                vpd_sm=0.4;
                vpd_la_min=0.7;
                vpd_la_mean=vpd_la_mean+0.04;
            end;       
        end;
        
        if strcmp(value(Beginner2), 'No'), %that means non-beginner & adaptive-On
            vpd_sm = max(vpd_sm, 0.4);
            vpd_la_min = max(vpd_la_min, 0.7);
            vpd_la_mean = max(vpd_la_mean, 0.8);
        end;
        
        VpdSmall.value     = max(vpd_sm,0.001);
        VpdLargeMin.value  = vpd_la_min;
        VpdLargeMean.value = vpd_la_mean;
        
        VpdsSection(obj,'change');
        
        %%%C_ReEnter%%%%%
        
        if strcmp(value(Beginner1), 'Yes'),  
            %according to VpdSmall, change C_ReEnter and RewardAvailPeriod
            if vpd_sm<0.2,
                C_ReEnter.value='Go2Cpks';
                RewardAvailPeriod.value=20;
            end;
        end;
        
    case 'beginner1',
        if strcmp(value(Beginner1), 'Yes'),
            Beginner2.value='Yes';
        end;
        
    case 'c_reenter',
        %if Go2CpkS, jitter has to be 0
        if strcmp(value(C_ReEnter), 'Go2Cpks'),
            ParamsSection(obj, 'jitter0'); 
        end;

    case 'beginner_param_view',
        switch value(BeginnerParams)
            case 'hidden',
                set(value(myfig), 'Visible', 'off');
            case 'view',
                set(value(myfig), 'Visible', 'on');
        end;

    case 'beginner_param_hide',
        BeginnerParams.value='hidden';
        set(value(myfig), 'Visible', 'off');
    case 'delete',
        delete(value(myfig));

    otherwise,
        error(['Don''t know how to handle action ' action]);
end;


