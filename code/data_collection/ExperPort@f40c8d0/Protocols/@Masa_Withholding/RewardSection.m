
function [x, y, ...
    DelayToReward, ...
    RightLarge, RightSmall, LeftLarge, LeftSmall, CenterLarge, CenterSmall, ...
    PortAssign] ...
    = RewardSection(obj, action, x, y)

GetSoloFunctionArgs;
%SoloFunction('ParamsSection', 'rw_args', {}, 'ro_args', {});

switch action,
 case 'init',
   EditParam(obj, 'DelayToReward', 0.5, x, y); next_row(y);
   EditParam(obj, 'LargeReward_ul', 40, x, y); next_row(y);
   EditParam(obj, 'SmallReward_ul', 10, x, y); next_row(y);
   DispParam(obj, 'CenterLarge', NaN, x,y);
   DispParam(obj, 'CenterSmall', NaN, x,y+20);
   DispParam(obj, 'LeftLarge', NaN, x, y, 'position', [x y 100 20]);
   DispParam(obj, 'RightLarge', NaN, x, y, 'position', [x+100 y 100 20]); next_row(y);
   DispParam(obj, 'LeftSmall', NaN, x, y, 'position', [x y 100 20]);
   DispParam(obj, 'RightSmall', NaN, x, y, 'position', [x+100 y 100 20]); next_row(y);
   MenuParam(obj, 'ValveConnectConfig',{'V1->L V2->R','V1->C','V2->C'},1,x,y); next_row(y);
   set_callback({LargeReward_ul, SmallReward_ul,ValveConnectConfig}, ...
       {'RewardSection','calculate'});
   MenuParam(obj, 'PortAssign', ...
       {'NP-C;Rew-Both','NP-C;Rew-L','NP-C;Rew-R', ...
        'LP-C;Rew-Both','LP-C;Rew-L','LP-C;Rew-R', ...
        'NP-L,Rew-C','NP-R,Rew-C', ...
        'LP-L,Rew-C','LP-R,Rew-C', ...
        'NP-L;LP-R;Rew-C','NP-R;LP-L;Rew-C'}, ...
        1,x,y, 'labelfraction', 0.45); next_row(y);
   SubHeaderParam(obj, 'RewardParams', 'Reward Parameters',x,y);next_row(y);
   next_row(y,0.5);
   RewardSection(obj,'calculate');
   
 case 'prepare_next_trial',
     %actually only for the case being called on LoadSettings
     if n_done_trials == 0,
         RewardSection(obj, 'calculate');
     end;
     
 case 'calculate',         
     %calculate reward value change display if necessary
    [VALVE SIZE OPEN_TIME] = ...
       textread('watercalib.txt', '%s %d %f', 'delimiter',';');
   if strcmp(value(ValveConnectConfig),'V1->L V2->R'),
       IDX_1S = find(strcmp(VALVE,'Valve1') & SIZE == value(SmallReward_ul));
       if isempty(IDX_1S), LeftSmall.value = NaN; Warning('you need to calibrate water?');
       else LeftSmall.value = OPEN_TIME(IDX_1S);
       end;
       IDX_1L = find(strcmp(VALVE,'Valve1') & SIZE == value(LargeReward_ul));
       if isempty(IDX_1L), LeftLarge.value = NaN; Warning('you need to calibrate water?');
       else LeftLarge.value = OPEN_TIME(IDX_1L);
       end;
       IDX_2S = find(strcmp(VALVE,'Valve2') & SIZE == value(SmallReward_ul));
       if isempty(IDX_2S), RightSmall.value = NaN; Warning('you need to calibrate water?');
       else RightSmall.value = OPEN_TIME(IDX_2S);
       end;
       IDX_2L = find(strcmp(VALVE,'Valve2') & SIZE == value(LargeReward_ul));
       if isempty(IDX_2L), RightLarge.value = NaN; Warning('you need to calibrate water?');
       else RightLarge.value = OPEN_TIME(IDX_2L);
       end;
       set([get_ghandle(CenterLarge) get_lhandle(CenterLarge)],'visible','off');
       set([get_ghandle(CenterSmall) get_lhandle(CenterSmall)],'visible','off');
       set([get_ghandle(LeftLarge) get_lhandle(LeftLarge)],'visible','on');
       set([get_ghandle(LeftSmall) get_lhandle(LeftSmall)],'visible','on');
       set([get_ghandle(RightLarge) get_lhandle(RightLarge)],'visible','on');
       set([get_ghandle(RightSmall) get_lhandle(RightSmall)],'visible','on');
   elseif strcmp(value(ValveConnectConfig),'V1->C'),
       IDX_1S = find(strcmp(VALVE,'Valve1') & SIZE == value(SmallReward_ul));
       if isempty(IDX_1S), CenterSmall.value = NaN; Warning('you need to calibrate water?');
       else CenterSmall.value = OPEN_TIME(IDX_1S);
       end;
       IDX_1L = find(strcmp(VALVE,'Valve1') & SIZE == value(LargeReward_ul));
       if isempty(IDX_1L), CenterLarge.value = NaN; Warning('you need to calibrate water?');
       else CenterLarge.value = OPEN_TIME(IDX_1L);
       end;
       set([get_ghandle(CenterLarge) get_lhandle(CenterLarge)],'visible','on');
       set([get_ghandle(CenterSmall) get_lhandle(CenterSmall)],'visible','on');
       set([get_ghandle(LeftLarge) get_lhandle(LeftLarge)],'visible','off');
       set([get_ghandle(LeftSmall) get_lhandle(LeftSmall)],'visible','off');
       set([get_ghandle(RightLarge) get_lhandle(RightLarge)],'visible','off');
       set([get_ghandle(RightSmall) get_lhandle(RightSmall)],'visible','off');
   elseif strcmp(value(ValveConnectConfig),'V2->C'),
       IDX_2S = find(strcmp(VALVE,'Valve2') & SIZE == value(SmallReward_ul));
       if isempty(IDX_2S), CenterSmall.value = NaN;Warning('you need to calibrate water?');
       else CenterSmall.value = OPEN_TIME(IDX_2S);
       end;
       IDX_2L = find(strcmp(VALVE,'Valve2') & SIZE == value(LargeReward_ul));
       if isempty(IDX_2L), CenterLarge.value = NaN;Warning('you need to calibrate water?');
       else CenterLarge.value = OPEN_TIME(IDX_2L);
       end;
       set([get_ghandle(CenterLarge) get_lhandle(CenterLarge)],'visible','on');
       set([get_ghandle(CenterSmall) get_lhandle(CenterSmall)],'visible','on');
       set([get_ghandle(LeftLarge) get_lhandle(LeftLarge)],'visible','off');
       set([get_ghandle(LeftSmall) get_lhandle(LeftSmall)],'visible','off');
       set([get_ghandle(RightLarge) get_lhandle(RightLarge)],'visible','off');
       set([get_ghandle(RightSmall) get_lhandle(RightSmall)],'visible','off');
   end; 
     
 otherwise,
   error(['Don''t know how to deal with action ' action]);
   
end;

