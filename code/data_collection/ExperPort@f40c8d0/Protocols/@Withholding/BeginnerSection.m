function [x, y, ...
    Beginner, WaitPokeNecessary, TimeToFakePoke, RewardCounter] = ...
    BeginnerSection(obj, action, x, y)
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

switch action
    case 'init',
        
        fig=gcf; %main figure of Masa_Wighholding protocol
        MenuParam(obj, 'Beginner', {'Yes', 'No'}, 1, x, y);next_row(y);
        set_callback(Beginner, {'BeginnerSection', 'beginner'});
        SubHeaderParam(obj, 'BeginnerSection', 'Beginner Section', x, y);
        next_row(y);
        oldx=x; oldy=y;
        
        %new figure for beginner parameters for nose poke block
        x=1; y=1;
        SoloParamHandle(obj, 'myfig', 'value', figure, 'saveable',0);
        set(value(myfig),'Position',[1090 45, 200 80], ...
            'Visible', 'on', 'MenuBar', 'none', 'Name', 'Beginner', ...
            'NumberTitle', 'off', 'CloseRequestFcn', ...
            ['BeginnerSection(' class(obj) ', ''beginner_param_hide'')']);

        MenuParam(obj, 'WaitPokeNecessary', {'No', 'Yes'}, 1, x, y, 'labelfraction', 0.6);next_row(y);
        set_callback(WaitPokeNecessary, {'BeginnerSection', 'wait_poke_necessary'});
        MenuParam(obj, 'TimeToFakePoke', {0.0001,3,6,10,20,30,60,100,300},1, x, y', 'labelfraction', 0.6);next_row(y);
        set_callback(TimeToFakePoke, {'BeginnerSection', 'time_to_fake_poke'});
        DispParam(obj, 'RewardCounter', 0, x, y, 'labelfraction', 0.6);next_row(y);
        SubHeaderParam(obj, 'BeginnerParams', 'Beginner Parameters',x,y);
        
        figure(fig);x=oldx;y=oldy;
        %end of case 'init'
        
    case 'wait_poke_necessary',
        if strcmp(value(WaitPokeNecessary), 'No'),
            Beginner.value='Yes';
            set(value(myfig), 'Visible', 'on');
        end;
        
    case 'time_to_fake_poke',
        switch value(TimeToFakePoke),
            case 0.0001,
                RewardCounter.value=0;
            case 3,
                RewardCounter.value=5;
            case 6,
                RewardCounter.value=10;
            case 10,
                RewardCounter.value=20;
            case 20,
                RewardCounter.value=30;
            case 30,
                RewardCounter.value=40;
            case 60,
                RewardCounter.value=50;
            case 100,
                RewardCounter.value=60;
            case 300,
                RewardCounter.value=70;
        end;              
 
    case 'beginner',
        %callback of SPH Beginner in this section
        %also called from case 'visualize_nose_poke_block_params' in this
        %section
        switch value(Beginner)
            case 'No',
                set(value(myfig), 'Visible', 'off');
                WaitPokeNecessary.value = 'Yes';
            case 'Yes',
                set(value(myfig), 'Visible', 'on');
        end;
        
    case 'wait_poke_necessary_yes',
        %callback of TrighLengthConstant
        WaitPokeNecessary.value = 'Yes';

    case 'beginner_param_hide',
        Beginner.value='No';
        BeginnerSection(obj, 'beginner');
        set(value(myfig), 'Visible', 'off');

    otherwise,
        error(['Don''t know how to handle action ' action]);
end;


