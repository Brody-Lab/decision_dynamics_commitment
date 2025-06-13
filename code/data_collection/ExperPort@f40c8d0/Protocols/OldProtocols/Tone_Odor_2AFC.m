function out = tone_odor_2afc(varargin)

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
        
        R=1;    %Right
        L=2;    %Left
        B=3;    %Both

        Blnk = 0;
        Ch_A= 2^3;
        Ch_B= 2^4;

        FC  =[500 1000 2000 3000 5000 7000 9000 11000 13000 15000 17000 23000];   % frequency of choice, Hz
        FL ={'500','1k','2k','3k','5k','7k','9k','11k','13k','15k','17k','23k'};  % list of frequency of choice
        rc=10;
        lc=2;
        rf=FC(rc);
        lf=FC(lc);
        rl=FL{rc};
        ll=FL{lc};
        Port = [  R     R     R       R         R         L     L      L     L    L ];
        OdorCh=[Blnk  Ch_B   Ch_B  Ch_B       Ch_A      Ch_B  Ch_A   Ch_A  Ch_A Blnk];
        Ratio={[ 0     50     0       0         0         0     0      0    50    0 ],
               [ 0      0     0       0         0         0     0      0   100    0 ],
               [ 0    100     0       0         0         0     0      0     0    0 ],
               [50      0     0       0         0         0     0      0     0   50 ],
               [ 0      0     0       0         0         0     0      0     0  100 ],
               [100     0     0       0         0         0     0      0     0    0 ],
               [20     12    13       5         0         0     5     13    12   20 ],
               [ 0      0    25      25         0         0    25     25     0    0 ],
               [ 0      0     0       0         0         0    50     50     0    0 ],
               [ 0      0    50      50         0         0     0      0     0    0 ],
               [30     20     0       0         0         0     0      0    20   30 ],
               [25     25     0       0         0         0     0      0    25   25 ];
               [ 0      0     0      25        25        25    25      0     0    0 ]};
        Freq  =[rf   2345    lf      rf        rf        lf    lf     rf  2345   lf ];  %Hz
        Dur   =[200   200   200     200       200       200   200    200   200  200 ];  %msec
        SPL   =[ 60  -100    60      60        60        60    60     60  -100   60 ];  %Max=PPdB SPL
        Str   ={[rl ' 60dB 200ms'],'Odor B 200ms',['Odor B &' ll ' 200ms'],['Odor B &' rl ' 200ms'],['Odor A &' rl ' 200ms'],['Odor B &' ll ' 200ms'],['Odor A &' ll ' 200ms'],['Odor A &' rl ' 200ms'],'Odor A 200ms',[ll ' 60dB 200ms']};
        Ratio_Str ={'Olfactory','Odor A','Odor B','Auditory',[ll 'Hz tone'],[rl 'Hz tone'],'AvBv[ ] w/tone','A or B w/tone','odor A w/tone','odor B w/tone','odor/tone=2:3','odor/tone=1:1','Auditory w/odor'}; 

%         Freq=fliplr(Freq);
%         Str=fliplr(Str);
%         TmOut=fliplr(TmOut);

        JntGrp={[ 1  2 3  7  5;   % For ploting joint performance in the same column, ie, mean of tone 1 and 10 is ploted in a group. 
                 10  9 4  8  6],
                [ 1 10 2 9]' }    % Additional group lists can be added in the cell array.
        JntGrpXTitle={'aud' 'olf' 'odrB' 'odrA' 'A+B' 'AVG'};
        ScriptList={'none','sound L<-->R','sound R<-->L','Odor A<-->B','Odor B<-->A','Odor<-->sound','Sound<-->Odor','Aud<->AvB w/tone'};
         
        VPS_Freq=[  -1    -1    -1     -1     -1];  %Hz
        VPS_Dur =[  10    10    10     25     25];  %msec
        VPS_SPL =[ -10    65    55     65     55];  %Max=PPdB SPL
        VPS_Str ={'silence' '10ms-65dBwn' '10ms-55dBwn' '25ms-65dBwn' '25ms-55dBwn'}; 
        InitParam(me,'VPS_Freq','value',VPS_Freq);
        InitParam(me,'VPS_Dur','value',VPS_Dur);
        InitParam(me,'VPS_SPL','value',VPS_SPL);
        
        WN_SPL =[ 50     40     30    -10 ];  %Max=PPdB SPL
        WN_Str ={'20dB atten' '30dB atten' '40dB atten' 'silence'}; 
        InitParam(me,'WN_SPL','value',WN_SPL);
        
        InitParam(me,'MaxTrial','value',1200); 
        
        n=n+.2;
        InitParam(me,'LastTonePokeDur','ui','disp','value',0,'pref',0,'pos',[h n*vs hs*.85 vs]); 
        SetParamUI(me,'LastTonePokeDur','label','Last TnPokeDur');
        InitParam(me,'LeftAbort','ui','disp','value',0,'pref',0,'pos',[h+hs*1.8 n*vs hs*.5 vs]); 
        SetParamUI(me,'LeftAbort','label','Left Abort');
        InitParam(me,'RightAbort','ui','disp','value',0,'pref',0,'pos',[h+hs*3 n*vs hs*.6 vs]); 
        SetParamUI(me,'RightAbort','label','Right Abort');
        InitParam(me,'rWaterValveDur','ui','edit','value',.12,'pos',[h+hs*4.3 n*vs hs*.7 vs]);
        SetParamUI(me,'rWaterValveDur','label','R_WaterV_Dur'); 
        InitParam(me,'WN_for_Odor','ui','checkbox','value',0,'pref',0,'pos',[h+hs*5.9 n*vs hs*1.5 vs]);
        SetParamUI(me,'WN_for_Odor','label','','string','play wn for Odor'); 
        InitParam(me,'Tn_for_VP','ui','checkbox','value',0,'pref',0,'pos',[h+hs*7.5 n*vs hs*1.5 vs]);
        SetParamUI(me,'Tn_for_VP','label','','string','play tone for VP'); 
        
        n=n+1;
        InitParam(me,'FirstTonePokeDur','ui','disp','value',0,'pref',0,'pos',[h n*vs hs*.85 vs]); 
        SetParamUI(me,'FirstTonePokeDur','label','TnPokeDur (ms)');
        InitParam(me,'LeftFalse','ui','disp','value',0,'pref',0,'pos',[h+hs*1.8 n*vs hs*.5 vs]); 
        SetParamUI(me,'LeftFalse','label','Left False');
        InitParam(me,'RightFalse','ui','disp','value',0,'pref',0,'pos',[h+hs*3 n*vs hs*.6 vs]); 
        SetParamUI(me,'RightFalse','label','Right False');
        InitParam(me,'lWaterValveDur','ui','edit','value',.12,'pos',[h+hs*4.3 n*vs hs*.7 vs]);
        SetParamUI(me,'lWaterValveDur','label','L_WaterV_Dur'); 
        InitParam(me,'WN_Level','ui','popupmenu','list',WN_Str,'value',4,'user',4,'pos',[h+hs*5.9 n*vs hs*.7 vs]);
        SetParamUI(me,'WN_Level','label','WhiteNoise_L');
        InitParam(me,'VP_Signal','ui','popupmenu','list',VPS_Str,'value',1,'user',1,'pos',[h+hs*7.5 n*vs hs*.8 vs]);
        SetParamUI(me,'VP_Signal','label','VP_Signal');
        
        n=n+1; 
        InitParam(me,'CountedTrial','ui','disp','value',0,'pref',0,'pos',[h n*vs hs*.85 vs]); 
        SetParamUI(me,'CountedTrial','label','Counted Trial');
        InitParam(me,'LeftMiss','ui','disp','value',0,'pref',0,'pos',[h+hs*1.8 n*vs hs*.5 vs]); 
        SetParamUI(me,'LeftMiss','label','Left Miss');
        InitParam(me,'RightMiss','ui','disp','value',0,'pref',0,'pos',[h+hs*3 n*vs hs*.6 vs]); 
        SetParamUI(me,'RightMiss','label','Right Miss');
        InitParam(me,'ValidTonePokeDur','ui','edit','value',0.1,'pos',[h+hs*4.3 n*vs hs*.7 vs]);
        SetParamUI(me,'ValidTonePokeDur','label','ValidPokeDur');
        InitParam(me,'DelayTone','ui','checkbox','value',1,'pref',1,'pos',[h+hs*5.9 n*vs hs*1 vs]);
        SetParamUI(me,'DelayTone','label','','string','Delay Tone'); 
        InitParam(me,'DelayOdor','ui','checkbox','value',0,'pref',0,'pos',[h+hs*6.7 n*vs hs*1 vs]);
        SetParamUI(me,'DelayOdor','label','','string','Delay Odor'); 
        InitParam(me,'VP_Odor','ui','popupmenu','list',{'no odor' 'odor A' 'odor B'},'value',1,'user',[0 2^2+2^3 2^2+2^4],'pos',[h+hs*7.5 n*vs hs*.8 vs]);
        SetParamUI(me,'VP_Odor','label','VP_Odor');
        
        n=n+1;
        InitParam(me,'ValidScore','ui','disp','value',0,'pref',0,'pos',[h n*vs hs*.85 vs]); 
        SetParamUI(me,'ValidScore','label','Valid Score');
        InitParam(me,'LeftHit','ui','disp','value',0,'pref',0,'pos',[h+hs*1.8 n*vs hs*.5 vs]); 
        SetParamUI(me,'LeftHit','label','Left Hit');
        InitParam(me,'RightHit','ui','disp','value',0,'pref',0,'pos',[h+hs*3 n*vs hs*.6 vs]); 
        SetParamUI(me,'RightHit','label','Right Hit');
        InitParam(me,'WaterAvailDur','ui','edit','value',3,'pos',[h+hs*4.3 n*vs hs*.7 vs]);
        SetParamUI(me,'WaterAvailDur','label','WaterAvailDur');
        InitParam(me,'DelaySchedule','ui','disp','value',0,'pref',0,'user',[],'pos',[h+hs*5.9 n*vs hs*.7 vs]); 
        SetParamUI(me,'DelaySchedule','label','Delay (ms)');
        InitParam(me,'TimeOut','ui','edit','value',6,'pos',[h+hs*7.5 n*vs hs*.8 vs]); 
        SetParamUI(me,'TimeOut','label','TimeOut');

        
        n=n+1;
        InitParam(me,'RecentScore','ui','disp','value',0,'pref',0,'pos',[h n*vs hs*.85 vs]); 
        SetParamUI(me,'RecentScore','label','Recent Score =>');
        InitParam(me,'rLeftScore','ui','disp','value',0,'pref',0,'pos',[h+hs*1.8 n*vs hs*.5 vs]); 
        SetParamUI(me,'rLeftScore','label','rLeftScore');
        InitParam(me,'rRightScore','ui','disp','value',0,'pref',0,'pos',[h+hs*3 n*vs hs*.6 vs]); 
        SetParamUI(me,'rRightScore','label','rRightScore');
        InitParam(me,'RecentHistory','ui','edit','value',20,'pos',[h+hs*4.3 n*vs hs*.7 vs]); 
        SetParamUI(me,'RecentHistory','label','Recent History'); 
        InitParam(me,'maxRndDelay','ui','edit','value',150,'pos',[h+hs*5.9 n*vs hs*.7 vs]); 
        SetParamUI(me,'maxRndDelay','label','maxRndDelay');
        InitParam(me,'BlockLength','ui','edit','value',50,'pos',[h+hs*7.5 n*vs hs*.8 vs]); 
        SetParamUI(me,'BlockLength','label','Block Lgth');
        
        n=n+1;
        InitParam(me,'TotalScore','ui','disp','value',0,'pref',0,'pos',[h n*vs hs*.85 vs]); 
        SetParamUI(me,'TotalScore','label','Total Score');
        InitParam(me,'LeftScore','ui','disp','value',0,'pref',0,'pos',[h+hs*1.8 n*vs hs*.5 vs]); 
        SetParamUI(me,'LeftScore','label','Left Score');
        InitParam(me,'RightScore','ui','disp','value',0,'pref',0,'pos',[h+hs*3 n*vs hs*.6 vs]); 
        SetParamUI(me,'RightScore','label','Right Score');
        InitParam(me,'DirectDelivery','ui','edit','value',0,'pos',[h+hs*4.3 n*vs hs*.7 vs]); 
        SetParamUI(me,'DirectDelivery','label','Direct Delivery');
        InitParam(me,'minRndDelay','ui','edit','value',50,'pos',[h+hs*5.9 n*vs hs*.7 vs]); 
        SetParamUI(me,'minRndDelay','label','minRndDelay');
        InitParam(me,'Script','ui','popupmenu','list',ScriptList,'value',1,'pos',[h+hs*7.5 n*vs hs*.8 vs]);
        SetParamUI(me,'Script','label','add. Script');
        
        n=n+1;
        InitParam(me,'ToneSet','ui','popupmenu','list',Ratio_Str,'value',4,'user',4,'pref',0,'pos',[h n*vs hs*.85 vs]);
        SetParamUI(me,'ToneSet','label','Tn Ratio Setting');
        InitParam(me,'LeftToneFreq','ui','popupmenu','list',FL,'value',lc,'user',lc,'pref',0,'pos',[h+hs*1.8 n*vs hs*.5 vs]);
        SetParamUI(me,'LeftToneFreq','label','Left Freq');
        InitParam(me,'RightToneFreq','ui','popupmenu','list',FL,'value',rc,'user',rc,'pref',0,'pos',[h+hs*3 n*vs hs*.6 vs]);
        SetParamUI(me,'RightToneFreq','label','Right Freq');
        InitParam(me,'SameSideLimit','ui','edit','value',Inf,'pos',[h+hs*4.3 n*vs hs*.7 vs]); 
        SetParamUI(me,'SameSideLimit','label','SameSideLimit');         
        InitParam(me,'ToneDelay','ui','edit','value',50,'pos',[h+hs*5.9 n*vs hs*.7 vs]); 
        SetParamUI(me,'ToneDelay','label','ToneDelay'); 
        InitParam(me,'ITI','ui','edit','value',1,'pos',[h+hs*7.5 n*vs hs*.8 vs]); 
        SetParamUI(me,'ITI','label','ITI');
        
        n=n+1.1;
        % message box
        uicontrol(fig,'tag','message','style','edit',...
            'enable','inact','horiz','left','pos',[h n*vs hs*1.9 vs]);
        InitParam(me,'Miss_Correction','ui','radiobutton','value',0,'pref',0,'pos',[h+hs*2 n*vs hs*.425 vs]);
        SetParamUI(me,'Miss_Correction','label','','string','miss'); 
        InitParam(me,'False_Correction','ui','radiobutton','value',0,'pref',0,'pos',[h+hs*2.425 n*vs hs*.45 vs]);
        SetParamUI(me,'False_Correction','label','','string','false'); 
        InitParam(me,'Abort_Correction','ui','radiobutton','value',0,'pref',0,'pos',[h+hs*2.875 n*vs hs*1.4 vs]);
        SetParamUI(me,'Abort_Correction','label','','string','abort Correction in next'); 
        InitParam(me,'CorrectionTrial','ui','edit','value',5,'pref',0,'range',[1 10],'pos',[h+hs*4.2 n*vs hs*.25 vs]);
        SetParamUI(me,'CorrectionTrial','label','trials');
        InitParam(me,'ChangeSchedule','ui','pushbutton','value',0,'pref',0,'pos',[h+hs*5 n*vs hs*.75 vs]);
        SetParamUI(me,'ChangeSchedule','label','','string','New Schedule'); 

        InitParam(me,'FixedDelay','ui','checkbox','value',1,'pref',0,'pos',[h+hs*5.9 n*vs hs*.8 vs]);
        SetParamUI(me,'FixedDelay','label','','string','FixedDelay','callback',['SetParam(''' mfilename ''',''RandomDelay'',GetParam(''' mfilename ''',''FixedDelay''));FigHandler']); 
        InitParam(me,'RandomDelay','ui','checkbox','value',0,'pref',0,'pos',[h+hs*6.7 n*vs hs*.8 vs]);
        SetParamUI(me,'RandomDelay','label','','string','Rnd Delay','callback',['SetParam(''' mfilename ''',''FixedDelay'',GetParam(''' mfilename ''',''RandomDelay''));FigHandler']); 
        InitParam(me,'ClearScore','ui','checkbox','value',1,'pref',0,'pos',[h+hs*7.5 n*vs hs*.8 vs]);
        SetParamUI(me,'ClearScore','label','','string','Clear Score'); 
        
        n=n+1.5;
        InitParam(me,'Stim_Disp','ui','disp','user',Str,'value',Str{1},'pref',0,'pos',[h n*vs hs*1.1 vs]); 
        SetParamUI(me,'Stim_Disp','label','','HorizontalAlignment','Left');        
        InitParam(me,'PlotAxes_Back','value',0,'user',0);
        InitParam(me,'PlotAxes_Forward','value',0,'user',0);
        InitParam(me,'SetPlotAxes_Back2Start','ui','pushbutton','value',0,'pref',0,'pos',[h+hs*1.3 n*vs hs*.5 vs]);
        SetParamUI(me,'SetPlotAxes_Back2Start','label','','string','|<<');
        InitParam(me,'SetPlotAxes_Back','ui','pushbutton','value',0,'pref',0,'pos',[h+hs*1.8 n*vs hs*.5 vs]);
        SetParamUI(me,'SetPlotAxes_Back','label','','string','<');
        InitParam(me,'SetPlotAxes_Default','ui','pushbutton','value',0,'pref',0,'pos',[h+hs*5.4 n*vs hs*.5 vs]);
        SetParamUI(me,'SetPlotAxes_Default','label','','string','< reset >');
        InitParam(me,'SetPlotAxes_Forward','ui','pushbutton','value',0,'pref',0,'pos',[h+hs*7.5 n*vs hs*.5 vs]);
        SetParamUI(me,'SetPlotAxes_Forward','label','','string','>');
        InitParam(me,'SetPlotAxes_Forward2End','ui','pushbutton','value',0,'pref',0,'pos',[h+hs*8 n*vs hs*.5 vs]);
        SetParamUI(me,'SetPlotAxes_Forward2End','label','','string','>>|');
        
        InitParam(me,'Trial_Events','value',[],'trial',[]);
        InitParam(me,'WaterPort','value',Port);
        InitParam(me,'OdorChannel','value',OdorCh);
        InitParam(me,'ToneRatio','value',Ratio{GetParam(me,'ToneSet')}/sum(Ratio{GetParam(me,'ToneSet')}),'user',Ratio);
        tone_list=[];
        tone_list_n=[];
        for i=[1,3,2]   %Right Port==1, Left Port==2, Both ==3
            tone_list     =[tone_list find(Port==i)];
            tone_list_n   =[tone_list_n length(find(Port==i))];
        end
        InitParam(me,'Tone_list','value',tone_list,'user',tone_list_n);
        [Y,I]=sort(tone_list);
        nGrpLst=length(JntGrp);
        for i=1:nGrpLst
            JntGrp{i}=reshape(I(JntGrp{i}),size(JntGrp{i}));
        end
        
        BlankSchedule=zeros(1,GetParam(me,'MaxTrial'));
        InitParam(me,'ToneFreq','value',BlankSchedule,'user',Freq);
        InitParam(me,'ToneDur','value',BlankSchedule,'user',Dur);
        InitParam(me,'ToneSPL','value',BlankSchedule,'user',SPL);
        InitParam(me,'Schedule','value',BlankSchedule);        
        InitParam(me,'ToneSchedule','value',BlankSchedule);
        InitParam(me,'DelaySchedule','user',BlankSchedule);
        InitParam(me,'Port_Side','value',BlankSchedule);
        InitParam(me,'Result','value',BlankSchedule);
        InitParam(me,'TonePokeDur','value',BlankSchedule);
        InitParam(me,'nTonePoke','value',BlankSchedule);
        InitParam(me,'JntGroup','value',JntGrp);
        InitParam(me,'JntGrpXTitle','value',JntGrpXTitle);
        
        InitParam(me,'Beep','value',[]);
        beep=InitTones;
        InitParam(me,'vp_sound','value',[]);        
        vp_sound=InitVP_Sound;
        change_schedule;
        rpbox('InitRPSound');
        ToneSchedule=GetParam(me,'ToneSchedule');
        next_tone=ToneSchedule(GetParam(me,'CountedTrial')+1);
        rpbox('LoadRPSound',{beep{next_tone}+fresh_wn(next_tone),vp_sound{GetParam(me,'VP_Signal')}});
        rpbox('send_matrix', [0 0 0 0 0 0 0 180 0 0]);
        rpbox('send_matrix',state_transition_matrix);
        
        set(fig,'pos',[140 100 hs*9 (n+26)*vs],'visible','on');
        update_plot;
        
    case 'trialend'
        
    case 'reset'
        Message('control','wait for RP (RP2/RM1) reseting');
        if Getparam(me,'ClearScore')
            clear_score;
        end
        SetParam(me,'Trial_Events','value',[],'trial',[]);
        BlankSchedule=zeros(1,GetParam(me,'MaxTrial'));
        SetParam(me,'Schedule','value',BlankSchedule);
        SetParam(me,'ToneFreq','value',BlankSchedule);
        SetParam(me,'ToneDur','value',BlankSchedule);
        SetParam(me,'ToneSPL','value',BlankSchedule);
        SetParam(me,'Port_Side','value',BlankSchedule);
        SetParam(me,'Result','value',BlankSchedule);
        SetParam(me,'TonePokeDur','value',BlankSchedule);
        SetParam(me,'nTonePoke','value',BlankSchedule);
        change_schedule(GetParam(me,'MaxTrial'));
        update_plot;
        rpbox('InitRPSound');
        rpbox('send_matrix', [0 0 0 0 0 0 0 180 0 0]);
        rpbox('send_matrix',state_transition_matrix);
        beep=GetParam(me,'beep');
        vp_sound=GetParam(me,'vp_sound');
        eval([me '(''script'')']);
        ToneSchedule=GetParam(me,'ToneSchedule');
        next_tone=ToneSchedule(GetParam(me,'CountedTrial')+1);
        rpbox('LoadRPSound',{beep{next_tone}+fresh_wn(next_tone),vp_sound{GetParam(me,'VP_Signal')}});
        Message('control','');
              
    case {'lwatervalvedur' 'rwatervalvedur'}
        rpbox('send_matrix',state_transition_matrix);
        
    case 'toneset'
        setting=GetParam(me,'ToneSet');
        Ratio=GetParam(me,'ToneRatio','user');
        SetParam(me,'ToneRatio','value',Ratio{setting}/sum(Ratio{setting}));
        eval([me '(''changeschedule'')']);
        
    case {'lefttonefreq' , 'righttonefreq'}
        FC  =[500 1000 2000 3000 5000 7000 9000 11000 13000 15000 17000 23000];   % frequency of choice, Hz
        FL ={'500','1k','2k','3k','5k','7k','9k','11k','13k','15k','17k','23k'};  % list of frequency of choice
        rc=Getparam(me,'RightToneFreq');
        lc=Getparam(me,'leftToneFreq');;
        rf=FC(rc);
        lf=FC(lc);
        rl=FL{rc};
        ll=FL{lc};
        Freq  =[rf   2345    lf      rf        rf        lf    lf     rf  2345   lf ];  %Hz
        Str   ={[rl ' 60dB 200ms'],'Odor B 200ms',['Odor B &' ll ' 200ms'],['Odor B &' rl ' 200ms'],['Odor A &' rl ' 200ms'],['Odor B &' ll ' 200ms'],['Odor A &' ll ' 200ms'],['Odor A &' rl ' 200ms'],'Odor A 200ms',[ll ' 60dB 200ms']};
        Ratio_Str ={'Olfactory','Odor A','Odor B','Auditory',[ll 'Hz tone'],[rl 'Hz tone'],'AvBv[ ] w/tone','A or B w/tone','odor A w/tone','odor B w/tone','odor/tone=2:3','odor/tone=1:1','Auditory w/odor'}; 

        BlankSchedule=zeros(1,GetParam(me,'MaxTrial'));
        SetParam(me,'ToneFreq','user',Freq);
        SetParam(me,'ToneSet','list',Ratio_Str);
        SetParam(me,'Stim_Disp','user',Str); 
        InitTones;
        eval([me '(''changeschedule'')']);
        
    case 'vp_signal'
        if GetParam(me,'VP_Signal')>1
            SetParam(me,'Tn_for_VP',0);
            SetParam(me,'VP_Signal','user',GetParam(me,'VP_Signal'))
        end
        beep=GetParam(me,'beep');
        vp_sound=GetParam(me,'vp_sound');
        ToneSchedule=GetParam(me,'ToneSchedule');
        next_tone=ToneSchedule(GetParam(me,'CountedTrial')+1);
        rpbox('LoadRPSound',{beep{next_tone}+fresh_wn(next_tone),vp_sound{GetParam(me,'VP_Signal')}});
        
    case 'tn_for_vp'
        if GetParam(me,'Tn_for_VP')
            SetParam(me,'VP_Signal',1);
        else
            SetParam(me,'VP_Signal',GetParam(me,'VP_Signal','user'));
        end
        eval([me '(''vp_signal'')']);
        
    case 'wn_level'
        beep=GetParam(me,'beep');
        vp_sound=GetParam(me,'vp_sound');
        ToneSchedule=GetParam(me,'ToneSchedule');
        next_tone=ToneSchedule(GetParam(me,'CountedTrial')+1);
        rpbox('LoadRPSound',{beep{next_tone}+fresh_wn(next_tone),vp_sound{GetParam(me,'VP_Signal')}});        
        
    case {'init_schedule','changeschedule'}
        change_schedule;
        if ~getparam('rpbox','run')
            rpbox('send_matrix',state_transition_matrix);
            beep=GetParam(me,'beep');
            ToneSchedule=GetParam(me,'ToneSchedule');
            rpbox('LoadRPSound',{beep{ToneSchedule(GetParam(me,'CountedTrial')+1)}});
        end
        update_plot;
        
    case 'setplotaxes_back2start'
        SetParam(me,'PlotAxes_Back',GetParam(me,'MaxTrial'));
        update_plot;
    case 'setplotaxes_back'
        SetParam(me,'PlotAxes_Back',GetParam(me,'PlotAxes_Back')+50);
        update_plot;
    case 'setplotaxes_default'
        SetParam(me,'PlotAxes_Back',0);
        SetParam(me,'PlotAxes_Forward',0);
        update_plot;
    case 'setplotaxes_forward'        
        SetParam(me,'PlotAxes_Forward',GetParam(me,'PlotAxes_Forward')+50);
        update_plot;
    case 'setplotaxes_forward2end'        
        SetParam(me,'PlotAxes_Forward',GetParam(me,'MaxTrial'));
        update_plot;
        
    case 'update'
        update_event;
    case 'state35'
        update_event;
        CountedTrial    =GetParam(me,'CountedTrial')+1;
        Result          =GetParam(me,'Result');        
        New_Events      =GetParam(me,'Trial_Events','value');
        Trial_Events    =GetParam(me,'Trial_Events','trial');        
        RightHit=GetParam(me,'RightHit');
        LeftHit=GetParam(me,'LeftHit');
        RightAbort=GetParam(me,'RightAbort');
        LeftAbort=GetParam(me,'LeftAbort');
        RightMiss=GetParam(me,'RightMiss');
        LeftMiss=GetParam(me,'LeftMiss');
        RightFalse=GetParam(me,'RightFalse');
        LeftFalse=GetParam(me,'LeftFalse');
        Port_Side       =GetParam(me,'Port_Side');        
        pts             =Port_Side(CountedTrial);         % water port_side 1:Right, 2:Left, 3:Both
        
        SetParam(me,'TotalScore',(RightHit+LeftHit)/(RightHit+LeftHit+RightMiss+LeftMiss+RightFalse+LeftFalse+RightAbort+LeftAbort));
        SetParam(me,'ValidScore',(RightHit+LeftHit)/(RightHit+LeftHit+RightMiss+LeftMiss+RightFalse+LeftFalse));
        SetParam(me,'RightScore',RightHit/(RightHit+RightMiss+RightFalse+RightAbort));
        SetParam(me,'LeftScore',LeftHit/(LeftHit+LeftMiss+LeftFalse+LeftAbort));
        
        RcntHis=GetParam(me,'RecentHistory');         
        rcnt_trial=max(1,CountedTrial-RcntHis):CountedTrial;
        rRightHit   =size(find(Result(rcnt_trial)==1 & Port_Side(rcnt_trial)==1),2);
        rLeftHit    =size(find(Result(rcnt_trial)==1 & Port_Side(rcnt_trial)==2),2);
        rRightScore =rRightHit/size(find(Port_Side(rcnt_trial)==1),2);
        rLeftScore  =rLeftHit/size(find(Port_Side(rcnt_trial)==2),2);
        SetParam(me,'rRightScore',rRightScore);
        SetParam(me,'rLeftScore',rLeftScore);
        SetParam(me,'RecentScore',(rRightHit+ rLeftHit)/length(rcnt_trial) );
        
        SetParam(me,'CountedTrial',CountedTrial);
        SetParam(me,'Trial_Events','trial',[Trial_Events {New_Events} ]);
        SetParam(me,'Trial_Events','value',[]);
        eval([me '(''script'')']);
        ToneSchedule=GetParam(me,'ToneSchedule');
        Schedule=GetParam(me,'Schedule');
        ToneFreq = GetParam(me,'ToneFreq');
        ToneDur  = GetParam(me,'ToneDur');
        ToneSPL  = GetParam(me,'ToneSPL');
        Port_Side       =GetParam(me,'Port_Side');        
        if (GetParam(me,'False_Correction') & Result(CountedTrial)==2)|(GetParam(me,'Miss_Correction') & Result(CountedTrial)==3)|...
                (GetParam(me,'Abort_Correction') & Result(CountedTrial)==4)
            Delay_correction=ceil(rand*GetParam(me,'CorrectionTrial'));
            Schedule(CountedTrial+Delay_correction)=Schedule(CountedTrial);
            Port_Side(CountedTrial+Delay_correction)=pts;
            ToneFreq(CountedTrial+Delay_correction)=ToneFreq(CountedTrial);
            ToneDur(CountedTrial+Delay_correction) =ToneDur(CountedTrial);
            ToneSPL(CountedTrial+Delay_correction) =ToneSPL(CountedTrial);
            ToneSchedule(CountedTrial+Delay_correction)=ToneSchedule(CountedTrial);            
            SetParam(me,'ToneSchedule',ToneSchedule);
            SetParam(me,'Schedule',Schedule);
            SetParam(me,'Port_Side',Port_Side);
            SetParam(me,'ToneFreq',ToneFreq);
            SetParam(me,'ToneDur',ToneDur);
            SetParam(me,'ToneSPL',ToneSPL);
        end
        beep=GetParam(me,'beep');
        next_tone=ToneSchedule(CountedTrial+1);
        rpbox('LoadRPSound',{beep{next_tone}+fresh_wn(next_tone)});
        update_plot;
        rpbox('send_matrix',state_transition_matrix);
        
    case 'script'
        CountedTrial = GetParam(me,'CountedTrial')+getparam('rpbox','run')+ (GetParam(me,'CountedTrial')==0);
        if GetParam(me,'Script')==2
            if  mod(ceil(CountedTrial/GetParam(me,'BlockLength')),2) & GetParam(me,'ToneSet')~=5
                SetParam(me,'ToneSet',5);
                eval([me '(''toneset'')']);
            elseif ~mod(ceil(CountedTrial/GetParam(me,'BlockLength')),2) & GetParam(me,'ToneSet')~=6
                SetParam(me,'ToneSet',6);
                eval([me '(''toneset'')']);
            end        
        elseif GetParam(me,'Script')==3
            if  mod(ceil(CountedTrial/GetParam(me,'BlockLength')),2) & GetParam(me,'ToneSet')~=6
                SetParam(me,'ToneSet',6);
                eval([me '(''toneset'')']);
            elseif ~mod(ceil(CountedTrial/GetParam(me,'BlockLength')),2) & GetParam(me,'ToneSet')~=5
                SetParam(me,'ToneSet',5);
                eval([me '(''toneset'')']);
            end
        elseif GetParam(me,'Script')==4
            if  mod(ceil(CountedTrial/GetParam(me,'BlockLength')),2) & GetParam(me,'ToneSet')~=2
                SetParam(me,'ToneSet',2);
                eval([me '(''toneset'')']);
            elseif ~mod(ceil(CountedTrial/GetParam(me,'BlockLength')),2) & GetParam(me,'ToneSet')~=3
                SetParam(me,'ToneSet',3);
                eval([me '(''toneset'')']);
            end        
        elseif GetParam(me,'Script')==5
            if  mod(ceil(CountedTrial/GetParam(me,'BlockLength')),2) & GetParam(me,'ToneSet')~=3
                SetParam(me,'ToneSet',3);
                eval([me '(''toneset'')']);
            elseif ~mod(ceil(CountedTrial/GetParam(me,'BlockLength')),2) & GetParam(me,'ToneSet')~=2
                SetParam(me,'ToneSet',2);
                eval([me '(''toneset'')']);
            end
        elseif GetParam(me,'Script')==6
            if  mod(ceil(CountedTrial/GetParam(me,'BlockLength')),2) & GetParam(me,'ToneSet')~=1
                SetParam(me,'ToneSet',1);
%                 SetParam(me,'ValidTonePokeDur',0.1);
                eval([me '(''toneset'')']);
            elseif ~mod(ceil(CountedTrial/GetParam(me,'BlockLength')),2) & GetParam(me,'ToneSet')~=4
                SetParam(me,'ToneSet',4);
%                 SetParam(me,'ValidTonePokeDur',0.03);
                eval([me '(''toneset'')']);
            end
        elseif GetParam(me,'Script')==7
            if  mod(ceil(CountedTrial/GetParam(me,'BlockLength')),2) & GetParam(me,'ToneSet')~=4
                SetParam(me,'ToneSet',4);
%                 SetParam(me,'ValidTonePokeDur',0.03);
                eval([me '(''toneset'')']);
            elseif ~mod(ceil(CountedTrial/GetParam(me,'BlockLength')),2) & GetParam(me,'ToneSet')~=1
                SetParam(me,'ToneSet',1);
%                 SetParam(me,'ValidTonePokeDur',0.1);
                eval([me '(''toneset'')']);
            end
        elseif GetParam(me,'Script')==8
            if  mod(ceil(CountedTrial/GetParam(me,'BlockLength')),2) & GetParam(me,'ToneSet')~=4
                SetParam(me,'ToneSet',4);
                SetParam(me,'RandomDelay',1);
                SetParam(me,'FixedDelay',0);
                eval([me '(''toneset'')']);
            elseif ~mod(ceil(CountedTrial/GetParam(me,'BlockLength')),2) & GetParam(me,'ToneSet')~=8
                SetParam(me,'ToneSet',8);
                SetParam(me,'RandomDelay',0);
                SetParam(me,'FixedDelay',1);
                eval([me '(''toneset'')']);
            end        
        end
        
    case 'restore'
        var=lower(...
            {'LastTonePokeDur'  'LeftAbort'  'RightAbort'  'lWaterValveDur' 'rWaterValveDur' ...
                'FirstTonePokeDur' 'LeftFalse'  'RightFalse'  'ValidTonePokeDur'...
                'CountedTrial'     'LeftMiss'   'RightMiss'   'WaterAvailDur'...
                'ValidScore'       'LeftHit'    'RightHit'    'DirectDelivery'   'maxRndDelay'...
                'RecentScore'      'rLeftScore' 'rRightScore' 'RecentHistory'    'minRndDelay'...
                'TotalScore'       'LeftScore'  'RightScore'  'SameSideLimit'    'ToneDelay'});
        for i=1:length(var)
            Setparam(me,var{i},'h',findobj('tag',var{i},'style','edit'));
        end
        
    case 'close'
        SetParam('rpbox','protocols',1);
    otherwise
        out=0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=InitTones

FilterPath=[GetParam('rpbox','protocol_path') '\PPfilter.mat'];
if ( size(dir(FilterPath),1) == 1 )
    PP=load(FilterPath);
    PP=PP.PP;
    message(me,'PPfilter found! Generating Calibrated Tones');
else
    PP=[];
    message(me,'Generating Non-calibrated Tones');
end

Freq=GetParam(me,'ToneFreq','user');
Dur=GetParam(me,'ToneDur','user');
SPL=GetParam(me,'ToneSPL','user');
n_tones=length(Freq);
ToneAttenuation = ones(1,n_tones)*70 -SPL;

for tn=1:n_tones
    if isempty(PP) | Freq(tn)== -1
        ToneAttenuation_adj = ToneAttenuation(tn);
    else
        ToneAttenuation_adj = ToneAttenuation(tn) - ppval(PP, log10(Freq(tn)));
        % Remove any negative attenuations and replace with zero attenuation.
        ToneAttenuation_adj = ToneAttenuation_adj .* (ToneAttenuation_adj > 0);
    end
    beep{tn}  = 1 * makebeep(50e6/1024, ToneAttenuation_adj ,Freq(tn), Dur(tn),3);
end
SetParam(me,'beep',beep);
out=beep;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=fresh_wn(next_tone)

Dur=GetParam(me,'ToneDur','user');
WN_SPL =GetParam(me,'WN_SPL');
OdorCh =GetParam(me,'OdorChannel');
OdorCh =OdorCh(next_tone);
if OdorCh & ~GetParam(me,'WN_for_Odor')
    wn  = 1 * makebeep(50e6/1024, 200 ,-1, Dur(next_tone),3);
else
    Attenuation = 70 - WN_SPL(GetParam(me,'wn_level'));
    wn  = 1 * makebeep(50e6/1024, Attenuation ,-1, Dur(next_tone),3);
end
out=wn;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function out=state_transition_matrix
% varargin={vpd,wad,pts,tnd,tmo}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
% the columns of the transition matrix represent inputs
% Cin,Cout,Lin,Lout,Rin, Rout, Times-up
% The rows are the states (from Staet 0 upto 32)
% The timer is in unit of seconds, # of columns >= # of states
% DIO output in "word" format, 1=DIO-0_ON, 8=DIO-3_ON (DIO-0~8) 
% AO output in "word" format, 1=AO-1_ON, 3=AO-1,2_ON,  (AO-1,2)

CountedTrial = GetParam(me,'CountedTrial')+1;
dd=(GetParam(me,'DirectDelivery')>CountedTrial)*3;
vpd=GetParam(me,'ValidTonePokeDur');
if vpd < 0.001 % vpd has to be larger than the sampling reate of RPDevice
    vpd=0.001;  % sec
end
wad=GetParam(me,'WaterAvailDur');
Port_Side=GetParam(me,'Port_Side'); 
pts=Port_Side(CountedTrial);         % water port_side 1:Right, 2:Left, 3:Both
ToneSchedule=GetParam(me,'ToneSchedule');
DelaySchedule=GetParam(me,'DelaySchedule','user');
och=GetParam(me,'OdorChannel');
och=och(ToneSchedule((CountedTrial)));
odr=och + (2^2)*(och>0)
dlo=GetParam(me,'DelayOdor');
dlo=odr*(~dlo);
vpo_ch=GetParam(me,'VP_Odor','user');
vpo=vpo_ch(GetParam(me,'VP_Odor'));
dlt=GetParam(me,'DelayTone');
dlt=1*(~dlt);
tnd=GetParam(me,'ToneDur');
tnd=tnd(CountedTrial)/1000;
iti=GetParam(me,'ITI');
tmo=GetParam(me,'TimeOut');
lvd=GetParam(me,'lWaterValveDur');
rvd=GetParam(me,'rWaterValveDur');

ltd=(tnd-vpd);  %leftover tone duration
ltd=ltd*(ltd>0);
if  0 < ltd & ltd < 0.001  % ltd has to be larger than the sampling reate of RPDevice
    ltd=0.001;  % sec
end
dly=0.001;
if GetParam(me,'FixedDelay')
    dly=GetParam(me,'ToneDelay')/1000;
elseif GetParam(me,'RandomDelay')
    dly=(GetParam(me,'minRndDelay')+exp(-rand)*(GetParam(me,'maxRndDelay')-GetParam(me,'minRndDelay'))/(exp(1)-1))/1000;
end
DelaySchedule(CountedTrial)=dly;
SetParam(me,'DelaySchedule','value',dly*1000,'user',DelaySchedule);


vpt=GetParam(me,'Tn_for_VP');

if pts+dd==1
    state_transition_matrix=[ ...                               % Right Side Water Port
    %  Cin Cout Lin Lout Rin Rout TimeUp        Timer DIO  AO  
        0    0   0    0   0    0    1           iti   0    0;   % State  0 "ITI-State"
        2    1   1    1   1    1    1           180   0    0;   % State  1 "Pre-State"
        2    8   2    2   2    2    3           dly   dlo dlt;  % State  2 "Center Poke in, before tone on"
        3    8   3    3   3    3    4+(ltd==0)  vpd   odr  1;   % State  3 "tone on"
        4    5   8    4   7    4    5           ltd   odr  1;   % State  4 "pre- Center Poke out"
        6    6   9    5   7    5   10           wad   vpo  2;   % State  5 "Valid Poke Signal"
        6    6   9    6   7    6   10           wad   0    2;   % State  6 "Reward Avaiable Dur"
        7    7   7    7   7    7   35           rvd   2   vpt;  % State  7 "Valid Poke ==> Water!!! :)"
        8    8   8    8   8    8   35           tmo   0    0;   % State  8 "ShortPoke => Abort => House Light "
        9    9   9    9   9    9   35           tmo   0    0;   % State  9 "FalsePoke, wrong side => House Light "
       10   10  10   10  10   10   35           tmo   0    0;]; % State 10 "ValidTonePoke but missed reward => House Light "
elseif pts+dd==2
    state_transition_matrix=[ ...                               % Left Side Water Port
    %  Cin Cout Lin Lout Rin Rout TimeUp        Timer DIO  AO  
        0    0   0    0   0    0   11           iti   0    0;   % State 0 "ITI-State"
        zeros(10,10);
       12   11  11   11  11   11   11           180   0    0;   % State 11 "Pre-State"
       12   18  12   12  12   12   13           dly   dlo dlt;  % State 12 "Center Poke in, before tone on"
       13   18  13   13  13   13   14+(ltd==0)  vpd   odr  1;   % State 13 "tone on"
       14   15  17   14  19   14   15           ltd   odr  1;   % State 14 "pre- Center Poke out"
       16   16  17   15  19   15   20           wad   vpo  2;   % State 15 "Reward Avaiable Dur"
       16   16  17   16  19   16   20           wad   0    2;   % State 16 "Reward Avaiable Dur"
       17   17  17   17  17   17   35           lvd   1   vpt;  % State 17 "Valid Poke ==> Water!!! :)"
       18   18  18   18  18   18   35           tmo   0    0;   % State 18 "ShortPoke => Abort => House Light "
       19   19  19   19  19   19   35           tmo   0    0;   % State 19 "FalsePoke, wrong side => House Light "
       20   20  20   20  20   20   35           tmo   0    0;]; % State 20 "ValidTonePoke but missed reward => House Light "
elseif pts+dd==3	
    state_transition_matrix=[ ...                               % Both Side Water Port
     %  Cin Cout Lin Lout Rin Rout TimeUp        Timer DIO AO  
        0    0   0    0   0    0   21           iti   0    0;   % State 0 "ITI-State"
        zeros(20,10);
       22   21  21   21  21   21   21           180   0    0;   % State 21 "Pre-State"
       22   29  22   22  22   22   23           dly   dlo dlt;  % State 22 "Center Poke in, before tone on"
       23   29  23   23  23   23   24+(ltd==0)  vpd   odr  1;   % State 23 "tone on"
       24   25  27   24  28   24   25           ltd   odr  1;   % State 24 "pre- Center Poke out"
       26   26  27   25  28   25   31           wad   vpo  2;   % State 25 "Reward Avaiable Dur"
       26   26  27   26  28   26   31           wad   0    2;   % State 26 "Reward Avaiable Dur"
       27   27  27   27  27   27   35           lvd   1   vpt;  % State 27 "Valid Poke ==> Water!!! :)"
       28   28  28   28  28   28   35           rvd   2   vpt;  % State 28 "Valid Poke ==> Water!!! :)"
       29   29  29   29  29   29   35           tmo   0    0;   % State 29 "ShortPoke => Abort => House Light "
       30   30  30   30  30   30   35           tmo   0    0;   % State 30 "FalsePoke, wrong side => House Light "
       31   31  31   31  31   31   35           tmo   0    0;]; % State 31 "ValidTonePoke but missed reward => House Light "
elseif pts+dd==4
    state_transition_matrix=[ ...                               % Right Side Water Port direct delivery
    %  Cin Cout Lin Lout Rin Rout TimeUp        Timer DIO  AO  
        1    0   0    0    0   0    0           iti   0    0;   % State 0 "ITI-State"
        2    1   1    1    1   1    1           180   0    0;   % State 1 "Pre-State"
        2    7   2    2    2   2    3           dly   dlo dlt;  % State 2 "Center Poke in, before tone on"
        3    7   3    3    3   3    4+(ltd==0)  vpd   odr  1;   % State 3 "tone on"
        4    5   8    0    5   0    5           ltd   odr  1;   % State 4 "pre- Center Poke out"
        5    5   5    5    5   5    6           rvd  2+vpo 2;   % State 5 "Valid Poke ==> Water!!! :)"
        6    6   6    6   35  35    9           wad   0   vpt;  % State 6 "rat finds Water!!! :)"
        7    7   7    7    7   7    0          .001   0    0;   % State 7 "ShortPoke => Abort"
        8    8   8    8    8   8    0          .001   0    0;   % State 8 "FalsePoke, wrong side "
        9    9   9    9    9   9    0          .001   0    0;]; % State 9 "ValidTonePoke but missed reward"
elseif pts+dd==5
    state_transition_matrix=[ ...                                % Left Side Water Port
     %  Cin Cout Lin Lout Rin Rout TimeUp        Timer DIO  AO  
        11    0   0    0   0    0    0           iti   0    0;   % State 0 "ITI-State"
        zeros(10,10);
        12   11  11   11  11   11   11           180   0    0;   % State 11 "Pre-State"
        12   17  12   12  12   12   13           dly   dlo dlt;  % State 12 "Center Poke in, before tone on"
        13   17  13   13  13   13   14+(ltd==0)  vpd   odr  1;   % State 13 "tone on"
        14   15  15    0  18    0   15           ltd   odr  1;   % State 14 "pre- Center Poke out"
        15   15  15   15  15   15   16           lvd  1+vpo 2;   % State 15 "Valid Poke ==> Water!!! :)"
        16   16  35   35  16   16   19           wad   0   vpt;  % State 16 "rat finds Water!!! :)"
        17   17  17   17  17   17    0          .001   0    0;   % State 17 "ShortPoke => Abort => House Light "
        18   18  18   18  18   18    0          .001   0    0;   % State 18 "FalsePoke, wrong side => House Light "
        19   19  19   19  19   19    0          .001   0    0;]; % State 19 "ValidTonePoke but missed reward => House Light "
elseif pts+dd==6	
    state_transition_matrix=[ ...                                % Both Side Water Port
     %  Cin Cout Lin Lout Rin Rout TimeUp        Timer DIO  AO  
        21    0   0    0   0    0    0           iti   0    0;   % State 0 "ITI-State"
        zeros(20,10);
        22   21  21   21  21   21   21           180   0    0;   % State 21 "Pre-State"
        22   27  22   22  22   22   23           dly   dlo dlt;  % State 22 "Center Poke in, before tone on"
        23   27  23   23  23   23   24+(ltd==0)  vpd   odr  1;   % State 23 "tone on"
        24   25  25    0  25    0   25           ltd   odr  1;   % State 24 "pre- Center Poke out"
        25   25  25   25  25   25   26    (rvd+lvd)/2 3+vpo 2;   % State 25 "Valid Poke ==> Water!!! :)"
        26   26  35   35  35   35   29           wad   0   vpt;  % State 26 "rat finds Water!!! :)"
        27   27  27   27  27   27    0          .001   0    0;   % State 27 "ShortPoke => Abort => House Light "
        28   28  28   28  28   28    0          .001   0    0;   % State 28 "FalsePoke, wrong side => House Light "
        29   29  29   29  29   29    0          .001   0    0;]; % State 29 "ValidTonePoke but missed reward => House Light "
end
out=state_transition_matrix;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function clear_score
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SetParam(me,'CountedTrial',0); 
SetParam(me,'LastTonePokeDur',0); 

SetParam(me,'TotalScore',0); 
SetParam(me,'RecentScore',0); 
SetParam(me,'rLeftScore',0); 
SetParam(me,'rRightScore',0); 

SetParam(me,'LeftScore',0); 
SetParam(me,'LeftHit',0); 
SetParam(me,'LeftMiss',0); 
SetParam(me,'LeftFalse',0); 
SetParam(me,'LeftAbort',0); 

SetParam(me,'RightScore',0); 
SetParam(me,'RightHit',0); 
SetParam(me,'RightMiss',0); 
SetParam(me,'RightFalse',0); 
SetParam(me,'RightAbort',0); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function update_event
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CountedTrial    =GetParam(me,'CountedTrial')+1;
dd=(GetParam(me,'DirectDelivery')>CountedTrial);
Trial_Events    =GetParam(me,'Trial_Events','value');
Result          =GetParam(me,'Result');
TonePokeDur     =GetParam(me,'TonePokeDur');
nTonePoke       =GetParam(me,'nTonePoke');
Port_Side       =GetParam(me,'Port_Side');        
pts             =Port_Side(CountedTrial);         % water port_side 1:Right, 2:Left, 3:Both
if dd
    rHit =[6 5;6 6;26 5;26 6];
    lHit =[16 3;16 4;26 3;26 4];
    rAbort =[0 0];
    lAbort =[0 0];
    bAbort =[0 0];
    lFalse =[0 0];
    rFalse =[0 0];
    rMiss =[0 0];
    lMiss =[0 0];
    bMiss =[0 0]; 
else
    rHit =[4 5;5 5;6 5;24 5;25 5;26 5];
    lHit =[14 3;15 3;16 3;24 3;25 3;26 3];
    rAbort =[2 2;3 2];
    lAbort =[12 2;13 2];
    bAbort =[22 2;23 2];
    lFalse =[4 3;5 3;6 3];
    rFalse =[14 5;15 5;16 5];
    rMiss =[5 7;  6 7];
    lMiss =[15 7;16 7];
    bMiss =[25 7;26 7]; 
end

Event=Getparam('rpbox','event','user'); % [state,chan,event time]
for i=1:size(Event,1)
    if Event(i,2)==1        %tone poke in
        if (Event(i,1:2)==[1 1] |Event(i,1:2)==[11 1] |Event(i,1:2)==[21 1] )& (CountedTrial-1)
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
            TonePokeDur(CountedTrial)=lastpkdur;
            SetParam(me,'TonePokeDur',TonePokeDur);
        end
        if sum(prod(repmat(Event(i,1:2),size(rAbort,1),1)==rAbort,2))
            Result(CountedTrial) =4;  % ShortPoke => Abort 
            message(me,['ShortPoke => RightAbort #' num2str(GetParam(me,'RightAbort')+1)],'green');
            SetParam(me,'RightAbort',GetParam(me,'RightAbort')+1);
            Trial_Events=[Trial_Events;Event(i,1:3)];
        elseif sum(prod(repmat(Event(i,1:2),size(lAbort,1),1)==lAbort,2))
            Result(CountedTrial) =4;  % ShortPoke => Abort 
            message(me,['ShortPoke => LeftAbort #' num2str(GetParam(me,'LeftAbort')+1)],'green');
            SetParam(me,'LeftAbort',GetParam(me,'LeftAbort')+1);
            Trial_Events=[Trial_Events;Event(i,1:3)];
        elseif sum(prod(repmat(Event(i,1:2),size(bAbort,1),1)==bAbort,2))
            Result(CountedTrial) =4;  % ShortPoke => Abort 
            message(me,['ShortPoke => Abort #' num2str(GetParam(me,'LeftAbort')+GetParam(me,'RightAbort'))],'green');            
            SetParam(me,'RightAbort',GetParam(me,'RightAbort')+.5);
            SetParam(me,'LeftAbort',GetParam(me,'LeftAbort')+.5);
            Trial_Events=[Trial_Events;Event(i,1:3)];
        end
    elseif Event(i,2)==3    %Left poke in
        if sum(prod(repmat(Event(i,1:2),size(lHit,1),1)==lHit,2))
            Result(CountedTrial) =1;  % Hit
            message(me,['Left Hit #' num2str(GetParam(me,'LeftHit')+1)],'cyan');
            SetParam(me,'LeftHit',GetParam(me,'LeftHit')+1);
            Trial_Events=[Trial_Events;Event(i,1:3)];
        elseif sum(prod(repmat(Event(i,1:2),size(lFalse,1),1)==lFalse,2))
            Result(CountedTrial) =2;  % FalsePoke, wrong side
            message(me,['Wrong side, FalsePoke #' num2str(GetParam(me,'LeftFalse')+1)],'red');
            SetParam(me,'LeftFalse',GetParam(me,'LeftFalse')+1);
            Trial_Events=[Trial_Events;Event(i,1:3)];
        end
    elseif Event(i,2)==4    %Left poke out
        
    elseif Event(i,2)==5    %Right poke in
        if sum(prod(repmat(Event(i,1:2),size(rHit,1),1)==rHit,2))
            Result(CountedTrial) =1;  % Hit
            message(me,['Right Hit #' num2str(GetParam(me,'RightHit')+1)],'cyan');            
            SetParam(me,'RightHit',GetParam(me,'RightHit')+1);
            Trial_Events=[Trial_Events;Event(i,1:3)];
        elseif sum(prod(repmat(Event(i,1:2),size(rFalse,1),1)==rFalse,2))
            Result(CountedTrial) =2;  % FalsePoke, wrong side
            message(me,['Wrong side, FalsePoke #' num2str(GetParam(me,'RightFalse')+1)],'red');            
            SetParam(me,'RightFalse',GetParam(me,'RightFalse')+1);
            Trial_Events=[Trial_Events;Event(i,1:3)];
        end
    elseif Event(i,2)==6    %Right poke out
        
    elseif Event(i,2)==7    % time up
        if sum(prod(repmat(Event(i,1:2),size(rMiss,1),1)==rMiss,2))
            Result(CountedTrial) =3;  % ValidTonePoke but missed reward
            message(me,'Missed reward');
            SetParam(me,'RightMiss',GetParam(me,'RightMiss')+1);
            Trial_Events=[Trial_Events;Event(i,1:3)];
        elseif sum(prod(repmat(Event(i,1:2),size(lMiss,1),1)==lMiss,2))
            Result(CountedTrial) =3;  % ValidTonePoke but missed reward
            message(me,'Missed reward');            
            SetParam(me,'LeftMiss',GetParam(me,'LeftMiss')+1);
            Trial_Events=[Trial_Events;Event(i,1:3)];
        elseif sum(prod(repmat(Event(i,1:2),size(bAbort,1),1)==bAbort,2))
            Result(CountedTrial) =3;  % ValidTonePoke but missed reward
            message(me,'Missed reward');
            SetParam(me,'RightMiss',GetParam(me,'RightMiss')+.5);
            SetParam(me,'LeftMiss',GetParam(me,'LeftMiss')+.5);            
            Trial_Events=[Trial_Events;Event(i,1:3)];
        end
    end
end
SetParam(me,'Result',Result);
SetParam(me,'nTonePoke',nTonePoke);
SetParam(me,'Trial_Events','value',Trial_Events);
Setparam('rpbox','event','user',[]);    %clearing events so it won't get counted twice

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function update_plot
global exper

fig = findobj('tag',me);
figure(fig);
h = findobj(fig,'tag','plot_schedule');
if ~isempty(h)
    axes(h);
    set(h,'pos',[0.15 0.31 0.8 0.26]);
else
    h = axes('tag','plot_schedule','pos',[0.15 0.31 0.8 0.26]);    
end
ToneSchedule=GetParam(me,'ToneSchedule');
Schedule=GetParam(me,'Schedule');
Result=GetParam(me,'Result');
CountedTrial = GetParam(me,'CountedTrial');
MaxTrial = GetParam(me,'MaxTrial');
plot([CountedTrial+1:MaxTrial],Schedule(CountedTrial+1:MaxTrial),'c.'); hold on
Hit=find(Result==1);
if Hit
    plot(Hit,Schedule(Hit),'b.');
end
false=find(Result==2);
if false
    plot(false,Schedule(false),'r.');
end
miss=find(Result==3);
if miss
    plot(miss,Schedule(miss),'bo');
end
abort=find(Result==4);
if abort
    plot(abort,Schedule(abort),'g.');
end

plot(CountedTrial+1,Schedule(CountedTrial+1),'or');
Str=GetParam(me,'Stim_Disp','user');
SetParam(me,'Stim_Disp',Str{ToneSchedule(CountedTrial+1)});
ax = axis;

tone_list=GetParam(me,'Tone_List');
tone_list_n=GetParam(me,'Tone_List','user');
cum_tone_list_n=cumsum(tone_list_n);
for i=1:2
    if cum_tone_list_n(i)*(cum_tone_list_n(i+1)-cum_tone_list_n(i))
        devide =cum_tone_list_n(i)+.5;
        plot([0 ax(2)],[devide devide],':k');
    end
end
hold off;
PlotAxes_Back   =GetParam(me,'PlotAxes_Back');
PlotAxes_Forward=GetParam(me,'PlotAxes_Forward');
axis([min(max(ceil((CountedTrial-90-PlotAxes_Back)/50)*50,0),max((MaxTrial-100-PlotAxes_Back),0)) ...
        min(max(ceil((CountedTrial+10+PlotAxes_Forward)/50)*50,100),MaxTrial) ax(3)-.3 ax(4)+.8]);
xlabel('Counted Trial');
ylabel_str={'Right <==','Both',' ==> Left'};

ylabel([[ylabel_str{find(tone_list_n)}] sprintf('\n') 'Tone/Odor Chan']);
Ratio=GetParam(me,'ToneRatio');
YTickLabel=[];
for i=1:length(tone_list)
    YTickLabel{i}=sprintf('%d(%2.0f%%)',tone_list(i),Ratio(tone_list(i))*100 );
end
set(h,'YTick', [1:length(tone_list)],'YTickLabel',YTickLabel);
set(h,'tag','plot_schedule');

%%%%%%%%%%%%%%%%% plot performance %%%%%%%%%%%%%%%%
h = findobj(fig,'tag','plot_performance');
if ~isempty(h)
    axes(h);
    set(h,'pos',[0.10 0.7 0.4 0.25]);
else
    h = axes('tag','plot_performance','pos',[0.10 0.7 0.4 0.25]);    
end

Valid_Performance=[];
if CountedTrial
    Performance=zeros(size(tone_list));
    Valid_Performance=Performance;
    Miss_Performance=Performance;
    False_Performance=Performance;
    Abort_Performance=Performance;
    n_Hit=Performance;
    n_Fls=Performance;
    n_Mis=Performance;
    n_Abt=Performance;
    n_trial=Performance;
    for i=1:length(tone_list)
        trial_idx=find(Schedule(1:CountedTrial)==i);
        n_trial(i)=length(trial_idx);
        n_Hit(i)=size(find(Result(trial_idx)==1),2);
        n_Fls(i)=size(find(Result(trial_idx)==2),2);
        n_Mis(i)=size(find(Result(trial_idx)==3),2);        
        n_Abt(i)=size(find(Result(trial_idx)==4),2);
        Performance(i)=n_Hit(i)/n_trial(i);
        Valid_Performance(i)=n_Hit(i)/ (n_trial(i)-n_Abt(i));
        False_Performance(i)=n_Fls(i)/ n_trial(i);
        Miss_Performance(i)=n_Mis(i)/ n_trial(i);
        Abort_Performance(i)=n_Abt(i)/ n_trial(i);
    end
    x=1:length(tone_list);
    plot(x,Performance,'b*',x,Valid_Performance,'c-',x,Miss_Performance,'bo',x,Abort_Performance,'g.',x,False_Performance,'r.');
end

axis([0.5 sum(tone_list_n)+.5 0 1]);
set(h,'XTick',[1:1:sum(tone_list_n)],'XTickLabel',tone_list);
xlabel([ sprintf('%6.2g',Valid_Performance)  sprintf('\n') 'Tone / Odro Ch.']);
ylabel(['Performance' sprintf('\n') 'Fraction correct']);
set(h,'tag','plot_performance');

% %%%%%%%%%%%%%%%%% plot joint performance %%%%%%%%%%%%%%%%
h = findobj(fig,'tag','plot_jnt_performance');
if ~isempty(h)
    axes(h);
    set(h,'pos',[0.6 0.7 0.35 0.25]);
else
    h = axes('tag','plot_jnt_performance','pos',[0.6 0.7 0.35 0.25]);
end
plot_performance=[];
if CountedTrial
    JntGrp=Getparam(me,'JntGroup');
    nGrpLst=length(JntGrp);
    for i=1:nGrpLst
        JntPerformance=mean(reshape(Valid_Performance(JntGrp{i}),size(JntGrp{i})),1);
        plot_performance=[plot_performance , JntPerformance];
        
    end
    plot(plot_performance,'-*');
    axis([0.5 size(plot_performance,2)+.5 0.4 1]);
end


set(h,'XTick',[1:length(plot_performance)],'XTickLabel',GetParam(me,'JntGrpXTitle'));
xlabel([ sprintf('%6.2g',plot_performance)  sprintf('\n') 'Tone / Odro Ch.']);
ylabel(['Performance' sprintf('\n') 'Fraction correct']);
set(h,'tag','plot_jnt_performance');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function change_schedule(varargin)
a=clock;
rand('state', ceil(a(end)));

CountedTrial = GetParam(me,'CountedTrial')+getparam('rpbox','run');
Schedule    = GetParam(me,'Schedule');
ToneSchedule= GetParam(me,'ToneSchedule');
Port_Side   = GetParam(me,'Port_Side');
ToneFreq    = GetParam(me,'ToneFreq');
ToneDur     = GetParam(me,'ToneDur');
ToneSPL     = GetParam(me,'ToneSPL');
Freq_List   = GetParam(me,'ToneFreq','user');
Dur_List    = GetParam(me,'ToneDur','user');
SPL_List    = GetParam(me,'ToneSPL','user');

Port=GetParam(me,'WaterPort');
Ratio=GetParam(me,'ToneRatio');

MaxTrial = GetParam(me,'MaxTrial');

tone_list=GetParam(me,'Tone_list');
Cum_Ratio   =[0 cumsum(Ratio(tone_list(1:end)))/sum(Ratio)];

last_port_side=0;
same_side_cont=0;
same_side_limit=GetParam(me,'SameSideLimit');
for i = CountedTrial+1 : MaxTrial
    random_num = rand;
    for j = 1:length(Ratio)
        if Cum_Ratio(j) <= random_num & random_num < Cum_Ratio(j+1) 
            chan=j;
        end
    end
    
    Port_Side(i)=Port(tone_list(chan));
    
    if last_port_side==Port_Side(i)
        same_side_cont=same_side_cont+1;
    else
        same_side_cont=0;
    end
    
    while same_side_cont > same_side_limit
        random_num = rand;
        for j = 1:length(Ratio)
            if Cum_Ratio(j) <= random_num & random_num < Cum_Ratio(j+1) 
                chan=j;
            end
        end
        Port_Side(i)=Port(tone_list(chan));
        if last_port_side==Port_Side(i)
            same_side_cont=same_side_cont+1;
        else
            same_side_cont=0;
        end
        if same_side_cont > MaxTrial
            message(me,'SameSideLimit changed','error');
            SetParam(me,'SameSideLimit',inf);
            same_side_limit=inf;
        end
    end
    Schedule(i)=chan;
    ToneSchedule(i)=tone_list(chan);
    ToneFreq(i)=Freq_List(tone_list(chan));
    ToneDur(i) =Dur_List(tone_list(chan));
    ToneSPL(i) =SPL_List(tone_list(chan));
    
    last_port_side=Port_Side(i);
end

SetParam(me,'Schedule','value',Schedule);
SetParam(me,'Port_Side','value',Port_Side);
SetParam(me,'ToneFreq','value',ToneFreq);
SetParam(me,'ToneDur','value',ToneDur);
SetParam(me,'ToneSPL','value',ToneSPL);
SetParam(me,'ToneSchedule','value',ToneSchedule);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=InitVP_Sound

FilterPath=[GetParam('rpbox','protocol_path') '\PPfilter.mat'];
if ( size(dir(FilterPath),1) == 1 )
    PP=load(FilterPath);
    PP=PP.PP;
    message(me,'Generating Calibrated Tones');
else
    PP=[];
    message(me,'Generating Non-calibrated Tones');
end

Freq=GetParam(me,'VPS_Freq');
Dur=GetParam(me,'VPS_Dur');
SPL=GetParam(me,'VPS_SPL');

n_tones=length(Freq);
ToneAttenuation = ones(1,n_tones)*70 -SPL;

for tn=1:n_tones
    if isempty(PP) | Freq(tn)== -1
        ToneAttenuation_adj = ToneAttenuation(tn);
    else
        ToneAttenuation_adj = ToneAttenuation(tn) - ppval(PP, log10(Freq(tn)));
        % Remove any negative attenuations and replace with zero attenuation.
        ToneAttenuation_adj = ToneAttenuation_adj .* (ToneAttenuation_adj > 0);
    end
    vp_sound{tn}  = 1 * makebeep(50e6/1024, ToneAttenuation_adj ,Freq(tn), Dur,3);
end
SetParam(me,'vp_sound',vp_sound);
out=vp_sound;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=me
% Simple function for getting the name of this m-file.
out=lower(mfilename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = callback
out = [lower(mfilename) ';'];