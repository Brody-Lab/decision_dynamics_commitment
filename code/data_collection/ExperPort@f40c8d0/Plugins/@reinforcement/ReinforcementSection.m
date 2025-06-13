% [varargout] = ReinforcementSection(obj, action, varargin)
%
% A plugin that provides an interface for generating partially reinforced trials.
% The plugin creates a togglebutton that opens and closes a new
% figure
%
% To use, simply add
%
%  >> reinforcement
%
% to the class definition of your protocol and then add
%
%
%  >> [x, y] = ReinforcementSection(obj, 'init', x, y);
%
% to your protocol's init section.
%
% IMPORTANT NOTE: Since the text boxes are GUI SoloParamHandles, Dispatcher will
% automatically store a history of the comments boxes on every trial. This
% is completely unnecessary. Clearing the history on each trial is
% recommended so as to avoid unnecessary memory hogging. See
% action='clear_history' below.
%
% PARAMETERS:
% -----------
%
% obj         Defaut object argument
%
% action      A string, one of the following:
%
%     'init' x y     RETURNS x, y
%             The 'init' action expects two more parameters, x and y, the
%             pixel position on the current figure on which a button that
%             opens/closes the Comments box figure will be placed. Returns
%             an x and y position suitable for putting in a GUI element
%             that will not overlap with the CommentsSection one.
%
%     'add_reward_state' sma state_name reward_dio reward_time RETURNS sma
%
%               This is where the main action happens.  Given all the
%               variables set in the gui (or through the set function) this
%               creates adds a state to the sma which plays the reward
%               sound and delivers water reward if the "rules" indicate
%               that reward should be delivered on this trial
%
%
%     'set' name value
%
%     'get' name RETURNS value
%
%
%     'close'
%             Close and delete any figures or SoloParamHandles associated
%             with this section.
%
%     'reinit'
%             Closes and deletes figures and SoloParamHandles associated
%             with this section; then reinitializes, starting at the same
%             point of the same original figure than the last 'init'
%
%
% EXAMPLE:
% --------
%
% On every 'prepare_next_trial' in your state matrix section, you could do:
%    [LeftWValveTime RightWValveTime] = WaterValvesSection(obj, 'get_water_times', hit_streak);
%    if this_trial=='r'
%        water_dio=right1water;
%        water_time = RightWValveTime;
%    else
%        water_dio=left1water;
%        water_time = LeftWValveTime;
%    end
%    sma=ReinforcementSection(obj, 'add_reward_state',sma,'reward_state',water_dio,water_time);


% Written by Jeffrey Erlich Aug 2011

function [x, y] = ReinforcementSection(obj, action, varargin)

GetSoloFunctionArgs(obj);
curtime=now;

switch action,
    
    %% INIT
    
    case 'init'
        
        
        
        if length(varargin) < 2,
            error('Need at least two arguments, x and y position, to initialize %s', mfilename);
        end;
        x = varargin{1}; y = varargin{2};
        
        
        SoloParamHandle(obj,'right_baited','value',1);
        SoloParamHandle(obj,'left_baited','value',1);
        SoloParamHandle(obj,'right_baited_history','value',[]);
        SoloParamHandle(obj,'left_baited_history','value',[]);
        SoloParamHandle(obj,'right_reward_history','value',[]);
        SoloParamHandle(obj,'left_reward_history','value',[]);
        
        
        SoloParamHandle(obj, 'my_xyfig', 'value', [x y double(gcf)]);
        ToggleParam(obj, 'RFShow', 0, x, y, 'OnString', 'Reinf Showing', ...
            'OffString', 'Reinf Hidden', 'TooltipString', 'Show/Hide Reinfocement panel');
        set_callback(RFShow, {mfilename, 'show_hide'}); %#ok<NODEF> (Defined just above)
        next_row(y);
        
        SoloParamHandle(obj, 'myfig', 'value', double(figure('Position', [ 226   122  606   163], ...
            'closerequestfcn', [mfilename '(' class(obj) ', ''hide'');'], 'MenuBar', 'none', ...
            'Name', mfilename)), 'saveable', 0);
        set(gcf, 'Visible', 'off');
        
        nx=10; ny=10;
        
        % ---
        
        NumeditParam(obj,'L_maxwithout',1,nx,ny);
        next_row(ny);
        MenuParam(obj,'L_RFSchedType',{'Prob'},'Prob',nx,ny, ...
            'labelfraction',0.65, ...
            'TooltipString',sprintf(['\nVR: Variable Ratio\nVI: Variable Interval\n'  ...
            'FR: Fixed Ratio\nFI: Fixed Interval\nIf you use a ratio schedule than the distrib ui' ...
            'units are in trials.  If you use a schedule interval then the distribUI units' ...
            'are in seconds\nUse google to learn more about the different reward schedules.']));
        
        
        
        lh=get_glhandle(L_RFSchedType);
        p2=get(lh(2),'Position');
        p2(3)=80;
        set(lh(2),'Position',p2)
        
        next_row(ny);
        
        [nx, ny] = DistribInterface(obj, 'add', 'Left_IRI', nx, ny, 'Style', ...
            'binomial', 'Mu', 1, 'Sd', 3, 'Min', 0, 'Max', 5);
        
        
        
        next_column(nx);
        nx=nx-40;
        ny=10;
        NumeditParam(obj,'R_maxwithout',1,nx,ny);
        next_row(ny);
        
        MenuParam(obj,'R_RFSchedType',{'Prob'},'Prob',nx,ny, ...
            'labelfraction',0.65, ...
            'TooltipString',sprintf(['\nVR: Variable Ratio\nVI: Variable Interval\n'  ...
            'FR: Fixed Ratio\nFI: Fixed Interval\nIf you use a ratio schedule than the distrib ui' ...
            'units are in trials.  If you use a schedule interval then the distribUI units' ...
            'are in seconds\nUse google to learn more about the different reward schedules.']));
        
        lh=get_glhandle(R_RFSchedType);
        p2=get(lh(2),'Position');
        p2(3)=80;
        set(lh(2),'Position',p2)
        next_row(ny);
        
        [nx, ny] = DistribInterface(obj, 'add', 'Right_IRI', nx, ny, 'Style', ...
            'binomial', 'Mu', 1, 'Sd', 3, 'Min', 0, 'Max', 5);
        
        next_column(nx);
        ny=10;
        nx=nx-40;
        SoundInterface(obj,'add','Reward_Sound',nx,ny,'Volume',0,'Duration',0);
        
        
        
        % ---
        
        figure(value(my_xyfig(3)));
        
        
        
    case 'baited',
        %% baited
        x=value(left_baited);
        y=value(right_baited);
        
        
    case 'get_sound_id',
        x=SoundManagerSection(obj, 'get_sound_id', 'Reward_Sound');
    
        
    case 'trial_completed',    
        right_baited_history.value=[value(right_baited_history); right_baited+0];
        left_baited_history.value=[value(left_baited_history); left_baited+0];
        
        last_side=varargin{1};
        last_hit=varargin{2};
        
        % First find out if the last trial was correct and
        % push the history
        
        if last_hit==1
            if last_side=='r' || last_side==1
                if right_baited==1
                    right_reward_history.value=[value(right_reward_history) 1];
                else
                    right_reward_history.value=[value(right_reward_history) 0];
                end
                right_baited.value=0;
                left_reward_history.value=[value(left_reward_history) 0];
                
            elseif last_side=='l' || last_side==-1
                if left_baited==1
                    left_reward_history.value=[value(left_reward_history) 1];
                else
                    left_reward_history.value=[value(left_reward_history) 0];
                end
                left_baited.value=0;
                right_reward_history.value=[value(right_reward_history) 0];
                
            else
                error('ReinforcementSection only recognizes l/r or -1/1 for sides')
            end
        else
            left_reward_history.value=[value(left_reward_history) 0];
            right_reward_history.value=[value(right_reward_history) 0];
        end
    case 'prepare_next_trial'
        %% prepare_next_trial

        
        % Now figure out if we should bait the left and right rewards.
        
        % Eventually this code will be more complex, and will likely move
        % to a different place in the code, but for now do the simple thing
        
        % Do right
        
        biased_coin_flip=DistribInterface(obj,'get_new_sample','Right_IRI');
        if biased_coin_flip==1 || (length(right_baited_history)>R_maxwithout && sum(right_baited_history(end-(R_maxwithout-1):end))==0)
            right_baited.value=1;
        end
        
        biased_coin_flip=DistribInterface(obj,'get_new_sample','Left_IRI');
        if biased_coin_flip==1 || (length(left_baited_history)>L_maxwithout && sum(left_baited_history(end-(R_maxwithout-1):end))==0)
            left_baited.value=1;
        end
        
        
        
    case 'add_to_pd'
        %% add to pd
        x=varargin{1};
        x.right_baited=right_baited_history(:);
        x.left_baited=left_baited_history(:);
        x.right_rewards=right_reward_history(:);
        x.left_rewards=left_reward_history(:);
        
        
        
        %% GET
        
    case 'get',
        sph=eval(varargin{1});
        x = value(sph);     %#ok<NODEF>
        
        %% SET
        
    case 'set',
        if nargin < 4,
            warning('ReinforcementSection:Invalid', '''set'' action needs 4 parameters');
            return;
        end;
        name=varargin{1};
        val=varargin{2};
        
        sph=eval(name);
        sph.value_callback = val;
        
        
        %% SHOW HIDE
        
    case 'hide',
        RFShow.value = 0; set(value(myfig), 'Visible', 'off');
        
    case 'show',
        RFShow.value = 1; set(value(myfig), 'Visible', 'on');
        
    case 'show_hide',
        if RFShow == 1, set(value(myfig), 'Visible', 'on'); %#ok<NODEF> (defined by GetSoloFunctionArgs)
        else                   set(value(myfig), 'Visible', 'off');
        end;
        
        
        % ------------------------------------------------------------------
        %%              CLOSE
        % ------------------------------------------------------------------
    case 'close'
        if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)),
            delete(value(myfig));
        end;
        delete_sphandle('owner', ['^@' class(obj) '$'], 'fullname', ['^' mfilename '_']);
        
        
        % ------------------------------------------------------------------
        %%              REINIT
        % ------------------------------------------------------------------
    case 'reinit'
        x = my_xyfig(1); y = my_xyfig(2); origfig = my_xyfig(3);
        currfig = double(gcf);
        
        feval(mfilename, obj, 'close');
        
        figure(origfig);
        feval(mfilename, obj, 'init', x, y);
        figure(currfig);
        
        
    otherwise
        warning('ReinforcementSection:Invalid', 'Don''t know action %s\n', action);
end;

