function [out] = SeqDiscSamp8(varargin)

% - implement changing dot color as soon as we have an answer, not only at
% - the end of the trial...

% Version History 
% 090605 (SP): SeqDiscSamp7:  Delay2Chord is now a variable distribution defined by a
% mean ('Del2Cd_Mean') and standard deviation ('Del2Cd_StDev')
% 091205 (SP) : SeqDiscSamp8:  The 'F1-F2' sounds are played at a different
% volume (F1F2SPL) than the 'GO' signal 'GOSPL'.

global exper

if nargin > 0
    action = lower(varargin{1});
else
    action = lower(get(gcbo,'tag'));
end

out=1;
switch action

    case 'init'
        fp = fopen('debug_out.txt', 'w'); fclose(fp);
        ModuleNeeds(me, {'rpbox'});
        SetParam(me,'priority','value',GetParam('rpbox','priority')+1);
        fig = ModuleFigure(me,'visible','off'); 

        %first column
        rownum = 1; colnum = 1;
        InitializeUIEditParam('RampDur',                     0.005, rownum, colnum);   rownum = rownum+1;
        InitializeUIEditParam('NTones',                         16, rownum, colnum);   rownum = rownum+1;
        InitializeUIEditParam('BaseFreq',                        1, rownum, colnum);   rownum = rownum+1;
        InitializeUIEditParam('GOSPL',                         60, rownum, colnum);   rownum = rownum+1;
        InitializeUIEditParam('F1F2SPL',                         20, rownum, colnum);   rownum = rownum+1;
        
        rownum = rownum+0.5; % Blank row

        InitializeUIEditParam('ChordDur',                        1, rownum, colnum);  rownum = rownum+1;
        %InitializeUIEditParam('Delay2Chord',                     1, rownum, colnum);  rownum = rownum+1;
        InitializeUIEditParam('Delay',                           1, rownum, colnum);  rownum = rownum+1;
        InitializeUIEditParam('SoundDur',                        1, rownum, colnum);  rownum = rownum+1;
        InitializeUIEditParam('PreSoundMeanTime',              0.2, rownum, colnum);  rownum = rownum+1;
        InitializeUIEditParam('PreSoundMinTime',              0.05, rownum, colnum);  rownum = rownum+1;
        InitializeUIEditParam('PreSoundMaxTime',                 2, rownum, colnum);  rownum = rownum+1;

        InitializeUIEditParam('Del2Cd_Mean',              1, rownum, colnum);  rownum = rownum+1;
        InitializeUIEditParam('Del2Cd_StDev',              1, rownum, colnum);  rownum = rownum+1;
        %InitializeUIEditParam('D2CMinTime',              0.5, rownum, colnum);  rownum = rownum+1;
        %InitializeUIEditParam('D2CMaxTime',                 1.5, rownum, colnum);  rownum = rownum+1;
        InitializeUIEditParam('DrinkTime',                     0.5, rownum, colnum);  rownum = rownum+1;
        rownum = rownum+2; % Blank rows

        NTypes = 4;
        InitParam(me, 'NTypes', 'value', NTypes );
        InitializeUICheckBox('T4',                               1, rownum, colnum);   colnum = colnum+0.5;
        InitializeUIEditShortParam('T4F1', 'F1',                 8, rownum, colnum);   colnum = colnum+0.75;
        InitializeUIEditShortParam('T4F2', 'F2',                 4, rownum, colnum);   colnum = colnum+0.75;
        InitializeUIDispShortParam('S4', 'Side',               'L', rownum, colnum);   colnum = colnum+0.75;
        InitializeUIEditShortParam('P4', 'Prob',              0.25, rownum, colnum);   rownum = rownum+1; colnum=1;
        InitializeUICheckBox('T3',                               1, rownum, colnum);   colnum = colnum+0.5;
        InitializeUIEditShortParam('T3F1', 'F1',                 4, rownum, colnum);   colnum = colnum+0.75;
        InitializeUIEditShortParam('T3F2', 'F2',                 8, rownum, colnum);   colnum = colnum+0.75;
        InitializeUIDispShortParam('S3', 'Side',               'R', rownum, colnum);   colnum = colnum+0.75;
        InitializeUIEditShortParam('P3', 'Prob',              0.25, rownum, colnum);   rownum = rownum+1; colnum=1;
        InitializeUICheckBox('T2',                               1, rownum, colnum);   colnum = colnum+0.5;
        InitializeUIEditShortParam('T2F1', 'F1',                 2, rownum, colnum);   colnum = colnum+0.75;
        InitializeUIEditShortParam('T2F2', 'F2',                 1, rownum, colnum);   colnum = colnum+0.75;
        InitializeUIDispShortParam('S2', 'Side',               'L', rownum, colnum);   colnum = colnum+0.75;
        InitializeUIEditShortParam('P2', 'Prob',              0.25, rownum, colnum);   rownum = rownum+1; colnum=1;
        InitializeUICheckBox('T1',                               1, rownum, colnum);   colnum = colnum+0.5;
        InitializeUIEditShortParam('T1F1', 'F1',                 1, rownum, colnum);   colnum = colnum+0.75;
        InitializeUIEditShortParam('T1F2', 'F2',                 2, rownum, colnum);   colnum = colnum+0.75;
        InitializeUIDispShortParam('S1', 'Side',                'R', rownum, colnum);   colnum = colnum+0.75;
        InitializeUIEditShortParam('P1', 'Prob',              0.25, rownum, colnum);   rownum = rownum+1; colnum=1;
        InitParam(me, 'TypeProb', 'value', zeros(1,NTypes) );
        InitParam(me, 'TypeSide', 'value', zeros(1,NTypes) ); %0=left, 1=right
        update_typesettings;

        rownum = rownum + 1;
        InitializeUIPushParam('SaveSettings',                           rownum, colnum);   rownum = rownum+1;
        InitializeUIPushParam('LoadSettings',                           rownum, colnum);   rownum = rownum+1;

        rownum = rownum + 0.5;
        InitializeUIPushParam('SaveData',                               rownum, colnum);   rownum = rownum+1;
        InitializeUIPushParam('LoadData',                               rownum, colnum);   rownum = rownum+1;
        InitializeUIEditParam('RatName',                     'ratname', rownum, colnum);   rownum = rownum+1;

        %second column
        rownum = 1; colnum = 3;
        InitializeUIEditParam('LeftWValveTime',                        0.2, rownum, colnum);   rownum = rownum+1;
        InitializeUIEditParam('RightWValveTime',                      0.14, rownum, colnum);   rownum = rownum+1;

        rownum = rownum+0.5; % Blank row
        InitializeUIEditParam('LastCpokeMins',                   5, rownum, colnum);   rownum = rownum+1;
        InitializeUIEditParam('NForStat',                       50, rownum, colnum);   rownum = rownum+1;

        rownum = rownum+0.5;
        InitializeUIEditParam('WNTimeUnit',                           0.5, rownum, colnum);  rownum = rownum + 1;
        InitializeUIMenuParam('ITI',               ...
            {'1' '2' '3' '4' '5' '6' '8' '10' '15' '20' '30'}, 4, rownum, colnum); rownum = rownum + 1;
        InitializeUIMenuParam('WithdrawalTimeOut', ...
            {'1' '2' '3' '4' '5' '6' '8' '10' '15' '20' '30'}, 4, rownum, colnum); rownum = rownum + 1;
        InitializeUIMenuParam('ErrorTimeOut',      ...
            {'1' '2' '3' '4' '5' '6' '8' '10' '15' '20' '30'}, 4, rownum, colnum); rownum = rownum + 1;

        rownum = rownum+0.5;
        InitializeUIMenuParam('MaxSameType', {'1' '2' '3' '4' '5' '6' '7' '8' '9' '10' 'Inf'},4, rownum, colnum); rownum = rownum + 1;
        InitializeUIMenuParam('MaxSameSide', {'1' '2' '3' '4' '5' '6' '7' '8' '9' '10' 'Inf'},4, rownum, colnum); rownum = rownum + 1;
        InitializeUIEditParam('Stubbornness',                          0.5, rownum, colnum);   rownum = rownum + 1;
        InitializeUIEditParam('CenterProb',                           0, rownum, colnum);  rownum = rownum + 1;
        InitializeUIMenuParam('Schedule', {'With Early Move', 'No Early Move'}, 1, rownum, colnum);  rownum = rownum + 1;

        rownum = rownum+7.5;
        InitParam(me,  'LeftPort',   'ui', 'togglebutton', 'pref', 0, 'enable', 'inact', 'pos', position(rownum, colnum, 0.4));
        SetParamUI(me, 'LeftPort',   'label', '', 'enable', 'inact', 'String', 'Left');
        InitParam(me,  'CenterPort', 'ui', 'togglebutton', 'pref', 0, 'enable', 'inact', 'pos', position(rownum, colnum+0.5, 0.4));
        SetParamUI(me, 'CenterPort', 'label', '', 'enable', 'inact', 'String', 'Center');
        InitParam(me,  'RightPort',  'ui', 'togglebutton', 'pref', 0, 'enable', 'inact', 'pos', position(rownum, colnum+1, 0.4));
        SetParamUI(me, 'RightPort',  'label', '', 'enable', 'inact', 'String', 'Right'); rownum = rownum+1;
        rownum = rownum + 0.5;
        InitParam(me,  'F1orF2_but',  'ui', 'togglebutton', 'pref', 0, 'enable', 'inact', 'pos', position(rownum, colnum+0.15, 0.6));
        SetParamUI(me, 'F1orF2_but',  'label', '', 'enable', 'inact', 'String', 'F1/F2'); 
        InitParam(me,  'GO_but',  'ui', 'togglebutton', 'pref', 0, 'enable', 'inact', 'pos', position(rownum, colnum+1, 0.6));
        SetParamUI(me, 'GO_but',  'label', '', 'enable', 'inact', 'String', 'GO'); rownum = rownum+1;


        %third column
        rownum = 1; colnum = 5;
        InitializeUIDispParam('Last10',                                  0, rownum, colnum);   rownum = rownum + 1;
        InitializeUIDispParam('Last20',                                  0, rownum, colnum);   rownum = rownum + 1;
        InitializeUIDispParam('Last40',                                  0, rownum, colnum);   rownum = rownum + 1;
        InitializeUIDispParam('Last80',                                  0, rownum, colnum);   rownum = rownum + 1;

        rownum = rownum+0.5; % Blank row
        InitializeUIDispParam('CenterPokes',                             0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('LeftPokes',                               0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('RightPokes',                              0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('LeftRewards',                             0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('RightRewards',                            0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('Rewards',                                 0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('Trials',                                  0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('WdrawOnCenter',                           0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('WdrawOverall',                           0, rownum, colnum);   rownum = rownum+1;


        % ------ Schedule ---------
        maxtrials = 1000; InitParam(me, 'MaxTrials',     'value', maxtrials);
        InitParam(me, 'SideList', 'value', zeros(1, maxtrials));    %side of sample sounds
        InitParam(me, 'TypeList', 'value', zeros(1, maxtrials));    %type of (f1,f2) combination
        set_future_trials(1);
        InitParam(me, 'CenterList', 'value', zeros(1, maxtrials));  %whether chord is centered or not
        InitParam(me, 'Withdraw_Trials', 'value', zeros(1, maxtrials)); % whether rat withdrew during this trial (0=no, 1=yes)
        set_future_centertrials(1);
        InitParam(me, 'FreqList', 'value', zeros(2, maxtrials));
        set_future_frequencies(1);
        InitParam(me, 'PreSoundTimeList', 'value', zeros(2, maxtrials));
        set_future_presoundtimes(1);

        InitParam(me, 'Delay2ChordList', 'value', zeros(2, maxtrials));
        set_future_delay2chord(1);

        InitParam(me, 'RewardHistory',       'value', []);  % defined in terms of first sideport response 'hm'
        initialize_plot;

        InitParam(me, 'CenterPokeTimes',     'value', zeros(1,20000)); % start times of center pokes
        InitParam(me, 'CenterPokeDurations', 'value', zeros(1,20000)); % How long each of the above was
        InitParam(me, 'CenterPokeStateHist', 'value', zeros(1,20000)); % State number in which each center poke was initiated
        InitParam(me, 'nCenterPokes',   'value', 0);
        InitParam(me, 'CPokeState', 'value', 0);
        InitParam(me, 'LastPokeInTime', 'value', 0);
        InitParam(me, 'LastPokeOutTime');
        initialize_centerpokes_plot;

        InitParam(me, 'CurrentSide',  'value', []);
        InitParam(me, 'CurrentChord',  'value', []);
        InitParam(me, 'CurrentHit', 'value', []);
        InitParam(me, 'Sounds',       'value', MakeSounds);
        InitParam(me, 'StateMatrix',  'value', state_transition_matrix);

        rpbox('InitRP3StereoSound');
        rpbox('LoadRP3StereoSound', GetParam(me,'Sounds'));
        %rpbox('send_matrix', GetParam(me, 'StateMatrix') );
        rpbox('send_matrix', GetParam(me, 'StateMatrix'), 1);
        set(fig, 'Visible', 'on');

        return;

    case 'update',
        WpkS   = GetStateNumber( 'WaitForPoke'  );
        ChrdS  = GetStateNumber( 'Chord' );
        WaitS  = GetStateNumber( 'PreChord' );
        Event  = Getparam('rpbox','event','user');

        for i=1:size(Event,1)
            % colouring the right buttons
            if     Event(i,2)==1
                SetParamUI(me,'CenterPort','BackgroundColor',[0 1 0]);
                SetParam(me, 'LastPokeInTime', Event(i,3));
                SetParam(me, 'CenterPokes', GetParam(me, 'CenterPokes')+1);
                SetParam(me, 'CPokeState', Event(i,1));

            elseif Event(i,2)==2
                SetParamUI(me,'CenterPort','BackgroundColor',[0.8 0.8 0.8]);
                SetParam(me, 'LastPokeOutTime', Event(i,3));
                lastpokeouttime = Event(i,3);
            elseif Event(i,2)==3
                SetParamUI(me,'LeftPort','BackgroundColor',[0 1 0]);
                SetParam(me, 'LeftPokes', GetParam(me, 'LeftPokes')+1);
            elseif Event(i,2)==4
                SetParamUI(me,'LeftPort','BackgroundColor',[0.8 0.8 0.8]);
            elseif Event(i,2)==5
                SetParamUI(me,'RightPort','BackgroundColor',[0 1 0]);
                SetParam(me, 'RightPokes', GetParam(me, 'RightPokes')+1);
            elseif Event(i,2)==6
                SetParamUI(me,'RightPort','BackgroundColor',[0.8 0.8 0.8]);
            else
            end
            
            if Event(i,1) == GetStateNumber('PreSound') & Event(i,2) == 7
                SetParamUI(me, 'F1orF2_but', 'BackgroundColor', [1 0 0]);                
            elseif Event(i,1) == GetStateNumber('PreChord') & Event(i,2) == 7
                SetParamUI(me, 'GO_but', 'BackgroundColor', [1 0 0]);
            else
                SetParamUI(me, 'F1orF2_but', 'BackgroundColor', [0.8 0.8 0.8]);
                SetParamUI(me, 'GO_but', 'BackgroundColor', [0.8 0.8 0.8]);
            end;

            current_side = GetParam(me, 'CurrentSide');
            current_chord = GetParam(me, 'CurrentChord');
            current_hit = GetParam(me, 'CurrentHit');
            if isempty(current_hit),  % haven't figured out yet if this trial was a hit
                % we're in the post-sample tone, allowing left/right poke
                if Event(i,1)==WaitS
                    if     ( (Event(i,2)==3 & current_side=='l') | (Event(i,2)==5 & current_side=='r') ),
                        SetParam(me, 'CurrentHit', 'h');
                        SetParam(me, 'RewardHistory', [GetParam(me, 'RewardHistory') ; 'e']); %early hit
                        SetParam(me, 'Rewards',        GetParam(me, 'Rewards') +1);
                        if Event(i,2)==3,    SetParam(me, 'LeftRewards',  GetParam(me, 'LeftRewards') +1);
                        else                 SetParam(me, 'RightRewards', GetParam(me, 'RightRewards')+1);
                        end;
                    elseif ( (Event(i,2)==3 & current_side=='r') | (Event(i,2)==5 & current_side=='l') ),
                        SetParam(me, 'CurrentHit', 'm');
                        SetParam(me, 'RewardHistory', [GetParam(me, 'RewardHistory') ; 'f']); %early miss
                    end;
                end;

                % we're in the chord/post-chord tone, wait for poke act state
                if Event(i,1)==WpkS | Event(i,1)==ChrdS,
                    if     ( (Event(i,2)==3 & current_side=='l') | (Event(i,2)==5 & current_side=='r') ),
                        SetParam(me, 'CurrentHit', 'h');
                        SetParam(me, 'Rewards',        GetParam(me, 'Rewards') +1);
                        if ( current_chord == 'c' ) %chord is centered
                            SetParam(me, 'RewardHistory', [GetParam(me, 'RewardHistory') ; 'e']); %hit
                        else                        %chord is left/right
                            SetParam(me, 'RewardHistory', [GetParam(me, 'RewardHistory') ; 'h']);
                        end
                        if Event(i,2)==3,    SetParam(me, 'LeftRewards',  GetParam(me, 'LeftRewards') +1);
                        else                 SetParam(me, 'RightRewards', GetParam(me, 'RightRewards')+1);
                        end;

                    elseif ( (Event(i,2)==3 & current_side=='r') | (Event(i,2)==5 & current_side=='l') ),
                        SetParam(me, 'CurrentHit', 'm');
                        if ( current_chord == 'c' ) %chord is centered
                            SetParam(me, 'RewardHistory', [GetParam(me, 'RewardHistory') ; 'f']); %miss
                        else                        %chord is left/right
                            SetParam(me, 'RewardHistory', [GetParam(me, 'RewardHistory') ; 'm']);
                        end;
                    end;
                elseif Event(i,1) == GetStateNumber('Withdrawal')
                    wdraw_list = GetParam('Withdraw_Trials');
                    this_trial = GetParam(me, 'Trials')+1;
                    wdraw_list(this_trial) = 1;
                    SetParam(me, 'Withdraw_Trials');                    
                end;
            end;

            if ismember(Event(i,2), [2]), % it was a center poke out
                nCenterPokes        = GetParam(me, 'nCenterPokes')+1;
                CenterPokeTimes     = GetParam(me, 'CenterPokeTimes');
                CenterPokeDurations = GetParam(me, 'CenterPokeDurations');
                CenterPokeStateHist = GetParam(me, 'CenterPokeStateHist');
                LastPokeInTime      = GetParam(me, 'LastPokeInTime');
                state               = GetParam(me, 'CPokeState');

                CenterPokeTimes(nCenterPokes) = LastPokeInTime;
                CenterPokeDurations(nCenterPokes) = lastpokeouttime - LastPokeInTime;
                CenterPokeStateHist(nCenterPokes) = state;
                SetParam(me, 'nCenterPokes', nCenterPokes);       SetParam(me, 'CenterPokeStateHist', CenterPokeStateHist);
                SetParam(me, 'CenterPokeTimes', CenterPokeTimes); SetParam(me, 'CenterPokeDurations', CenterPokeDurations);
                update_centerpokes_plot;
            end;
        end
        if size(Event,1)>0,
            laststate = Event(end,1);
        end;

        return;


    case 'close',
        SetParam('rpbox','protocols',1);
        return;

    case 'reset'
        SetParam(me, 'Trials', 0); SetParam(me, 'Rewards', 0); SetParam(me, 'RightRewards', 0);
        SetParam(me, 'LeftRewards', 0); SetParam(me, 'RightPokes', 0); SetParam(me, 'LeftPokes', 0);
        SetParam(me, 'CenterPokes', 0);
        SetParam(me, 'LastPokeInTime', 'value', 0); SetParam(me, 'LastPokeOutTime', 'value', 0);
        set_future_trials(1);
        SetParam(me, 'RewardHistory',       'value', []);  % defined in terms of first sideport response 'hm'
        initialize_plot;
        SetParam(me, 'CurrentSide',  'value', []);
        SetParam(me, 'CurrentHit', 'value', []);
        SetParam(me, 'CurrentChord', 'value', []);
        SetParam(me, 'Sounds',       'value', MakeSounds);
        SetParam(me, 'StateMatrix',  'value', state_transition_matrix);
        rpbox('InitRP3StereoSound');
        rpbox('LoadRP3StereoSound', GetParam(me,'Sounds'));
        %rpbox('send_matrix', GetParam(me, 'StateMatrix') );
        rpbox('send_matrix', GetParam(me, 'StateMatrix'), 1);

    case 'state35',

        fp = fopen( 'debug_out.txt', 'a' );   fprintf( fp, '\nStart SeqDiscSamp6 state 35\n');   fclose( fp );
        Trials       = GetParam(me, 'Trials');
        if GetParam(me, 'CurrentHit')=='m',
            Stubbornness = GetParam(me, 'Stubbornness');
            side_list    = GetParam(me, 'SideList');
            type_list    = GetParam(me, 'TypeList');
            if rand(1) <= Stubbornness,
                side_list(Trials+2) = side_list(Trials+1);
                type_list(Trials+2) = type_list(Trials+1);
                set_future_frequencies(Trials+2);
            end;
            SetParam(me, 'SideList', side_list);
            SetParam(me, 'TypeList', type_list);
        end;
        SetParam(me, 'Sounds', MakeSounds);
        rpbox('LoadRP3StereoSound', GetParam(me, 'Sounds'));
        SetParam(me, 'Trials', GetParam(me, 'Trials')+1);
        SetParam(me, 'StateMatrix', state_transition_matrix);
        SetParam(me, 'CurrentHit',  []);

        fp = fopen( 'debug_out.txt', 'a' );   fprintf( fp, '\nupdate_plot\n');   fclose( fp );
        update_plot;

        fp = fopen( 'debug_out.txt', 'a' );   fprintf( fp, '\nupdate_meanhitst\n');   fclose( fp );
        update_meanhits;

        fp = fopen( 'debug_out.txt', 'a' );   fprintf( fp, '\nupdate_statistics\n');   fclose( fp );
        update_statistics;

        fp = fopen( 'debug_out.txt', 'a' );   fprintf( fp, '\nsendmatrix\n');   fclose( fp );
        %rpbox('send_matrix', GetParam(me, 'StateMatrix') );
        rpbox('send_matrix', GetParam(me, 'StateMatrix'), 1);

        fp = fopen( 'debug_out.txt', 'a' );   fprintf( fp, '\nFinish SeqDiscSamp6 state 35\n');   fclose( fp );

    case 'savesettings',
        save_uiparamvalues(me, GetParam(me, 'RatName'));

    case 'loadsettings',
        if load_uiparamvalues(me, GetParam(me, 'RatName')),
            update_typesettings;
            NT = GetParam(me,'Trials')+1;
            if GetParam('rpbox', 'state')==35,
                set_future_trials(NT);
                set_future_centertrials(NT);
                set_future_frequencies(NT);
            else
                set_future_trials(NT+1);
                set_future_centertrials(NT+1);
                set_future_frequencies(NT+1);
            end;
            update_plot;
            update_stimulus_plot;
        end;

    case 'savedata',
        save_data(me, GetParam(me, 'RatName'));

    case 'loaddata',
        if load_data(me, GetParam(me, 'RatName')),
            update_plot;
            update_stimulus_plot;
            update_statistics;
            update_centerpokes_plot;
        end;

    case {'centerprob'},
        CheckParam( me, 'CenterProb', 0, 1, 0 );
        if GetParam('rpbox', 'state')==35, set_future_centertrials(GetParam(me, 'Trials')+1);
        else                               set_future_centertrials(GetParam(me, 'Trials')+2);
        end;
        update_plot;


    case {'t1', 't2', 't3', 't4', 'p1', 'p2', 'p3', 'p4', 'maxsameside', 'maxsametype'},
        if (GetParam( me, 'T1' )==0 & GetParam( me, 'T2' ) ==0 & GetParam( me, 'T3')==0 & GetParam( me, 'T4')==0 )
            SetParam( me, 'T1', 1 );
        end
        NTypes = GetParam( me, 'NTypes' );
        for k=1:NTypes
            if (GetParam( me, ['T',int2str(k)] )==0)
                SetParam( me, ['P',int2str(k)], 0 );
            end
            CheckParam( me, ['P', int2str(k)], 0, 1e100, 1/NTypes );
        end
        update_typesettings;
        if GetParam('rpbox', 'state')==35, set_future_trials(GetParam(me, 'Trials')+1);
        else                               set_future_trials(GetParam(me, 'Trials')+2);
        end;
        update_plot;
        update_stimulus_plot;

    case {'t1f1', 't1f2', 't2f1', 't2f2', 't3f1', 't3f2', 't4f1', 't4f2'},
        for k=1:GetParam(me,'NTypes');
            CheckParam( me, ['T',int2str(k),'F1'], 1, 20, 1 );
            CheckParam( me, ['T',int2str(k),'F2'], 1, 20, 1 );
        end
        update_typesettings;
        if GetParam('rpbox', 'state')==35, set_future_frequencies(GetParam(me, 'Trials')+1);
        else                               set_future_frequencies(GetParam(me, 'Trials')+2);
        end
        update_stimulus_plot;

    case {'presoundmeantime', 'presoundmintime', 'presoundmaxtime', ...
            'delay2chord_mean', 'delay2chord_stdev', ...
            'sounddur', 'delay', 'chorddur'}, %'delay2chord',
        CheckParam( me, 'PreSoundMeanTime', 0, 100, 0.1 );
        CheckParam( me, 'PreSoundMinTime',  0, GetParam( me, 'PreSoundMaxTime' ), 0.05 );
        CheckParam( me, 'PreSoundMeanTime', GetParam( me, 'PreSoundMinTime'), 100, 0.1 );

        CheckParam( me, 'Del2Cd_Mean', 0, 100, 0.5 );
        CheckParam( me, 'Del2Cd_StDev', 0, 1, 0.01 );
        %CheckParam( me, 'D2CMinTime',  0, GetParam( me, 'D2CMaxTime' ), 0.05 );
        %CheckParam( me, 'D2CMaxTime', GetParam( me, 'D2CMinTime'), 100, 0.5 );

        if GetParam('rpbox', 'state')==35,
            set_future_presoundtimes(GetParam(me, 'Trials')+1);
            set_future_delay2chord(GetParam(me, 'Trials')+1);
        else
            set_future_presoundtimes(GetParam(me, 'Trials')+2);
            set_future_delay2chord(GetParam(me, 'Trials')+2);
        end
        CheckParam( me, 'SoundDur', 0, 100, 0.2 );
        CheckParam( me, 'Delay', 0, 100, 0 );
        %CheckParam( me, 'Delay2Chord', 0, 100, 0.5 );
        CheckParam( me, 'ChordDur', 0, 100, 0.2 );

    case 'lastcpokemins',
        CheckParam( me, 'LastCPokeMins', 0, 1000, 30 );
        update_centerpokes_plot;

    case 'nforstat',
        CheckParam( me, 'NForStat', 0, 10000, 50 );
        update_statistics;

    case 'stubbornness',
        CheckParam( me, 'Stubbornness', 0, 1, 0.5);

    case {'rightwvalvetime','leftwvalvetime'},
        CheckParam( me, 'RightWValveTime', 0, 10, 0.2);
        CheckParam( me, 'LeftWValveTime', 0, 10, 0.2);

    case {'gospl','f1f2spl','basefreq','ntones','rampdur'},
        CheckParam( me, 'GOSPL', 0, 70, 60);
        CheckParam( me, 'F1F2SPL', 0, 70, 60);
        CheckParam( me, 'BaseFreq', 0, 10, 1);
        CheckParam( me, 'NTones', 1, 32, 16);
        CheckParam( me, 'RampDur', 0, 0.05, 0.005);

    otherwise
        out = 0;
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         set_future_trials (starting_at_trial_number)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = set_future_trials(starting_at);

maxtrials = GetParam(me, 'MaxTrials');
side_list = GetParam(me, 'SideList');
type_list = GetParam(me, 'TypeList');
type_prob = GetParam(me, 'TypeProb');
NTypes    = GetParam(me, 'NTypes');
cumprob   = cumsum( type_prob );
type_side = GetParam(me, 'TypeSide'); %0=left, 1=right
maxsametype = GetParam(me, 'MaxSameType');
maxsameside = GetParam(me, 'MaxSameSide');
sidecounter = zeros(1,2);
typecounter = zeros(1,NTypes);
repcounter  = 0;
k=starting_at;
while k<=maxtrials,
    b=rand(1);
    ind = find( b < cumprob );
    thistype = ind(1);
    thisside = (type_side( thistype )==1)+1;
    if ( sidecounter( thisside ) > maxsameside | typecounter( thistype ) > maxsametype )
        %repeat, since we hit the same side/type
        repcounter = repcounter+1; %HACK against hang-up
        if repcounter<25, continue; end
    end
    type_list( k ) = thistype;
    side_list( k ) = thisside-1;
    typecounter( thistype ) = typecounter( thistype )+1;
    sidecounter( thisside ) = sidecounter( thisside )+1;
    othertypes = setxor( 1:NTypes, thistype );
    otherside  = 3-thisside;
    typecounter( othertypes ) = 0;
    sidecounter( otherside ) = 0;
    repcounter = 0;
    k=k+1;
end
SetParam(me, 'TypeList', type_list );
SetParam(me, 'SideList', side_list );

return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         set_future_centertrials (starting_at_trial_number)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = set_future_centertrials(starting_at);

maxtrials = GetParam(me, 'MaxTrials');
center_list = GetParam(me, 'CenterList');
maxsame   = 8; %GetParam(me, 'MaxSameCenter');
center_list(starting_at:maxtrials)   = rand(1,maxtrials-starting_at+1)>=GetParam(me, 'CenterProb');
%-> center trials = 0; Left/Right Trials = 1

%if maxsame < 10,
%	seg_starts  = find(diff([-Inf center_list -1]));
%	seg_lengths = diff(seg_starts);
%	long_segs   = find(seg_lengths > maxsame);
%	while ~isempty(long_segs),
%		switch_point = seg_starts(long_segs(1)) + ceil(seg_lengths(long_segs(1))/2);
%		center_list(switch_point) = 1 - center_list(switch_point);
%		seg_starts  = find(diff([-Inf side_list]));
%		seg_lengths = diff(seg_starts);
%		long_segs   = find(seg_lengths > maxsame);
%	end;
%end;

SetParam(me, 'CenterList', 'value', center_list);
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         set_future_frequencies (starting_at_trial_number)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = set_future_frequencies(starting_at);

maxtrials = GetParam(me, 'MaxTrials');
type_list = GetParam(me, 'TypeList');
freq_list = GetParam(me, 'FreqList');
for k=starting_at:maxtrials,
    freq_list(1,k) = GetParam( me, ['T', int2str(type_list(k)),'F1'] );
    freq_list(2,k) = GetParam( me, ['T', int2str(type_list(k)),'F2'] );
end
SetParam(me,'FreqList', freq_list );



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         set_future_presoundtimes (starting_at_trial_number)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = set_future_presoundtimes(starting_at);

time_list = GetParam( me, 'PreSoundTimeList' );
psmt = GetParam( me, 'PreSoundMeanTime' );
psmin = GetParam( me, 'PreSoundMinTime' );
psmax = GetParam( me, 'PreSoundMaxTime' );
maxtrials = GetParam( me, 'MaxTrials' );
tmp = - psmt * log( 1 - rand(1,maxtrials-starting_at+1) + 0.000000001 );
tmp( tmp> psmax ) = psmax;
tmp( tmp< psmin ) = psmin;
time_list( starting_at:maxtrials ) = tmp;
SetParam( me, 'PreSoundTimeList', time_list );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         set_future_delay2chord (starting_at_trial_number)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = set_future_delay2chord(starting_at);

time_list = GetParam( me, 'Delay2ChordList' );
psmt = GetParam( me, 'Del2Cd_Mean' );
pssd = GetParam(me, 'Del2Cd_StDev');
maxtrials = GetParam( me, 'MaxTrials' );
tmp = psmt + (pssd * randn(1, maxtrials-starting_at+1));
tmp(tmp < 0.01 ) = 0.1;

tmp(tmp >= psmt*2 ) = psmt;
time_list( starting_at:maxtrials ) = tmp;
SetParam( me, 'Delay2ChordList', time_list );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         update_meanhits
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = update_meanhits();

guys = [10 20 40 80];
Trials = GetParam(me, 'Trials');
rwdhist= GetParam(me, 'RewardHistory' );

Hits   = ( (rwdhist == 'h') | (rwdhist == 'e') );
for i=1:length(guys),
    trials = max(Trials-guys(i)+1, 1):Trials;
    SetParam(me, ['Last' num2str(guys(i))], mean(Hits(trials)));
end;

% Compute 'withdrawal-during-surround-sound-trials'
wdraw_list = GetParam(me, 'Withdraw_Trials');
center_list = GetParam(me, 'center_list');
ind1 = find(wdraw_list == 1 & center_list == 0);    % find surround-sound 
                                                    % trials in which rat withdrew
ind2 = find(wdraw_list == 1);


wd_label = GetParam(me, 'WdrawOnCenter');
total_surround = length((find(center_list(1:10) ==0)));
SetParam(me, 'WdrawOnCenter', length(ind1)/total_surround);
SetParam(me, 'WdrawOverall', length(ind2)/(Trials+1));      % overall withdrawal rate


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         update_typesettings
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = update_typesettings();

NTypes = GetParam(me, 'Ntypes');

%update probabilities
p=zeros(1,NTypes);
for k=1:NTypes,
    p(k) = GetParam( me, ['P', int2str(k)] );
end
if (sum(p)==0), p(1)=1; end;
p = p/sum(p);
%now round this a bit for better display
p2 = p(1:NTypes-1);
p2 = round( p2*100 )/100;
p = [p2, 1-sum(p2)];
%done.
for k=1:NTypes,
    SetParam( me, ['P', int2str(k)], p(k) );
end
SetParam( me, 'TypeProb', p );

%update sides
s=zeros(1,NTypes); %0=left, 1=right
for k=1:NTypes,
    f1   = GetParam( me, ['T', int2str(k), 'F1'] );
    f2   = GetParam( me, ['T', int2str(k), 'F2'] );
    if (f1>f2)
        s(k) = 0; %left
        SetParam( me, ['S', int2str(k)], 'L' );
    else
        s(k) = 1; %right
        SetParam( me, ['S', int2str(k)], 'R' );
    end
end
SetParam( me, 'TypeSide', s );
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         initialize_plot
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = initialize_plot

fig = findobj('Tag', me);
figure(fig);

% First plot rewards
h     = findobj(fig, 'Tag', 'plot_sides');
if ~isempty(h), delete(h); end
h = axes('Position', [0.26 0.85 0.67 0.12]);
set(h,'tag','plot_sides');
update_plot;

% Then plot stimuli
h     = findobj(fig, 'Tag', 'plot_stimuli');
if ~isempty(h), delete(h); end
h = axes('Position', [0.05 0.85 0.17 0.12]);
set(h,'tag','plot_stimuli');
update_stimulus_plot;

%Then statistics
h     = findobj(fig, 'Tag', 'plot_statistics');
if ~isempty(h), delete(h); end
h = axes('Position', [0.75 0.42 0.17 0.2]);
set(h,'tag','plot_statistics');
update_statistics;
return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         update_stimulus_plot
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = update_stimulus_plot

fig = findobj('Tag', me);
h   = findobj(fig, 'Tag', 'plot_stimuli');
if ~isempty(h),
    axes(h); cla;
    pp = plot( [0.1, 20], [0.1, 20] );
    set( pp, 'Color', [0.65 0.65 0.65] );
    for k=1:GetParam(me,'NTypes')
        if GetParam( me, ['T' int2str(k) ] ),
            f1=GetParam( me, ['T' int2str(k) 'F1' ]);
            f2=GetParam( me, ['T' int2str(k) 'F2' ]);
            tt = text( f1,f2, int2str(k), 'FontSize', 12 );
            set( tt, 'Color', 'b' );
        end
    end
    axis( [0.7 20 0.7 20] );
    xlabel('f1 (kHz)'); ylabel('f2 (kHz)');
    set( h, 'XScale', 'log', 'YScale', 'log' );
    set( h, 'XTick', [1 2 5 10 20], 'YTick', [1 2 5 10 20] );
    set(h,'tag','plot_stimuli');
end
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         update_statistics
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = update_statistics

fig = findobj('Tag', me);
h   = findobj(fig, 'Tag', 'plot_statistics');
if ~isempty(h),
    axes(h); cla;
    side_list = GetParam( me, 'SideList' );
    type_list = GetParam( me, 'TypeList' );
    rewd_hist = GetParam( me, 'RewardHistory' );
    rewd_hist = rewd_hist';
    ntrials   = GetParam( me, 'Trials' );
    ntypes    = GetParam( me, 'NTypes' );
    N         = GetParam( me, 'NForStat');
    Nbeg = max( 1, ntrials-N );
    ind=Nbeg:ntrials;
    for k=1:ntypes
        NT{k} = ind( find( type_list(ind)==k ) );
    end
    outcomes = 'hemf';              % hit / early hit / miss/ early miss
    colors = [0 1 0; 0 0.5 0; 1 0 0; 0.5 0 0];    % corresponding colors
    for j=1:ntypes                                % loop over stimuli
        y1=0; y2=0;
        for k=1:4                                 % loop over outcomes
            HTS = find( rewd_hist(NT{j})==outcomes(k) );
            frt = length(HTS) / max(1,length( NT{j} ));
            y2 = y2 + frt;
            plotbox( j, y1, y2, colors(k,:) );
            y1 = y1 + frt;
        end
    end
    axis( [0.5 ntypes+0.5 0 1.2] );
    ylabel('Percentage correct');
    set( h, 'XTick', 1:ntypes );
    set( h,'tag','plot_statistics');
end
return;


function plotbox( xpos, y1, y2, col );

pp = patch( [xpos-0.4, xpos+0.4, xpos+0.4, xpos-0.4, xpos-0.4], ...
    [y1,       y1,       y2,       y2,       y1], 'k');
set( pp, 'FaceColor', col );
set( pp, 'EdgeColor', col );
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         update_plot
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function [] = update_plot

fig   = findobj('Tag', me);
h     = findobj(fig, 'Tag', 'plot_sides');
if ~isempty(h),
    axes(h); cla;

    ntrials        = GetParam(me, 'Trials');  % These are # of already finished trials
    maxtrials      = GetParam(me, 'MaxTrials');
    side_list      = GetParam(me, 'SideList'); side_list = 2 - side_list; % 2==left,  1==right
    center_list    = GetParam(me, 'CenterList');
    type_list      = GetParam(me, 'TypeList');
    reward_history = GetParam(me, 'RewardHistory');
    if isempty(reward_history), reward_history = zeros(0,1); end;

    hold on;

    axmin = max(ntrials-50,1);
    axmax = axmin+80;

    % First the future
    futind=ntrials+1:axmax;
    centerind = find( center_list(futind)==0 );
    tt = text(futind(centerind), side_list(futind(centerind)), int2str( type_list(futind(centerind))' ) );
    set( tt, 'Color', 'k', 'FontSize', 8 );

    lrind     = find( center_list(futind)==1 );
    tt = text(futind(lrind), side_list(futind(lrind)), int2str( type_list(futind(lrind))' ) );
    set( tt, 'Color', 'b', 'FontSize', 8 );

    % Now the past
    pastind=axmin:ntrials;
    ind = find(reward_history(pastind) == 'h');
    hits = pastind(ind);
    if (~isempty(hits))
        tt = text( hits, side_list(hits), int2str( type_list(hits)' ) );
        set( tt, 'Color', 'g', 'FontSize', 8 );
    end

    ind = find(reward_history(pastind) == 'm');
    misses = pastind(ind);
    if (~isempty(misses))
        tt = text( misses, side_list(misses), int2str( type_list(misses)' ) );
        set( tt, 'Color', 'r', 'FontSize', 8 );
    end

    ind = find(reward_history(pastind) == 'e');
    earlyhits = pastind(ind);
    if (~isempty(earlyhits))
        tt = text( earlyhits, side_list(earlyhits), int2str( type_list(earlyhits)' ) );
        set( tt, 'Color', [0 0.5 0], 'FontSize', 8 );
    end

    ind = find(reward_history(pastind) == 'f');
    earlymisses = pastind(ind);
    if (~isempty(earlymisses))
        tt = text( earlymisses, side_list(earlymisses), int2str( type_list(earlymisses)' ) );
        set( tt, 'Color', [0.5 0 0], 'FontSize', 8 );
    end

    pp = plot(ntrials+1, side_list(ntrials+1), 'ro'); hold off;
    set( pp, 'MarkerSize', 10 );
    axis([axmin axmax 0.5 2.5]);

    xlabel('trials'); ylabel('Port');
    set(h, 'YTick', [1 2], 'YTickLabel', {'Rt' 'Lt'});
    set(h, 'YAxisLocation', 'right');
    set(h,'tag','plot_sides');
end;


return



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         initialize_centerpokes_plot
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = initialize_centerpokes_plot

h = axes('Position', [0.26 0.675 0.67 0.12]);
set(h, 'Tag', 'CenterPokesPlot');
xlabel('secs');
ylabel('CPokeDur');

vpd = GetParam( me, 'PreSoundMeanTime') + 2*GetParam( me, 'SoundDur') + GetParam( me, 'Delay' ) ...
    + GetParam( me, 'Del2Cd_Mean');
l = line([0 100], [vpd vpd]);
set(l, 'Color', 0.8*[1 1 1], 'Tag', 'vpdline');

pd = line([0], [0]);
set(pd, 'Color', 'k', 'Marker', '.', 'LineStyle', '-', 'Tag', 'pdline');

r = line([0], [0]);
set(r, 'Color', 'r', 'Marker', '.', 'LineStyle', 'none', 'Tag', 'rline');
axis([0 100 0 1.5*vpd]);
set(h, 'YAxisLocation', 'right');

h2 = axes('Position', [0.05 0.675 0.17 0.12]);
set(h2, 'Tag', 'CenterPokesHist', 'XLim', [0 0.95], 'YLim', [0 1]);
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         update_centerpokes_plot
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = update_centerpokes_plot

fig   = findobj('Tag', me);
h     = findobj(fig, 'Tag', 'CenterPokesPlot');
h2    = findobj(fig, 'Tag', 'CenterPokesHist');

if ~isempty(h) | ~isempty(h2),
    nCenterPokes        = GetParam(me, 'nCenterPokes');
    CenterPokeTimes     = GetParam(me, 'CenterPokeTimes');
    CenterPokeDurations = GetParam(me, 'CenterPokeDurations');
    CenterPokeStateHist = GetParam(me, 'CenterPokeStateHist');

    u = find(CenterPokeTimes(nCenterPokes) - CenterPokeTimes < GetParam(me, 'LastCpokeMins')*60  &  ...
        CenterPokeDurations>0);
end;

if ~isempty(h),
    vline = findobj(h, 'Tag', 'vpdline');
    pline = findobj(h, 'Tag', 'pdline');
    rline = findobj(h, 'Tag', 'rline');

    if length(u)>0,
        set(pline, 'XData', CenterPokeTimes(u), 'YData', CenterPokeDurations(u));
        from = min(CenterPokeTimes(u))-1;       to  = max(CenterPokeTimes(u))+1;
        bot  = min(CenterPokeDurations(u))*0.9; top = max(CenterPokeDurations(u))*1.1;
        set(h, 'XLim', [from to], 'YLim', [bot top]);

        red_u = find(CenterPokeStateHist(u) == GetStateNumber('BaseState'));
        set(rline, 'XData', CenterPokeTimes(u(red_u)), 'YData', CenterPokeDurations(u(red_u)));
        vpd = GetParam( me, 'PreSoundMeanTime') + 2*GetParam( me, 'SoundDur') + GetParam( me, 'Delay' ) ...
            + GetParam( me, 'Del2Cd_Mean');
        set(vline, 'XData', [from to], 'YData', [vpd vpd]);
    end;
    set(h, 'YAxisLocation', 'right');
end;

if ~isempty(h2) & length(u) > 1,
    axes(h2);
    n = CenterPokeDurations(u);  [n, x] = hist(n, 0:0.001:max(n)); n = 100*cumsum(n)/length(u);
    plot(n, x); set(h2, 'Tag', 'CenterPokesHist');
    gridpts = [0 25 50 75 95]; % must always contain 0
    set(gca, 'XTick', gridpts, 'XGrid', 'on', 'Xlim', gridpts([1 end]));

    p = zeros(size(gridpts)); p(1) = 1; empty_flag = 0;
    for i=2:length(gridpts),
        z = max(find(n <= gridpts(i)));
        if isempty(z), empty_flag = 1;
        else p(i) = z;
        end;
    end;
    if ~empty_flag,
        if min(diff(x(p)))>0, set(gca, 'YTick', x(p), 'Ygrid', 'on', 'YLim', x(p([1 end]))); end;
    end;
end;
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         InitializeUIPushParam
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = InitializeUIPushParam(parname, rownum, colnum)

InitParam(me, parname, 'ui', 'pushbutton', 'pos', position(rownum, colnum));
SetParamUI(me, parname, 'label', parname);
return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         InitializeUIEditParam
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = InitializeUIEditParam(parname, parval, rownum, colnum)

InitParam(me, parname, 'ui', 'edit', 'value', parval, 'pos', position(rownum, colnum), 'user', 1);
SetParamUI(me, parname, 'label', parname);
return;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         InitializeUIEditShortParam
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = InitializeUIEditShortParam(parname, parlabel, parval, rownum, colnum)

pos = position(rownum, colnum); pos(3) = pos(3)/3;
InitParam(me, parname, 'ui', 'edit', 'value', parval, 'pos', pos, 'user', 1);
SetParamUI(me, parname, 'label', parlabel);
return;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         InitializeUIDispParam
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = InitializeUIDispParam(parname, parval, rownum, colnum)

InitParam(me, parname, 'ui', 'disp', 'value', parval, 'pos', position(rownum, colnum));
SetParamUI(me, parname, 'label', parname);
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         InitializeUIDispShortParam
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = InitializeUIDispShortParam(parname, parlabel, parval, rownum, colnum)

pos = position(rownum, colnum); pos(3) = pos(3)/3;
InitParam(me, parname, 'ui', 'disp', 'value', parval, 'pos', pos);
SetParamUI(me, parname, 'label', parlabel);
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         InitializeUICheckBox
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = InitializeUICheckBox(parname, parval, rownum, colnum)

InitParam(me, parname,'ui','checkbox','value',parval,'pref',0,'pos',position(rownum,colnum,0.4));
SetParamUI(me, parname,'label','','string',parname);
return;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         InitializeUIMenuParam
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = InitializeUIMenuParam(parname, parlist, parval, rownum, colnum)

InitParam(me, parname, 'ui', 'popupmenu', 'list', parlist, 'value', parval, 'pos', position(rownum, colnum), 'user', 1);
SetParamUI(me, parname, 'label', parname);
return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         state_transition_matrix
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [stm] = state_transition_matrix

lwvt        = GetParam(me, 'LeftWValveTime');
rwvt        = GetParam(me, 'RightWValveTime');
ntrials     = GetParam(me, 'Trials');
side_list   = GetParam(me, 'SideList');
center_list = GetParam(me, 'CenterList');
wntime      = GetParam(me, 'WNTimeUnit');
drkt        = GetParam(me, 'DrinkTime');
schedu      = GetParam(me, 'Schedule' );

this_side = side_list(ntrials+1);
if this_side==0, SetParam(me, 'CurrentSide', 'l');
else             SetParam(me, 'CurrentSide', 'r');
end;
this_center=center_list(ntrials+1);
if this_center==0, SetParam(me, 'CurrentChord', 'c'); %center trial     (centered chord)
else               SetParam(me, 'CurrentChord', 'l'); %left/right trial (lateralized chords)
end;

prst_arr = GetParam(me, 'PreSoundTimeList' );
prst = prst_arr( ntrials+1 );
sdur = 2*GetParam(me, 'SoundDur') + GetParam(me,'Delay');

%wdur = GetParam(me, 'Delay2Chord');
wdur_arr = GetParam(me, 'Delay2ChordList');
wdur = wdur_arr( ntrials+1 );

cdur = GetParam(me, 'ChordDur');
wntime = max( wntime, 0.05 );
if wntime>0.05
    wnsound=4;
else
    wnsound=0;
end
itiloop = GetParam( me, 'ITI' );
errorloop = GetParam( me, 'ErrorTimeOut' );
withdrawalloop = GetParam( me, 'WithdrawalTimeOut' );

global statematrix;
InitStateMatrix;
InitState( 'DeadTime' );

%note that retrigger state initializes a second state,
%to have this state directly follow the deadtime state,
%we need to set these states here.
SetRetriggerState( 'DeadTime', 'Tup', 'S35', 'Time', wntime, 'Aout', wnsound, 'Loop', 1 );  % white noise during deadtime
SetState( 'S35',          'Def', 'DeadTime', 'Time', 0.03);

InitState( 'BaseState');
InitState( 'PreSound' );
InitState( 'SampleSound' );
InitState( 'PreChord' );
InitState( 'Chord' );
InitState( 'WaitForPoke' );
InitState( 'Reward' );
InitState( 'NoReward' );
InitState( 'Drink' );
InitState( 'ITIState' );
InitState( 'Withdrawal' );

SetState( 'Start',        'Def', 'BaseState', 'Time', 0.01  );  % dummy state
SetState( 'BaseState',    'Cin', 'PreSound' );                  % wait till cpoke
SetState( 'PreSound',     'Def', 'BaseState',  'Tup', 'SampleSound', 'Time', prst );    % no time out; if poke maintained, go to samplesound
SetState( 'SampleSound',  'Def', 'Withdrawal', 'Tup', 'PreChord', 'Time', sdur, 'Aout', 2 ); % if pull-out, goto withdrawal; else prepare for "go" signal

if (schedu==0) % no early moves allowed
    SetState( 'PreChord', 'Def', 'Withdrawal', 'Tup', 'Chord', 'Time', wdur );        % if pull-out, goto withdrawal
else           % early moves allowed
    if this_side==0, %left trial
        SetState( 'PreChord', 'Tup', 'Chord', 'Time', wdur, ...                         % why have reward here?
            'Lin', 'Reward',  'Rin', 'NoReward' );
    else
        SetState( 'PreChord', 'Tup', 'Chord', 'Time', wdur, ...
            'Lin', 'NoReward','Rin', 'Reward' );
    end
end

if this_side==0, %left trial
    SetState( 'Chord',      'Tup', 'WaitForPoke', 'Time', cdur, 'Aout', 1, ...          % go signal
        'Lin', 'Reward',    'Rin', 'NoReward' );
    SetState( 'WaitForPoke','Lin', 'Reward', 'Rin', 'NoReward' );                       % rewardavailability time
    SetState( 'Reward',     'Tup', 'Drink', 'Time', lwvt, 'Dout', 1 );                  % in correct reward poke, deliver water, allow drink time
else
    SetState( 'Chord',      'Tup', 'WaitForPoke', 'Time', cdur, 'Aout', 1, ...
        'Lin', 'NoReward',  'Rin', 'Reward' );
    SetState( 'WaitForPoke','Lin', 'NoReward', 'Rin', 'Reward' );
    SetState( 'Reward',     'Tup', 'Drink', 'Time', rwvt, 'Dout', 2 );
end

SetState( 'Drink',               'Tup',  'ITIState',   'Time', drkt );                  % note: water delivered in 'reward' state; state just gives drink-time
SetRetriggerState( 'ITIState',   'Tup',  'S35',      'Time', wntime, 'Aout', wnsound, 'Loop', itiloop );    % trial up; play white noise; what's loop?
SetRetriggerState( 'NoReward',   'Tup',  'ITIState', 'Time', wntime, 'Aout', wnsound, 'Loop', errorloop );  % all white-noise playing stages need to be retriggered
SetRetriggerState( 'Withdrawal', 'Tup',  'BaseState', 'Time', wntime, 'Aout', wnsound, 'Loop', withdrawalloop ); % premature withdrawal- time out

stm = CreateStateMatrix;

%error('here');
return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         MakeSounds
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sounds] = MakeSounds()

SoundDur =GetParam(me,'SoundDur');
DelayDur =GetParam(me,'Delay');
ChordDur =GetParam(me,'ChordDur');
RampDur  =GetParam(me,'RampDur');
GO_SPL      =GetParam(me,'GOSPL');
f1f2_SPL      =GetParam(me,'F1F2SPL');
BaseFreq =GetParam(me,'BaseFreq') * 1000;
NTones   =GetParam(me,'NTones');
ntrials  =GetParam(me,'Trials');
type_list=GetParam(me,'TypeList');
side_list=GetParam(me,'SideList');
center_list=GetParam(me,'CenterList');

sounds = cell(3,1);
chord = MakeChord( 50e6/1024, 70-GO_SPL, BaseFreq, NTones, ChordDur*1000, RampDur*1000 );
thistype = type_list(ntrials+2);
f1 = GetParam( me, ['T', int2str(thistype), 'F1'] );
f2 = GetParam( me, ['T', int2str(thistype), 'F2'] );

zros = zeros(1,length(chord));
if center_list(ntrials+2)==1 %LEFT/RIGHT trial:
    if side_list(ntrials+2)==0, %left side trials
        sounds{1} = [chord; zros]';
    else                        %right side trials
        sounds{1} = [zros; chord]';
    end;
else                         %CENTER TRIAL
    sounds{1} = [chord; chord]';
end
snd = Make2Sines( 50e6/1024, 70-f1f2_SPL-6, f1*1000, f2*1000, SoundDur*1000, DelayDur*1000, RampDur*1000 );
sounds{2} = snd; %[snd; snd]';
sounds{3} = 0.05*rand(1,floor(GetParam(me, 'WNTimeUnit')*50e6/1024));
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         CheckParam - to avoid crash due to incomplete user input
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function par = CheckParam( who, parname, minval, maxval, defval )

par = GetParam( who, parname );
if (isempty(par) | par<minval | par>maxval )
    setParam( who, parname, defval );
    par = defval;
end

return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         position -- for putting items in a figure
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [pos] = position(rownum, colnum, mywidth)

if nargin<3, mywidth = 1; end;

itemwidth = 100; itemheight = 20;
pos = [(colnum-1)*itemwidth+1 (rownum-1)*itemheight mywidth*itemwidth itemheight];
return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                me  : returns name of current mfile
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [myname] = me
myname = lower(mfilename);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       callback  : returns name of current mfile followed by
%                semicolon
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [myname] = callback
myname = [me ';'];





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function InitStateMatrix

global statematrix
statematrix=[];
statematrix.max_states = 128;
statematrix.state = cell(1,statematrix.max_states);
for k=1:statematrix.max_states,
    statematrix.state{k}.name = '';
    statematrix.state{k}.no = 0;
    statematrix.state{k}.created = 0;
end
statematrix.state{1}.name = 'Start';  %start state
statematrix.state{1}.no   = 0;
statematrix.state{2}.name = 'S35';   %end state
statematrix.state{2}.no   = 35;
statematrix.number_of_states = 2;
statematrix.next_no = 1;
statematrix.created = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function InitState( statename )

global statematrix
nos = statematrix.number_of_states+1;
if nos>statematrix.max_states
    error( 'Maximum Number of States exceeded' );
end
statematrix.state{nos}.name = statename;
statematrix.state{nos}.no   = statematrix.next_no;
statematrix.number_of_states = statematrix.number_of_states + 1;
statematrix.next_no = statematrix.next_no + 1;
if (statematrix.next_no == 35 ) %skip since already occupied
    statematrix.next_no = statematrix.next_no + 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function stateno = GetStateNumber( statename )

global statematrix

%can only be called after CreateStateMatrix has been called
if statematrix.created == 0,
    error( 'Illegal Call: Need to Create State Matrix First' );
end

eval( ['stateno = statematrix.statecodes.', statename , ';' ] );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function n = GetStateIndex( statename )

global statematrix
for k=1:statematrix.max_states
    if ( strcmp( statematrix.state{k}.name, statename ) )
        n=k;
        return;
    end
end
error( 'Non-Existent State' );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SetState( thisstate, varargin )

%don't change order here!
pairs = { ...
    'Def'    thisstate  ; ...
    'Cin'           []  ; ...
    'Cout'          []  ; ...
    'Lin'           []  ; ...
    'Lout'          []  ; ...
    'Rin'           []  ; ...
    'Rout'          []  ; ...
    'Tup'           []  ; ...
    'Time'         10  ; ...
    'Aout'           0  ; ...
    'Dout'           0  ; ...
    }; parseargs(varargin, pairs);


global statematrix

n = GetStateIndex( thisstate );

if (statematrix.state{n}.created==1)
    error( ['attempt to overwrite state ' thisstate] );
end

for i=1:rows(pairs),
    eval(['statematrix.state{' int2str(n) '}.' pairs{i,1} ' = ' pairs{i,1} ';']);
end;

%Fill in Default Values for 'Cin-Tup' if Arguments have not been provided
for i=2:8
    eval( ['emptystate = isempty(' pairs{i,1} ');' ] );
    if emptystate,
        eval(['statematrix.state{' int2str(n) '}.' pairs{i,1} ' =  statematrix.state{n}.Def;']);
    end
end;
statematrix.state{n}.created=1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SetRetriggerState( thisstate, varargin )

%don't change order here!
pairs = { ...
    'Def'    thisstate  ; ...
    'Cin'           []  ; ...
    'Cout'          []  ; ...
    'Lin'           []  ; ...
    'Lout'          []  ; ...
    'Rin'           []  ; ...
    'Rout'          []  ; ...
    'Tup'           []  ; ...
    'Time'          10  ; ...
    'Aout'           0  ; ...
    'Dout'           0  ; ...
    'Loop'           1  ; ...
    }; parseargs(varargin, pairs);

global statematrix

%Initialize Transitional Retrigger States
retriggerstate{1} = thisstate;
for k=2:Loop
    retriggerstate{k} = [ 'R', thisstate, int2str(k) ];
    InitState( retriggerstate{k} );
end

%Initialize Actual States
for k=1:Loop
    actualstate{k} = [ 'A', thisstate, int2str(k) ];
    InitState( actualstate{k} );
end

%Connect States
for k=1:Loop

    %k-th Retrigger State goes to k-th Actual state
    SetState( retriggerstate{k}, 'Def', retriggerstate{1}, 'Tup', actualstate{k}, 'Time', 0.03 );

    if (k<Loop)
        %k-th Actual State goes to k+1-th Retrigger State
        SetState( actualstate{k}, 'Def', retriggerstate{1}, 'Tup', retriggerstate{k+1}, ...
            'Time', Time, 'Aout', Aout, 'Dout', Dout );

    else
        %Final Actual State goes to user-provided States
        n = GetStateIndex( actualstate{k} );

        for i=1:rows(pairs),
            eval(['statematrix.state{' int2str(n) '}.' pairs{i,1} ' = ' pairs{i,1} ';']);
        end;

        %Fill in Default Values for 'Cin-Tup' if Arguments have not been provided
        for i=2:8
            eval( ['emptystate = isempty(' pairs{i,1} ');' ] );
            if emptystate,
                eval(['statematrix.state{' int2str(n) '}.' pairs{i,1} ' =  statematrix.state{n}.Def;']);
            end
        end;
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function stm = CreateStateMatrix

global statematrix

%To speed things up, first define variable names, identical to
%state names, whose value correspond to state number

for k=1:statematrix.number_of_states
    eval(['statematrix.statecodes.' statematrix.state{k}.name ' = statematrix.state{k}.no;'] );
end

stm = zeros( length(statematrix.state), 10 );
for k=1:statematrix.number_of_states
    eval( ['stm(' int2str(statematrix.state{k}.no+1) ',1)  = statematrix.statecodes.', statematrix.state{k}.Cin  ';'] );
    eval( ['stm(' int2str(statematrix.state{k}.no+1) ',2)  = statematrix.statecodes.', statematrix.state{k}.Cout ';'] );
    eval( ['stm(' int2str(statematrix.state{k}.no+1) ',3)  = statematrix.statecodes.', statematrix.state{k}.Lin  ';'] );
    eval( ['stm(' int2str(statematrix.state{k}.no+1) ',4)  = statematrix.statecodes.', statematrix.state{k}.Lout ';'] );
    eval( ['stm(' int2str(statematrix.state{k}.no+1) ',5)  = statematrix.statecodes.', statematrix.state{k}.Rin  ';'] );
    eval( ['stm(' int2str(statematrix.state{k}.no+1) ',6)  = statematrix.statecodes.', statematrix.state{k}.Rout ';'] );
    eval( ['stm(' int2str(statematrix.state{k}.no+1) ',7)  = statematrix.statecodes.', statematrix.state{k}.Tup  ';'] );
    eval( ['stm(' int2str(statematrix.state{k}.no+1) ',8)  = statematrix.state{k}.Time;' ] );
    eval( ['stm(' int2str(statematrix.state{k}.no+1) ',9)  = statematrix.state{k}.Dout;' ] );
    eval( ['stm(' int2str(statematrix.state{k}.no+1) ',10) = statematrix.state{k}.Aout;' ] );
end
statematrix.created = 1;
