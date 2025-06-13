function out = Tone2AFC_25_200ms_2k15k(varargin)

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
        
        Port =[  R     R     R    R     R     R     L     L    L    L     L    L];
        Ratio={[ 8     8     8    9     9     8     8     9    9    8     8    8],
               [16     9     7    7     6     5     5     6    7    7     9   16],
               [18     9     8    7     6     2     2     6    7    8     9   18],
               [20    12     0   10     6     0     0     6   10    0    12   20],
               [22    12     0   14     2     0     0     2   14    0    12   22],
               [28     0     0   22     0     0     0     0   22    0     0   28],
               [48     0     0    2     0     0     0     0    2    0     0   48]};
        Ratio_Str ={'Full task' 'Advance(L6)' 'Intermediate(L5)' 'Basic(L4)' 'Easy(L3)' 'level=2' 'level=1'}; 
        Freq =[15000 15000 15000 15000 15000 15000  2000 2000 2000  2000  2000 2000 ];  %Hz
        Dur  =[ 200   200   200    25     25    25    25   25   25   200   200  200 ];  %msec
        SPL  =[  69    59    49    69     59    49    40   52   64    40    52   64 ];  %Max=PPdB SPL
        TmOut=[   4     3     2     4      3     2     2    3    4     2     3    4 ];  %Sec
        Str  ={'15k 69dB 200ms','15k 59dB 200ms','15k 49dB 200ms','15k 69dB 25ms','15k 59dB 25ms','15k 49dB 25ms',...
                '2k 40dB 25ms','2k 52dB 25ms','2k 64dB 25ms','2k 40dB 200ms','2k 52dB 200ms','2k 64dB 200ms'};
        Freq=fliplr(Freq);
        Str=fliplr(Str);
        TmOut=fliplr(TmOut);

        JntGrp={[ 6  5  4  ; % For ploting joint performance in the same column, ie, mean of tone 1 and 12 is ploted in a group. 
                  7  8  9] ; % Additional group lists can be added in the cell array.
                [ 3  2  1  ; 
                 10 11 12]};

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
        InitParam(me,'WaterValveDur','ui','edit','value',.15,'pos',[h+hs*4.3 n*vs hs*.7 vs]);
        SetParamUI(me,'WaterValveDur','label','WaterV_Dur'); 
        InitParam(me,'WN_Level','ui','popupmenu','list',WN_Str,'value',3,'user',3,'pos',[h+hs*5.9 n*vs hs*.7 vs]);
        SetParamUI(me,'WN_Level','label','WhiteNoise_L');
        
        n=n+1;
        InitParam(me,'FirstTonePokeDur','ui','disp','value',0,'pref',0,'pos',[h n*vs hs*.85 vs]); 
        SetParamUI(me,'FirstTonePokeDur','label','TnPokeDur (ms)');
        InitParam(me,'LeftFalse','ui','disp','value',0,'pref',0,'pos',[h+hs*1.8 n*vs hs*.5 vs]); 
        SetParamUI(me,'LeftFalse','label','Left False');
        InitParam(me,'RightFalse','ui','disp','value',0,'pref',0,'pos',[h+hs*3 n*vs hs*.6 vs]); 
        SetParamUI(me,'RightFalse','label','Right False');
        InitParam(me,'RespDelayDur','ui','edit','value',0.15,'pos',[h+hs*4.3 n*vs hs*.7 vs]);
        SetParamUI(me,'RespDelayDur','label','ResponseDelay');
        InitParam(me,'VP_Signal','ui','popupmenu','list',VPS_Str,'value',4,'user',4,'pos',[h+hs*5.9 n*vs hs*.7 vs]);
        SetParamUI(me,'VP_Signal','label','VP_Signal');
        
        n=n+1; 
        InitParam(me,'CountedTrial','ui','disp','value',0,'pref',0,'pos',[h n*vs hs*.85 vs]); 
        SetParamUI(me,'CountedTrial','label','Counted Trial');
        InitParam(me,'LeftMiss','ui','disp','value',0,'pref',0,'pos',[h+hs*1.8 n*vs hs*.5 vs]); 
        SetParamUI(me,'LeftMiss','label','Left Miss');
        InitParam(me,'RightMiss','ui','disp','value',0,'pref',0,'pos',[h+hs*3 n*vs hs*.6 vs]); 
        SetParamUI(me,'RightMiss','label','Right Miss');
        InitParam(me,'WaterAvailDur','ui','edit','value',3,'pos',[h+hs*4.3 n*vs hs*.7 vs]);
        SetParamUI(me,'WaterAvailDur','label','WaterAvailDur');
        InitParam(me,'TimeOut','ui','popupmenu','list',TmOut,'value',1,'pos',[h+hs*5.9 n*vs hs*.7 vs]);
        SetParamUI(me,'TimeOut','label','Time Out');    
        
        n=n+1;
        InitParam(me,'ValidScore','ui','disp','value',0,'pref',0,'pos',[h n*vs hs*.85 vs]); 
        SetParamUI(me,'ValidScore','label','Valid Score');
        InitParam(me,'LeftHit','ui','disp','value',0,'pref',0,'pos',[h+hs*1.8 n*vs hs*.5 vs]); 
        SetParamUI(me,'LeftHit','label','Left Hit');
        InitParam(me,'RightHit','ui','disp','value',0,'pref',0,'pos',[h+hs*3 n*vs hs*.6 vs]); 
        SetParamUI(me,'RightHit','label','Right Hit');
        InitParam(me,'DirectDelivery','ui','edit','value',0,'pos',[h+hs*4.3 n*vs hs*.7 vs]); 
        SetParamUI(me,'DirectDelivery','label','Direct Delivery');
        InitParam(me,'maxRndDelay','ui','edit','value',150,'pos',[h+hs*5.9 n*vs hs*.7 vs]); 
        SetParamUI(me,'maxRndDelay','label','maxRndDelay');
        
        n=n+1;
        InitParam(me,'RecentScore','ui','disp','value',0,'pref',0,'pos',[h n*vs hs*.85 vs]); 
        SetParamUI(me,'RecentScore','label','Recent Score =>');
        InitParam(me,'rLeftScore','ui','disp','value',0,'pref',0,'pos',[h+hs*1.8 n*vs hs*.5 vs]); 
        SetParamUI(me,'rLeftScore','label','rLeftScore');
        InitParam(me,'rRightScore','ui','disp','value',0,'pref',0,'pos',[h+hs*3 n*vs hs*.6 vs]); 
        SetParamUI(me,'rRightScore','label','rRightScore');
        InitParam(me,'RecentHistory','ui','edit','value',20,'pos',[h+hs*4.3 n*vs hs*.7 vs]); 
        SetParamUI(me,'RecentHistory','label','Recent History'); 
        InitParam(me,'minRndDelay','ui','edit','value',50,'pos',[h+hs*5.9 n*vs hs*.7 vs]); 
        SetParamUI(me,'minRndDelay','label','minRndDelay');
        
        n=n+1;
        InitParam(me,'TotalScore','ui','disp','value',0,'pref',0,'pos',[h n*vs hs*.85 vs]); 
        SetParamUI(me,'TotalScore','label','Total Score');
        InitParam(me,'LeftScore','ui','disp','value',0,'pref',0,'pos',[h+hs*1.8 n*vs hs*.5 vs]); 
        SetParamUI(me,'LeftScore','label','Left Score');
        InitParam(me,'RightScore','ui','disp','value',0,'pref',0,'pos',[h+hs*3 n*vs hs*.6 vs]); 
        SetParamUI(me,'RightScore','label','Right Score');
        InitParam(me,'SameSideLimit','ui','edit','value',9,'pos',[h+hs*4.3 n*vs hs*.7 vs]); 
        SetParamUI(me,'SameSideLimit','label','SameSideLimit'); 
        InitParam(me,'ToneDelay','ui','edit','value',50,'pos',[h+hs*5.9 n*vs hs*.7 vs]); 
        SetParamUI(me,'ToneDelay','label','ToneDelay'); 
        
        n=n+1;
        InitParam(me,'ToneSet','ui','popupmenu','list',Ratio_Str,'value',1,'user',1,'pref',0,'pos',[h n*vs hs*.85 vs]);
        SetParamUI(me,'ToneSet','label','Tn Ratio Setting');
        InitParam(me,'ChangeSchedule','ui','pushbutton','value',0,'pref',0,'pos',[h+hs*1.8 n*vs hs*.75 vs]);
        SetParamUI(me,'ChangeSchedule','label','','string','New Schedule'); 
        InitParam(me,'Miss_Correction','ui','radiobutton','value',0,'pref',0,'pos',[h+hs*3 n*vs hs*.425 vs]);
        SetParamUI(me,'Miss_Correction','label','','string','miss'); 
        InitParam(me,'False_Correction','ui','radiobutton','value',0,'pref',0,'pos',[h+hs*3.425 n*vs hs*.45 vs]);
        SetParamUI(me,'False_Correction','label','','string','false'); 
        InitParam(me,'Abort_Correction','ui','radiobutton','value',0,'pref',0,'pos',[h+hs*3.875 n*vs hs*.95 vs]);
        SetParamUI(me,'Abort_Correction','label','','string','abort Correction'); 
        
        InitParam(me,'ClearScore','ui','checkbox','value',1,'pref',0,'pos',[h+hs*5.1 n*vs hs*.8 vs]);
        SetParamUI(me,'ClearScore','label','','string','Clear Score'); 
        InitParam(me,'FixedDelay','ui','checkbox','value',1,'pref',0,'pos',[h+hs*5.9 n*vs hs*.8 vs]);
        SetParamUI(me,'FixedDelay','label','','string','FixedDelay','callback',['SetParam(''' mfilename ''',''RandomDelay'',GetParam(''' mfilename ''',''FixedDelay''));FigHandler']); 
        InitParam(me,'RandomDelay','ui','checkbox','value',0,'pref',0,'pos',[h+hs*6.7 n*vs hs*.8 vs]);
        SetParamUI(me,'RandomDelay','label','','string','Rnd Delay','callback',['SetParam(''' mfilename ''',''FixedDelay'',GetParam(''' mfilename ''',''RandomDelay''));FigHandler']); 
        
        n=n+1.1;
        % message box
        uicontrol(fig,'tag','message','style','edit',...
            'enable','inact','horiz','left','pos',[h n*vs hs*2.3 vs]);
        
        n=n+1.1;
        InitParam(me,'Tone_Disp','ui','disp','user',Str,'value',Str{1},'pref',0,'pos',[h n*vs hs*1.05 vs]); 
        SetParamUI(me,'Tone_Disp','label','','HorizontalAlignment','Left');        
        InitParam(me,'PlotAxes_Back','value',0,'user',0);
        InitParam(me,'PlotAxes_Forward','value',0,'user',0);
        InitParam(me,'SetPlotAxes_Back2Start','ui','pushbutton','value',0,'pref',0,'pos',[h+hs*1.1 n*vs hs*.5 vs]);
        SetParamUI(me,'SetPlotAxes_Back2Start','label','','string','|<<');
        InitParam(me,'SetPlotAxes_Back','ui','pushbutton','value',0,'pref',0,'pos',[h+hs*1.6 n*vs hs*.5 vs]);
        SetParamUI(me,'SetPlotAxes_Back','label','','string','<');
        InitParam(me,'SetPlotAxes_Default','ui','pushbutton','value',0,'pref',0,'pos',[h+hs*4.5 n*vs hs*.5 vs]);
        SetParamUI(me,'SetPlotAxes_Default','label','','string','< reset >');
        InitParam(me,'SetPlotAxes_Forward','ui','pushbutton','value',0,'pref',0,'pos',[h+hs*6.1 n*vs hs*.5 vs]);
        SetParamUI(me,'SetPlotAxes_Forward','label','','string','>');
        InitParam(me,'SetPlotAxes_Forward2End','ui','pushbutton','value',0,'pref',0,'pos',[h+hs*6.6 n*vs hs*.5 vs]);
        SetParamUI(me,'SetPlotAxes_Forward2End','label','','string','>>|');
        
        InitParam(me,'WaterPort','value',Port);
        InitParam(me,'ToneRatio','value',Ratio{1}/sum(Ratio{1}),'user',Ratio);
        tone_list=[];
        tone_list_n=[];
        for i=[1,3,2]   %Right Port==1, Left Port==2, Both ==3
            tone_list     =[tone_list find(Port==i)];
            tone_list_n   =[tone_list_n length(find(Port==i))];
        end
        InitParam(me,'Tone_list','value',tone_list,'user',tone_list_n);
        
        BlankSchedule=zeros(1,GetParam(me,'MaxTrial'));
        InitParam(me,'ToneFreq','value',BlankSchedule,'user',Freq);
        InitParam(me,'ToneDur','value',BlankSchedule,'user',Dur);
        InitParam(me,'ToneSPL','value',BlankSchedule,'user',SPL);
        InitParam(me,'Schedule','value',BlankSchedule);        
        InitParam(me,'ToneSchedule','value',BlankSchedule);
        InitParam(me,'Port_Side','value',BlankSchedule);
        InitParam(me,'Result','value',BlankSchedule);
        InitParam(me,'TonePokeDur','value',BlankSchedule);
        InitParam(me,'nTonePoke','value',BlankSchedule);
        InitParam(me,'JntGroup','value',JntGrp);
        
        InitParam(me,'Beep','value',[]);
        beep=InitTones;
        InitParam(me,'vp_sound','value',[]);
        vp_sound=InitVP_Sound;
        change_schedule(GetParam(me,'MaxTrial'));
        rpbox('InitRPSound');
        ToneSchedule=GetParam(me,'ToneSchedule');
        next_tone=ToneSchedule(GetParam(me,'CountedTrial')+1);
        rpbox('LoadRPSound',{beep{next_tone}+fresh_wn(next_tone),vp_sound{GetParam(me,'VP_Signal')}});
        rpbox('send_matrix', [0 0 0 0 0 0 0 180 0 0]);
        rpbox('send_matrix',state_transition_matrix);
        
        set(fig,'pos',[140 100 hs*7.5 (n+26)*vs],'visible','on');
        update_plot;
        
    case 'trialend'
        
    case 'reset'
        Message('control','wait for RP (RP2/RM1) reseting');
        if Getparam(me,'ClearScore')
            clear_score;
        end
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
        ToneSchedule=GetParam(me,'ToneSchedule');
        next_tone=ToneSchedule(GetParam(me,'CountedTrial')+1);
        rpbox('LoadRPSound',{beep{next_tone}+fresh_wn(next_tone),vp_sound{GetParam(me,'VP_Signal')}});
        Message('control','');
        
        
    case 'watervalvedur'
        rpbox('send_matrix',state_transition_matrix);
        
    case 'toneset'
        setting=GetParam(me,'ToneSet');
        Ratio=GetParam(me,'ToneRatio','user');
        SetParam(me,'ToneRatio','value',Ratio{setting}/sum(Ratio{setting}));
        eval([me '(''changeschedule'')']);
        
    case 'vp_signal'
        beep=GetParam(me,'beep');
        vp_sound=GetParam(me,'vp_sound');
        ToneSchedule=GetParam(me,'ToneSchedule');
        next_tone=ToneSchedule(GetParam(me,'CountedTrial')+1);
        rpbox('LoadRPSound',{beep{next_tone}+fresh_wn(next_tone),vp_sound{GetParam(me,'VP_Signal')}});        
        
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
        ToneSchedule=GetParam(me,'ToneSchedule');
        Schedule=GetParam(me,'Schedule');
        ToneFreq = GetParam(me,'ToneFreq');
        ToneDur  = GetParam(me,'ToneDur');
        ToneSPL  = GetParam(me,'ToneSPL');
        Port_Side       =GetParam(me,'Port_Side');        
        pts             =Port_Side(CountedTrial);         % water port_side 1:Right, 2:Left, 3:Both
        RightHit=GetParam(me,'RightHit');
        LeftHit=GetParam(me,'LeftHit');
        RightAbort=GetParam(me,'RightAbort');
        LeftAbort=GetParam(me,'LeftAbort');
        RightMiss=GetParam(me,'RightMiss');
        LeftMiss=GetParam(me,'LeftMiss');
        RightFalse=GetParam(me,'RightFalse');
        LeftFalse=GetParam(me,'LeftFalse');

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
        beep=GetParam(me,'beep');
        
        if (GetParam(me,'False_Correction') & Result(CountedTrial)==2)|(GetParam(me,'Miss_Correction') & Result(CountedTrial)==3)|...
                (GetParam(me,'Abort_Correction') & Result(CountedTrial)==4)
            Delay_correction=ceil(rand*5);
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
        next_tone=ToneSchedule(CountedTrial+1);
        rpbox('LoadRPSound',{beep{next_tone}+fresh_wn(next_tone)});
        update_plot;
        rpbox('send_matrix',state_transition_matrix);
        
    case 'restore'
        var=lower(...
            {'LastTonePokeDur'  'LeftAbort'  'RightAbort'  'WaterValveDur' ...
                'FirstTonePokeDur' 'LeftFalse'  'RightFalse'  'RespDelayDur'...
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

long_beep = 0 * makebeep(50e6/1024, 70 , 30, max(Dur),3);
long_beep_lgh=length(long_beep);
InitParam(me,'Max_beep_lgh','value',long_beep_lgh);
for tn=1:n_tones
    if isempty(PP) | Freq(tn)== -1
        ToneAttenuation_adj = ToneAttenuation(tn);
    else
        ToneAttenuation_adj = ToneAttenuation(tn) - ppval(PP, log10(Freq(tn)));
        % Remove any negative attenuations and replace with zero attenuation.
        ToneAttenuation_adj = ToneAttenuation_adj .* (ToneAttenuation_adj > 0);
    end
    beep{tn} = 1 * makebeep(50e6/1024, ToneAttenuation_adj ,Freq(tn), Dur(tn),3);
end

SetParam(me,'beep',beep);
out=beep;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=fresh_wn(next_tone)

Dur=GetParam(me,'ToneDur','user');
WN_SPL =GetParam(me,'WN_SPL');
Attenuation = 70 - WN_SPL(GetParam(me,'wn_level'));
wn  = 1 * makebeep(50e6/1024, Attenuation ,-1, Dur(next_tone),3);

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
rdd=GetParam(me,'RespDelayDur');
if rdd < 0.001 % vpd has to be larger than the sampling reate of RPDevice
    rdd=0.001;  % sec
end
wad=GetParam(me,'WaterAvailDur');
Port_Side=GetParam(me,'Port_Side'); 
pts=Port_Side(CountedTrial);         % water port_side 1:Right, 2:Left, 3:Both
tnd=GetParam(me,'ToneDur');
tnd=tnd(CountedTrial)/1000;
Schedule=GetParam(me,'Schedule');
tmo=GetParam(me,'TimeOut','list');
tmo=tmo(Schedule((CountedTrial)));
wvd=GetParam(me,'WaterValveDur');

% ltd=(tnd-vpd);  %leftover tone duration
% ltd=ltd*(ltd>0);
% if  0 < ltd & ltd < 0.001  % ltd has to be larger than the sampling reate of RPDevice
%     ltd=0.001;  % sec
% end
dly=0.001;
if GetParam(me,'FixedDelay')
    dly=GetParam(me,'ToneDelay')/1000;
elseif GetParam(me,'RandomDelay')
    dly=(GetParam(me,'minRndDelay')+exp(-rand)*(GetParam(me,'maxRndDelay')-GetParam(me,'minRndDelay'))/(exp(1)-1))/1000;
end

if pts+dd==1
    state_transition_matrix=[ ...                            % Right Side Water Port
    %  Cin Cout Lin Lout Rin Rout TimeUp        Timer DIO  AO  
        1    0   0    0   0    0    0           180   0    0;   % State 0 "Pre-State"
        1    0   1    1   1    1    2           dly   0    0;   % State 1 "Center Poke in, before tone on"
        2    6   2    2   2    2    3           tnd   0    1;   % State 2 "tone on"
        3    6   3    3   3    3    4           rdd   0    1;   % State 3 "pre- Center Poke out"
        4    4   7    0   5    0    8           wad   0    3;   % State 4 "Reward Avaiable Dur"
        5    5   5    5   5    5   35           wvd   2    0;   % State 5 "Valid Poke ==> Water!!! :)"
        6    6   6    6   6    6   35           tmo   0    0;   % State 6 "ShortPoke => Abort => House Light "
        7    7   7    7   7    7   35           tmo   0    0;   % State 7 "FalsePoke, wrong side => House Light "
        8    8   8    8   8    8   35           tmo   0    0;]; % State 8 "ValidTonePoke but missed reward => House Light "
elseif pts+dd==2
    state_transition_matrix=[ ...                            % Left Side Water Port
     %  Cin Cout Lin Lout Rin Rout TimeUp        Timer DIO  AO  
        11    0   0    0   0    0    0           180   0    0;   % State 0 "Pre-State"
        zeros(10,10);
        11    0  11   11  11   11   12           dly   0    0;   % State 11 "Center Poke in, before tone on"
        12   16  12   12  12   12   13           tnd   0    1;   % State 12 "tone on"
        13   16  13   13  13   13   14           rdd   0    1;   % State 13 "pre- Center Poke out"
        14   14  15    0  17    0   18           wad   0    3;   % State 14 "Reward Avaiable Dur"
        15   15  15   15  15   15   35           wvd   1    0;   % State 15 "Valid Poke ==> Water!!! :)"
        16   16  16   16  16   16   35           tmo   0    0;   % State 16 "ShortPoke => Abort => House Light "
        17   17  17   17  17   17   35           tmo   0    0;   % State 17 "FalsePoke, wrong side => House Light "
        18   18  18   18  18   18   35           tmo   0    0;]; % State 18 "ValidTonePoke but missed reward => House Light "
elseif pts+dd==3	
    state_transition_matrix=[ ...                            % Both Side Water Port
     %  Cin Cout Lin Lout Rin Rout TimeUp        Timer DIO  AO  
        21    0   0    0   0    0    0           180   0    0;   % State 0 "Pre-State"
        zeros(20,10);
        21    0  21   21  21   21   22           dly   0    0;   % State 21 "Center Poke in, before tone on"
        22   26  22   22  22   22   23           tnd   0    1;   % State 22 "tone on"
        23   26  23   23  23   23   24           rdd   0    1;   % State 23 "pre- Center Poke out"
        24   24  15    0   5    0   28           wad   0    3;   % State 24 "Reward Avaiable Dur"
        25   25  25   25  25   25   35           wvd   3    0;   % State 25 "Valid Poke ==> Water!!! :)"
        26   26  26   26  26   26   35           tmo   0    0;   % State 26 "ShortPoke => Abort => House Light "
        27   27  27   27  27   27   35           tmo   0    0;   % State 27 "FalsePoke, wrong side => House Light "
        28   28  28   28  28   28   35           tmo   0    0;]; % State 28 "ValidTonePoke but missed reward => House Light "
elseif pts+dd==4
    state_transition_matrix=[ ...                            % Right Side Water Port direct delivery
    %  Cin Cout Lin Lout Rin Rout TimeUp        Timer DIO  AO  
        1    0   0    0    0   0    0           180   0    0;   % State 0 "Pre-State"
        1    0   1    1    1   1    2           dly   0    0;   % State 1 "Center Poke in, before tone on"
        2    6   2    2    2   2    3           tnd   0    1;   % State 2 "tone on"
        3    6   3    3    3   3    4           rdd   0    1;   % State 3 "pre- Center Poke out"
        4    4   4    4    4   4    5           wvd   2    3;   % State 4 "Valid Poke ==> Water!!! :)"
        5    5   5    5   35  35    8           wad   0    0;   % State 5 "rat finds Water!!! :)"
        6    6   6    6    6   6    0          .001   0    0;   % State 6 "ShortPoke => Abort"
        7    7   7    7    7   7    0          .001   0    0;   % State 7 "FalsePoke, wrong side "
        8    8   8    8    8   8    0          .001   0    0;]; % State 8 "ValidTonePoke but missed reward"
elseif pts+dd==5
    state_transition_matrix=[ ...                            % Left Side Water Port
     %  Cin Cout Lin Lout Rin Rout TimeUp        Timer DIO  AO  
        11    0   0    0   0    0    0           180   0    0;   % State 0 "Pre-State"
        zeros(10,10);
        11    0  11   11  11   11   12           dly   0    0;   % State 11 "Center Poke in, before tone on"
        12   16  12   12  12   12   13           tnd   0    1;   % State 12 "tone on"
        13   16  13   13  13   13   14           rdd   0    1;   % State 13 "pre- Center Poke out"
        14   14  14   14  14   14   15           wvd   1    3;   % State 14 "Valid Poke ==> Water!!! :)"
        15   15  35   35  15   15    8           wad   0    0;   % State 15 "rat finds Water!!! :)"
        16   16  16   16  16   16    0          .001   0    0;   % State 16 "ShortPoke => Abort => House Light "
        17   17  17   17  17   17    0          .001   0    0;   % State 17 "FalsePoke, wrong side => House Light "
        18   18  18   18  18   18    0          .001   0    0;]; % State 18 "ValidTonePoke but missed reward => House Light "
elseif pts+dd==6	
    state_transition_matrix=[ ...                            % Both Side Water Port
     %  Cin Cout Lin Lout Rin Rout TimeUp        Timer DIO  AO  
        21    0   0    0   0    0    0           180   0    0;   % State 0 "Pre-State"
        zeros(20,10);
        21    0  21   21  21   21   22           dly   0    0;   % State 21 "Center Poke in, before tone on"
        22   26  22   22  22   22   23           tnd   0    1;   % State 22 "tone on"
        23   26  23   23  23   23   24           rdd   0    1;   % State 23 "pre- Center Poke out"
        24   24  24   24  24   24   25           wvd   3    3;   % State 24 "Valid Poke ==> Water!!! :)"
        25   25  35   35  35   35    8           wad   0    0;   % State 25 "rat finds Water!!! :)"
        26   26  26   26  26   26    0          .001   0    0;   % State 26 "ShortPoke => Abort => House Light "
        27   27  27   27  27   27    0          .001   0    0;   % State 27 "FalsePoke, wrong side => House Light "
        28   28  28   28  28   28    0          .001   0    0;]; % State 28 "ValidTonePoke but missed reward => House Light "
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
Result          =GetParam(me,'Result');
TonePokeDur     =GetParam(me,'TonePokeDur');
nTonePoke       =GetParam(me,'nTonePoke');
Port_Side       =GetParam(me,'Port_Side');        
pts             =Port_Side(CountedTrial);         % water port_side 1:Right, 2:Left, 3:Both
if dd
    rHit =[5 5;5 6;25 5;25 6];
    lHit =[15 3;15 4;25 3;25 4];
    rAbort =[2 2;3 2];
    lAbort =[12 2;13 2];
    bAbort =[22 2;23 2];
    lFalse =[4 3];
    rFalse =[14 5];
    rMiss =[8 7];
    lMiss =[18 7];
    bMiss =[28 7]; 
else
    rHit =[4 5;24 5];
    lHit =[14 3;24 3];
    rAbort =[2 2;3 2];
    lAbort =[12 2;13 2];
    bAbort =[22 2;23 2];
    lFalse =[3 3;4 3];
    rFalse =[13 5;14 5];
    rMiss =[4 7];
    lMiss =[14 7];
    bMiss =[24 7];    
end

Event=Getparam('rpbox','event','user'); % [state,chan,event time]
for i=1:size(Event,1)
    if Event(i,2)==1        %tone poke in
        if Event(i,1:2)==[0 1] & (CountedTrial-1)
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
        elseif sum(prod(repmat(Event(i,1:2),size(lAbort,1),1)==lAbort,2))
            Result(CountedTrial) =4;  % ShortPoke => Abort 
            message(me,['ShortPoke => LeftAbort #' num2str(GetParam(me,'LeftAbort')+1)],'green');
            SetParam(me,'LeftAbort',GetParam(me,'LeftAbort')+1);
        elseif sum(prod(repmat(Event(i,1:2),size(bAbort,1),1)==bAbort,2))
            Result(CountedTrial) =4;  % ShortPoke => Abort 
            message(me,['ShortPoke => Abort #' num2str(GetParam(me,'LeftAbort')+GetParam(me,'RightAbort'))],'green');            
            SetParam(me,'RightAbort',GetParam(me,'RightAbort')+.5);
            SetParam(me,'LeftAbort',GetParam(me,'LeftAbort')+.5);  
        end
    elseif Event(i,2)==3    %Left poke in
        if sum(prod(repmat(Event(i,1:2),size(lHit,1),1)==lHit,2))
            Result(CountedTrial) =1;  % Hit
            message(me,['Left Hit #' num2str(GetParam(me,'LeftHit')+1)],'cyan');
            SetParam(me,'LeftHit',GetParam(me,'LeftHit')+1);
        elseif sum(prod(repmat(Event(i,1:2),size(lFalse,1),1)==lFalse,2))
            Result(CountedTrial) =2;  % FalsePoke, wrong side
            message(me,['Wrong side, FalsePoke #' num2str(GetParam(me,'LeftFalse')+1)],'red');
            SetParam(me,'LeftFalse',GetParam(me,'LeftFalse')+1);
        end
    elseif Event(i,2)==4    %Left poke out
        
    elseif Event(i,2)==5    %Right poke in
        if sum(prod(repmat(Event(i,1:2),size(rHit,1),1)==rHit,2))
            Result(CountedTrial) =1;  % Hit
            message(me,['Right Hit #' num2str(GetParam(me,'RightHit')+1)],'cyan');            
            SetParam(me,'RightHit',GetParam(me,'RightHit')+1);
        elseif sum(prod(repmat(Event(i,1:2),size(rFalse,1),1)==rFalse,2))
            Result(CountedTrial) =2;  % FalsePoke, wrong side
            message(me,['Wrong side, FalsePoke #' num2str(GetParam(me,'RightFalse')+1)],'red');            
            SetParam(me,'RightFalse',GetParam(me,'RightFalse')+1);
        end
    elseif Event(i,2)==6    %Right poke out
        
    elseif Event(i,2)==7    % time up
        if sum(prod(repmat(Event(i,1:2),size(rMiss,1),1)==rMiss,2))
            Result(CountedTrial) =3;  % ValidTonePoke but missed reward
            message(me,'Missed reward');
            SetParam(me,'RightMiss',GetParam(me,'RightMiss')+1);
        elseif sum(prod(repmat(Event(i,1:2),size(lMiss,1),1)==lMiss,2))
            Result(CountedTrial) =3;  % ValidTonePoke but missed reward
            message(me,'Missed reward');            
            SetParam(me,'LeftMiss',GetParam(me,'LeftMiss')+1);
        elseif sum(prod(repmat(Event(i,1:2),size(bAbort,1),1)==bAbort,2))
            Result(CountedTrial) =3;  % ValidTonePoke but missed reward
            message(me,'Missed reward');
            SetParam(me,'RightMiss',GetParam(me,'RightMiss')+.5);
            SetParam(me,'LeftMiss',GetParam(me,'LeftMiss')+.5);            
        end
    end
end
SetParam(me,'Result',Result);
SetParam(me,'nTonePoke',nTonePoke);
Setparam('rpbox','event','user',[]);    %clearing events so it won't get counted twice

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function update_plot
global exper

fig = findobj('tag',me);
figure(fig);
h = findobj(fig,'tag','plot_schedule');
if ~isempty(h)
    axes(h);
    set(h,'pos',[0.15 0.3 0.8 0.26]);
else
    h = axes('tag','plot_schedule','pos',[0.15 0.3 0.8 0.26]);    
end
Schedule=GetParam(me,'Schedule');
ToneSchedule=GetParam(me,'ToneSchedule');
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
Str=GetParam(me,'Tone_Disp','user');
SetParam(me,'Tone_Disp',Str{ToneSchedule(CountedTrial+1)});
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
        min(max(ceil((CountedTrial+10+PlotAxes_Forward)/50)*50,100),MaxTrial) ax(3)-.3 ax(4)+1]);
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

if CountedTrial
    Performance=zeros(size(tone_list));
    Valid_Performance=zeros(size(tone_list));
    Miss_Performance=zeros(size(tone_list));
    False_Performance=zeros(size(tone_list));
    Abort_Performance=zeros(size(tone_list));
    n_Hit=zeros(size(tone_list));
    n_Fls=zeros(size(tone_list));
    n_Mis=zeros(size(tone_list));    
    n_Abt=zeros(size(tone_list));
    n_trial=zeros(size(tone_list));
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
xlabel('Tone / Odro Ch.');
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
        x=1:length(JntGrp{i});
        JntPerformance=mean(Valid_Performance(JntGrp{i}),1);
        plot_performance=[plot_performance ; JntPerformance];
    end
    plot(x,plot_performance,'-*');
    axis([0.5 size(plot_performance,2)+.5 0.4 1]);
end

set(h,'XTick',[1:6],'XTickLabel',tone_list(1:6));
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