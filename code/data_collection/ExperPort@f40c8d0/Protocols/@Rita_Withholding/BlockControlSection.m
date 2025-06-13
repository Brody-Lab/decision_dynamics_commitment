function [x, y, BlockName] = ...
            BlockControlSection(obj, action, x, y)

GetSoloFunctionArgs;

switch action
    case 'init',       
        NumEditParam(obj, 'EveryN', 100, x, y);
        NumEditParam(obj, 'Min_Flat', 81, x, y , 'position', [x y 100 20]);
        NumEditParam(obj, 'Max_Flat', 120, x, y, 'position', [x+100 y 100 20]);
        NumEditParam(obj, 'Min_Exp', 81, x, y, 'position', [x y 100 20]);
        NumEditParam(obj, 'Prob_Exp', 0.2, x, y, 'position', [x+100 y 100 20]);next_row(y);
        MenuParam(obj, 'BlockSwitchMethod', ...
            {'Manual','Auto_EveryN','Auto_FlatDist','Auto_ExpDist'},1,x,y); next_row(y); 
        set_callback({BlockSwitchMethod,EveryN,Min_Flat,Max_Flat,Min_Exp}, ...
                     {'BlockControlSection', 'reset'});
        NumEditParam(obj, 'SwitchInNTrials', NaN, x, y); next_row(y);
        MenuParam(obj, 'BlockName', {'NosePoke','LeverPress','Both'}, 1, x, y); next_row(y);
        set_callback(BlockName, {'BlockControlSection', 'block_name'});
        SubHeaderParam(obj, 'BlockControlParams', 'Block Control Parameters',x,y);next_row(y);
        next_row(y,0.5);
        SoloParamHandle(obj, 'DoneTrialBlock', 'value', 'NosePoke');
        
        set([get_ghandle(EveryN) get_lhandle(EveryN)],'visible','off');
        set([get_ghandle(Min_Flat) get_lhandle(Min_Flat)],'visible','off');
        set([get_ghandle(Max_Flat) get_lhandle(Max_Flat)],'visible','off');
        set([get_ghandle(Min_Exp) get_lhandle(Min_Exp)],'visible','off');
        set([get_ghandle(Prob_Exp) get_lhandle(Prob_Exp)],'visible','off');             
    
    case 'prepare_next_trial',
        
        if n_done_trials == 0, %called from LoadSettings
            BlockControlSection(obj,'reset');
            return;
        end;
        
        BLOCK_NAME = value(BlockName);
        BLOCK_NAME_HISTORY = get_history(BlockName);
        PREVIOUS_BLOCK_NAME = BLOCK_NAME_HISTORY{n_done_trials};
        
        if ~strcmp(PREVIOUS_BLOCK_NAME,BLOCK_NAME), %manually switched. do nothing
            return;
        end;
        
        switch value(BlockSwitchMethod),
            case 'Manual',
                %do nothing
            case 'Auto_EveryN',
                SwitchInNTrials.value = value(SwitchInNTrials)-1; %count down
                if value(SwitchInNTrials) == 0,
                    %SWITCH!!
                    if strcmp(BLOCK_NAME,'NosePoke'),
                        BLOCK_NAME = 'LeverPress';
                    elseif strcmp(BLOCK_NAME,'LeverPress'),
                        BLOCK_NAME = 'NosePoke';
                    end;
                    ShowBlockParams.value = 1 - value(ShowBlockParams);
                    SwitchInNTrials.value = value(EveryN); %new value for the next switch
                end;
            case 'Auto_FlatDist',
                SwitchInNTrials.value = value(SwitchInNTrials)-1; %count down
                if value(SwitchInNTrials) == 0,
                    %SWITCH!!
                    if strcmp(BLOCK_NAME,'NosePoke'),
                        BLOCK_NAME = 'LeverPress';
                    elseif strcmp(BLOCK_NAME,'LeverPress'),
                        BLOCK_NAME = 'NosePoke';
                    end;
                    ShowBlockParams.value = 1 - value(ShowBlockParams);
                    nums = randperm(value(Max_Flat)-value(Min_Flat));
                    SwitchInNTrials.value = value(Min_Flat)+nums(1);
                end;
            case 'Auto_ExpDist',
                SwitchInNTrials.value = value(SwitchInNTrials)-1; %count down
                SwitchInNTrials.value = max(value(SwitchInNTrials),0); %should not go down below 0
                if value(SwitchInNTrials) == 0, %Ready To Switch, Roll a Dice
                    if rand < value(Prob_Exp),
                        %SWITCH!!
                        if strcmp(BLOCK_NAME,'NosePoke'),
                            BLOCK_NAME = 'LeverPress';
                        elseif strcmp(BLOCK_NAME,'LeverPress'),
                            BLOCK_NAME = 'NosePoke';
                        end;
                        ShowBlockParams.value = 1 - value(ShowBlockParams);
                        SwitchInNTrials.value = value(Min_Exp);
                    end;
                end;
            otherwise,
                error('don''t know this param for BlockSwitchMethod %s', ...
                        value(BlockSwitchMethod));
        end;
        
        BlockName.value = BLOCK_NAME;
        
    case 'set_next_done_trial_block', %another simple function for prepare next trial
        DoneTrialBlock.value = value(BlockName);

    case 'block_name',
        BlockControlSection(obj,'reset');

    case 'reset',
        %calculate new value for SwithInNTrials
        switch value(BlockSwitchMethod),
            case 'Manual',
                set([get_ghandle(EveryN) get_lhandle(EveryN)],'visible','off');
                set([get_ghandle(Min_Flat) get_lhandle(Min_Flat)],'visible','off');
                set([get_ghandle(Max_Flat) get_lhandle(Max_Flat)],'visible','off');
                set([get_ghandle(Min_Exp) get_lhandle(Min_Exp)],'visible','off');
                set([get_ghandle(Prob_Exp) get_lhandle(Prob_Exp)],'visible','off');
                
            case 'Auto_EveryN',
                set([get_ghandle(EveryN) get_lhandle(EveryN)],'visible','on');
                set([get_ghandle(Min_Flat) get_lhandle(Min_Flat)],'visible','off');
                set([get_ghandle(Max_Flat) get_lhandle(Max_Flat)],'visible','off');
                set([get_ghandle(Min_Exp) get_lhandle(Min_Exp)],'visible','off');
                set([get_ghandle(Prob_Exp) get_lhandle(Prob_Exp)],'visible','off');
                
                SwitchInNTrials.value = value(EveryN); 
                
            case 'Auto_FlatDist',
                set([get_ghandle(EveryN) get_lhandle(EveryN)],'visible','off');
                set([get_ghandle(Min_Flat) get_lhandle(Min_Flat)],'visible','on');
                set([get_ghandle(Max_Flat) get_lhandle(Max_Flat)],'visible','on');
                set([get_ghandle(Min_Exp) get_lhandle(Min_Exp)],'visible','off');
                set([get_ghandle(Prob_Exp) get_lhandle(Prob_Exp)],'visible','off');
                
                nums = randperm(value(Max_Flat)-value(Min_Flat));
                SwitchInNTrials.value = value(Min_Flat)+nums(1);        
                
            case 'Auto_ExpDist',
                set([get_ghandle(EveryN) get_lhandle(EveryN)],'visible','off');
                set([get_ghandle(Min_Flat) get_lhandle(Min_Flat)],'visible','off');
                set([get_ghandle(Max_Flat) get_lhandle(Max_Flat)],'visible','off');
                set([get_ghandle(Min_Exp) get_lhandle(Min_Exp)],'visible','on');
                set([get_ghandle(Prob_Exp) get_lhandle(Prob_Exp)],'visible','on');
                
                SwitchInNTrials.value = value(Min_Exp);
                
            otherwise,
                error('don''t know this param for BlockSwitchMethod %s', ...
                        value(BlockSwitchMethod));
        end;
                
    otherwise,
        error('don''t know this action %s', action);
        
end;

