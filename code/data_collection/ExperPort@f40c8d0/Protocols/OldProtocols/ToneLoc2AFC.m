function out = toneloc2AFC(varargin)

global exper

if nargin > 0 
    action = lower(varargin{1});
else
    action = lower(get(gcbo,'tag'));
end

out=1;  
switch action
    
    case 'init'
        ModuleNeeds(me,{'rpbox'});
        
        SetParam(me,'priority','value',GetParam('rpbox','priority')+1);
        fig = ModuleFigure(me,'visible','off');	
        
        hs = 100;
        h = 5;
        vs = 20;
        n = 0;
        
        Freq=[1000 2000 5000 7000 13000 15000 17000 23000  -1  -1  -1  -1   1   2   1   2   1   2];  %Hz
        Dur =[ 100  100  100  100   100   100   100   100 100 100 100 100 100 100 100 100 100 100];  %msec
        SPL =[  70   70   70   70    70    70    70    70  45  30  20  15  70  70  60  60  50  50];  %Max=PPdB SPL
        Str ={'1k 70dB 100ms','2k 70dB 100ms','5k 70dB 100ms','7k 70dB 100ms','13k 70dB 100ms',...
                '15k 70dB 100ms','17k 70dB 100ms','23k 70dB 100ms','wn 25dB atn 100ms','wn 40dB atn 100ms','wn 50dB atn 100ms','wn 55dB atn 100ms','Low-Chord',...
                'Hi-Chord','Low-Chord -10dB','Hi-Chord -10dB','Low-Chord -20dB','Hi-Chord -20dB','Silence','Random'}; 
        
        InitParam(me,'MaxTrial','value',1000);        
        
        n=n+.2;
        InitParam(me,'DirectDeliver1','ui','edit','value',0,'user',0,'pos',[h n*vs hs*1.2 vs]);
        SetParamUI(me,'DirectDeliver1','label','DirectDeliver 1','enable','on');
        InitParam(me,'DirectDeliver2','ui','edit','value',0,'user',0,'pos',[h+hs*2.1 n*vs hs*.85 vs]);
        SetParamUI(me,'DirectDeliver2','label','DirectDeliver 2','enable','on');
        InitParam(me,'WaterValveDur','ui','edit','value',.12,'pos',[h+hs*3.9 n*vs hs*.85 vs]);
        SetParamUI(me,'WaterValveDur','label','WaterV_Dur');
        InitParam(me,'Abort1','ui','disp','value',0,'pref',0,'pos',[h+hs*5.8 n*vs hs*.85 vs]);
        SetParamUI(me,'Abort1','label','Abort 1');
        InitParam(me,'Abort2','ui','disp','value',0,'pref',0,'pos',[h+hs*7.6 n*vs hs*.85 vs]);
        SetParamUI(me,'Abort2','label','Abort 2');
        n=n+1;
        
        InitParam(me,'Tn1_Right_Ch','ui','popupmenu','list',Str,'value',length(Str)-1,'user',length(Str)-1,'distractor',length(Str)-1,'pos',[h n*vs hs*1.2 vs]); 
        SetParamUI(me,'Tn1_Right_Ch','label','Tone 1: Right','enable','off','UserData',9);
        InitParam(me,'Tn2_Right_Ch','ui','popupmenu','list',Str,'value',2,'user',2,'distractor',length(Str)-1,'pos',[h+hs*2.1 n*vs hs*.85 vs]); 
        SetParamUI(me,'Tn2_Right_Ch','label','Tone 2: Right','enable','off','UserData',2);
        InitParam(me,'ValidPokeDur','ui','edit','value',.02,'pos',[h+hs*3.9 n*vs hs*.85 vs]);
        SetParamUI(me,'ValidPokeDur','label','ValidPoke_Dur');
        InitParam(me,'rightFalse1','ui','disp','value',0,'pref',0,'pos',[h+hs*5.8 n*vs hs*.85 vs]);
        SetParamUI(me,'rightFalse1','label','False right poke1');
        InitParam(me,'rightFalse2','ui','disp','value',0,'pref',0,'pos',[h+hs*7.6 n*vs hs*.85 vs]);
        SetParamUI(me,'rightFalse2','label','False right poke2');
        n=n+1;
        
        InitParam(me,'Tn1_Left_Ch','ui','popupmenu','list',Str,'value',2,'user',2,'distractor',length(Str)-1,'pos',[h n*vs hs*1.2 vs]); 
        SetParamUI(me,'Tn1_Left_Ch','label','Tone 1: Left','enable','on','UserData',9);
        InitParam(me,'Tn2_Left_Ch','ui','popupmenu','list',Str,'value',2,'user',2,'distractor',length(Str)-1,'pos',[h+hs*2.1 n*vs hs*.85 vs]); 
        SetParamUI(me,'Tn2_Left_Ch','label','Tone 2: Left','enable','on','UserData',2);
        InitParam(me,'RewardAvailDur','ui','edit','value',3,'pos',[h+hs*3.9 n*vs hs*.85 vs]);
        SetParamUI(me,'RewardAvailDur','label','RewardAvail_Dur');
        InitParam(me,'leftFalse1','ui','disp','value',0,'pref',0,'pos',[h+hs*5.8 n*vs hs*.85 vs]);
        SetParamUI(me,'leftFalse1','label','False left poke 1');
        InitParam(me,'leftFalse2','ui','disp','value',0,'pref',0,'pos',[h+hs*7.6 n*vs hs*.85 vs]);
        SetParamUI(me,'leftFalse2','label','False left poke 2');
        n=n+1;
        
        InitParam(me,'Tone1_Src','ui','popupmenu','list',{'Left';'Right';'Both/same';'Both/indp';'Random'},'value',1,'user',1,'enable_distractor',0,'use_cshedule',0,'pos',[h n*vs hs*1.2 vs]); 
        SetParamUI(me,'Tone1_Src','label','Tone 1 Source','enable','off');
        InitParam(me,'Tone2_Src','ui','popupmenu','list',{'Left';'Right';'Both/same';'Both/indp';'None';'Random'},'value',3,'user',3,'enable_distractor',0,'use_cshedule',0,'pos',[h+hs*2.1 n*vs hs*.85 vs]); 
        SetParamUI(me,'Tone2_Src','label','Tone 2 Source','enable','on');
        InitParam(me,'TimeOut','ui','edit','value',0,'pos',[h+hs*3.9 n*vs hs*.85 vs]);
        SetParamUI(me,'TimeOut','label','Time Out (sec)');
        InitParam(me,'Miss1','ui','disp','value',0,'pref',0,'pos',[h+hs*5.8 n*vs hs*.85 vs]);
        SetParamUI(me,'Miss1','label','Missed reward 1');
        InitParam(me,'Miss2','ui','disp','value',0,'pref',0,'pos',[h+hs*7.6 n*vs hs*.85 vs]);
        SetParamUI(me,'Miss2','label','Missed reward 2');
        n=n+1;
        
        InitParam(me,'CueSource','ui','popupmenu','list',{'1st tone location','2nd tone location','both tone location',...
                '1st tone freq','2nd tone freq','both tone freq'},'value',1,'user',1,'pos',[h n*vs hs*1.2 vs]);
        SetParamUI(me,'CueSource','label','CueSource');
        InitParam(me,'WaterPort','ui','popupmenu','list',{'Left';'Right';'Both';'Left_NoWater';'Right_NoWater';'Both_NoWater'},'value',1,'user',1,'pos',[h+hs*2.1 n*vs hs*.85 vs]);
        SetParamUI(me,'WaterPort','label','Water Port');
        InitParam(me,'Tone_Start','ui','edit','value',1,'pos',[h+hs*3.9 n*vs hs*.85 vs]);
        SetParamUI(me,'Tone_Start','label','Tone Start');
        InitParam(me,'RightHit1','ui','disp','value',0,'pref',0,'pos',[h+hs*5.8 n*vs hs*.85 vs]);
        SetParamUI(me,'RightHit1','label','Right Hit 1');
        InitParam(me,'RightHit2','ui','disp','value',0,'pref',0,'pos',[h+hs*7.6 n*vs hs*.85 vs]);
        SetParamUI(me,'RightHit2','label','Right Hit 2');
        n=n+1;
        
        task_list={'custom setting','Tn1 Loc: Left','Tn1 Loc: Right','Tn2 Loc: Left','Tn2 Loc: Right',...
                'Both Loc: 10L-10R','Both Loc: Random','Tn1 Loc: 10L-10R','Tn1 Loc: Random','Tn1Freq2AFC LBR',...
                'Tn1Freq2AFC LR','Tn1 Loc:2AFC','DM-Go/NoGo:Right Only','Match:R / nonMatch:L','DelayMatch','DelayMatch+distractor'}
        InitParam(me,'Task','ui','popupmenu','list',task_list,'value',1,'user',1,'pos',[h n*vs hs*1.2 vs]);
        SetParamUI(me,'Task','label','Task Setting');
        InitParam(me,'MinIPI','ui','popupmenu','list',{'250ms';'300ms';'350ms';'400ms';'500ms';'1 sec';'1.5 sec';'2 sec';'3 sec'},'value',3,...
            'user',[.25 .3 .35 .4 .5 1 1.5 2 3],'pos',[h+hs*2.1 n*vs hs*.85 vs]); 
        SetParamUI(me,'MinIPI','label','Min. IPI');
        InitParam(me,'Tone_Delay','ui','edit','value',.001,'pos',[h+hs*3.9 n*vs hs*.85 vs]);
        SetParamUI(me,'Tone_Delay','label','Tone Delay');
        InitParam(me,'LeftHit1','ui','disp','value',0,'pref',0,'pos',[h+hs*5.8 n*vs hs*.85 vs]);
        SetParamUI(me,'LeftHit1','label','Left Hit 1');
        InitParam(me,'LeftHit2','ui','disp','value',0,'pref',0,'pos',[h+hs*7.6 n*vs hs*.85 vs]);
        SetParamUI(me,'LeftHit2','label','Left Hit 2');
        n=n+1
        
        script={'none','T1f2AFC-->T1wnLoc','T1f2AFC-->wm_2AFCLoc','wm-->2AFCLoc'};
        InitParam(me,'Script','ui','popupmenu','list',script,'value',1,'user',1,'pos',[h n*vs hs*1.2 vs]);
        SetParamUI(me,'Script','label','Script');
        InitParam(me,'MaxIPI','ui','popupmenu','list',{'1 sec';'2 sec';'5 sec';'10 sec'},'value',2,...
            'user',[1 2 5 10],'pos',[h+hs*2.1 n*vs hs*.85 vs]); 
        SetParamUI(me,'MaxIPI','label','Max. IPI');
        InitParam(me,'ITI','ui','edit','value',1,'pref',1,'pos',[h+hs*3.9 n*vs hs*.85 vs]);
        SetParamUI(me,'ITI','label','ITI');
        InitParam(me,'Valid1st','ui','disp','value',0,'pref',0,'pos',[h+hs*5.8 n*vs hs*.85 vs]);
        SetParamUI(me,'Valid1st','label','Valid 1st poke');
        InitParam(me,'Valid2nd','ui','disp','value',0,'pref',0,'pos',[h+hs*7.6 n*vs hs*.85 vs]);
        SetParamUI(me,'Valid2nd','label','Valid 2nd poke');
        
        n=n+1; 
        InitParam(me,'CountedTrial','ui','disp','value',0,'pref',0,'pos',[h n*vs hs*1.2 vs]);
        SetParamUI(me,'CountedTrial','label','CountedTrial');        
        InitParam(me,'LastTonePokeDur','ui','disp','value',0,'pref',0,'user1',0,'user2',0,'pos',[h+hs*2.1 n*vs hs*.85 vs]); 
        SetParamUI(me,'LastTonePokeDur','label','Last TnPokeDur');        
        InitParam(me,'FirstTonePokeDur','ui','disp','value',0,'pref',0,'user1',0,'user2',0,'pos',[h+hs*3.9 n*vs hs*.85 vs]); 
        SetParamUI(me,'FirstTonePokeDur','label','TnPokeDur (ms)');        
        InitParam(me,'IPIAbort','ui','disp','value',0,'pref',0,'pos',[h+hs*5.8 n*vs hs*.85 vs]);
        SetParamUI(me,'IPIAbort','label','IPI L/R poke');
        InitParam(me,'IPIMiss','ui','disp','value',0,'pref',0,'pos',[h+hs*7.6 n*vs hs*.85 vs]);
        SetParamUI(me,'IPIMiss','label','>IPI no poke');
        InitParam(me,'NoGoCorrect','ui','disp','value',0,'pref',0,'pos',[h+hs*7.6 (n+1)*vs hs*.85 vs]);
        SetParamUI(me,'NoGoCorrect','label','Correct NoGo');
        
        n=n+1.2; 
        % message box
        uicontrol(fig,'tag','message','style','edit',...
            'enable','inact','horiz','left','pos',[h n*vs hs*2 vs]);
        InitParam(me,'ChangeSchedule','ui','pushbutton','value',0,'pref',0,'pos',[h+hs*2.1 n*vs hs*.75 vs]);
        SetParamUI(me,'ChangeSchedule','label','','string','New Schedule'); 
        InitParam(me,'ClearScore','ui','checkbox','value',1,'pref',0,'pos',[h+hs*3 n*vs hs*.8 vs]);
        SetParamUI(me,'ClearScore','label','','string','Clear Score');         
        InitParam(me,'Miss_Correction','ui','radiobutton','value',0,'pref',0,'pos',[h+hs*3.8 n*vs hs*.425 vs]);
        SetParamUI(me,'Miss_Correction','label','','string','miss'); 
        InitParam(me,'False_Correction','ui','radiobutton','value',0,'pref',0,'pos',[h+hs*4.225 n*vs hs*.45 vs]);
        SetParamUI(me,'False_Correction','label','','string','false'); 
        InitParam(me,'Abort_Correction','ui','radiobutton','value',0,'pref',0,'pos',[h+hs*4.675 n*vs hs*1.4 vs]);
        SetParamUI(me,'Abort_Correction','label','','string','abort Correction in next'); 
        InitParam(me,'CorrectionTrial','ui','edit','value',5,'pref',0,'range',[1 10],'pos',[h+hs*6 n*vs hs*.25 vs]);
        SetParamUI(me,'CorrectionTrial','label','trials');
        
        n=n+2.1;
        InitParam(me,'PlotAxes_Back','value',0,'user',0);
        InitParam(me,'PlotAxes_Forward','value',0,'user',0);
        InitParam(me,'SetPlotAxes_Back2Start','ui','pushbutton','value',0,'pref',0,'pos',[h+hs*0.4 n*vs hs*.5 vs]);
        SetParamUI(me,'SetPlotAxes_Back2Start','label','','string','|<<');
        InitParam(me,'SetPlotAxes_Back','ui','pushbutton','value',0,'pref',0,'pos',[h+hs*.9 n*vs hs*.5 vs]);
        SetParamUI(me,'SetPlotAxes_Back','label','','string','<');
        InitParam(me,'SetPlotAxes_Default','ui','pushbutton','value',0,'pref',0,'pos',[h+hs*3.8 n*vs hs*.5 vs]);
        SetParamUI(me,'SetPlotAxes_Default','label','','string','< reset >');
        InitParam(me,'SetPlotAxes_Forward','ui','pushbutton','value',0,'pref',0,'pos',[h+hs*5.2 n*vs hs*.5 vs]);
        SetParamUI(me,'SetPlotAxes_Forward','label','','string','>');
        InitParam(me,'SetPlotAxes_Forward2End','ui','pushbutton','value',0,'pref',0,'pos',[h+hs*5.7 n*vs hs*.5 vs]);
        SetParamUI(me,'SetPlotAxes_Forward2End','label','','string','>>|');
        
        InitParam(me,'Trial_Events','value',[],'trial',[]);
        
        BlankSchedule=zeros(1,GetParam(me,'MaxTrial'));
        InitParam(me,'ToneFreq','value',BlankSchedule,'user',Freq);
        InitParam(me,'ToneDur','value',BlankSchedule,'user',Dur);
        InitParam(me,'ToneSPL','value',BlankSchedule,'user',SPL);
        InitParam(me,'Result','value',BlankSchedule);
        %         InitParam(me,'TonePokeDur','value',BlankSchedule);
        InitParam(me,'nTonePoke','value',BlankSchedule);
        
        
        InitParam(me,'ValidPokeNum','value',BlankSchedule);
        InitParam(me,'Stimulus_Schedule','value',BlankSchedule);
        InitParam(me,'WaterPort_Schedule','value',BlankSchedule);
        InitParam(me,'ToneSource_Schedule','value',BlankSchedule);
        InitParam(me,'Tone_Schedule','value',BlankSchedule,'user',0);
        InitParam(me,'NoGo_Schedule','value',BlankSchedule);
        InitParam(me,'NoGo_Ratio','value',0);
        InitParam(me,'DirectDeliver_Schedule','value',BlankSchedule);

        
        InitParam(me,'Tn1_Right_Freq','value',11);
        InitParam(me,'Tn1_Left_Freq','value',10);
        InitParam(me,'Tn2_Right_Freq','value',11);
        InitParam(me,'Tn2_Left_Freq','value',10);
        InitParam(me,'ToneLoc2AFC_List','value',[9 10 11 4 5 6 7 8]);
        InitParam(me,'DelayMatchSample_List','value',[10 11]);
        InitParam(me,'NonSample_List','value',[]);
        InitParam(me,'rBeep','value',[]);
        InitParam(me,'lBeep','value',[]);        
        InitTones;
        rpbox('InitRPStereoSound');
        %         beep=CurrentTones;        
        %         rpbox('LoadRPStereoSound',beep);
        eval([me '(''task'')']);
        
        rpbox('send_matrix', [0 0 0 0 0 0 0 180 0 0]);
        rpbox('send_matrix',state_transition_matrix(NextParam));
        
        set(fig,'pos',[140 361-n*vs hs*9.6 (n+18)*vs],'visible','on');
        plot_schedule;
        
    case 'trialready'
        % %         rpbox('send_matrix',state_transition_matrix(NextParam));
        
    case 'trialend'
        
    case 'reset'
        Message(me,'');
        Message('control','wait for RP (RP2/RM1) reseting');
        if Getparam(me,'ClearScore')
            SetParam(me,'CountedTrial',0);
            SetParam(me,'Abort1',0); 
            SetParam(me,'Abort2',0); 
            SetParam(me,'rightFalse1',0);
            SetParam(me,'rightFalse2',0);
            SetParam(me,'leftFalse1',0);
            SetParam(me,'leftFalse2',0);
            SetParam(me,'Miss1',0);
            SetParam(me,'Miss2',0);
            SetParam(me,'rightHit1',0);
            SetParam(me,'rightHit2',0);
            SetParam(me,'leftHit1',0);
            SetParam(me,'leftHit2',0);
            SetParam(me,'Valid1st',0);
            SetParam(me,'Valid2nd',0);
            SetParam(me,'IPIAbort',0);
            SetParam(me,'IPIMiss',0);
            SetParam(me,'NoGoCorrect',0);
        end
        
        SetParam(me,'Trial_Events','value',[],'trial',[]);
        BlankSchedule= zeros(1,GetParam(me,'MaxTrial'));
        SetParam(me,'nTonePoke','value',BlankSchedule);
        SetParam(me,'Result','value',BlankSchedule);        
        SetParam(me,'ValidPokeNum','value',BlankSchedule);
        SetParam(me,'WaterPort_Schedule','value',BlankSchedule);
        SetParam(me,'ToneSource_Schedule','value',BlankSchedule);
        SetParam(me,'Tone_Schedule','value',BlankSchedule,'user',0);
        %         SetParam(me,'Tn1_Right_Freq','value',6);
        %         SetParam(me,'Tn1_Left_Freq','value',2);
        %         SetParam(me,'Tn2_Right_Freq','value',6);
        %         SetParam(me,'Tn2_Left_Freq','value',2);
        SetParam(me,'DirectDeliver_Schedule','value',BlankSchedule);
        eval([me '(''task'')']);
        
        plot_schedule;   
        rpbox('InitRPStereoSound');
        rpbox('send_matrix', [0 0 0 0 0 0 0 180 0 0]);
        rpbox('send_matrix',state_transition_matrix(NextParam));
        beep=CurrentTones;
        rpbox('LoadRPStereoSound',beep);
        Message('control','');
        
    case {'directdeliver1','directdeliver2'}
        if strcmp(get(gcbo,'tag'),'directdeliver1')
            SetParam(me,'DirectDeliver1','user',GetParam(me,'DirectDeliver1'));
        elseif strcmp(get(gcbo,'tag'),'directdeliver2')
            SetParam(me,'DirectDeliver2','user',GetParam(me,'DirectDeliver2'));
        end
        eval([me '(''task'')']);
        
        
        
    case {'task','changeschedule'}
        change_schedule;
        check_tone1_src;
        check_tone2_src;
        update_new_schedule;
        if ~getparam('rpbox','run')
            rpbox('send_matrix',state_transition_matrix(NextParam));
            beep=CurrentTones;
            rpbox('LoadRPStereoSound',beep);
        end
        plot_schedule;
        
    case {'tone_start'}
        rpbox('send_matrix',state_transition_matrix(NextParam));
        plot_schedule;
        
    case {'waterport','cuesource'}
        if strcmp(get(gcbo,'tag'),'waterport')
            SetParam(me,'waterport','user',get(gcbo,'value'));
        elseif strcmp(get(gcbo,'tag'),'cuesource')
            SetParam(me,'CueSource','user',get(gcbo,'value'));
        end
        task_id=GetParam(me,'task');
        change_schedule;
        check_tone1_src;
        check_tone2_src;
        update_new_schedule;
        
        beep=CurrentTones;
        rpbox('LoadRPStereoSound',beep);
        rpbox('send_matrix',state_transition_matrix(NextParam));
        plot_schedule;
        
    case {'watervalvedur'}
        rpbox('send_matrix',state_transition_matrix(NextParam));
        
    case 'tone1_src'            %{'Left';'Right';'Both/same';'Both/indp'}
        check_tone1_src;
        beep=CurrentTones;
        rpbox('LoadRPStereoSound',beep);
        
    case 'tone2_src'            %{'Left';'Right';'Both/same';'Both/indp';'None'}
        check_tone2_src;
        update_new_schedule;
        beep=CurrentTones;
        rpbox('LoadRPStereoSound',beep);
        rpbox('send_matrix',state_transition_matrix(NextParam));
        plot_schedule;
        
    case {'tn1_right_ch','tn1_left_ch','tn2_right_ch','tn2_left_ch'}
        set(gcbo,'UserData',get(gcbo,'value'));
        if GetParam(me,'Tone1_src')==3 & ismember(get(gcbo,'tag'),['tn1_right_ch','tn1_left_ch'])
            SetParam(me,'Tn1_Right_Ch',GetParam(me,'Tn1_Left_Ch'));
        elseif GetParam(me,'Tone2_src')==3 & ismember(get(gcbo,'tag'),['tn2_right_ch','tn2_left_ch'])            
            SetParam(me,'Tn2_Right_Ch',GetParam(me,'Tn2_Left_Ch'));
        end
        beep=CurrentTones;
        rpbox('LoadRPStereoSound',beep);
        
    case 'setplotaxes_back2start'
        SetParam(me,'PlotAxes_Back',GetParam(me,'MaxTrial'));
        plot_schedule;
    case 'setplotaxes_back'
        SetParam(me,'PlotAxes_Back',GetParam(me,'PlotAxes_Back')+50);
        plot_schedule;
    case 'setplotaxes_default'
        SetParam(me,'PlotAxes_Back',0);
        SetParam(me,'PlotAxes_Forward',0);
        plot_schedule;
    case 'setplotaxes_forward'        
        SetParam(me,'PlotAxes_Forward',GetParam(me,'PlotAxes_Forward')+50);
        plot_schedule;
    case 'setplotaxes_forward2end'        
        SetParam(me,'PlotAxes_Forward',GetParam(me,'MaxTrial'));
        plot_schedule;
        
    case 'update'
        update_event;
    case 'state35'
        update_event;
        CountedTrial = GetParam(me,'CountedTrial')+1;
        New_Events      =GetParam(me,'Trial_Events','value');
        Trial_Events    =GetParam(me,'Trial_Events','trial');
        SetParam(me,'Trial_Events','trial',[Trial_Events {New_Events} ]);
        SetParam(me,'Trial_Events','value',[]);
        
        task_id=GetParam(me,'task');
        Result=GetParam(me,'Result');
        Stimulus_Schedule  =GetParam(me,'Stimulus_Schedule');
        WaterPort_Schedule =GetParam(me,'WaterPort_Schedule');
        ToneSource_Schedule=GetParam(me,'ToneSource_Schedule');
        Tone_Schedule=GetParam(me,'Tone_Schedule');
        NoGo_Schedule=GetParam(me,'NoGo_Schedule');        
        if (GetParam(me,'False_Correction') & mod(Result(CountedTrial),100)==2)|(GetParam(me,'Miss_Correction') & mod(Result(CountedTrial),100)==3)|...
                (GetParam(me,'Abort_Correction') & mod(Result(CountedTrial),100)==4)
            Delay_correction=ceil(rand*GetParam(me,'CorrectionTrial'));
            Stimulus_Schedule(CountedTrial+Delay_correction)=Stimulus_Schedule(CountedTrial);
            WaterPort_Schedule(CountedTrial+Delay_correction)=WaterPort_Schedule(CountedTrial);            
            ToneSource_Schedule(CountedTrial+Delay_correction)=ToneSource_Schedule(CountedTrial);            
            Tone_Schedule(CountedTrial+Delay_correction)=Tone_Schedule(CountedTrial);
            NoGo_Schedule(CountedTrial+Delay_correction)=NoGo_Schedule(CountedTrial);
            SetParam(me,'Stimulus_Schedule',Stimulus_Schedule);
            SetParam(me,'WaterPort_Schedule',WaterPort_Schedule);
            SetParam(me,'ToneSource_Schedule',ToneSource_Schedule);
            SetParam(me,'Tone_Schedule',Tone_Schedule);
            SetParam(me,'NoGo_Schedule',NoGo_Schedule);
        end
        
        if GetParam(me,'Script')==2
            if CountedTrial < 180  & task_id~=11
                SetParam(me,'Task',11);
            elseif CountedTrial>180 & CountedTrial<300  & task_id~=9
                SetParam(me,'Task',9);
            end
        elseif GetParam(me,'Script')==3
            if CountedTrial < 170  & task_id~=11
                SetParam(me,'Task',11);
            elseif CountedTrial>170 & CountedTrial<200  & task_id~=9
                SetParam(me,'Task',9);
            elseif CountedTrial>200 & CountedTrial<300  & task_id~=12
                SetParam(me,'Task',12);
            end
        elseif GetParam(me,'Script')==4
            if CountedTrial < 80  & task_id~=9
                SetParam(me,'Task',9);
            elseif CountedTrial>80 & CountedTrial<200  & task_id~=12
                SetParam(me,'Task',12);
            end
        end
        
        SetParam(me,'CountedTrial',CountedTrial);
        change_schedule;
        check_tone1_src;
        check_tone2_src;
        update_new_schedule;
        
        beep=CurrentTones;
        rpbox('LoadRPStereoSound',beep);
        plot_schedule;
        rpbox('send_matrix',state_transition_matrix(NextParam));
        
    case 'close'
        SetParam('rpbox','protocols',1);
    otherwise
        out=0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function out=NextParam
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
CountedTrial = GetParam(me,'CountedTrial')+1;
MaxTrial=GetParam(me,'MaxTrial');
DD1=GetParam(me,'DirectDeliver1');
DD2=GetParam(me,'DirectDeliver2');

dd=GetParam(me,'DirectDeliver_Schedule');
dd=dd(CountedTrial);

vpn=GetParam(me,'ValidPokeNum');
vpn=vpn(CountedTrial);

vpd=GetParam(me,'ValidPokeDur');
if vpd < 0.001 % vpd has to be larger than the sampling reate of RPDevice
    vpd=0.001;  % sec
end

rad=GetParam(me,'RewardAvailDur');
wpt=GetParam(me,'WaterPort_Schedule');
wpt=wpt(CountedTrial);   %1:Left, 2:Right, 3:Both, 4~6:None
wpt=wpt.*(wpt<4);

tns=GetParam(me,'Tone_Start');
tns=(tns<=CountedTrial);

dur=GetParam(me,'ToneDur','user')/1000; %convert to Seconds for state machine
dur=[dur 0 max(dur)];
td1=max(dur([GetParam(me,'tn1_Right_ch'),GetParam(me,'tn1_left_ch')]));
td2=max(dur([GetParam(me,'tn2_Right_ch'),GetParam(me,'tn2_left_ch')]));

tmo=GetParam(me,'TimeOut');

min_ipi=GetParam(me,'MinIPI','user');
min_ipi=min_ipi(GetParam(me,'MinIPI'));
max_ipi=GetParam(me,'MaxIPI','user');
max_ipi=max_ipi(GetParam(me,'MaxIPI'));

out=[dd,vpn,vpd,rad,wpt,tns,td1,td2,tmo,min_ipi,max_ipi];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function out=state_transition_matrix(varargin)
% varargin={dd,vpd,rad,wpt,tns,td1,td2,tmo,min_ipi,max_ipi}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
% the columns of the transition matrix represent inputs
% Cin,Cout,Lin,Lout,Rin, Rout, Times-up
% The rows are the states (from Staet 0 upto 32)
% The timer is in unit of seconds, # of columns >= # of states
% DIO output in "word" format, 1=DIO-0_ON, 8=DIO-3_ON (DIO-0~8) 
% AO output in "word" format, 1=AO-1_ON, 3=AO-1,2_ON,  (AO-1,2)
if nargin<2
    dd =varargin{1}(1);
    vpn=varargin{1}(2);
    vpd=varargin{1}(3);
    rad=varargin{1}(4);
    wpt=varargin{1}(5);
    tns=varargin{1}(6);
    td1=varargin{1}(7);
    td2=varargin{1}(8);
    tmo=varargin{1}(9);
    min_ipi=varargin{1}(10);
    max_ipi=varargin{1}(11);
elseif nargin>8
    dd =varargin{1};
    vpn=varargin{2};
    vpd=varargin{3};
    rad=varargin{4};
    wpt=varargin{5};
    tns=varargin{6};
    td1=varargin{7};    
    td2=varargin{8};
    tmo=varargin{9};
    min_ipi=varargin{10};
    max_ipi=varargin{11};    
else
    error('wrong input format ');
    return
end 
wvd=GetParam(me,'WaterValveDur');
iti=GetParam(me,'ITI');
if bitget(wpt,1)
    Lin=26;
    Lin2=29;    
else
    Lin=24;
    Lin2=32;    
end
if bitget(wpt,2)
    Rin=27;
    Rin2=30;
else
    Rin=25;
    Rin2=33;
end

if dd==1
    state_transition_matrix=[ ...
            %  Cin Cout Lin Lout Rin Rout TimeUp Timer DIO   AO  
        0    0   0    0   0    0    1     iti   0      0;  % State 0 "ITI-State"
        2    1   1    1   1    1    1     180   0      0;  % State 1 "Pre-State"
        2   28   2    2   2    2    3     vpd   0  1*tns;  % State 2 "Center Poke in"
        3    3  Lin   3  Rin   3    4     wvd  wpt 1*tns;  % State 3 "Valid Poke ==> Water!!! :)"
        2    4  Lin   4  Rin   4   34     rad   0      0;  % State 4 "End trial when the rat finds water within rad"
        zeros(19,10);
        24   24  24   24  24   24   34    .001   0      0;  % State 24 "False left Poke 1==> TimeOut "
        25   25  25   25  25   25   34    .001   0      0;  % State 25 "False right Poke 1==> TimeOut "
        26   26  26   26  26   26   35    .001   0      0;  % State 26 "Left Hit 1==> end trial"
        27   27  27   27  27   27   35    .001   0      0;  % State 27 "Right Hit 1==> end trial"
        28   28  28   28  28   28   34    .001   0      0;  % State 28 "Short Poke ==> Abort ==> TimeOut "
        29   29  29   29  29   29   35    .001   0      0;  % State 29 "Left Hit 2==> end trial"
        30   30  30   30  30   30   35    .001   0      0;  % State 30 "Right Hit 2==> end trial"
        31   31  31   31  31   31   34    .001   0      0;  % State 31 "IPI Poke ==> TimeOut "
        32   32  32   32  32   32   34    .001   0      0;  % State 32 "False left Poke 2==> TimeOut "
        33   33  33   33  33   33   34    .001   0      0;  % State 33 "False right Poke 2==> TimeOut "
        34   34  34   34  34   34    1     tmo   0      0;];% State 34 "TimeOut "
    
elseif dd==2
    state_transition_matrix=[ ...
            %  Cin Cout Lin  Lout Rin Rout TimeUp Timer DIO   AO  
        0    0   0     0    0    0    1     iti   0      0;  % State  0 "ITI-State"
        5    1   1     1    1    1    1     180   0      0;  % State  1 "Pre-State"
        zeros(3,10);
        5   28   5     5    5    5    6     vpd   0  1*tns;  % State  5 "Center Poke in"
        6    6  31    31   31   31    7 min_ipi   0  1*tns;  % State  6 "IPI"
        8    7  31    31   31   31    0 max_ipi   0      0;  % State  7 "2nd Pre-State"
        8   28   8     8    8    8    9     vpd   0  2*tns;  % State  8 "2nd Center Poke in"
        9    9  Lin2   9  Rin2   9   10     wvd  wpt 2*tns;  % State  9 "Valid Poke ==> Water!!! :)"
        10   10  Lin2  10  Rin2  10   34     rad   0      0;  % State 10 "End trial when the rat finds water within rad"
        zeros(13,10);
        24   24  24    24   24   24   34    .001   0      0;  % State 24 "False left Poke 1==> TimeOut "
        25   25  25    25   25   25   34    .001   0      0;  % State 25 "False right Poke 1==> TimeOut "
        26   26  26    26   26   26   35    .001   0      0;  % State 26 "Left Hit 1==> end trial"
        27   27  27    27   27   27   35    .001   0      0;  % State 27 "Right Hit 1==> end trial"
        28   28  28    28   28   28   34    .001   0      0;  % State 28 "Short Poke ==> Abort ==> TimeOut "
        29   29  29    29   29   29   35    .001   0      0;  % State 29 "Left Hit 2==> end trial"
        30   30  30    30   30   30   35    .001   0      0;  % State 30 "Right Hit 2==> end trial"
        31   31  31    31   31   31   34    .001   0      0;  % State 31 "IPI Poke ==> TimeOut "
        32   32  32    32   32   32   34    .001   0      0;  % State 32 "False left Poke 2==> TimeOut "
        33   33  33    33   33   33   34    .001   0      0;  % State 33 "False right Poke 2==> TimeOut "
        34   34  34    34   34   34    1     tmo   0      0;];% State 34 "TimeOut "
    
elseif vpn==1
    ltd=(td1-vpd);  %leftover tone duration
    ltd=ltd*(ltd>0);
    if ltd < 0.001 % ltd has to be larger than the sampling reate of RPDevice
        ltd=0.001;  % sec
    end
    
    state_transition_matrix=[ ...
     %  Cin Cout Lin   Lout Rin   Rout TimeUp        Timer DIO  AO  
         0   0   0      0   0      0    1           iti   0      0;  % State  0 "ITI-State"
        11   1   1      1   1      1    1           180   0      0;  % State  1 "Pre-State"
        zeros(9,10);
        11   0   11    11   11    11   12          .001   0      0;  % State 11 "Center Poke in, delay before tone on"
        12  28   12    12   12    12   13+(ltd==0)  vpd   0    tns;  % State 12 "Tone On"
        13  14  Lin    13  Rin    13   14           ltd   0    tns;  % State 13 "pre- Center Poke out"
        14  14  Lin    14  Rin    14   34           rad   0      0;  % State 14 "Reward Avaiable Dur ==>Miss if no response"
        zeros(9,10);
        24   24   24    24   24    24   34          .001   0      0;  % State 24 "False left Poke 1==> TimeOut "
        25   25   25    25   25    25   34          .001   0      0;  % State 25 "False right Poke 1==> TimeOut "
        26   26   26    26   26    26   35           wvd   1      0;  % State 26 "Left Hit 1==> end trial"
        27   27   27    27   27    27   35           wvd   2      0;  % State 27 "Right Hit 1==> end trial"
        28   28   28    28   28    28   34          .001   0      0;  % State 28 "Short Poke ==> Abort ==> TimeOut "
        29   29   29    29   29    29   35           wvd   1      0;  % State 29 "Left Hit 2==> end trial"
        30   30   30    30   30    30   35           wvd   2      0;  % State 30 "Right Hit 2==> end trial"
        31   31   31    31   31    31   34          .001   0      0;  % State 31 "IPI Poke ==> TimeOut "
        32   32   32    32   32    32   34          .001   0      0;  % State 32 "False left Poke 2==> TimeOut "
        33   33   33    33   33    33   34          .001   0      0;  % State 33 "False right Poke 2==> TimeOut "
        34   34   34    34   34    34   35           tmo   0      0;];% State 34 "TimeOut "
    
elseif vpn==2
    ltd1=(td1-vpd);  %leftover tone duration
    ltd1=ltd1*(ltd1>0);
    if ltd1 < 0.001 % ltd has to be larger than the sampling reate of RPDevice
        ltd1=0.001;  % sec
    end
    ltd2=(td2-vpd);  %leftover tone duration
    ltd2=ltd2*(ltd2>0);
    if ltd2 < 0.001 % ltd has to be larger than the sampling reate of RPDevice
        ltd2=0.001;  % sec
    end
    
    if wpt==0
        NoGo=23;
        iti=0.001;
        mis=15;
    else
        NoGo=23;
        mis=34;
    end
    
    state_transition_matrix=[ ...
     %  Cin Cout Lin   Lout Rin   Rout TimeUp         Timer DIO   AO  
         0    0   0      0   0      0    1            iti   0      0;  % State  0 "ITI-State"
        11    1   1      1   1      1    1            180   0      0;  % State  1 "Pre-State"
        zeros(9,10);
        11    0   11    11   11    11   16           .001   0      0;  % State 11 "Center Poke in, delay before tone on"
        zeros(3,10);
        15   15   15    15   15    15   35           .001   0      0;  % State 15 "NoGo" Trial correctly No-Go
        16   28   16    16   16    16   17+(ltd1==0)  vpd   0  1*tns;  % State 16 "Tone On"
        17   18   31    31   31    31   18            ltd1  0  1*tns;  % State 17 "pre- Center Poke out"
        18   18   31    31   31    31   19    min_ipi-ltd1  0      0;  % State 18 "IPI"
        20   19   31    31   31    31    0 max_ipi-min_ipi  0      0;  % State 19 "2nd Pre-State"
        20   19   20    20   20    20   21           .001   0      0;  % State 20 "Center Poke in, delay before tone on"
        21   28   21    21   21    21   22+(ltd2==0)  vpd   0  2*tns;  % State 21 "Tone On"
        22   23  Lin2   22  Rin2   22   23           ltd2   0  2*tns;  % State 22 "pre- Center Poke out"
       NoGo  23  Lin2   23  Rin2   23  mis            rad   0      0;  % State 23 "Reward Avaiable Dur ==>Miss if no response"
        24   24   24    24   24    24   34           .001   0      0;  % State 24 "False left Poke 1==> TimeOut "
        25   25   25    25   25    25   34           .001   0      0;  % State 25 "False right Poke 1==> TimeOut "
        26   26   26    26   26    26   35            wvd   1      0;  % State 26 "Left Hit 1==> end trial"
        27   27   27    27   27    27   35            wvd   2      0;  % State 27 "Right Hit 1==> end trial"
        28   28   28    28   28    28   34           .001   0      0;  % State 28 "Short Poke ==> Abort ==> TimeOut "
        29   29   29    29   29    29   35            wvd   1      0;  % State 29 "Left Hit 2==> end trial"
        30   30   30    30   30    30   35            wvd   2      0;  % State 30 "Right Hit 2==> end trial"
        31   31   31    31   31    31   34           .001   0      0;  % State 31 "IPI Poke ==> TimeOut "
        32   32   32    32   32    32   34           .001   0      0;  % State 32 "False left Poke 2==> TimeOut "
        33   33   33    33   33    33   34           .001   0      0;  % State 33 "False right Poke 2==> TimeOut "
        34   34   34    34   34    34   35            tmo   0      0;];% State 34 "TimeOut "
    
end
out=state_transition_matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_schedule
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global exper

CountedTrial = GetParam(me,'CountedTrial')+1;

fig = findobj('tag',me);
figure(fig);
a = findobj(fig,'tag','plot_schedule');
if ~isempty(a)
    axes(a);
    set(a,'pos',[0.05 0.86 0.6 0.13]);
else
    a = axes('tag','plot_schedule','pos',[0.05 0.86 0.6 0.13]);
end
cla;
os = GetParam(me,'tone_start');
ValidPokeNum=GetParam(me,'ValidPokeNum');
Result=GetParam(me,'Result');
Stimulus_Schedule  =GetParam(me,'Stimulus_Schedule');
WaterPort_Schedule =GetParam(me,'WaterPort_Schedule');
WaterPort_Schedule_left=WaterPort_Schedule*NaN;
WaterPort_Schedule_right=WaterPort_Schedule_left;
if max(WaterPort_Schedule)>3
    EmptyWaterPort_Schedule=WaterPort_Schedule.*(WaterPort_Schedule>3);
    EmptyWaterPort_Schedule=mod(EmptyWaterPort_Schedule,3);
    WaterPort_Schedule=WaterPort_Schedule.*(WaterPort_Schedule<=3);
    EmptyWaterPort_Schedule_left=WaterPort_Schedule_left;
    EmptyWaterPort_Schedule_right=WaterPort_Schedule_left;
    EmptyWaterPort_Schedule_left(find(bitget(EmptyWaterPort_Schedule,1)))=2;
    EmptyWaterPort_Schedule_right(find(bitget(EmptyWaterPort_Schedule,2)))=1;
end
WaterPort_Schedule_left(find(bitget(WaterPort_Schedule,1)))=2;
WaterPort_Schedule_right(find(bitget(WaterPort_Schedule,2)))=1;
ToneSource_Schedule=GetParam(me,'ToneSource_Schedule');
ToneSource_Schedule_left =ToneSource_Schedule*NaN;
ToneSource_Schedule_right=ToneSource_Schedule_left;
ToneSource_Schedule_left(find(bitget(ToneSource_Schedule,1)))=2;
ToneSource_Schedule_right(find(bitget(ToneSource_Schedule,2)))=1;

MaxTrial=GetParam(me,'MaxTrial');
eff_CountedTrial=min(CountedTrial,MaxTrial);
ax_range=max(CountedTrial,MaxTrial);
plot(ValidPokeNum,'.'); hold on
plot(CountedTrial,ValidPokeNum(eff_CountedTrial),'or');
ax = axis;
plot([os os],[0,3],':k');
ax(1) = 1; ax(2) =ax_range;
PlotAxes_Back   =GetParam(me,'PlotAxes_Back');
PlotAxes_Forward=GetParam(me,'PlotAxes_Forward');
axis([min(max(ceil((CountedTrial-91-PlotAxes_Back)/50)*50,0),max((MaxTrial-100-PlotAxes_Back),0)) ...
        min(max(ceil((CountedTrial+9+PlotAxes_Forward)/50)*50,100),MaxTrial) 0.5 2.5]);

%     xlabel('CountedTrial');
ylabel('Valid Poke #');
set(a,'tag','plot_schedule','Ytick',[1 2]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
b = findobj(fig,'tag','plot_ToneSource_Schedule');
if ~isempty(b)
    axes(b);
    set(b,'pos',[0.05 0.67 0.6 0.15]);
else
    b = axes('tag','plot_ToneSource_Schedule','pos',[0.05 0.67 0.6 0.15]);
end
cla;
plot([CountedTrial:MaxTrial],ToneSource_Schedule_left(CountedTrial:MaxTrial),'c.'); hold on
plot([CountedTrial:MaxTrial],ToneSource_Schedule_right(CountedTrial:MaxTrial),'c.');    

dd1 = GetParam(me,'DirectDeliver1');
dd2 = GetParam(me,'DirectDeliver2');
if dd2
    plot(1:dd1,ToneSource_Schedule_left(1:dd1),'.g');
    plot(1:dd1,ToneSource_Schedule_right(1:dd1),'.g');    
    plot(dd1+1:dd1+dd2,ToneSource_Schedule_left(dd1+1:dd1+dd2),'.c');
    plot(dd1+1:dd1+dd2,ToneSource_Schedule_right(dd1+1:dd1+dd2),'.c');    
else
    plot(1:dd1,ToneSource_Schedule_left(1:dd1),'.c');
    plot(1:dd1,ToneSource_Schedule_right(1:dd1),'.c');    
end

Hit=find(mod(Result,100)==1);
if Hit
    plot(Hit,ToneSource_Schedule_left(Hit),'b.');
    plot(Hit,ToneSource_Schedule_right(Hit),'b.');    
end
false=find(mod(Result,100)==2);
if false
    plot(false,ToneSource_Schedule_left(false),'r.');
    plot(false,ToneSource_Schedule_right(false),'r.');    
end
miss=find(mod(Result,100)==3);
if miss
    plot(miss,ToneSource_Schedule_left(miss),'bo');
    plot(miss,ToneSource_Schedule_right(miss),'bo');
end
abort=find(mod(Result,100)==4);
if abort
    plot(abort,ToneSource_Schedule_left(abort),'g.');
    plot(abort,ToneSource_Schedule_right(abort),'g.');
end
plot(CountedTrial,ToneSource_Schedule_left(eff_CountedTrial),'or'); 
plot(CountedTrial,ToneSource_Schedule_right(eff_CountedTrial),'or'); 

ax = axis;
plot([os os],[0,3],':k');
ax(1) = 1; ax(2) = ax_range;
PlotAxes_Back   =GetParam(me,'PlotAxes_Back');
PlotAxes_Forward=GetParam(me,'PlotAxes_Forward');
axis([min(max(ceil((CountedTrial-91-PlotAxes_Back)/50)*50,0),max((MaxTrial-100-PlotAxes_Back),0)) ...
        min(max(ceil((CountedTrial+9+PlotAxes_Forward)/50)*50,100),MaxTrial) 0.5 2.5]);

set(gca,'yTick',[1 2]);
set(gca,'yTicklabel',[]);
ylabel(['Tone Source' sprintf('\n') 'Right<-->Left']);
set(b,'tag','plot_ToneSource_Schedule','Ytick',[1 2],'XTickLabel',[]);
%%%%%%%%%%%%%%%%%%%%%%%%
c = findobj(fig,'tag','plot_WaterPort_Schedule');
if ~isempty(c)
    axes(c);
    set(c,'pos',[0.05 0.45 0.6 0.17]);
else
    c = axes('tag','plot_WaterPort_Schedule','pos',[0.05 0.45 0.6 0.17]);
end
cla;
plot([CountedTrial:MaxTrial],WaterPort_Schedule_left(CountedTrial:MaxTrial),'c.'); hold on
plot([CountedTrial:MaxTrial],WaterPort_Schedule_right(CountedTrial:MaxTrial),'c.');
plot(CountedTrial,WaterPort_Schedule_left(eff_CountedTrial),'or'); 
plot(CountedTrial,WaterPort_Schedule_right(eff_CountedTrial),'or'); 

if exist('EmptyWaterPort_Schedule')
    plot([CountedTrial:MaxTrial],EmptyWaterPort_Schedule_left(CountedTrial:MaxTrial),'m.');
    plot([CountedTrial:MaxTrial],EmptyWaterPort_Schedule_right(CountedTrial:MaxTrial),'m.');
    plot(CountedTrial,EmptyWaterPort_Schedule_left(eff_CountedTrial),'or'); 
    plot(CountedTrial,EmptyWaterPort_Schedule_right(eff_CountedTrial),'or'); 
end 
dd1 = GetParam(me,'DirectDeliver1');
dd2 = GetParam(me,'DirectDeliver2');
if dd2
    plot(1:dd1,WaterPort_Schedule_left(1:dd1),'.g');
    plot(1:dd1,WaterPort_Schedule_right(1:dd1),'.g');
    plot(dd1+1:dd1+dd2,WaterPort_Schedule_left(dd1+1:dd1+dd2),'.c');
    plot(dd1+1:dd1+dd2,WaterPort_Schedule_right(dd1+1:dd1+dd2),'.c');
else
    plot(1:dd1,WaterPort_Schedule_left(1:dd1),'.c');
    plot(1:dd1,WaterPort_Schedule_right(1:dd1),'.c');
end

if Hit
    plot(Hit,WaterPort_Schedule_left(Hit),'b.');
    plot(Hit,WaterPort_Schedule_right(Hit),'b.');
    if exist('EmptyWaterPort_Schedule')
        plot(Hit,EmptyWaterPort_Schedule_left(Hit),'k.');
        plot(Hit,EmptyWaterPort_Schedule_right(Hit),'k.');
    end 
end
if false
    plot(false,WaterPort_Schedule_left(false),'r.');
    plot(false,WaterPort_Schedule_right(false),'r.');    
    if exist('EmptyWaterPort_Schedule')
        plot(false,EmptyWaterPort_Schedule_left(false),'m.');
        plot(false,EmptyWaterPort_Schedule_right(false),'m.');
    end 
end
if miss
    plot(miss,WaterPort_Schedule_left(miss),'bo');
    plot(miss,WaterPort_Schedule_right(miss),'bo');
    if exist('EmptyWaterPort_Schedule')
        plot(miss,EmptyWaterPort_Schedule_left(miss),'k.');
        plot(miss,EmptyWaterPort_Schedule_right(miss),'k.');
    end 
end
if abort
    plot(abort,WaterPort_Schedule_left(abort),'g.');
    plot(abort,WaterPort_Schedule_right(abort),'g.');
    if exist('EmptyWaterPort_Schedule')
        plot(abort,EmptyWaterPort_Schedule_left(abort),'g.');
        plot(abort,EmptyWaterPort_Schedule_right(abort),'g.');
    end 
end

ax = axis;
plot([os os],[0,3],':k');
ax(1) = 1; ax(2) = ax_range;
PlotAxes_Back   =GetParam(me,'PlotAxes_Back');
PlotAxes_Forward=GetParam(me,'PlotAxes_Forward');
axis([min(max(ceil((CountedTrial-91-PlotAxes_Back)/50)*50,0),max((MaxTrial-100-PlotAxes_Back),0)) ...
        min(max(ceil((CountedTrial+9+PlotAxes_Forward)/50)*50,100),MaxTrial) 0 3]);
set(gca,'yTick',[1 2]);
set(gca,'yTicklabel',[]);
xlabel('CountedTrial');
ylabel(['WaterPort' sprintf('\n') 'Right<== ==>Left']);
set(c,'tag','plot_WaterPort_Schedule');
%%%%%%%%%%%%%%%%% plot performance %%%%%%%%%%%%%%%%
h = findobj(fig,'tag','plot_performance');
if ~isempty(h)
    axes(h);
    set(h,'pos',[0.71 0.73 0.27 0.25]);
else
    h = axes('tag','plot_performance','pos',[0.71 0.73 0.27 0.25]);
end

unique_stimulus=unique(Stimulus_Schedule(find(Stimulus_Schedule>100)));
if CountedTrial
    Performance=zeros(size(unique_stimulus));
    Valid_Performance=Performance;
    Miss_Performance=Performance;
    False_Performance=Performance;
    Abort_Performance=Performance;
    n_Hit=Performance;
    n_Fls=Performance;
    n_Mis=Performance;
    n_Abt=Performance;
    n_trial=Performance
    for i=1:length(unique_stimulus)
        trial_idx=find(Stimulus_Schedule(1:CountedTrial-1)==unique_stimulus(i));
        n_trial(i)=length(trial_idx);
        n_Hit(i)=size(find(mod(Result(trial_idx),100)==1),2);
        n_Fls(i)=size(find(mod(Result(trial_idx),100)==2),2);
        n_Mis(i)=size(find(mod(Result(trial_idx),100)==3),2);        
        n_Abt(i)=size(find(mod(Result(trial_idx),100)==4),2);
        Performance(i)=n_Hit(i)/n_trial(i);
        Valid_Performance(i)=n_Hit(i)/ (n_trial(i)-n_Abt(i));
        False_Performance(i)=n_Fls(i)/ n_trial(i);
        Miss_Performance(i)=n_Mis(i)/ n_trial(i);
        Abort_Performance(i)=n_Abt(i)/ n_trial(i);
    end
    x=1:length(unique_stimulus);
    plot(x,Performance,'b*',x,Valid_Performance,'c-',x,Miss_Performance,'bo',x,Abort_Performance,'g.',x,False_Performance,'r.');
end

axis([0.45 length(unique_stimulus)+.5 0 1]);
set(h,'XTick',[1:1:length(unique_stimulus)],'XTickLabel',unique_stimulus);
xlabel([ sprintf('%5.2g',Valid_Performance)  sprintf('\n') 'Tone / Odro Ch.']);
ylabel(['Perfrm. Fraction correct']);
set(h,'tag','plot_performance');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function change_schedule
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global exper
task_id=GetParam(me,'task');
task_id_change=(task_id~=GetParam(me,'task','user'));
SetParam(me,'task','user',task_id);
CountedTrial = GetParam(me,'CountedTrial')+1;
MaxTrial = GetParam(me,'MaxTrial');
DD1=GetParam(me,'DirectDeliver1');
DD2=GetParam(me,'DirectDeliver2');
Stimulus_Schedule  =GetParam(me,'Stimulus_Schedule');
WaterPort_Schedule =GetParam(me,'WaterPort_Schedule');
ToneSource_Schedule=GetParam(me,'ToneSource_Schedule');
Tone_Schedule=GetParam(me,'Tone_Schedule');
NoGo_Schedule=GetParam(me,'NoGo_Schedule');
running=getparam('rpbox','run');

SetParam(me,'Tone1_Src','enable_distractor',0,'use_schedule',0);            % Default is no distractor from the silent channel, do not use tone source schedule
SetParam(me,'Tone2_Src','enable_distractor',0,'use_schedule',0,'NoGo',0);   % Default do not use NoGo_Schedule to silent the target sample at 2nd tone
switch task_id   % 1:'custom setting',2:'Left',3:'Right',4:'10L-10R',5:'Random'
    case 1          % 'custom setting'
        SetParam(me,'waterport',GetParam(me,'waterport','user'));
        SetParam(me,'CueSource',GetParam(me,'CueSource','user'));
        SetParamUI(me,'WaterPort','enable','on');
        SetParamUI(me,'CueSource','enable','on');
        WaterPort=GetParam(me,'WaterPort');
        WaterPort_Schedule(CountedTrial:MaxTrial)  = WaterPort;
        Stimulus_Schedule(CountedTrial:MaxTrial)  = WaterPort+task_id*100;
    case {2,4}      % 'Tn1 Loc: Left','Tn2 Loc: Left'
        SetParam(me,'WaterPort',1);         %left
        SetParamUI(me,'WaterPort','enable','inactive');
        SetParam(me,'CueSource',task_id/2);     %location cue from 1st tone
        SetParamUI(me,'CueSource','enable','inactive');
        WaterPort_Schedule(CountedTrial:MaxTrial)  = 1;
        Stimulus_Schedule(CountedTrial:MaxTrial)  = 1+task_id*100;
    case {3,5}      % 'Tn1 Loc: Right','Tn2 Loc: Right'
        SetParam(me,'WaterPort',2);         %right
        SetParamUI(me,'WaterPort','enable','inactive');
        SetParam(me,'CueSource',(task_id-1)/2);     %location cue from 1st tone
        SetParamUI(me,'CueSource','enable','inactive');
        WaterPort_Schedule(CountedTrial:MaxTrial)  = 2;
        Stimulus_Schedule(CountedTrial:MaxTrial)  = 2+task_id*100;
    case {6,8}      % 'Both Loc: 10L-10R','Tn1 Loc: 10L-10R'
        if task_id==6
            SetParam(me,'CueSource',3);     %location cue from BOTH tone
        elseif task_id==8
            SetParam(me,'CueSource',1);     %location cue from 1st tone
        end
        SetParamUI(me,'CueSource','enable','off');
        SetParamUI(me,'WaterPort','enable','inactive');
        WaterPort_Schedule(CountedTrial:MaxTrial)  = ceil(mod((((CountedTrial:MaxTrial)-.5)./10),2));
        Stimulus_Schedule(CountedTrial:MaxTrial)  = WaterPort_Schedule(CountedTrial:MaxTrial)+task_id*100;
        if ismember(get(gcbo,'tag'),{'task','reset'})
            v1=0;   v2=0;
            while v1*v2==0
                [s1 v1]=listdlg('PromptString','Select Tone 1 Left Chanel:','InitialValue',2,'SelectionMode','single','ListSize',[160 160],'ListString',getparam(me,'Tn1_Left_ch','list'));
                [s2 v2]=listdlg('PromptString','Select Tone 1 Right Channel:','InitialValue',2,'SelectionMode','single','ListSize',[160 160],'ListString',getparam(me,'Tn1_Right_ch','list'));                
            end
            SetParamUI(me,'Tn1_Left_ch','UserData',s1);
            SetParamUI(me,'Tn1_Right_ch','UserData',s2);
        end
        SetParam(me,'WaterPort',WaterPort_Schedule(CountedTrial));
    case 7          % 'Both Loc: Random'
        SetParam(me,'CueSource',3);     %location cue from BOTH tone
        SetParam(me,'Tone1_Src','enable_distractor',1);     % enable distractor from the silent channel
        SetParam(me,'Tone2_Src','enable_distractor',1);     % enable distractor from the silent channel
        SetParamUI(me,'WaterPort','enable','off');
        SetParamUI(me,'CueSource','enable','off');
        if ismember(get(gcbo,'tag'),{'task','reset'})
            WaterPort_Schedule(CountedTrial:MaxTrial)  = ceil(rand(1,(MaxTrial-CountedTrial+1))*2);
            Stimulus_Schedule(CountedTrial:MaxTrial)  = WaterPort_Schedule(CountedTrial:MaxTrial)+task_id*100;
            ToneSelectFig=figure('windowstyle','modal','position',[200 200 600 100],'name','Select Tone Settings:','resize','off','numbertitle','off','menubar','none');
            tsfig=ToneSelectFig;
            tL   = uicontrol('parent',tsfig,'string','Left','style','text','horiz','center','position',[40 60 60 20]);
            tR   = uicontrol('parent',tsfig,'string','Right','style','text','horiz','center','position',[40 40 60 20]);
            t1c  = uicontrol('parent',tsfig,'string','Tone 1 Cue','style','text','horiz','center','position',[100 80 120 20]);
            ht1cL= uicontrol('style','popupmenu','background',[1 1 1],'string',getparam(me,'Tn1_Left_ch' ,'list'),'position',[100 60 120 20],'value',GetParamUI(me,'Tn1_Left_Ch', 'UserData'),'callback',['SetParamUI(''' me ''',''Tn1_Left_Ch'',''UserData'',get(gcbo,''value''));']);
            ht1cR= uicontrol('style','popupmenu','background',[1 1 1],'string',getparam(me,'Tn1_Right_ch','list'),'position',[100 40 120 20],'value',GetParamUI(me,'Tn1_Right_Ch','UserData'),'callback',['SetParamUI(''' me ''',''Tn1_Right_Ch'',''UserData'',get(gcbo,''value''));']);
            t1d  = uicontrol('parent',tsfig,'string','Tone 1 distractor','style','text','horiz','center','position',[220 80 120 20]);
            ht1dL= uicontrol('style','popupmenu','background',[1 1 1],'string',getparam(me,'Tn1_Left_ch' ,'list'),'position',[220 60 120 20],'value',GetParam(me,'Tn1_Left_Ch','distractor'),'callback',['SetParam(''' me ''',''Tn1_Left_Ch'',''distractor'',get(gcbo,''value''));']);
            ht1dR= uicontrol('style','popupmenu','background',[1 1 1],'string',getparam(me,'Tn1_Right_ch','list'),'position',[220 40 120 20],'value',GetParam(me,'Tn1_Right_Ch','distractor'),'callback',['SetParam(''' me ''',''Tn1_Right_Ch'',''distractor'',get(gcbo,''value''));']);
            t2c  = uicontrol('parent',tsfig,'string','Tone 2 Cue','style','text','horiz','center','position',[360 80 120 20]);
            ht2cL= uicontrol('style','popupmenu','background',[1 1 1],'string',getparam(me,'Tn2_Left_ch' ,'list'),'position',[360 60 120 20],'value',GetParamUI(me,'Tn2_Left_Ch','UserData'),'callback',['SetParamUI(''' me ''',''Tn2_Left_Ch'',''UserData'',get(gcbo,''value''));']);
            ht2cR= uicontrol('style','popupmenu','background',[1 1 1],'string',getparam(me,'Tn2_Right_ch','list'),'position',[360 40 120 20],'value',GetParamUI(me,'Tn2_Right_Ch','UserData'),'callback',['SetParamUI(''' me ''',''Tn2_Right_Ch'',''UserData'',get(gcbo,''value''));']);
            t2d  = uicontrol('parent',tsfig,'string','Tone 2 distractor','style','text','horiz','center','position',[480 80 120 20]);
            ht2dL= uicontrol('style','popupmenu','background',[1 1 1],'string',getparam(me,'Tn2_Left_ch' ,'list'),'position',[480 60 120 20],'value',GetParam(me,'Tn2_Left_Ch','distractor'),'callback',['SetParam(''' me ''',''Tn2_Left_Ch'',''distractor'',get(gcbo,''value''));']);
            ht2dR= uicontrol('style','popupmenu','background',[1 1 1],'string',getparam(me,'Tn2_Right_ch','list'),'position',[480 40 120 20],'value',GetParam(me,'Tn2_Right_Ch','distractor'),'callback',['SetParam(''' me ''',''Tn2_Right_Ch'',''distractor'',get(gcbo,''value''));']);
            finish_btn = uicontrol('style','pushbutton','string','Finish','position',[480 10 120 20],'callback',['delete(' num2str(tsfig) ')']);
            try
                set(ToneSelectFig, 'visible','on');
                uiwait(ToneSelectFig);
            catch
                if ishandle(ToneSelectFig)
                    delete(ToneSelectFig)
                end
            end
        elseif  ismember(get(gcbo,'tag'),{'changeschedule'})
            WaterPort_Schedule(CountedTrial:MaxTrial)  = ceil(rand(1,(MaxTrial-CountedTrial+1))*2);
            Stimulus_Schedule(CountedTrial:MaxTrial)  = WaterPort_Schedule(CountedTrial:MaxTrial)+task_id*100;
        elseif  task_id_change
            WaterPort_Schedule(CountedTrial:MaxTrial)  = ceil(rand(1,(MaxTrial-CountedTrial+1))*2);
            Stimulus_Schedule(CountedTrial:MaxTrial)  = WaterPort_Schedule(CountedTrial:MaxTrial)+task_id*100;
        end
        SetParam(me,'WaterPort',WaterPort_Schedule(CountedTrial));
        
    case 9          % 'Tn1 Loc: Random'
        SetParam(me,'CueSource',1);     %location cue from 1st tone
        SetParam(me,'Tone1_Src','enable_distractor',1);     % enable distractor from the silent channel
        SetParamUI(me,'WaterPort','enable','off');
        SetParamUI(me,'CueSource','enable','off');
        if ismember(get(gcbo,'tag'),{'task','reset'})
            WaterPort_Schedule((CountedTrial+running):MaxTrial)  = ceil(rand(1,MaxTrial-CountedTrial-running+1)*2);
            Stimulus_Schedule((CountedTrial+running):MaxTrial)  = WaterPort_Schedule((CountedTrial+running):MaxTrial)+task_id*100;
            ToneSelectFig=figure('windowstyle','modal','position',[200 200 400 100],'name','Select Tone Settings:','resize','off','numbertitle','off','menubar','none');
            tsfig=ToneSelectFig;
            tL   = uicontrol('parent',tsfig,'string','Left','style','text','horiz','center','position',[40 60 60 20]);
            tR   = uicontrol('parent',tsfig,'string','Right','style','text','horiz','center','position',[40 40 60 20]);
            t1c  = uicontrol('parent',tsfig,'string','Tone 1 Cue','style','text','horiz','center','position',[100 80 120 20]);
            ht1cL= uicontrol('style','popupmenu','background',[1 1 1],'string',getparam(me,'Tn1_Left_ch' ,'list'),'position',[100 60 120 20],'value',GetParamUI(me,'Tn1_Left_Ch', 'UserData'),'callback',['SetParamUI(''' me ''',''Tn1_Left_Ch'',''UserData'',get(gcbo,''value''));']);
            ht1cR= uicontrol('style','popupmenu','background',[1 1 1],'string',getparam(me,'Tn1_Right_ch','list'),'position',[100 40 120 20],'value',GetParamUI(me,'Tn1_Right_Ch','UserData'),'callback',['SetParamUI(''' me ''',''Tn1_Right_Ch'',''UserData'',get(gcbo,''value''));']);
            t1d  = uicontrol('parent',tsfig,'string','Tone 1 distractor','style','text','horiz','center','position',[220 80 120 20]);
            ht1dL= uicontrol('style','popupmenu','background',[1 1 1],'string',getparam(me,'Tn1_Left_ch' ,'list'),'position',[220 60 120 20],'value',GetParam(me,'Tn1_Left_Ch','distractor'),'callback',['SetParam(''' me ''',''Tn1_Left_Ch'',''distractor'',get(gcbo,''value''));']);
            ht1dR= uicontrol('style','popupmenu','background',[1 1 1],'string',getparam(me,'Tn1_Right_ch','list'),'position',[220 40 120 20],'value',GetParam(me,'Tn1_Right_Ch','distractor'),'callback',['SetParam(''' me ''',''Tn1_Right_Ch'',''distractor'',get(gcbo,''value''));']);
            finish_btn = uicontrol('style','pushbutton','string','Finish','position',[280 10 120 20],'callback',['delete(' num2str(tsfig) ')']);
            try
                set(ToneSelectFig, 'visible','on');
                uiwait(ToneSelectFig);
            catch
                if ishandle(ToneSelectFig)
                    delete(ToneSelectFig)
                end
            end
        elseif ismember(get(gcbo,'tag'),{'changeschedule'})
            WaterPort_Schedule((CountedTrial+running):MaxTrial)  = ceil(rand(1,MaxTrial-CountedTrial-running+1)*2);
            Stimulus_Schedule((CountedTrial+running):MaxTrial)  = WaterPort_Schedule((CountedTrial+running):MaxTrial)+task_id*100;
        elseif task_id_change
            WaterPort_Schedule((CountedTrial+running):MaxTrial)  = ceil(rand(1,MaxTrial-CountedTrial-running+1)*2);
            Stimulus_Schedule((CountedTrial+running):MaxTrial)  = WaterPort_Schedule((CountedTrial+running):MaxTrial)+task_id*100;
        end
        SetParam(me,'WaterPort',WaterPort_Schedule(CountedTrial));
        
    case {10,11}        %'Tn1Freq2AFC LBR','Tn1Freq2AFC LR'
        SetParam(me,'CueSource',4);     %location cue from Tone 1 frequency
        SetParam(me,'Tone1_Src','use_schedule',1)
        SetParamUI(me,'WaterPort','enable','off');
        SetParamUI(me,'CueSource','enable','off');
        if ismember(get(gcbo,'tag'),{'task','reset'})
            WaterPort_Schedule((CountedTrial+running):MaxTrial)  = ceil(rand(1,MaxTrial-CountedTrial-running+1)*2);
            if task_id==10
                ToneSource_Schedule((CountedTrial+running):MaxTrial)  = ceil(rand(1,MaxTrial-CountedTrial-running+1)*3);
                Stimulus_Schedule((CountedTrial+running):MaxTrial)  = ((WaterPort_Schedule((CountedTrial+running):MaxTrial)-1)*3 + ToneSource_Schedule((CountedTrial+running):MaxTrial))+task_id*100;
            elseif  task_id==11
                ToneSource_Schedule((CountedTrial+running):MaxTrial)  = ceil(rand(1,MaxTrial-CountedTrial-running+1)*2);
                Stimulus_Schedule((CountedTrial+running):MaxTrial)  = ((WaterPort_Schedule((CountedTrial+running):MaxTrial)-1)*2 + ToneSource_Schedule((CountedTrial+running):MaxTrial))+task_id*100;
            end
            ToneSelectFig=figure('windowstyle','modal','position',[200 500 240 100],'name','Select Tone Settings:','resize','off','numbertitle','off','menubar','none');
            tsfig=ToneSelectFig;
            tL   = uicontrol('parent',tsfig,'string','Left water port','style','text','horiz','center','position',[20 60 80 20]);
            tR   = uicontrol('parent',tsfig,'string','Right water port','style','text','horiz','center','position',[20 40 80 20]);
            t1f  = uicontrol('parent',tsfig,'string','Tone 1 Frequency','style','text','horiz','center','position',[100 80 120 20]);
            ht1fL= uicontrol('style','popupmenu','background',[1 1 1],'string',getparam(me,'Tn1_Left_ch' ,'list'),'position',[100 60 120 20],'value',GetParam(me,'Tn1_Left_Freq'),'callback',['SetParam(''' me ''',''Tn1_Left_Freq'',get(gcbo,''value''));']);
            ht1fR= uicontrol('style','popupmenu','background',[1 1 1],'string',getparam(me,'Tn1_Right_ch','list'),'position',[100 40 120 20],'value',GetParam(me,'Tn1_Right_Freq'),'callback',['SetParam(''' me ''',''Tn1_Right_Freq'',get(gcbo,''value''));']);
            finish_btn = uicontrol('style','pushbutton','string','Finish','position',[100 10 120 20],'callback',['delete(' num2str(tsfig) ')']);
            try
                set(ToneSelectFig, 'visible','on');
                uiwait(ToneSelectFig);
            catch
                if ishandle(ToneSelectFig)
                    delete(ToneSelectFig)
                end
            end
            Tone_Schedule(find(WaterPort_Schedule((CountedTrial+running):MaxTrial)==1)+(CountedTrial+running)-1)  = GetParam(me,'Tn1_Left_Freq');
            Tone_Schedule(find(WaterPort_Schedule((CountedTrial+running):MaxTrial)==2)+(CountedTrial+running)-1)  = GetParam(me,'Tn1_Right_Freq');
            SetParam(me,'Tone_Schedule',Tone_Schedule);
        elseif ismember(get(gcbo,'tag'),{'changeschedule'}) 
            WaterPort_Schedule((CountedTrial+running):MaxTrial)  = ceil(rand(1,MaxTrial-CountedTrial-running+1)*2);
            if task_id==10
                ToneSource_Schedule((CountedTrial+running):MaxTrial)  = ceil(rand(1,MaxTrial-CountedTrial-running+1)*3);
                Stimulus_Schedule((CountedTrial+running):MaxTrial)  = ((WaterPort_Schedule((CountedTrial+running):MaxTrial)-1)*3 + ToneSource_Schedule((CountedTrial+running):MaxTrial))+task_id*100;
            elseif  task_id==11
                ToneSource_Schedule((CountedTrial+running):MaxTrial)  = ceil(rand(1,MaxTrial-CountedTrial-running+1)*2);
                Stimulus_Schedule((CountedTrial+running):MaxTrial)  = ((WaterPort_Schedule((CountedTrial+running):MaxTrial)-1)*2 + ToneSource_Schedule((CountedTrial+running):MaxTrial))+task_id*100;
            end
            Tone_Schedule(find(WaterPort_Schedule((CountedTrial+running):MaxTrial)==1)+(CountedTrial+running)-1)  = GetParam(me,'Tn1_Left_Freq');
            Tone_Schedule(find(WaterPort_Schedule((CountedTrial+running):MaxTrial)==2)+(CountedTrial+running)-1)  = GetParam(me,'Tn1_Right_Freq');
            SetParam(me,'Tone_Schedule',Tone_Schedule);
        elseif task_id_change
%             running=0;            
            WaterPort_Schedule((CountedTrial+running):MaxTrial)  = ceil(rand(1,MaxTrial-CountedTrial-running+1)*2);
            if task_id==10
                ToneSource_Schedule((CountedTrial+running):MaxTrial)  = ceil(rand(1,MaxTrial-CountedTrial-running+1)*3);
                Stimulus_Schedule((CountedTrial+running):MaxTrial)  = ((WaterPort_Schedule((CountedTrial+running):MaxTrial)-1)*3 + ToneSource_Schedule((CountedTrial+running):MaxTrial))+task_id*100;
            elseif  task_id==11
                ToneSource_Schedule((CountedTrial+running):MaxTrial)  = ceil(rand(1,MaxTrial-CountedTrial-running+1)*2);
                Stimulus_Schedule((CountedTrial+running):MaxTrial)  = ((WaterPort_Schedule((CountedTrial+running):MaxTrial)-1)*2 + ToneSource_Schedule((CountedTrial+running):MaxTrial))+task_id*100;
            end
            Tone_Schedule(find(WaterPort_Schedule((CountedTrial+running):MaxTrial)==1)+(CountedTrial+running)-1)  = GetParam(me,'Tn1_Left_Freq');
            Tone_Schedule(find(WaterPort_Schedule((CountedTrial+running):MaxTrial)==2)+(CountedTrial+running)-1)  = GetParam(me,'Tn1_Right_Freq');
            SetParam(me,'Tone_Schedule',Tone_Schedule);
        end
        SetParam(me,'WaterPort',WaterPort_Schedule(CountedTrial));
    case 12             %'Tn1 Loc:2AFC'
        SetParam(me,'CueSource',1);     %location cue from 1st tone
        SetParam(me,'Tone1_Src','use_schedule',1);
        SetParamUI(me,'WaterPort','enable','off');
        SetParamUI(me,'CueSource','enable','off');
        if ismember(get(gcbo,'tag'),{'task','reset'})
            WaterPort_Schedule((CountedTrial+running):MaxTrial)  = ceil(rand(1,MaxTrial-CountedTrial-running+1)*2);
            ToneLoc2AFC_List = GetParam(me,'ToneLoc2AFC_List');
            Str=getparam(me,'Tn1_Left_ch' ,'list');
            ToneSelectFig=figure('windowstyle','modal','position',[200 500 340 300],'name','Select Tone Settings:','resize','off','numbertitle','off','menubar','none');
            tsfig=ToneSelectFig;
            tUn  = uicontrol('parent',tsfig,'string','Tone Unused','style','text','horiz','center','position',[20 260 80 20]);
            tUs  = uicontrol('parent',tsfig,'string','Tone Chosen','style','text','horiz','center','position',[210 260 80 20]);
            Un_list = find(~ismember(1:length(Str),ToneLoc2AFC_List))
            Un_Str= cell(size(Str));
            Un_Str(Un_list)=Str(Un_list);
            Us_list = find(ismember(1:length(Str),ToneLoc2AFC_List))
            Us_Str= cell(size(Str));
            Us_Str(Us_list)=Str(Us_list);
            lUn  = uicontrol('parent',tsfig,'string',Un_Str,'style','listbox','horiz','center','position',[10 40 130 220],'tag','lUn','UserData',Un_list);
            lUs  = uicontrol('parent',tsfig,'string',Us_Str,'style','listbox','horiz','center','position',[200 40 130 220],'tag','lUs','UserData',Us_list);
            hAdd = uicontrol('parent',tsfig,'string','Add >','style','pushbutton','horiz','center','position',[141 180 58 20],'callback',...
                ['lUs=findobj(''tag'',''lUs'');lUn=findobj(''tag'',''lUn'');Un=get(lUn,''value'');Us_list=sort([get(lUs,''UserData'') Un]);Un_list=get(lUn,''UserData'');Un_list=Un_list(find(Un_list~=Un));Str=getparam(''' me ''',''Tn1_Left_ch'' ,''list'');Us_Str=cell(size(Str));Un_Str=cell(size(Str));Us_Str(Us_list)=Str(Us_list);Un_Str(Un_list)=Str(Un_list);set(lUs,''UserData'',Us_list,''string'',Us_Str);set(lUn,''UserData'',Un_list,''string'',Un_Str);' ]);
            hRmv = uicontrol('parent',tsfig,'string','< Remove','style','pushbutton','horiz','center','position',[141 150 58 20],'callback',...
                ['lUs=findobj(''tag'',''lUs'');lUn=findobj(''tag'',''lUn'');Us=get(lUs,''value'');Un_list=sort([get(lUn,''UserData'') Us]);Us_list=get(lUs,''UserData'');Us_list=Us_list(find(Us_list~=Us));Str=getparam(''' me ''',''Tn1_Left_ch'' ,''list'');Us_Str=cell(size(Str));Un_Str=cell(size(Str));Us_Str(Us_list)=Str(Us_list);Un_Str(Un_list)=Str(Un_list);set(lUs,''UserData'',Us_list,''string'',Us_Str);set(lUn,''UserData'',Un_list,''string'',Un_Str);' ]);
            finish_btn = uicontrol('parent',tsfig,'string','Finish','style','pushbutton','horiz','center','position',[141 100 58 20],'callback',...
                ['Us_list=get(findobj(''tag'',''lUs''),''UserData'');SetParam(''' me ''',''ToneLoc2AFC_List'',Us_list);delete(' num2str(tsfig) ')' ]);
            try
                set(ToneSelectFig, 'visible','on');
                uiwait(ToneSelectFig);
            catch
                if ishandle(ToneSelectFig)
                    delete(ToneSelectFig)
                end
            end
            ToneLoc2AFC_List = GetParam(me,'ToneLoc2AFC_List');
            Tone_Schedule((CountedTrial+running):MaxTrial)  = ToneLoc2AFC_List(ceil(rand(1,MaxTrial-CountedTrial-running+1)*length(ToneLoc2AFC_List)));
            Stimulus_Schedule((CountedTrial+running):MaxTrial)  = Tone_Schedule((CountedTrial+running):MaxTrial)+task_id*100;
            SetParam(me,'Tone_Schedule',Tone_Schedule);
        elseif ismember(get(gcbo,'tag'),{'changeschedule'})
            WaterPort_Schedule((CountedTrial+running):MaxTrial)  = ceil(rand(1,MaxTrial-CountedTrial-running+1)*2);
            ToneLoc2AFC_List = GetParam(me,'ToneLoc2AFC_List');
            Tone_Schedule((CountedTrial+running):MaxTrial)  = ToneLoc2AFC_List(ceil(rand(1,MaxTrial-CountedTrial-running+1)*length(ToneLoc2AFC_List)));
            Stimulus_Schedule((CountedTrial+running):MaxTrial)  = Tone_Schedule((CountedTrial+running):MaxTrial)+task_id*100;
            SetParam(me,'Tone_Schedule',Tone_Schedule);
        elseif task_id_change
            WaterPort_Schedule((CountedTrial+running):MaxTrial)  = ceil(rand(1,MaxTrial-CountedTrial-running+1)*2);
            ToneLoc2AFC_List = GetParam(me,'ToneLoc2AFC_List');
            Tone_Schedule((CountedTrial+running):MaxTrial)  = ToneLoc2AFC_List(ceil(rand(1,MaxTrial-CountedTrial-running+1)*length(ToneLoc2AFC_List)));
            Stimulus_Schedule((CountedTrial+running):MaxTrial)  = Tone_Schedule((CountedTrial+running):MaxTrial)+task_id*100;
            SetParam(me,'Tone_Schedule',Tone_Schedule);
        end
        SetParam(me,'WaterPort',WaterPort_Schedule(CountedTrial));
        SetParam(me,'Tone_Schedule','user',Tone_Schedule(CountedTrial));
        
    case {13,14}                % 'DelayMatch Go/NoGo'
        SetParam(me,'CueSource',5);     %location cue from 2nd tone
        SetParam(me,'Tone1_Src','use_schedule',1,'value',2,'user',2); % first tone source: right
        SetParam(me,'Tone2_Src','use_schedule',1,'value',2,'user',2); % second tone source: right
        SetParamUI(me,'WaterPort','enable','off');
        SetParamUI(me,'CueSource','enable','off');
        DelayMatchSample_List=GetParam(me,'DelayMatchSample_List');
        NonSample_List=GetParam(me,'NonSample_List');
        if ismember(get(gcbo,'tag'),{'task','reset'})
            Str=getparam(me,'Tn1_Left_ch' ,'list');
            ToneSelectFig=figure('windowstyle','normal','position',[200 500 540 350],'name','Select Tone for Delay Match to Sample Go/NoGo Task:','resize','off','numbertitle','off','menubar','none');
            tsfig=ToneSelectFig;
            tTg  = uicontrol('parent',tsfig,'string','Target Tones Chosen','style','text','horiz','center','position',[10 310 120 20]);
            tUn  = uicontrol('parent',tsfig,'string','Tone Unused','style','text','horiz','center','position',[210 310 80 20]);
            tNs  = uicontrol('parent',tsfig,'string','Non-Targets Chosen','style','text','horiz','center','position',[395 310 120 20]);
%             Un_list = find(~ismember(1:length(Str),[DelayMatchSample_List NonSample_List]))
            Un_list = 1:length(Str)
%             Un_Str= cell(size(Str));
%             Un_Str(Un_list)=Str(Un_list);
            Un_Str=Str;
            Tg_list = find(ismember(1:length(Str),DelayMatchSample_List))
            Tg_Str= cell(size(Str));
            Tg_Str(Tg_list)=Str(Tg_list);
            Ns_list = NonSample_List;
            Ns_Str= cell(size(Str));
            Ns_Str(Ns_list)=Str(Ns_list);
            NoGo_Ratio=GetParam(me,'NoGo_Ratio');
            lTg  = uicontrol('parent',tsfig,'string',Tg_Str,'style','listbox','horiz','center','position',[10 40 130 270],'tag','lTg','UserData',Tg_list);
            lUn  = uicontrol('parent',tsfig,'string',Un_Str,'style','listbox','horiz','center','position',[200 40 130 270],'tag','lUn','UserData',Un_list);
            lNs  = uicontrol('parent',tsfig,'string',Ns_Str,'style','listbox','horiz','center','position',[390 40 130 270],'tag','lNs','UserData',Ns_list);
            hAddTg = uicontrol('parent',tsfig,'string','< Add','style','pushbutton','horiz','center','position',[141 180 58 20],'callback',...
                ['lTg=findobj(''tag'',''lTg'');lUn=findobj(''tag'',''lUn'');Un=get(lUn,''value'');Un_list=get(lUn,''UserData'');Tg_list=sort([get(lTg,''UserData'') Un]);Str=getparam(''' me ''',''Tn1_Left_ch'' ,''list'');Tg_Str=cell(size(Str));Un_Str=cell(size(Str));Tg_Str(Tg_list)=Str(Tg_list);Un_Str(Un_list)=Str(Un_list);set(lTg,''UserData'',Tg_list,''string'',Tg_Str);set(lUn,''UserData'',Un_list,''string'',Un_Str);' ]);
            hRmvTg = uicontrol('parent',tsfig,'string','Remove >','style','pushbutton','horiz','center','position',[141 150 58 20],'callback',...
                ['lTg=findobj(''tag'',''lTg'');lUn=findobj(''tag'',''lUn'');Tg=get(lTg,''value'');Tg_list=get(lTg,''UserData'');if length(Tg_list)>1;Tg_list=Tg_list(find(Tg_list~=Tg));Str=getparam(''' me ''',''Tn1_Left_ch'' ,''list'');Tg_Str=cell(size(Str));Un_Str=cell(size(Str));Tg_Str(Tg_list)=Str(Tg_list);Un_Str(Un_list)=Str(Un_list);set(lTg,''UserData'',Tg_list,''string'',Tg_Str);set(lUn,''UserData'',Un_list,''string'',Un_Str);end' ]);
            hAddNs = uicontrol('parent',tsfig,'string','Add >','style','pushbutton','horiz','center','position',[331 180 58 20],'callback',...
                ['lNs=findobj(''tag'',''lNs'');lUn=findobj(''tag'',''lUn'');Un=get(lUn,''value'');Tg_list=get(findobj(''tag'',''lTg''),''UserData'');if length(Tg_list)-ismember(Un,Tg_list);Un_list=get(lUn,''UserData'');Ns_list=sort([get(lNs,''UserData'') Un]);Str=getparam(''' me ''',''Tn1_Left_ch'' ,''list'');Ns_Str=cell(size(Str));Un_Str=cell(size(Str));Ns_Str(Ns_list)=Str(Ns_list);Un_Str(Un_list)=Str(Un_list);set(lNs,''UserData'',Ns_list,''string'',Ns_Str);set(lUn,''UserData'',Un_list,''string'',Un_Str);end' ]);
            hRmvNs = uicontrol('parent',tsfig,'string','< Remove','style','pushbutton','horiz','center','position',[331 150 58 20],'callback',...
                ['lNs=findobj(''tag'',''lNs'');lUn=findobj(''tag'',''lUn'');Ns=get(lNs,''value'');Ns_list=get(lNs,''UserData'');Ns_list=Ns_list(find(Ns_list~=Ns));Str=getparam(''' me ''',''Tn1_Left_ch'' ,''list'');Ns_Str=cell(size(Str));Un_Str=cell(size(Str));Ns_Str(Ns_list)=Str(Ns_list);Un_Str(Un_list)=Str(Un_list);set(lNs,''UserData'',Ns_list,''string'',Ns_Str);set(lUn,''UserData'',Un_list,''string'',Un_Str);' ]);
            finish_btn = uicontrol('parent',tsfig,'string','Finish','style','pushbutton','horiz','center','position',[230 15 58 20],'callback',...
                ['Tg_list=get(findobj(''tag'',''lTg''),''UserData'');SetParam(''' me ''',''DelayMatchSample_List'',Tg_list);Ns_list=get(findobj(''tag'',''lNs''),''UserData'');SetParam(''' me ''',''NonSample_List'',Ns_list);delete(' num2str(tsfig) ');' ]);
            nsr = uicontrol('parent',tsfig,'tag','ns_ratio','style','edit','string',NoGo_Ratio,'horiz','right','backgroundcolor',[1 1 1],'position',[390 15 30 20],'callback',...
                ['Ns_list=get(findobj(''tag'',''lNs''),''UserData'');nsr=findobj(''tag'',''ns_ratio'');ns_ratio= str2num(get(nsr,''string''))*(length(Ns_list)>0);set(nsr,''string'',ns_ratio);SetParam(''' me ''',''NoGo_Ratio'',ns_ratio);']);
            tNs  = uicontrol('parent',tsfig,'string','% Non-Target trials','style','text','horiz','left','position',[422 12 120 20]);            
            try
                set(ToneSelectFig, 'visible','on');
                uiwait(ToneSelectFig);
            catch
                if ishandle(ToneSelectFig)
                    delete(ToneSelectFig);
                end
            end
            DelayMatchSample_List = GetParam(me,'DelayMatchSample_List');
            NonSample_List=GetParam(me,'NonSample_List');
        end
        if task_id_change |ismember(get(gcbo,'tag'),{'changeschedule','task','reset'})
            ToneSource_Schedule((CountedTrial+running):MaxTrial)=2;
            Tone_Schedule((CountedTrial+running):MaxTrial)  = DelayMatchSample_List(ceil(rand(1,MaxTrial-CountedTrial-running+1)*length(DelayMatchSample_List)));
            NoGo_Ratio=GetParam(me,'NoGo_Ratio');
            for i=(CountedTrial+running):MaxTrial
                if (rand > NoGo_Ratio/100)  
                    NoGo_Schedule(i)= 0;
                else
                    b=NonSample_List(find(NonSample_List~=Tone_Schedule(i)));
                    NoGo_Schedule(i)= b(ceil(rand*length(b)));
                    ToneSource_Schedule(i)=1;
                end
            end
            WaterPort_Schedule((CountedTrial+running):MaxTrial)  = 2;   %right
            if task_id==13
                WaterPort_Schedule(find(NoGo_Schedule((CountedTrial+running):MaxTrial)>0)+(CountedTrial+running)-1) = 5; %right no water
            elseif  task_id==14
                WaterPort_Schedule(find(NoGo_Schedule((CountedTrial+running):MaxTrial)>0)+(CountedTrial+running)-1) = 1;  %left
            end
            Stimulus_Schedule((CountedTrial+running):MaxTrial)  = (WaterPort_Schedule((CountedTrial+running):MaxTrial)-1)*length(DelayMatchSample_List)*length(NonSample_List) + Tone_Schedule((CountedTrial+running):MaxTrial)*(length(NonSample_List))+NoGo_Schedule((CountedTrial+running):MaxTrial)+task_id*100;
        end
       
        if NoGo_Schedule(CountedTrial)
            SetParam(me,'Tone2_Src','enable_distractor',1,'NoGo',1);     % enable distractor from the silent channel
            % setup distractor
            if ismember(ToneSource_Schedule(CountedTrial),[1,4])  %left
                SetParam(me,'Tn2_Right_Ch','distractor',NoGo_Schedule(CountedTrial));
            elseif  ismember(ToneSource_Schedule(CountedTrial),[2,5])  %right
                SetParam(me,'Tn2_left_Ch','distractor',NoGo_Schedule(CountedTrial));
            end
        end      
        SetParam(me,'NoGo_Schedule',NoGo_Schedule);
        SetParam(me,'Tone_Schedule',Tone_Schedule);
        SetParam(me,'Tone_Schedule','user',Tone_Schedule(CountedTrial));
        SetParam(me,'ToneSource_Schedule',ToneSource_Schedule);
        SetParam(me,'WaterPort',WaterPort_Schedule(CountedTrial));
        
    case {15,16}             % 'DelayMatch'
        SetParam(me,'CueSource',2);     %location cue from 2nd tone
        SetParam(me,'Tone1_Src','use_schedule',1,'value',3,'user',3); % first tone source: Both/same (left + right)
        SetParam(me,'Tone2_Src','use_schedule',1);        
        SetParamUI(me,'WaterPort','enable','off');
        SetParamUI(me,'CueSource','enable','off');
        DelayMatchSample_List=GetParam(me,'DelayMatchSample_List');
        if ismember(get(gcbo,'tag'),{'task','reset'})
            WaterPort_Schedule((CountedTrial+running):MaxTrial)  = ceil(rand(1,MaxTrial-CountedTrial-running+1)*2);
            Str=getparam(me,'Tn1_Left_ch' ,'list');
            ToneSelectFig=figure('windowstyle','modal','position',[200 500 340 300],'name','Select Tone for Delay Match to Sample Task:','resize','off','numbertitle','off','menubar','none');
            tsfig=ToneSelectFig;
            tUn  = uicontrol('parent',tsfig,'string','Tone Unused','style','text','horiz','center','position',[20 260 80 20]);
            tUs  = uicontrol('parent',tsfig,'string','Tone Chosen','style','text','horiz','center','position',[210 260 80 20]);
            Un_list = find(~ismember(1:length(Str),DelayMatchSample_List))
            Un_Str= cell(size(Str));
            Un_Str(Un_list)=Str(Un_list);
            Us_list = find(ismember(1:length(Str),DelayMatchSample_List))
            Us_Str= cell(size(Str));
            Us_Str(Us_list)=Str(Us_list);
            lUn  = uicontrol('parent',tsfig,'string',Un_Str,'style','listbox','horiz','center','position',[10 40 130 220],'tag','lUn','UserData',Un_list);
            lUs  = uicontrol('parent',tsfig,'string',Us_Str,'style','listbox','horiz','center','position',[200 40 130 220],'tag','lUs','UserData',Us_list);
            hAdd = uicontrol('parent',tsfig,'string','Add >','style','pushbutton','horiz','center','position',[141 180 58 20],'callback',...
                ['lUs=findobj(''tag'',''lUs'');lUn=findobj(''tag'',''lUn'');Un=get(lUn,''value'');Us_list=sort([get(lUs,''UserData'') Un]);Un_list=get(lUn,''UserData'');Un_list=Un_list(find(Un_list~=Un));Str=getparam(''' me ''',''Tn1_Left_ch'' ,''list'');Us_Str=cell(size(Str));Un_Str=cell(size(Str));Us_Str(Us_list)=Str(Us_list);Un_Str(Un_list)=Str(Un_list);set(lUs,''UserData'',Us_list,''string'',Us_Str);set(lUn,''UserData'',Un_list,''string'',Un_Str);' ]);
            hRmv = uicontrol('parent',tsfig,'string','< Remove','style','pushbutton','horiz','center','position',[141 150 58 20],'callback',...
                ['lUs=findobj(''tag'',''lUs'');lUn=findobj(''tag'',''lUn'');Us=get(lUs,''value'');Un_list=sort([get(lUn,''UserData'') Us]);Us_list=get(lUs,''UserData'');Us_list=Us_list(find(Us_list~=Us));Str=getparam(''' me ''',''Tn1_Left_ch'' ,''list'');Us_Str=cell(size(Str));Un_Str=cell(size(Str));Us_Str(Us_list)=Str(Us_list);Un_Str(Un_list)=Str(Un_list);set(lUs,''UserData'',Us_list,''string'',Us_Str);set(lUn,''UserData'',Un_list,''string'',Un_Str);' ]);
            finish_btn = uicontrol('parent',tsfig,'string','Finish','style','pushbutton','horiz','center','position',[141 100 58 20],'callback',...
                ['Us_list=get(findobj(''tag'',''lUs''),''UserData'');SetParam(''' me ''',''DelayMatchSample_List'',Us_list);delete(' num2str(tsfig) ')' ]);
            try
                set(ToneSelectFig, 'visible','on');
                uiwait(ToneSelectFig);
            catch
                if ishandle(ToneSelectFig)
                    delete(ToneSelectFig)
                end
            end
            DelayMatchSample_List = GetParam(me,'DelayMatchSample_List');
            Tone_Schedule((CountedTrial+running):MaxTrial)  = DelayMatchSample_List(ceil(rand(1,MaxTrial-CountedTrial-running+1)*length(DelayMatchSample_List)));
            Stimulus_Schedule((CountedTrial+running):MaxTrial)  = ((WaterPort_Schedule((CountedTrial+running):MaxTrial)-1)*length(DelayMatchSample_List) + Tone_Schedule((CountedTrial+running):MaxTrial))+task_id*100;
            SetParam(me,'Tone_Schedule',Tone_Schedule);
        elseif  ismember(get(gcbo,'tag'),{'changeschedule'})
            WaterPort_Schedule((CountedTrial+running):MaxTrial)  = ceil(rand(1,MaxTrial-CountedTrial-running+1)*2);
            Tone_Schedule((CountedTrial+running):MaxTrial)  = DelayMatchSample_List(ceil(rand(1,MaxTrial-CountedTrial-running+1)*length(DelayMatchSample_List)));
            Stimulus_Schedule((CountedTrial+running):MaxTrial)  = ((WaterPort_Schedule((CountedTrial+running):MaxTrial)-1)*length(DelayMatchSample_List) + Tone_Schedule((CountedTrial+running):MaxTrial))+task_id*100;
            SetParam(me,'Tone_Schedule',Tone_Schedule);
            
        elseif  task_id_change
            WaterPort_Schedule((CountedTrial+running):MaxTrial)  = ceil(rand(1,MaxTrial-CountedTrial-running+1)*2);
            Tone_Schedule((CountedTrial+running):MaxTrial)  = DelayMatchSample_List(ceil(rand(1,MaxTrial-CountedTrial-running+1)*length(DelayMatchSample_List)));
            Stimulus_Schedule((CountedTrial+running):MaxTrial)  = ((WaterPort_Schedule((CountedTrial+running):MaxTrial)-1)*length(DelayMatchSample_List) + Tone_Schedule((CountedTrial+running):MaxTrial))+task_id*100;
            SetParam(me,'Tone_Schedule',Tone_Schedule);
        end
        if task_id==15
        elseif  task_id==16
            SetParam(me,'Tone2_Src','enable_distractor',1);     % enable distractor from the silent channel
            % setup distractor
            b=DelayMatchSample_List(find(DelayMatchSample_List~=Tone_Schedule(CountedTrial)));
            b=b(ceil(rand*(length(DelayMatchSample_List)-1)));
            if WaterPort_Schedule(CountedTrial)==1  %left
                SetParam(me,'Tn2_Right_Ch','distractor',b);
            elseif  WaterPort_Schedule(CountedTrial)==2  %left
                SetParam(me,'Tn2_left_Ch','distractor',b);
            end
        end
        
        SetParam(me,'Tone_Schedule','user',Tone_Schedule(CountedTrial));
        SetParam(me,'WaterPort',WaterPort_Schedule(CountedTrial));
end

WaterPort=mod(GetParam(me,'WaterPort')-1,3)+1;
if GetParam(me,'CueSource')==1      %1st tone location
    SetParam(me,'Tone1_src',WaterPort);
    SetParamUI(me,'Tone1_src','enable','off');
    SetParam(me,'Tone2_src',GetParam(me,'Tone2_src','user'));
    SetParamUI(me,'Tone2_src','enable','on');
    ToneSource_Schedule(CountedTrial:MaxTrial)  = mod(WaterPort_Schedule(CountedTrial:MaxTrial)-1,3)+1;
elseif GetParam(me,'CueSource')==2  %2nd tone location
    SetParam(me,'Tone2_src',WaterPort);
    SetParamUI(me,'Tone2_src','enable','off');
    SetParam(me,'Tone1_src',GetParam(me,'Tone1_src','user'));
    SetParamUI(me,'Tone1_src','enable','on');
    ToneSource_Schedule(CountedTrial:MaxTrial)  = mod(WaterPort_Schedule(CountedTrial:MaxTrial)-1,3)+1;
elseif GetParam(me,'CueSource')==3  %Both tone location
    SetParam(me,'Tone1_src',WaterPort);        
    SetParam(me,'Tone2_src',WaterPort);
    SetParamUI(me,'Tone1_src','enable','off');
    SetParamUI(me,'Tone2_src','enable','off');
    ToneSource_Schedule(CountedTrial:MaxTrial)  = mod(WaterPort_Schedule(CountedTrial:MaxTrial)-1,3)+1;
elseif GetParam(me,'CueSource')==4  %1st tone frequency
    if GetParam(me,'Tone1_Src','use_schedule')
        SetParam(me,'Tone1_src',ToneSource_Schedule(CountedTrial));  % enable tone source schedule
        SetParam(me,'Tone_Schedule','user',Tone_Schedule(CountedTrial));
    else
        SetParam(me,'Tone1_src',3); %default play tone from both channel
        ToneSource_Schedule(CountedTrial:MaxTrial)  = 3;        
    end
    SetParam(me,'Tone2_src',GetParam(me,'Tone2_src','user'));
    SetParamUI(me,'Tone1_src','enable','off');
    SetParamUI(me,'Tone2_src','enable','on');
elseif GetParam(me,'CueSource')==5  %2ndt tone frequency
    SetParam(me,'Tone1_src',GetParam(me,'Tone1_src','user'));            
    if GetParam(me,'Tone2_Src','use_schedule')
        SetParam(me,'Tone2_src',ToneSource_Schedule(CountedTrial));  % enable tone source schedule
        SetParam(me,'Tone_Schedule','user',Tone_Schedule(CountedTrial));
    else
        SetParam(me,'Tone2_src',3); %default play tone from both channel
        ToneSource_Schedule(CountedTrial:MaxTrial)  = 3;        
    end    
    SetParamUI(me,'Tone1_src','enable','on');
    SetParamUI(me,'Tone2_src','enable','off');
elseif GetParam(me,'CueSource')==6  %Both tone frequency
    if GetParam(me,'Tone1_Src','use_schedule')
        SetParam(me,'Tone1_src',ToneSource_Schedule(CountedTrial));  % enable tone source schedule
        SetParam(me,'Tone_Schedule','user',Tone_Schedule(CountedTrial));        
    else
        SetParam(me,'Tone1_src',3); %default play tone from both channel
        ToneSource_Schedule(CountedTrial:MaxTrial)  = 3;        
    end
    if GetParam(me,'Tone2_Src','use_schedule')
        SetParam(me,'Tone2_src',ToneSource_Schedule(CountedTrial));  % enable tone source schedule
        %         SetParam(me,'Tone_Schedule','user',Tone_Schedule(CountedTrial));        
    else
        SetParam(me,'Tone2_src',3); %default play tone from both channel
        %         ToneSource_Schedule(1:MaxTrial)  = 3;     
    end    
    SetParamUI(me,'Tone1_src','enable','off');
    SetParamUI(me,'Tone2_src','enable','off');
end
SetParam(me,'WaterPort_Schedule',WaterPort_Schedule);
SetParam(me,'ToneSource_Schedule',ToneSource_Schedule);
SetParam(me,'Stimulus_Schedule',Stimulus_Schedule);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function check_tone1_src
global exper

tone1_src=GetParam(me,'tone1_src'); %{'Left';'Right';'Both/same';'Both/indp'}        
if strcmp(get(gcbo,'tag'),'tone1_src')
    SetParam(me,'Tone1_src','user',get(gcbo,'value'));
end
Tone_Schedule=GetParam(me,'Tone_Schedule','user');

Freq=GetParam(me,'ToneFreq','user');
n_tones=length(Freq);
if tone1_src==5
    tone1_src=ceil(rand*3);
end

if tone1_src==1     %Left
    if GetParam(me,'Tone1_Src','enable_distractor')
        SetParam(me,'Tn1_Right_Ch',GetParam(me,'Tn1_Right_Ch','distractor'));      % enable distractor from the silent channel
    else
        SetParam(me,'Tn1_Right_Ch',n_tones+1);      %silence
    end
    SetParamUI(me,'Tn1_Right_Ch','enable','off');
    if GetParam(me,'Tone1_Src','use_schedule')
        SetParam(me,'Tn1_Left_Ch',Tone_Schedule);
    else
        SetParam(me,'Tn1_Left_Ch',GetParamUI(me,'Tn1_Left_Ch','UserData'));
    end
    SetParamUI(me,'Tn1_Left_Ch','enable','on');
elseif tone1_src==2     %Right
    SetParamUI(me,'Tn1_Right_Ch','enable','on');
    if GetParam(me,'Tone1_Src','use_schedule')
        SetParam(me,'Tn1_Right_Ch',Tone_Schedule);
    else
        SetParam(me,'Tn1_Right_Ch',GetParamUI(me,'Tn1_Right_Ch','UserData'));
    end
    if GetParam(me,'Tone1_Src','enable_distractor')
        SetParam(me,'Tn1_Left_Ch',GetParam(me,'Tn1_Left_Ch','distractor'));      % enable distractor from the silent channel
    else
        SetParam(me,'Tn1_Left_Ch',n_tones+1);      %silence
    end
    SetParamUI(me,'Tn1_Left_Ch','enable','off');
elseif tone1_src==3     %Both/same
    SetParamUI(me,'Tn1_Right_Ch','enable','off');
    SetParamUI(me,'Tn1_Left_Ch','enable','on');
    if GetParam(me,'Tone1_Src','use_schedule')
        SetParam(me,'Tn1_Left_Ch',Tone_Schedule);
    else
        SetParam(me,'Tn1_Left_Ch',GetParamUI(me,'Tn1_Left_Ch','UserData'));
    end
    SetParam(me,'Tn1_Right_Ch',GetParam(me,'Tn1_Left_Ch'));
elseif tone1_src==4     %Both/indp
    SetParamUI(me,'Tn1_Right_Ch','enable','on');
    SetParam(me,'Tn1_Right_Ch',GetParamUI(me,'Tn1_Right_Ch','UserData'));            
    SetParamUI(me,'Tn1_Left_Ch','enable','on');
    SetParam(me,'Tn1_Left_Ch',GetParamUI(me,'Tn1_Left_Ch','UserData'));            
end        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function check_tone2_src
global exper

tone2_src=GetParam(me,'tone2_src');  %{'Left';'Right';'Both/same';'Both/indp';'None'}
if strcmp(get(gcbo,'tag'),'tone2_src')
    SetParam(me,'Tone2_src','user',get(gcbo,'value'));
end
Tone_Schedule=GetParam(me,'Tone_Schedule','user');

Freq=GetParam(me,'ToneFreq','user');
n_tones=length(Freq);
if tone2_src==6
    tone2_src=ceil(rand*3);
end
if tone2_src==1     %Left
    if GetParam(me,'Tone2_Src','enable_distractor')
        SetParam(me,'Tn2_Right_Ch',GetParam(me,'Tn2_Right_Ch','distractor'));      % enable distractor from the silent channel
    else
        SetParam(me,'Tn2_Right_Ch',n_tones+1);  %silence
    end
    SetParamUI(me,'Tn2_Right_Ch','enable','off');
    
    if GetParam(me,'Tone2_Src','NoGo')
        SetParam(me,'Tn2_Left_Ch',n_tones+1);      %silence
    elseif GetParam(me,'Tone2_Src','use_schedule')
        SetParam(me,'Tn2_Left_Ch',Tone_Schedule);
    else
        SetParam(me,'Tn2_Left_Ch',GetParamUI(me,'Tn2_Left_Ch','UserData'));
    end
    SetParamUI(me,'Tn2_Left_Ch','enable','on');
    SetParam(me,'DirectDeliver2',GetParam(me,'DirectDeliver2','user'));
    SetParamUI(me,'DirectDeliver2','enable','on');
elseif tone2_src==2     %Right
    if GetParam(me,'Tone2_Src','NoGo')
        SetParam(me,'Tn2_Right_Ch',n_tones+1);      %silence
    elseif GetParam(me,'Tone2_Src','use_schedule')
        SetParam(me,'Tn2_Right_Ch',Tone_Schedule);
    else
        SetParam(me,'Tn2_Right_Ch',GetParamUI(me,'Tn2_Right_Ch','UserData'));
    end
    SetParamUI(me,'Tn2_Right_Ch','enable','on');
    if GetParam(me,'Tone2_Src','enable_distractor')
        SetParam(me,'Tn2_Left_Ch',GetParam(me,'Tn2_Left_Ch','distractor'));      % enable distractor from the silent channel
    else
        SetParam(me,'Tn2_Left_Ch',n_tones+1);  %silence
    end
    SetParamUI(me,'Tn2_Left_Ch','enable','off');
    SetParam(me,'DirectDeliver2',GetParam(me,'DirectDeliver2','user'));
    SetParamUI(me,'DirectDeliver2','enable','on');
elseif tone2_src==3
    SetParamUI(me,'Tn2_Right_Ch','enable','off');
    SetParamUI(me,'Tn2_Left_Ch','enable','on');
    if GetParam(me,'Tone2_Src','use_schedule')
        SetParam(me,'Tn2_Left_Ch',Tone_Schedule);
    else
        SetParam(me,'Tn2_Left_Ch',GetParamUI(me,'Tn2_Left_Ch','UserData'));
    end
    SetParam(me,'Tn2_Right_Ch',GetParam(me,'Tn2_Left_Ch'));
    SetParam(me,'DirectDeliver2',GetParam(me,'DirectDeliver2','user'));
    SetParamUI(me,'DirectDeliver2','enable','on');
elseif tone2_src==4
    SetParamUI(me,'Tn2_Right_Ch','enable','on');
    SetParam(me,'Tn2_Right_Ch',GetParamUI(me,'Tn2_Right_Ch','UserData'));            
    SetParamUI(me,'Tn2_Left_Ch','enable','on');
    SetParam(me,'Tn2_Left_Ch',GetParamUI(me,'Tn2_Left_Ch','UserData'));
    SetParam(me,'DirectDeliver2',GetParam(me,'DirectDeliver2','user'));
    SetParamUI(me,'DirectDeliver2','enable','on');
elseif tone2_src==5
    SetParam(me,'Tn2_Right_Ch',n_tones+1);      %silence
    SetParamUI(me,'Tn2_Right_Ch','enable','off');
    SetParam(me,'Tn2_Left_Ch',n_tones+1);       %silence
    SetParamUI(me,'Tn2_Left_Ch','enable','off');
    SetParam(me,'DirectDeliver2',0);
    SetParamUI(me,'DirectDeliver2','enable','off'); 
end        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function update_event   %update_event(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if nargin > 0 
%     clk = varargin{1};
% else
%     clk = clock;
% end

CountedTrial = GetParam(me,'CountedTrial')+1;
dd=GetParam(me,'DirectDeliver_Schedule');
dd=dd(CountedTrial);

Trial_Events    =GetParam(me,'Trial_Events','value');
Result          =GetParam(me,'Result');
FirstTonePokeDur     =GetParam(me,'FirstTonePokeDur');
LastTonePokeDur     =GetParam(me,'LastTonePokeDur');
nTonePoke       =GetParam(me,'nTonePoke');

if dd==1
    Valid1st=[2 7];
    Valid2nd=[21 7];
    lHit1 =[26 7];
    rHit1 =[27 7];    
    lHit2 =[29 7];
    rHit2 =[30 7];
    Miss1 =[4 7];
    Miss2 =[23 7];
    lFalse1 =[24 7];
    rFalse1 =[25 7];    
    lFalse2 =[32 7];
    rFalse2 =[33 7];
    Abort1 =[2 2];
    Abort2 =[8 2;21 2];
elseif dd==2
    Valid1st=[5 7];
    Valid2nd=[8 7];
    lHit1 =[26 7];
    rHit1 =[27 7];    
    lHit2 =[29 7];
    rHit2 =[30 7];
    Miss1 =[4 7];
    Miss2 =[10 7];
    lFalse1 =[24 7];
    rFalse1 =[25 7];    
    lFalse2 =[32 7];
    rFalse2 =[33 7];
    Abort1 =[5 2];
    Abort2 =[8 2];
else
    Valid1st=[12 7;16 7];
    Valid2nd=[21 7];
    lHit1 =[26 7];
    rHit1 =[27 7];    
    lHit2 =[29 7];
    rHit2 =[30 7];
    Miss1 =[14 7];
    Miss2 =[23 7];
    lFalse1 =[24 7];
    rFalse1 =[25 7];    
    lFalse2 =[32 7];
    rFalse2 =[33 7];
    Abort1 =[12 2;16 2];
    Abort2 =[21 2];
end
IPIMiss=[7 7;19 7];
IPIAbort=[31 7];
NoGo=[15 7];

Event=Getparam('rpbox','event','user'); % [state,chan,event time]
for i=1:size(Event,1)
    if Event(i,2)==1        %tone poke in
        if (Event(i,1:2)==[1 1] |Event(i,1:2)==[7 1] |Event(i,1:2)==[19 1] )& (CountedTrial-1)
            nTonePoke(CountedTrial-1)=nTonePoke(CountedTrial-1)+nTonePoke(CountedTrial);
            nTonePoke(CountedTrial)=1;
        else
            nTonePoke(CountedTrial)=nTonePoke(CountedTrial)+1;
        end
        SetParam(me,'LastTonePokeDur','user1',Event(i,3));
        
    elseif Event(i,2)==2    %tone poke out
        lastpkdur=(Event(i,3)-GetParam(me,'LastTonePokeDur','user1'))*1000;
        SetParam(me,'LastTonePokeDur','user2',Event(i,3));
        SetParam(me,'LastTonePokeDur',lastpkdur);
        if nTonePoke(CountedTrial)==1
            SetParam(me,'FirstTonePokeDur',lastpkdur);
            %             TonePokeDur(CountedTrial)=lastpkdur;
            SetParam(me,'TonePokeDur',lastpkdur);
        end
        if sum(prod(repmat(Event(i,1:2),size(Abort1,1),1)==Abort1,2))
            Result(CountedTrial) =104;  % ShortPoke => Abort 
            SetParam(me,'Abort1',GetParam(me,'Abort1')+1);
            message(me,['ShortPoke => 1st poke Abort #' num2str(GetParam(me,'Abort1'))],'green');
            
            Trial_Events=[Trial_Events;Event(i,1:3)];
        elseif sum(prod(repmat(Event(i,1:2),size(Abort2,1),1)==Abort2,2))
            Result(CountedTrial) =204;  % ShortPoke => Abort 
            SetParam(me,'Abort2',GetParam(me,'Abort2')+1);
            message(me,['ShortPoke => 2nd poke Abort #' num2str(GetParam(me,'Abort2'))],'green');
            Trial_Events=[Trial_Events;Event(i,1:3) ];
        end
    elseif Event(i,2)==3    %Left poke in
    elseif Event(i,2)==4    %Left poke out
    elseif Event(i,2)==5    %Right poke in
    elseif Event(i,2)==6    %Right poke out
        
    elseif Event(i,2)==7    % time up
        if sum(prod(repmat(Event(i,1:2),size(Valid1st,1),1)==Valid1st,2))
            SetParam(me,'Valid1st',GetParam(me,'Valid1st')+1);
            Trial_Events=[Trial_Events;Event(i,1:3)];
        elseif sum(prod(repmat(Event(i,1:2),size(Valid2nd,1),1)==Valid2nd,2))
            SetParam(me,'Valid2nd',GetParam(me,'Valid2nd')+1);
            Trial_Events=[Trial_Events;Event(i,1:3)];
        elseif sum(prod(repmat(Event(i,1:2),size(lHit1,1),1)==lHit1,2))
            Result(CountedTrial) =101;  %Hit
            SetParam(me,'LeftHit1',GetParam(me,'LeftHit1')+1);
            message(me,['Left Hit 1 #' num2str(GetParam(me,'LeftHit1'))],'cyan');
            Trial_Events=[Trial_Events;Event(i,1:3)];
        elseif sum(prod(repmat(Event(i,1:2),size(rHit1,1),1)==rHit1,2))
            Result(CountedTrial) =101;  %Hit
            SetParam(me,'RightHit1',GetParam(me,'RightHit1')+1);
            message(me,['Right Hit 1 #' num2str(GetParam(me,'RightHit1'))],'cyan');
            Trial_Events=[Trial_Events;Event(i,1:3)];
        elseif sum(prod(repmat(Event(i,1:2),size(lHit2,1),1)==lHit2,2))
            Result(CountedTrial) =201;  %Hit
            SetParam(me,'LeftHit2',GetParam(me,'LeftHit2')+1);
            message(me,['Left Hit 2 #' num2str(GetParam(me,'LeftHit2'))],'cyan');
            Trial_Events=[Trial_Events;Event(i,1:3)];
        elseif sum(prod(repmat(Event(i,1:2),size(rHit2,1),1)==rHit2,2))
            Result(CountedTrial) =201;  %Hit
            SetParam(me,'RightHit2',GetParam(me,'RightHit2')+1);
            message(me,['Right Hit 2 #' num2str(GetParam(me,'RightHit2'))],'cyan');
            Trial_Events=[Trial_Events;Event(i,1:3)];
        elseif sum(prod(repmat(Event(i,1:2),size(Miss1,1),1)==Miss1,2))
            Result(CountedTrial) =103;  %ValidTonePoke but missed reward
            message(me,'1st poke, Missed reward');
            SetParam(me,'Miss1',GetParam(me,'Miss1')+1);
            Trial_Events=[Trial_Events;Event(i,1:3)];
        elseif sum(prod(repmat(Event(i,1:2),size(Miss2,1),1)==Miss2,2))
            Result(CountedTrial) =203;  %ValidTonePoke but missed reward
            message(me,'2nd poke, Missed reward');            
            SetParam(me,'Miss2',GetParam(me,'Miss2')+1);
            Trial_Events=[Trial_Events;Event(i,1:3)];
        elseif sum(prod(repmat(Event(i,1:2),size(lFalse1,1),1)==lFalse1,2))
            Result(CountedTrial) =102;  %False
            SetParam(me,'LeftFalse1',GetParam(me,'LeftFalse1')+1);
            message(me,['Left False 1 #' num2str(GetParam(me,'LeftFalse1'))],'red');
            Trial_Events=[Trial_Events;Event(i,1:3)];
        elseif sum(prod(repmat(Event(i,1:2),size(rFalse1,1),1)==rFalse1,2))
            Result(CountedTrial) =102;  %False
            SetParam(me,'RightFalse1',GetParam(me,'RightFalse1')+1);
            message(me,['Right False 1 #' num2str(GetParam(me,'RightFalse1'))],'red');
            Trial_Events=[Trial_Events;Event(i,1:3)];
        elseif sum(prod(repmat(Event(i,1:2),size(lFalse2,1),1)==lFalse2,2))
            Result(CountedTrial) =202;  %False
            SetParam(me,'LeftFalse2',GetParam(me,'LeftFalse2')+1);
            message(me,['Left False 2 #' num2str(GetParam(me,'LeftFalse2'))],'red');
            Trial_Events=[Trial_Events;Event(i,1:3)];
        elseif sum(prod(repmat(Event(i,1:2),size(rFalse2,1),1)==rFalse2,2))
            Result(CountedTrial) =202;  %False
            SetParam(me,'RightFalse2',GetParam(me,'RightFalse2')+1);
            message(me,['Right False 2 #' num2str(GetParam(me,'RightFalse2'))],'red');
            Trial_Events=[Trial_Events;Event(i,1:3)];
        elseif sum(prod(repmat(Event(i,1:2),size(IPIMiss,1),1)==IPIMiss,2))
            Result(CountedTrial) =104;  %IPI Miss 2nd Poke
            SetParam(me,'IPIMiss',GetParam(me,'IPIMiss')+1);
            message(me,['Missed 2nd Poke, IPIMiss #' num2str(GetParam(me,'IPIMiss'))],'green');
            Trial_Events=[Trial_Events;Event(i,1:3)];
        elseif sum(prod(repmat(Event(i,1:2),size(IPIAbort,1),1)==IPIAbort,2))
            Result(CountedTrial) =105;  %IPI poke left/right
            SetParam(me,'IPIAbort',GetParam(me,'IPIAbort')+1);
            message(me,['Right/Left poke during IPI#' num2str(GetParam(me,'IPIAbort'))],'red');
            Trial_Events=[Trial_Events;Event(i,1:3)];
        elseif sum(prod(repmat(Event(i,1:2),size(NoGo,1),1)==NoGo,2))
            Result(CountedTrial) =201;  %Correctly NoGo
            SetParam(me,'NoGoCorrect',GetParam(me,'NoGoCorrect')+1);
            message(me,['Correctly NoGo! #' num2str(GetParam(me,'NoGoCorrect'))],'cyan');
            Trial_Events=[Trial_Events;Event(i,1:3)];
        end
    end
end
SetParam(me,'Result',Result);
SetParam(me,'nTonePoke',nTonePoke);
SetParam(me,'Trial_Events','value',Trial_Events);
Setparam('rpbox','event','user',[]);    %clearing events so it won't get counted twice

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function update_new_schedule
global exper

tr = GetParam(me,'MaxTrial');
ValidPokeNum = [];
DirectDeliver_Schedule = [];

DD1=GetParam(me,'DirectDeliver1');
DD2=GetParam(me,'DirectDeliver2');
Tone2_Src=GetParam(me,'Tone2_Src');

% 1:'custom setting',2:'Left',3:'Right',4:'10L-10R',5:'Random'

ValidPokeNum(1:DD1)  = 1;
DirectDeliver_Schedule(1:DD1)=1;
if Tone2_Src==5
    ValidPokeNum(DD1+1:tr) = 1;
    DirectDeliver_Schedule(DD1+1:tr)=0;    
elseif DD2
    ValidPokeNum(DD1+1:tr) = 2;
    DirectDeliver_Schedule(DD1+1:DD1+DD2)=2;
    DirectDeliver_Schedule(DD1+DD2:tr)=0;        
else
    ValidPokeNum(DD1+1:tr) = 2;
    DirectDeliver_Schedule(DD1+1:tr)=0;
end

SetParam(me,'ValidPokeNum',ValidPokeNum);
SetParam(me,'DirectDeliver_Schedule',DirectDeliver_Schedule);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=InitTones

Freq=GetParam(me,'ToneFreq','user');
Dur=GetParam(me,'ToneDur','user');
SPL=GetParam(me,'ToneSPL','user');
n_tones=length(Freq);
ToneAttenuation = ones(1,n_tones)*70 -SPL;

ppfilter={'\PPfilter_right.mat' '\PPfilter_left.mat'};
for i=1:2
    FilterPath=[GetParam('rpbox','protocol_path') ppfilter{i}];
    if ( size(dir(FilterPath),1) == 1 )
        PP=load(FilterPath);
        PP=PP.PP;
        message(me,'Generating Calibrated Tones');
    else
        PP=[];
        message(me,'Generating Non-calibrated Tones');
    end
    
    for tn=1:n_tones
        if isempty(PP) | Freq(tn)== -1
            ToneAttenuation_adj = ToneAttenuation(tn);
            beep{tn}  = 1 * makebeep(50e6/1024, ToneAttenuation_adj ,Freq(tn), Dur(tn),3);
        elseif Freq(tn)== 1
            Low_Chord_freq=[4000 5000 7000 9000];
            for j=1:4
                ToneAttenuation_adj(j) = ToneAttenuation(tn) - ppval(PP, log10(Low_Chord_freq(j)));
                % Remove any negative attenuations and replace with zero attenuation.
                ToneAttenuation_adj(j) = ToneAttenuation_adj(j) .* (ToneAttenuation_adj(j) > 0);
            end
            beep{tn}  = 1/4 * makebeep(50e6/1024, ToneAttenuation_adj(1) ,Low_Chord_freq(1), Dur(tn),3)+...
                1/4 * makebeep(50e6/1024, ToneAttenuation_adj(2) ,Low_Chord_freq(2), Dur(tn),3)+...
                1/4 * makebeep(50e6/1024, ToneAttenuation_adj(3) ,Low_Chord_freq(3), Dur(tn),3)+...
                1/4 * makebeep(50e6/1024, ToneAttenuation_adj(4) ,Low_Chord_freq(4), Dur(tn),3);
        elseif Freq(tn)== 2 
            Hi_Chord_freq=[13000 15000 17000 19000];
            for j=1:4
                ToneAttenuation_adj(j) = ToneAttenuation(tn) - ppval(PP, log10(Hi_Chord_freq(j)));
                % Remove any negative attenuations and replace with zero attenuation.
                ToneAttenuation_adj(j) = ToneAttenuation_adj(j) .* (ToneAttenuation_adj(j) > 0);
            end
            beep{tn}  = 1/4 * (makebeep(50e6/1024, ToneAttenuation_adj(1) ,Hi_Chord_freq(1), Dur(tn),3)+...
                makebeep(50e6/1024, ToneAttenuation_adj(2) ,Hi_Chord_freq(2), Dur(tn),3)+...
                makebeep(50e6/1024, ToneAttenuation_adj(3) ,Hi_Chord_freq(3), Dur(tn),3)+...
                makebeep(50e6/1024, ToneAttenuation_adj(4) ,Hi_Chord_freq(4), Dur(tn),3));
        else
            ToneAttenuation_adj = ToneAttenuation(tn) - ppval(PP, log10(Freq(tn)));
            % Remove any negative attenuations and replace with zero attenuation.
            ToneAttenuation_adj = ToneAttenuation_adj .* (ToneAttenuation_adj > 0);
            beep{tn}  = 1 * makebeep(50e6/1024, ToneAttenuation_adj ,Freq(tn), Dur(tn),3);
        end
    end
    
    [mxDur idx]=max(Dur);
    beep{tn+1} = beep{idx}*0;
    Beep{i}=beep;
end

SetParam(me,'rbeep',Beep{1});
SetParam(me,'lbeep',Beep{2});
out=beep;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=CurrentTones
rbeep=GetParam(me,'rbeep');
lbeep=GetParam(me,'lbeep');
Freq=GetParam(me,'ToneFreq','user');
Dur=GetParam(me,'ToneDur','user');
n_tones=length(Freq);
SPL=GetParam(me,'ToneSPL','user');
ToneAttenuation = ones(1,n_tones)*70 -SPL;

Tn1_Right_Ch = GetParam(me,'Tn1_Right_Ch');
if Tn1_Right_Ch==n_tones+2
    Tn1_Right_Ch=ceil(rand*n_tones);
end
if Tn1_Right_Ch==n_tones+1
    r_beep1=rbeep{Tn1_Right_Ch};
elseif Freq(Tn1_Right_Ch)==-1
    r_beep1  = 1 * makebeep(50e6/1024, ToneAttenuation(Tn1_Right_Ch) ,Freq(Tn1_Right_Ch), Dur(Tn1_Right_Ch),3);
else
    r_beep1=rbeep{Tn1_Right_Ch};
end

Tn1_Left_Ch=GetParam(me,'Tn1_Left_Ch');
Tone1_Src=GetParam(me,'Tone1_Src');
if Tn1_Left_Ch==n_tones+2 & Tone1_Src==3
    Tn1_Left_Ch=Tn1_Right_Ch;
elseif Tn1_Left_Ch==n_tones+2
    Tn1_Left_Ch=ceil(rand*n_tones);        
end
if Tn1_Left_Ch==n_tones+1
    l_beep1=rbeep{Tn1_Left_Ch};
elseif Freq(Tn1_Left_Ch)==-1
    l_beep1  = 1 * makebeep(50e6/1024, ToneAttenuation(Tn1_Left_Ch) ,Freq(Tn1_Left_Ch), Dur(Tn1_Left_Ch),3);
else
    l_beep1=lbeep{Tn1_Left_Ch};
end


Tn2_Right_Ch=GetParam(me,'Tn2_Right_Ch');
if Tn2_Right_Ch==n_tones+2
    Tn2_Right_Ch=ceil(rand*n_tones);
end
if Tn2_Right_Ch==n_tones+1
    r_beep2=rbeep{Tn2_Right_Ch};
elseif Freq(Tn2_Right_Ch)==-1
    r_beep2  = 1 * makebeep(50e6/1024, ToneAttenuation(Tn2_Right_Ch) ,Freq(Tn2_Right_Ch), Dur(Tn2_Right_Ch),3);
else
    r_beep2=rbeep{Tn2_Right_Ch};
end

Tn2_Left_Ch=GetParam(me,'Tn2_Left_Ch');
Tone2_Src=GetParam(me,'Tone2_Src');
if Tn2_Left_Ch==n_tones+2 & Tone2_Src==3
    Tn2_Left_Ch=Tn2_Right_Ch;
elseif Tn2_Left_Ch==n_tones+2
    Tn2_Left_Ch=ceil(rand*n_tones);
end
if Tn2_Left_Ch==n_tones+1
    l_beep2=rbeep{Tn2_Left_Ch};
elseif Freq(Tn2_Left_Ch)==-1
    l_beep2  = 1 * makebeep(50e6/1024, ToneAttenuation(Tn2_Left_Ch) ,Freq(Tn2_Left_Ch), Dur(Tn2_Left_Ch),3);
else
    l_beep2=lbeep{Tn2_Left_Ch};
end

out={r_beep1;l_beep1;...
        r_beep2;l_beep2};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=me
% Simple function for getting the name of this m-file.
out=lower(mfilename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = callback
out = [lower(mfilename) ';'];

