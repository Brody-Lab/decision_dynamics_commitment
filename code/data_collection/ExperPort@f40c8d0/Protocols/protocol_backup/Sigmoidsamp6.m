function [out] = Tone2Sweeps(varargin)

% Recommended use: start with LeftAutoPilot on, but RightAutoPilot off. One at a time...
% LeftAutoPilot:  follow automatic stimulus trajectory for left port trials  (two trajectories for l port);
% RightAutoPilot: follow automatic stimulus trajectory for right port trials (two trajectories for r port);
% TrajSteps:      number of steps in trajectory. Currently not adjustable!!    
% TrajTrace:      number of previous (same side, same type) trials examined to ask whether we should go to the next step
% TrajPCorrect:   if the last TrajTrace steps at this step in the trajectory, for this side and this type, had >= TrajPCorrect, go to next step
% 
% TypeStubbornness: stubbornness with which you return to the same type if you make a mistake. (Same type *within* same side)
% TypeMaxSame:    maximum streak length (within same side)
% MaxSame:        maximum side streak length
% Stubbornness:   side stubbornness (ignoring type)
% 
% LType1Prob:     prob of getting type 1 (top trace in Lt rewards plot) in left side
% RType1Prob:     prob of getting type 1 (top trace in Rt rewards plot) in right side

% FOR SWEEPS TO GENERALIZED SWEEPS:
TrajSteps = 10;
L0TrajStart = [2.5  10  300  0];
L0TrajStop  = [3.5  12  300  0];
L1TrajStart = [2.5  10  300  0];
L1TrajStop  = [1   3.5  300  0];

R0TrajStart = [10  2.5  300  0];
R0TrajStop  = [3.5   1  300  0];
R1TrajStart = [10  2.5  300  0];
R1TrajStop  = [12  3.5  300  0];

DTrajSteps = 10;

persistent SSToneDur SSValidSoundTime SSMinValidPokeDur SSMaxValidPokeDur;

SSToneDur         = 0.25;
SSValidSoundTime  = 0.36;
SSMinValidPokeDur = 0.38;
SSMaxValidPokeDur = 0.43;

% % FOR TONES TO GENERALIZED SWEEPS:
% TrajSteps = 60;
% L0TrajStart = [2.5 2.5];
% L0TrajStop  = [3.5  12];
% L1TrajStart = [2.5 2.5];
% L1TrajStop  = [1   3.5];
% 
% R0TrajStart = [10   10];
% R0TrajStop  = [3.5   1];
% R1TrajStart = [10   10];
% R1TrajStop  = [12  3.5];


global exper

if nargin > 0 
    action = lower(varargin{1});
else
    action = lower(get(gcbo,'tag'));
end

out=1; 
% action,
switch action
    
    case 'init'
        ModuleNeeds(me, {'rpbox'});
        SetParam(me,'priority','value',GetParam('rpbox','priority')+1);
        fig = ModuleFigure(me,'visible','off');	
            
        rownum = 1; colnum = 1;

        InitializeUIEditParam('ITILength',                               1, rownum, colnum);   rownum = rownum+1;
        InitializeUIMenuParam('ITISound',    {'silence', 'white noise'}, 2, rownum, colnum);   rownum = rownum+1;
        InitializeUIMenuParam('ExtraITIonError', {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15'},...
                                                                         5, rownum, colnum);   rownum = rownum+1;
        InitializeUIEditParam('TimeOutLength',                         0.7, rownum, colnum);   rownum = rownum+1;
        InitializeUIMenuParam('TimeOutSound',{'silence', 'white noise'}, 2, rownum, colnum);   rownum = rownum+1;
        rownum = rownum+0.5; % Blank row
        InitializeUIEditParam('MaxValidPokeDur',                       0.45, rownum, colnum);  rownum = rownum+1;
        InitializeUIEditParam('MinValidPokeDur',                        0.3, rownum, colnum);  rownum = rownum+1;
        InitializeUIEditParam('VpdsHazardRate',                        0.01, rownum, colnum);  rownum = rownum+1;
        InitializeUIEditParam('DrinkTime',                                1, rownum, colnum);  rownum = rownum+1;
        rownum = rownum+0.5; % Blank row

        InitializeUIEditParam('ValidSoundTime',                        0.3, rownum, colnum);   rownum = rownum+1;
        InitializeUIEditParam('ToneDur',                               0.2, rownum, colnum);   rownum = rownum+1; 
        InitializeUIEditParam('RampDur',                             0.005, rownum, colnum);   rownum = rownum+1; 
        rownum = rownum+0.5; % Blank row
        InitializeUIEditParam('LastCpokeMins',                           5, rownum, colnum);   rownum = rownum+1;
        InitializeUIMenuParam('LastTrials', {'90', '150', '210', '270', '330', '390', '450'}, 1, rownum, colnum);   rownum = rownum+1;
        rownum = rownum+1;
        InitializeUIMenuParam('RightAutoPilot', {'off', 'on'},            1, rownum, colnum);   rownum = rownum+1;
        InitializeUIMenuParam('LeftAutoPilot',  {'off', 'on'},            2, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('TrajSteps',                        TrajSteps, rownum, colnum); rownum = rownum + 1;
        stepsmenu = {}; for i=0:GetParam(me, 'TrajSteps')-1, stepsmenu = [stepsmenu {num2str(i)}]; end;
        InitializeUIEditParam('TrajTrace',                                6, rownum, colnum);   rownum = rownum+1;
        InitializeUIEditParam('TrajPCorrect',                           0.8, rownum, colnum);   rownum = rownum+1;
        rownum = rownum + 1;
        InitializeUIEditParam('RatName',                          'ratname', rownum, colnum);   rownum = rownum+1;
        InitializeUIPushParam('SaveSettings',                                rownum, colnum);   rownum = rownum+1;
        InitializeUIPushParam('LoadSettings',                                rownum, colnum);   rownum = rownum+1;
        rownum = rownum + 0.5;
        InitializeUIPushParam('SaveData',                                    rownum, colnum);   rownum = rownum+1;
        InitializeUIPushParam('LoadData',                                    rownum, colnum);   rownum = rownum+1;
        
        
        rownum = 1; colnum = 3;
        InitializeUIEditParam('LeftWValveTime',                        0.2, rownum, colnum);   rownum = rownum+1;
        InitializeUIEditParam('RightWValveTime',                      0.14, rownum, colnum);   rownum = rownum+1;
        InitializeUIEditParam('LeftProb',                              0.5, rownum, colnum);   rownum = rownum+1;
        rownum = rownum+0.5; % Blank row
        InitializeUIDispParam('CenterPokes',                             0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('LeftPokes',                               0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('RightPokes',                              0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('LeftRewards',                             0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('RightRewards',                            0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('Rewards',                                 0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('Trials',                                  0, rownum, colnum);   rownum = rownum+1;
        InitializeUIMenuParam('WaterDelivery', {'direct', 'next correct poke', 'only if next poke correct'}, 3, rownum, colnum); rownum = rownum+1;
        InitializeUIMenuParam('RewardPorts',   {'correct port', 'both ports'},1,rownum,colnum);rownum = rownum+1;
        
        rownum = rownum+0.5;
        InitParam(me,  'LeftPort',   'ui', 'togglebutton', 'pref', 0, 'enable', 'inact', 'pos', position(rownum, colnum, 0.4));
        SetParamUI(me, 'LeftPort',   'label', '', 'enable', 'inact', 'String', 'Left');
        InitParam(me,  'CenterPort', 'ui', 'togglebutton', 'pref', 0, 'enable', 'inact', 'pos', position(rownum, colnum+0.5, 0.4));
        SetParamUI(me, 'CenterPort', 'label', '', 'enable', 'inact', 'String', 'Center');
        InitParam(me,  'RightPort',  'ui', 'togglebutton', 'pref', 0, 'enable', 'inact', 'pos', position(rownum, colnum+1, 0.4));
        SetParamUI(me, 'RightPort',  'label', '', 'enable', 'inact', 'String', 'Right'); rownum = rownum+1;
        
        rownum = rownum+0.5;
        InitializeUIEditParam('Stubbornness',                            0.2, rownum, colnum);   rownum = rownum + 1;
        InitializeUIEditParam('TypeStubbornness',                          1, rownum, colnum);   rownum = rownum + 1;
        InitializeUIMenuParam('MaxSame', {'1' '2' '3' '4' '5' '6' '7' '8' '9' '10' 'Inf'},6, rownum, colnum); rownum = rownum + 1;
        InitializeUIMenuParam('TypeMaxSame', {'1' '2' '3' '4' '5' '6' '7' '8' '9' '10' 'Inf'},3, rownum, colnum); rownum = rownum + 1;
        rownum = rownum+0.5;
        InitializeUIPushParam('StandardSettings',                             rownum, colnum);   rownum = rownum + 1;
        SetParamUI(me, 'StandardSettings', 'ToolTip', sprintf('Sets ToneDur=%g, ValidSoundTime=%g, MinValidPokeDur=%g, MaxValidPokeDur=%g, WaterDelivery=only if next poke correct', SSToneDur, SSValidSoundTime, SSMinValidPokeDur, SSMaxValidPokeDur));
        rownum = rownum+0.5;
        InitializeUIMenuHalfLeftParam('YokeDelay',   {'off', 'on'},        2, rownum, colnum);   rownum = rownum + 1;
        InitializeUIMenuHalfLeftParam('DAutoPilot',   {'off', 'on'},       2, rownum, colnum);   rownum = rownum + 1;
        InitializeUIDispHalfLeftParam('DTrajSteps',               DTrajSteps, rownum, colnum);   rownum = rownum + 1;  SetParamUI(me, 'DTrajSteps', 'label', 'DTrajSteps');
        dstepsmenu = {}; for i=0:GetParam(me, 'DTrajSteps')-1, dstepsmenu = [dstepsmenu {num2str(i)}]; end;
        InitializeUIEditHalfLeftParam('DTrace',                           20, rownum, colnum);   rownum = rownum + 1;  SetParamUI(me, 'DTrace',     'label', 'DTrace');
        InitializeUIEditHalfLeftParam('DPCorr',                         0.75, rownum, colnum);   rownum = rownum + 1;  SetParamUI(me, 'DPCorr',     'label', 'DPCorr');
        InitializeUIEditHalfLeftParam('MinDP',                           0.6, rownum, colnum);   rownum = rownum + 1;  SetParamUI(me, 'MinDP',      'label', 'MinDP');
        pos = position(rownum, colnum); rownum = rownum + 1;
        InitParam(me, 'DTrajStart', 'ui', 'edit', 'value',  40, 'pos', [pos(1) pos(2) pos(3)/3 pos(4)],          'user', 1);  SetParamUI(me, 'DTrajStart', 'label', '');
        InitParam(me, 'DTrajStop',  'ui', 'edit', 'value', 200, 'pos', [pos(1)+pos(3)/3 pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'DTrajStop', 'label', 'DTraj');
        InitializeUIMenuHalfLeftParam('DCurrS', dstepsmenu,                1, rownum, colnum); rownum = rownum + 1;
        
        
        remove_pref('R0CurrS'); remove_pref('R1CurrS'); remove_pref('L0CurrS'); remove_pref('L1CurrS');
        remove_pref('R0Start'); remove_pref('R0End');   remove_pref('R1Start'); remove_pref('R1End');
        remove_pref('L0Start'); remove_pref('L0End');   remove_pref('L1Start'); remove_pref('L1End');
        InitParam(me, 'L0TrajStart', 'value', L0TrajStart);      InitParam(me, 'L0TrajStop', 'value', L0TrajStop);
        InitParam(me, 'L1TrajStart', 'value', L1TrajStart);      InitParam(me, 'L1TrajStop', 'value', L1TrajStop);
        InitParam(me, 'R0TrajStart', 'value', R0TrajStart);      InitParam(me, 'R0TrajStop', 'value', R0TrajStop);
        InitParam(me, 'R1TrajStart', 'value', R1TrajStart);      InitParam(me, 'R1TrajStop', 'value', R1TrajStop);
        
        rownum = 1; colnum = 5.5;
        InitializeUIDispHalfLeftParam('R0Last10',                                  0, rownum, colnum);   rownum = rownum + 1;
        InitializeUIDispHalfLeftParam('R0Last20',                                  0, rownum, colnum);   rownum = rownum + 1;
        InitializeUIDispHalfLeftParam('R0Last40',                                  0, rownum, colnum);   rownum = rownum + 1;
        InitializeUIDispHalfLeftParam('R0Last80',                                  0, rownum, colnum);   rownum = rownum + 1;
        colnum = colnum - 0.5;
        pos = position(rownum, colnum); 
        InitParam(me, 'R0Start', 'ui', 'edit', 'value', R0TrajStart(1), 'pos', [pos(1) pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'R0Start', 'label', '');
        InitParam(me, 'R0End',   'ui', 'edit', 'value', R0TrajStart(2), 'pos', [pos(1)+pos(3)/3 pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'R0End', 'label', 'R0');
        pos = position(rownum, colnum+1); rownum = rownum + 1;
        InitParam(me, 'R0Tau',   'ui', 'edit', 'value', R0TrajStart(3), 'pos', [pos(1) pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'R0Tau', 'label', '');
        InitParam(me, 'R0Break', 'ui', 'edit', 'value', R0TrajStart(4), 'pos', [pos(1)+pos(3)/3 pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'R0Break', 'label', '');        
        InitializeUIMenuHalfLeftParam('R0CurrS', stepsmenu,                        1, rownum, colnum+0.5);   rownum = rownum + 1;
        InitializeUIEditParam('RType1Prob',                                      0.5, rownum, colnum+1.5);   rownum = rownum+1;

        rownum = rownum + 1;
        colnum = colnum + 0.5;
        InitializeUIDispHalfLeftParam('L0Last10',                                  0, rownum, colnum);   rownum = rownum + 1;
        InitializeUIDispHalfLeftParam('L0Last20',                                  0, rownum, colnum);   rownum = rownum + 1;
        InitializeUIDispHalfLeftParam('L0Last40',                                  0, rownum, colnum);   rownum = rownum + 1;
        InitializeUIDispHalfLeftParam('L0Last80',                                  0, rownum, colnum);   rownum = rownum + 1;
        colnum = colnum - 0.5;
        pos = position(rownum, colnum); 
        InitParam(me, 'L0Start', 'ui', 'edit', 'value', L0TrajStart(1), 'pos', [pos(1) pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'L0Start', 'label', '');
        InitParam(me, 'L0End',   'ui', 'edit', 'value', L0TrajStart(2), 'pos', [pos(1)+pos(3)/3 pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'L0End', 'label', 'L0');
        pos = position(rownum, colnum+1); rownum = rownum + 1;
        InitParam(me, 'L0Tau',   'ui', 'edit', 'value', L0TrajStart(3), 'pos', [pos(1) pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'L0Tau', 'label', '');
        InitParam(me, 'L0Break', 'ui', 'edit', 'value', L0TrajStart(4), 'pos', [pos(1)+pos(3)/3 pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'L0Break', 'label', '');        
        InitializeUIMenuHalfLeftParam('L0CurrS', stepsmenu,                         1, rownum, colnum+0.5);   rownum = rownum+1;
        InitializeUIEditParam('LType1Prob',                                       0.5, rownum, colnum+1.5);   rownum = rownum+1;

        rownum = 1; colnum = 7;
        InitializeUIDispHalfRightParam('R1Last10',                                  0, rownum, colnum);   rownum = rownum + 1;
        InitializeUIDispHalfRightParam('R1Last20',                                  0, rownum, colnum);   rownum = rownum + 1;
        InitializeUIDispHalfRightParam('R1Last40',                                  0, rownum, colnum);   rownum = rownum + 1;
        InitializeUIDispHalfRightParam('R1Last80',                                  0, rownum, colnum);   rownum = rownum + 1;
        pos = position(rownum, colnum);
        InitParam(me, 'R1Start', 'ui', 'edit', 'value', R1TrajStart(1), 'pos', [pos(1) pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'R1Start', 'label', '');
        InitParam(me, 'R1End',   'ui', 'edit', 'value', R1TrajStart(2), 'pos', [pos(1)+pos(3)/3 pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'R1End', 'label', 'R1');
        pos = position(rownum, colnum+1); rownum = rownum + 1;
        InitParam(me, 'R1Tau',   'ui', 'edit', 'value', R1TrajStart(3), 'pos', [pos(1) pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'R1Tau', 'label', '');
        InitParam(me, 'R1Break', 'ui', 'edit', 'value', R1TrajStart(4), 'pos', [pos(1)+pos(3)/3 pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'R1Break', 'label', '');        
        InitializeUIMenuHalfLeftParam('R1CurrS', stepsmenu,                         1, rownum, colnum+0.5); rownum = rownum + 1;
        rownum = rownum + 2;
        
        InitializeUIDispHalfRightParam('L1Last10',                                  0, rownum, colnum);   rownum = rownum + 1;
        InitializeUIDispHalfRightParam('L1Last20',                                  0, rownum, colnum);   rownum = rownum + 1;
        InitializeUIDispHalfRightParam('L1Last40',                                  0, rownum, colnum);   rownum = rownum + 1;
        InitializeUIDispHalfRightParam('L1Last80',                                  0, rownum, colnum);   rownum = rownum + 1;
        pos = position(rownum, colnum);
        InitParam(me, 'L1Start', 'ui', 'edit', 'value', L1TrajStart(1), 'pos', [pos(1) pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'L1Start', 'label', '');
        InitParam(me, 'L1End',   'ui', 'edit', 'value', L1TrajStart(2), 'pos', [pos(1)+pos(3)/3 pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'L1End', 'label', 'L1');
        pos = position(rownum, colnum+1); rownum = rownum + 1;
        InitParam(me, 'L1Tau',   'ui', 'edit', 'value', L1TrajStart(3), 'pos', [pos(1) pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'L1Tau', 'label', '');
        InitParam(me, 'L1Break', 'ui', 'edit', 'value', L1TrajStart(4), 'pos', [pos(1)+pos(3)/3 pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'L1Break', 'label', '');        
        InitializeUIMenuHalfLeftParam('L1CurrS', stepsmenu,                         1, rownum, colnum+0.5);   rownum = rownum + 1;
        rownum = rownum + 2;

        
        colnum = 5.75;
        InitializeUIDispHalfRightParam('Last10',                                  0, rownum, colnum);   rownum = rownum + 1;
        InitializeUIDispHalfRightParam('Last20',                                  0, rownum, colnum);   rownum = rownum + 1;
        InitializeUIDispHalfRightParam('Last40',                                  0, rownum, colnum);   rownum = rownum + 1;
        InitializeUIDispHalfRightParam('Last80',                                  0, rownum, colnum);   rownum = rownum + 1;
        rownum = rownum + 1;
        start_traj_row = rownum;        
        
        colnum = 4.5;
        pos = position(rownum, colnum);
        InitParam(me, 'R0TStopF0',  'ui', 'edit', 'value', R0TrajStop(1),  'pos', [pos(1) pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'R0TStopF0', 'label', '');
        InitParam(me, 'R0TStopF1',  'ui', 'edit', 'value', R0TrajStop(2),  'pos', [pos(1)+pos(3)/3 pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'R0TStopF1', 'label', 'R0TP');
        pos = position(rownum, colnum+1.1); rownum = rownum + 1;
        InitParam(me, 'R0TStopTau', 'ui', 'edit', 'value', R0TrajStop(3),  'pos', [pos(1) pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'R0TStopTau', 'label', '');
        InitParam(me, 'R0TStopBk',  'ui', 'edit', 'value', R0TrajStop(4),  'pos', [pos(1)+pos(3)/3 pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'R0TStopBk', 'label', '');        
        pos = position(rownum, colnum);
        InitParam(me, 'R0TStartF0', 'ui', 'edit', 'value', R0TrajStart(1), 'pos', [pos(1) pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'R0TStartF0', 'label', '');
        InitParam(me, 'R0TStartF1', 'ui', 'edit', 'value', R0TrajStart(2), 'pos', [pos(1)+pos(3)/3 pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'R0TStartF1', 'label', 'R0TS');
        pos = position(rownum, colnum+1.1); rownum = rownum + 1;
        InitParam(me, 'R0TStartTau','ui', 'edit', 'value', R0TrajStart(3), 'pos', [pos(1) pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'R0TStartTau', 'label', '');
        InitParam(me, 'R0TStartBk', 'ui', 'edit', 'value', R0TrajStart(4), 'pos', [pos(1)+pos(3)/3 pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'R0TStartBk', 'label', '');        
        rownum = rownum+0.5;
        pos = position(rownum, colnum);
        InitParam(me, 'L0TStopF0',  'ui', 'edit', 'value', L0TrajStop(1),  'pos', [pos(1) pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'L0TStopF0', 'label', '');
        InitParam(me, 'L0TStopF1',  'ui', 'edit', 'value', L0TrajStop(2),  'pos', [pos(1)+pos(3)/3 pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'L0TStopF1', 'label', 'L0TP');
        pos = position(rownum, colnum+1.1); rownum = rownum + 1;
        InitParam(me, 'L0TStopTau', 'ui', 'edit', 'value', L0TrajStop(3),  'pos', [pos(1) pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'L0TStopTau', 'label', '');
        InitParam(me, 'L0TStopBk',  'ui', 'edit', 'value', L0TrajStop(4),  'pos', [pos(1)+pos(3)/3 pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'L0TStopBk', 'label', '');        
        pos = position(rownum, colnum);
        InitParam(me, 'L0TStartF0', 'ui', 'edit', 'value', L0TrajStart(1), 'pos', [pos(1) pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'L0TStartF0', 'label', '');
        InitParam(me, 'L0TStartF1', 'ui', 'edit', 'value', L0TrajStart(2), 'pos', [pos(1)+pos(3)/3 pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'L0TStartF1', 'label', 'L0TS');
        pos = position(rownum, colnum+1.1); rownum = rownum + 1;
        InitParam(me, 'L0TStartTau','ui', 'edit', 'value', L0TrajStart(3), 'pos', [pos(1) pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'L0TStartTau', 'label', '');
        InitParam(me, 'L0TStartBk', 'ui', 'edit', 'value', L0TrajStart(4), 'pos', [pos(1)+pos(3)/3 pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'L0TStartBk', 'label', '');        
        
        
        colnum = 7; rownum = start_traj_row;
        pos = position(rownum, colnum);
        InitParam(me, 'R1TStopF0',  'ui', 'edit', 'value', R1TrajStop(1),  'pos', [pos(1) pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'R1TStopF0', 'label', '');
        InitParam(me, 'R1TStopF1',  'ui', 'edit', 'value', R1TrajStop(2),  'pos', [pos(1)+pos(3)/3 pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'R1TStopF1', 'label', 'R1TP');
        pos = position(rownum, colnum+1.1); rownum = rownum + 1;
        InitParam(me, 'R1TStopTau', 'ui', 'edit', 'value', R1TrajStop(3),  'pos', [pos(1) pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'R1TStopTau', 'label', '');
        InitParam(me, 'R1TStopBk',  'ui', 'edit', 'value', R1TrajStop(4),  'pos', [pos(1)+pos(3)/3 pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'R1TStopBk', 'label', '');        
        pos = position(rownum, colnum);
        InitParam(me, 'R1TStartF0', 'ui', 'edit', 'value', R1TrajStart(1), 'pos', [pos(1) pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'R1TStartF0', 'label', '');
        InitParam(me, 'R1TStartF1', 'ui', 'edit', 'value', R1TrajStart(2), 'pos', [pos(1)+pos(3)/3 pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'R1TStartF1', 'label', 'R1TS');
        pos = position(rownum, colnum+1.1); rownum = rownum + 1;
        InitParam(me, 'R1TStartTau','ui', 'edit', 'value', R1TrajStart(3), 'pos', [pos(1) pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'R1TStartTau', 'label', '');
        InitParam(me, 'R1TStartBk', 'ui', 'edit', 'value', R1TrajStart(4), 'pos', [pos(1)+pos(3)/3 pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'R1TStartBk', 'label', '');        
        rownum = rownum+0.5;
        pos = position(rownum, colnum);
        InitParam(me, 'L1TStopF0',  'ui', 'edit', 'value', L1TrajStop(1),  'pos', [pos(1) pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'L1TStopF0', 'label', '');
        InitParam(me, 'L1TStopF1',  'ui', 'edit', 'value', L1TrajStop(2),  'pos', [pos(1)+pos(3)/3 pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'L1TStopF1', 'label', 'L1TP');
        pos = position(rownum, colnum+1.1); rownum = rownum + 1;
        InitParam(me, 'L1TStopTau', 'ui', 'edit', 'value', L1TrajStop(3),  'pos', [pos(1) pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'L1TStopTau', 'label', '');
        InitParam(me, 'L1TStopBk',  'ui', 'edit', 'value', L1TrajStop(4),  'pos', [pos(1)+pos(3)/3 pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'L1TStopBk', 'label', '');        
        pos = position(rownum, colnum);
        InitParam(me, 'L1TStartF0', 'ui', 'edit', 'value', L1TrajStart(1), 'pos', [pos(1) pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'L1TStartF0', 'label', '');
        InitParam(me, 'L1TStartF1', 'ui', 'edit', 'value', L1TrajStart(2), 'pos', [pos(1)+pos(3)/3 pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'L1TStartF1', 'label', 'L1TS');
        pos = position(rownum, colnum+1.1); rownum = rownum + 1;
        InitParam(me, 'L1TStartTau','ui', 'edit', 'value', L1TrajStart(3), 'pos', [pos(1) pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'L1TStartTau', 'label', '');
        InitParam(me, 'L1TStartBk', 'ui', 'edit', 'value', L1TrajStart(4), 'pos', [pos(1)+pos(3)/3 pos(2) pos(3)/3 pos(4)], 'user', 1);  SetParamUI(me, 'L1TStartBk', 'label', '');        
        
        
        InitParam(me, 'CurrentBreakLen');
        InitParam(me, 'LrwS',   'value', 0); InitParam(me, 'RrwS', 'value', 0); % state #'s for Left  and Right  reward
        InitParam(me, 'LddS',   'value', 0); InitParam(me, 'RddS', 'value', 0); % state #'s for Left  and Right  direct del
        InitParam(me, 'pstart', 'value', 2); InitParam(me, 'WpkS', 'value', 0);
        InitParam(me, 'itistart', 'value', 200); InitParam(me, 'protocolname', 'value', me);
        % set(fig, 'Visible', 'on'); return;
        
        % ------ Schedule ---------
        maxtrials = 1000; InitParam(me, 'MaxTrials',     'value', maxtrials);
        InitParam(me, 'SideList', 'value', zeros(1, maxtrials));
        InitParam(me, 'TypeList', 'value', zeros(1, maxtrials));
        set_future_sides(1);
        InitParam(me, 'VpdsList', 'value', zeros(1, maxtrials));
        set_future_vpds(1);
        InitParam(me, 'RewardHistory',       'value', []);  % defined in terms of first sideport response 'hm'
        InitParam(me, 'RewardPortsHistory',  'value', []);  % trial-by-trial history of the value of RewardPort 'cb'
        InitParam(me, 'WaterDeliveryHistory','value', []);  % trial-by-trial history of water deliver method 'dno'
        initialize_plot;

        InitParam(me, 'CenterPokeTimes',     'value', zeros(1,20000)); % start times of center pokes
        InitParam(me, 'CenterPokeDurations', 'value', zeros(1,20000)); % How long each of the above was
        InitParam(me, 'CenterPokeStateHist', 'value', zeros(1,20000)); % State number in which each center poke was initiated
        InitParam(me, 'nCenterPokes',   'value', 0); InitParam(me, 'CPokeState', 'value', 0);
        InitParam(me, 'LastPokeInTime', 'value', 0); InitParam(me, 'LastPokeOutTime');
        initialize_centerpokes_plot;
        
        InitParam(me, 'L0Steps',           'value', zeros(1, maxtrials));
        InitParam(me, 'L1Steps',           'value', zeros(1, maxtrials));
        InitParam(me, 'R0Steps',           'value', zeros(1, maxtrials));
        InitParam(me, 'R1Steps',           'value', zeros(1, maxtrials));
        InitParam(me, 'DSteps',            'value', zeros(1, maxtrials));
        % enforce_current_trajectory_step;
        
        InitParam(me, 'SoundStartHistory', 'value', zeros(1, maxtrials));
        InitParam(me, 'SoundEndHistory',   'value', zeros(1, maxtrials));
        InitParam(me, 'CurrentSide',  'value', []); InitParam(me, 'CurrentHit', 'value', []);
        project_to_trajectories(1); project_to_dtraj(1);
        InitParam(me, 'Sounds',       'value', MakeSounds);
        InitParam(me, 'StateMatrix',  'value', state_transition_matrix);
        update_settings_histories;
        rpbox('InitRPSound');
        rpbox('LoadRPSound', GetParam(me,'Sounds'));
        rpbox('send_matrix', GetParam(me, 'StateMatrix'));
        InitParam(me, 'ChangeSound1', 'value', 0);
        InitParam(me, 'ChangeSound2', 'value', 0);
        InitParam(me, 'ChangeSound3', 'value', 0);
        set(fig, 'Visible', 'on');
        
        return;
        
    case 'update',
        LrwS   = GetParam(me, 'LrwS'); % Get the state numbers that correspond to Left Reward and Right Reward States
        RrwS   = GetParam(me, 'RrwS');
        WpkS   = GetParam(me, 'WpkS'); LddS = GetParam(me, 'LddS'); RddS = GetParam(me, 'RddS');
        pstart = GetParam(me, 'pstart'); 
        Event = Getparam('rpbox','event','user');
        
        for i=1:size(Event,1)
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
            
            current_side = GetParam(me, 'CurrentSide'); current_hit = GetParam(me, 'CurrentHit');
            if isempty(current_hit),  % haven't figured out yet if this trial was a hit
                if Event(i,1)==WpkS,  % we're in the post-sample tone, wait for poke act state
                    if     ( (Event(i,2)==3 & current_side=='l') | (Event(i,2)==5 & current_side=='r') ),
                        SetParam(me, 'CurrentHit', 'h');
                        SetParam(me, 'RewardHistory', [GetParam(me, 'RewardHistory') ; 'h']);
                        SetParam(me, 'Rewards',        GetParam(me, 'Rewards') +1);
                        if Event(i,2)==3,    SetParam(me, 'LeftRewards',  GetParam(me, 'LeftRewards') +1);
                        else                 SetParam(me, 'RightRewards', GetParam(me, 'RightRewards')+1);
                        end;
                    elseif ( (Event(i,2)==3 & current_side=='r') | (Event(i,2)==5 & current_side=='l') ),
                        SetParam(me, 'CurrentHit', 'm');
                        SetParam(me, 'RewardHistory', [GetParam(me, 'RewardHistory') ; 'm']);
                    end;
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
        
    case 'state35', tic,
        fp = fopen('trash.txt', 'w');
        Trials       = GetParam(me, 'Trials');
        if GetParam(me, 'CurrentHit')=='m',
            Stubbornness = GetParam(me, 'Stubbornness');
            side_list    = GetParam(me, 'SideList');
            if rand(1) <= Stubbornness, side_list(Trials+2) = side_list(Trials+1); end;
            SetParam(me, 'SideList', side_list);
            
            TypeStubbornness = GetParam(me, 'TypeStubbornness');
            type_list        = GetParam(me, 'TypeList');
            if rand(1) <= TypeStubbornness,
                u = min(find(side_list(Trials+2:end)==side_list(Trials+1)));
                if ~isempty(u), type_list(Trials+2+u-1) = type_list(Trials+1); end;
            end;
            SetParam(me, 'TypeList', type_list);
        end; 
        project_to_trajectories(Trials+2);
        check_trajectory_autopilots; check_dtraj_autopilot;
        SetParam(me, 'Trials', Trials+1); 
        sounds = MakeSounds;
        SetParam(me, 'Sounds', sounds); 
        fprintf(fp, 'After making sounds, %g\n', toc); tic,
        if GetParam(me, 'ChangeSound1'), rpbox('LoadRPSound1', sounds); SetParam(me, 'ChangeSound1', 0); end;
        if GetParam(me, 'ChangeSound2'), rpbox('LoadRPSound2', sounds); SetParam(me, 'ChangeSound2', 0); end;
        if GetParam(me, 'ChangeSound3'), rpbox('LoadRPSound3', sounds); SetParam(me, 'ChangeSound3', 0); end;
        fprintf(fp, 'After loading sounds, %g\n', toc); tic,
        SetParam(me, 'StateMatrix', state_transition_matrix);     
        Stubbornness = GetParam(me, 'Stubbornness');

        SetParam(me, 'CurrentHit',  []);

        update_plot; 
        update_settings_histories;
        update_meanhits;
        fprintf(fp, 'After updating plots, %g\n', toc); tic,
        rpbox('send_matrix', GetParam(me, 'StateMatrix'));
        fprintf(fp, 'After sending state trans mat %g\n', toc); tic,
        fclose(fp);
        
    case {'leftprob' 'ltype1prob' 'rtype1prob' 'maxsame' 'typemaxsame'},
        if GetParam('rpbox', 'state')==35, set_future_sides(GetParam(me, 'Trials')+1);
        else                               set_future_sides(GetParam(me, 'Trials')+2);
        end;
        update_plot;
                
    case 'rewardports'
        if GetParam(me, 'RewardPorts') == 1,  
            SetParamUI(me, 'WaterDelivery', 'enable', 'on',  'backgroundcolor', 'w');
        else                                  
            SetParamUI(me, 'WaterDelivery', 'enable', 'off', 'backgroundcolor', [0.8 0.8 0.8]);
%             SetParam(me, 'R0Start', 3.5); SetParam(me, 'R0End', 3.5);
%             SetParam(me, 'R1Start', 3.5); SetParam(me, 'R1End', 3.5);
%             SetParam(me, 'L0Start', 3.5); SetParam(me, 'L0End', 3.5);
%             SetParam(me, 'L1Start', 3.5); SetParam(me, 'L1End', 3.5);
        end;
        
        
    case 'reset'
        
        SetParam(me, 'Trials', 0); SetParam(me, 'Rewards', 0); SetParam(me, 'RightRewards', 0);
        SetParam(me, 'LeftRewards', 0); SetParam(me, 'RightPokes', 0); SetParam(me, 'LeftPokes', 0);
        SetParam(me, 'CenterPokes', 0);
        
        SetParam(me, 'LastPokeInTime', 'value', 0); SetParam(me, 'LastPokeOutTime', 'value', 0);
        set_future_sides(1);
        SetParam(me, 'RewardHistory',       'value', []);  % defined in terms of first sideport response 'hm'
        SetParam(me, 'RewardPortsHistory',  'value', []);  % trial-by-trial history of the value of RewardPort 'cb'
        SetParam(me, 'WaterDeliveryHistory','value', []);  % trial-by-trial history of water deliver method 'dno' 
        initialize_plot;
        
        SetParam(me, 'CurrentSide',  'value', []); SetParam(me, 'CurrentHit', 'value', []);
        SetParam(me, 'Sounds',       'value', MakeSounds);
        SetParam(me, 'StateMatrix',  'value', state_transition_matrix);
        update_settings_histories;
        rpbox('InitRPSound');
        rpbox('LoadRPSound', GetParam(me,'Sounds'));
        rpbox('send_matrix', GetParam(me, 'StateMatrix'));
        
    case {'vpdshazardrate', 'minvalidpokedur', 'maxvalidpokedur', 'ValidSoundTime'}
        check_legal_valid_poke_durs;
        set_future_vpds(GetParam(me, 'Trials')+2);
        update_plot;
   
    case 'lastcpokemins',
        update_centerpokes_plot;
        
    case 'lasttrials',
        update_plot;
        
    case 'tonedur'
        tdur = GetParam(me, 'ToneDur');
        if tdur < 0.04, tdur = 0.04; end;
        SetParam(me, 'ToneDur', tdur);
        if check_legal_valid_poke_durs,
            set_future_vpds(GetParam(me, 'Trials')+2);
            update_plot;
        end;
        
    case {'timeoutsound', 'timeoutlength'}, SetParam(me, 'ChangeSound2', 1);
    case {'itisound',     'itilength'},     SetParam(me, 'ChangeSound3', 1);
        
    case 'stubbornness',
        Stubbornness = GetParam(me, 'Stubbornness');
        if Stubbornness > 1, Stubbornness = 1; elseif Stubbornness < 0, Stubbornness=0; end;
        SetParam(me, 'Stubbornness', Stubbornness);
        
    case 'typestubbornness',
        TypeStubbornness = GetParam(me, 'TypeStubbornness');
        if TypeStubbornness > 1, TypeStubbornness = 1; elseif TypeStubbornness < 0, TypeStubbornness=0; end;
        SetParam(me, 'TypeStubbornness', TypeStubbornness);
        
    case {'l0start' 'l0end' 'l1start' 'l1end' 'r0start' 'r0end' 'r1start' 'r1end'},
        if GetParam('rpbox', 'state')==35, project_to_trajectories(GetParam(me, 'Trials')+1);
        else                               project_to_trajectories(GetParam(me, 'Trials')+2);
        end;
       
    case {'l0currs' 'l1currs' 'r0currs' 'r1currs'},
        stepnum = GetParam(me, action)-1;
        if GetParam('rpbox', 'state')==35, set_trajectory(upper(action(1:2)), stepnum, GetParam(me, 'Trials')+1);
        else                               set_trajectory(upper(action(1:2)), stepnum, GetParam(me, 'Trials')+2);
        end;
        
    case { ...
                'l0tstartf0' 'l0tstartf1' 'l0tstarttau' 'l0tstartbk' 'l0tstopf0' 'l0tstopf1' 'l0tstoptau' 'l0tstopbk' ...
                'l1tstartf0' 'l1tstartf1' 'l1tstarttau' 'l1tstartbk' 'l1tstopf0' 'l1tstopf1' 'l1tstoptau' 'l1tstopbk' ...
                'r0tstartf0' 'r0tstartf1' 'r0tstarttau' 'r0tstartbk' 'r0tstopf0' 'r0tstopf1' 'r0tstoptau' 'r0tstopbk' ...
                'r1tstartf0' 'r1tstartf1' 'r1tstarttau' 'r1tstartbk' 'r1tstopf0' 'r1tstopf1' 'r1tstoptau' 'r1tstopbk' ...
            },
        ttype     = action(1:2);
        startstop = action(4:7);       if startstop == 'star', startstop = 'start'; end;
        tentry    = action(end-1:end); if tentry    == 'au',   tentry    = 'ta';   end;
        
        traj = GetParam(me, [ttype 'traj' startstop]);
        switch tentry,
            case 'f0', traj(1) = GetParam(me, action);
            case 'f1', traj(2) = GetParam(me, action);
            case 'ta', traj(3) = GetParam(me, action);
            case 'bk', traj(4) = GetParam(me, action);
        end;
        SetParam(me, [ttype 'traj' startstop], traj);
        if GetParam('rpbox', 'state')==35, project_to_trajectories(GetParam(me, 'Trials')+1);
        else                               project_to_trajectories(GetParam(me, 'Trials')+2);
        end;

        
    case 'savesettings',
        save_uiparamvalues(me, GetParam(me, 'RatName'));
        
    case 'loadsettings',
        if load_uiparamvalues(me, GetParam(me, 'RatName')),
            for ttype = {'l0' 'l1' 'r0' 'r1'}
                for startstop = {'start' 'stop'}
                    traj = zeros(1,4);  tentry = {'f0' 'f1' 'tau' 'bk'}; 
                    for i=1:4, traj(i) = GetParam(me, [ttype{1} 't' startstop{1} tentry{i}]); end;
                    SetParam(me, [ttype{1} 'traj' startstop{1}], traj);
                end;
            end;
            if GetParam('rpbox', 'state')==35, set_future_sides(GetParam(me, 'Trials')+1); set_future_vpds(GetParam(me, 'Trials')+1);
            else                               set_future_sides(GetParam(me, 'Trials')+2); set_future_vpds(GetParam(me, 'Trials')+2);
            end;
        SetParam(me, 'ChangeSound1', 1);
        SetParam(me, 'ChangeSound2', 1);
        SetParam(me, 'ChangeSound3', 1);
        update_plot;
    
        end;
        
    case 'savedata',
        save_data(me, GetParam(me, 'RatName'));
        
    case 'loaddata',
        if load_data(me, GetParam(me, 'RatName')),
            for ttype = {'l0' 'l1' 'r0' 'r1'}
                for startstop = {'start' 'stop'}
                    traj = zeros(1,4);  tentry = {'f0' 'f1' 'tau' 'bk'}; 
                    for i=1:4, traj(i) = GetParam(me, [ttype{1} 't' startstop{1} tentry{i}]); end;
                    SetParam(me, [ttype{1} 'traj' startstop{1}], traj);
                end;
            end;
            SetParam(me, 'ChangeSound1', 1);
            SetParam(me, 'ChangeSound2', 1);
            SetParam(me, 'ChangeSound3', 1);        
            update_plot;
            update_centerpokes_plot;
        end;
        
    case 'standardsettings',
        SetParam(me, 'MinValidPokeDur', SSMinValidPokeDur);
        SetParam(me, 'MaxValidPokeDur', SSMaxValidPokeDur);
        SetParam(me, 'ToneDur',         SSToneDur);
        SetParam(me, 'ValidSoundTime',  SSValidSoundTime);
        SetParam(me, 'WaterDelivery', 3);
        set_future_vpds(GetParam(me, 'Trials')+2);
        update_plot;
                
    case {'dtrajstart', 'dtrajstop', 'yokedelay', 'dautopilot'}, 
        if GetParam('rpbox', 'state')==35, project_to_dtraj(GetParam(me, 'Trials')+1);
        else                               project_to_dtraj(GetParam(me, 'Trials')+2);
        end;
        
    case 'dcurrs'
        stepnum = GetParam(me, 'DCurrS')-1;
        if GetParam('rpbox', 'state') == 35, trialstart = GetParam(me, 'Trials')+1;
        else                                 trialstart = GetParam(me, 'Trials')+2;
        end;    
        set_dtraj(stepnum, trialstart);  
    
    otherwise
        out = 0;
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         check_trajectory_autopilots
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = check_trajectory_autopilots
    ntrace    = GetParam(me, 'TrajTrace');
    pcorr     = GetParam(me, 'TrajPCorrect');
    trials    = GetParam(me, 'Trials');
    side_list = GetParam(me, 'SideList');
    type_list = GetParam(me, 'TypeList');
    rew_hist  = GetParam(me, 'RewardHistory');
    
    if GetParam(me, 'LeftAutoPilot')==2,
        check_this_trajectory_autopilot('L0', ntrace, pcorr, trials, rew_hist, side_list, type_list);
        check_this_trajectory_autopilot('L1', ntrace, pcorr, trials, rew_hist, side_list, type_list);
    end;
    
    if GetParam(me, 'RightAutoPilot')==2,
        check_this_trajectory_autopilot('R0', ntrace, pcorr, trials, rew_hist, side_list, type_list);
        check_this_trajectory_autopilot('R1', ntrace, pcorr, trials, rew_hist, side_list, type_list);
    end;    

    return;

% ---    
    
function [] = check_this_trajectory_autopilot(trajtype, ntrace, pcorr, trials, rew_hist, side_list, type_list)
    
    switch trajtype,
        case 'L0', u = find(side_list==0 & type_list==0); 
        case 'L1', u = find(side_list==0 & type_list==1);
        case 'R0', u = find(side_list==1 & type_list==0);
        case 'R1', u = find(side_list==1 & type_list==1);
    end;  
    u = u(find(u<=trials+1));     
    if isempty(u), return; end;
    
    stephist = GetParam(me, [trajtype 'Steps']);
    if stephist(u(end)) ~= GetParam(me, [trajtype 'CurrS'])-1, return; end;
    
    us = find(stephist(u) == stephist(u(end)));
    z = max(find(diff(us)>1)); if ~isempty(z), if z+1<=length(us), us = us(z+1:end); end; end;
    if length(us) >= ntrace,
        if mean(rew_hist(u(us(end-ntrace+1:end)))=='h') >= pcorr,
            set_trajectory(trajtype, stephist(u(end))+1, trials+2);    
        end;
    end;

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         check_dtraj_autopilot
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = check_dtraj_autopilot()

    if GetParam(me, 'DAutoPilot')==1, return; end;
    
    ntrace    = GetParam(me, 'DTrace');
    pcorr     = GetParam(me, 'DPCorr');
    minp      = GetParam(me, 'MinDP');
    
    trials    = GetParam(me, 'Trials');
    side_list = GetParam(me, 'SideList');
    type_list = GetParam(me, 'TypeList');
    rew_hist  = GetParam(me, 'RewardHistory');

    set_dtraj(GetParam(me, 'DCurrS')-1, trials+2); % default is to stay at same step; 
                                                   % rest of function is to check for advancing one step
    
    if trials < ntrace, return; end;
    stephist = GetParam(me, 'DSteps');
    if stephist(trials+1) ~= GetParam(me, 'DCurrS')-1, return; end;
    
    us = find(stephist(1:trials+1) == stephist(trials+1));
    z = max(find(diff(us)>1)); if ~isempty(z), if z+1<=length(us), us = us(z+1:end); end; end;
    if length(us)<ntrace, return; end;
    
    mytrials = rew_hist(us(end-ntrace+1:end)); mymean = mean(mytrials=='h');
    if mymean <= pcorr, return; end;
    
    typemeans = []; ntrace = ceil(ntrace/2);
    for side = [0 1], 
        for ttype = [0 1],
            u = find(side_list==side & type_list==ttype);
            u = u(find(u<=trials+1));     
            if length(u)>=ntrace, 
                typemeans = [typemeans mean(rew_hist(u(end-ntrace+1:end))=='h')];
            end;
        end; 
    end;
    if ~isempty(typemeans),
        if min(typemeans)<=minp, return; end;
    end;
    set_dtraj(GetParam(me, 'DCurrS'), trials+2);
    
   
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         project_to_dtraj()
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = project_to_dtraj(trialnum)
    if GetParam(me, 'YokeDelay')==1, return; end;
    
    d = [];
    for ttype = {'L0' 'L1' 'R0' 'R1'}, d = [d GetParam(me, [ttype{1} 'Break'])]; end; d = mean(d);
    d0 = GetParam(me, 'DTrajStart');
    d1 = GetParam(me, 'DTrajStop');
    
    nsteps = GetParam(me, 'DTrajSteps');
    z2 = (0:nsteps-1)/(nsteps-1);
    
    t = z2*(d1 - d0) + d0;    
    
    [trash, snum] = min(abs(t-d)); 
    snum = snum - 1; % goes from 0 to nsteps-1
    
    set_dtraj(snum, trialnum);
    return;
    
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         set_dtraj(stepnum, trialnum)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = set_dtraj(stepnum, trialnum)
    if GetParam(me, 'YokeDelay')==1, return; end;
    
    d0 = GetParam(me, 'DTrajStart');
    d1 = GetParam(me, 'DTrajStop');
    
    nsteps = GetParam(me, 'DTrajSteps');
    if stepnum<0, stepnum = 0; elseif stepnum > nsteps-1, stepnum = nsteps-1; end;
    d  = (d1 - d0)*stepnum/(nsteps-1) + d0;

    for ttype = {'L0' 'L1' 'R0' 'R1'},
        SetParam(me, [ttype{1} 'Break'], round(d*100)/100); 
    end;
    SetParam(me, 'DCurrS', stepnum+1);
    steps = GetParam(me, 'DSteps');
    steps(trialnum) = stepnum;
    SetParam(me, 'DSteps', steps);
    return;

        
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         project_to_trajectories(trialnum)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = project_to_trajectories(trialnum)

    if GetParam(me, 'LeftAutoPilot')==2,
        stepnum = nearest_step('L0'); set_trajectory('L0', stepnum, trialnum);
        stepnum = nearest_step('L1'); set_trajectory('L1', stepnum, trialnum);
    end;
    
    if GetParam(me, 'RightAutoPilot')==2,
        stepnum = nearest_step('R0'); set_trajectory('R0', stepnum, trialnum);
        stepnum = nearest_step('R1'); set_trajectory('R1', stepnum, trialnum);
    end;
       
    return;
    

function [snum] = nearest_step(ttype)
    dyoke  = GetParam(me, 'YokeDelay');

    x = zeros(1,4);
    x(1) = GetParam(me, [ttype 'Start']); 
    x(2) = GetParam(me, [ttype 'End']); 
    x(3) = GetParam(me, [ttype 'Tau']);  
    x(4) = GetParam(me, [ttype 'Break']);
    
    x0   = GetParam(me, [ttype 'TrajStart']);
    x1   = GetParam(me, [ttype 'TrajStop']);
    
    if dyoke==2, x=x(1:3); x0 = x0(1:3); x1 = x1(1:3); end;
    
    nsteps = GetParam(me, 'TrajSteps');
    z2 = (0:nsteps-1)/(nsteps-1);
    t  = zeros(length(z2), length(x0));
    
    logu = find(x0~=0 & x1~=0);  % linear interp in log space
    linu = find(x0==0 | x1==0);  % linear interp in euclid space    
    if ~isempty(logu),
        t(:,logu) = z2'*(log(x1(logu))-log(x0(logu))) + ones(size(z2'))*log(x0(logu));
        t(:,logu) = exp(t(:,logu));
    end;
    if ~isempty(linu),
        t(:,linu) = z2'*(x1(linu) - x0(linu)) + ones(size(z2'))*x0(linu);    
    end;
    
    d = t - ones(size(z2'))*x;
    d = sum(d.^2,2);
    [trash, snum] = min(d); 
    snum = snum - 1; % goes from 0 to nsteps-1
    return;
    
    

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         set_trajectory(ttype, stepnum, trialnum)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = set_trajectory(ttype, stepnum, trialnum)
    nsteps = GetParam(me, 'TrajSteps');
    dyoke  = GetParam(me, 'YokeDelay');
    
    start  = GetParam(me, [ttype 'TrajStart']);
    stop   = GetParam(me, [ttype 'TrajStop']);
    x0 = start; x1 = stop;
    
    if stepnum<0, stepnum = 0; elseif stepnum > nsteps-1, stepnum = nsteps-1; end;
    logu = find(x0~=0 & x1~=0);  % linear interp in log space
    linu = find(x0==0 | x1==0);  % linear interp in euclid space
    
    x = zeros(1,length(start));
    if ~isempty(logu),
        x(logu) = (log(x1(logu))-log(x0(logu)))*stepnum/(nsteps-1) + log(x0(logu));
        x(logu) = exp(x(logu));
    end;
    if ~isempty(linu),
        x(linu) = (x1(linu) - x0(linu))*stepnum/(nsteps-1) + x0(linu);    
    end;

    
    SetParam(me, [ttype 'Start'], round(x(1)*100)/100);
    SetParam(me, [ttype 'End'],   round(x(2)*100)/100);
    SetParam(me, [ttype 'Tau'],   round(x(3)));
    if dyoke==1, SetParam(me, [ttype 'Break'], round(x(4)*100)/100); end;
    SetParam(me, [ttype 'CurrS'], stepnum+1);
    
    steps = GetParam(me, [ttype 'Steps']);
    steps(trialnum) = stepnum;
    SetParam(me, [ttype 'Steps'], steps);
    return;

    
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         check_legal_valid_pokes()
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [change_flag] = check_legal_valid_poke_durs()
    mn   = GetParam(me, 'MinValidPokeDur');
    mx   = GetParam(me, 'MaxValidPokeDur');
    tdur = GetParam(me, 'ToneDur');
    vlst = GetParam(me, 'ValidSoundTime');
    
    change_flag = 0;
    if mn   <  0,        mn = 0.01;      change_flag = 1; end;
    if mn   < vlst+0.02, mn = vlst+0.02; change_flag = 1; end;

    if mx   < mn,        mx = mn;        change_flag = 1; end;
    
    % if tdur < vlst,      tdur = vlst;    change_flag = 0; end;      
    SetParam(me, 'MinValidPokeDur', mn);
    SetParam(me, 'MaxValidPokeDur', mx);
    SetParam(me, 'ToneDur', tdur);
    return;
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         set_future_sides(starting_at_trial_number)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = set_future_sides(starting_at);
    maxtrials   = GetParam(me, 'MaxTrials');
    side_list   = GetParam(me, 'SideList');
    type_list   = GetParam(me, 'TypeList');
    maxsame     = GetParam(me, 'MaxSame');
    typemaxsame = GetParam(me, 'TypeMaxSame');
    
    side_list(starting_at:maxtrials) = make_limited_list(maxtrials-starting_at+1, GetParam(me, 'LeftProb'), maxsame);      % 1 means right
    SetParam(me, 'SideList', 'value', side_list);
       
    ur = find(side_list(starting_at:maxtrials)==1); % right side guys;
    ul = find(side_list(starting_at:maxtrials)==0); % left  side guys;
    
    type_list(ur+starting_at-1) = make_limited_list(length(ur), 1-GetParam(me, 'RType1Prob'), typemaxsame);
    type_list(ul+starting_at-1) = make_limited_list(length(ul), 1-GetParam(me, 'LType1Prob'), typemaxsame);
    SetParam(me, 'TypeList', 'value', type_list);
    
    return;

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         make_limited_list(len, prob, maxsame)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function side_list = make_limited_list(len, prob, maxsame)

    side_list = rand(1,len)>=prob; 
    if maxsame > 10, return; end;
    seg_starts  = find(diff([-Inf side_list -Inf]));
    seg_lengths = diff(seg_starts);
    long_segs   = find(seg_lengths > maxsame);
    while ~isempty(long_segs),
        switch_point = seg_starts(long_segs(1)) + ceil(seg_lengths(long_segs(1))/2);
        side_list(switch_point) = 1 - side_list(switch_point);
        seg_starts  = find(diff([-Inf side_list -Inf]));
        seg_lengths = diff(seg_starts);
        long_segs   = find(seg_lengths > maxsame);
    end;
            

  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         set_future_vpds(starting_at_trial_number)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = set_future_vpds(starting_at);
    maxtrials  = GetParam(me, 'MaxTrials');
    vpds_list  = GetParam(me, 'VpdsList');
    hazardrate = GetParam(me, 'VpdsHazardRate');
    min_vpd    = GetParam(me, 'MinValidPokeDur');
    max_vpd    = GetParam(me, 'MaxValidPokeDur');
    
    vpds = min_vpd:0.010:max_vpd;
    
    prob       = hazardrate*((1-hazardrate).^(0:length(vpds)-1));
    cumprob    = cumsum(prob/sum(prob));
    for i=starting_at:length(vpds_list), vpds_list(i) = vpds(min(find(rand(1)<=cumprob))); end;
    SetParam(me, 'VpdsList', 'value', vpds_list);
  return;
        



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         update_meanhits
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = update_meanhits();

guys = [10 20 40 80];
Trials = GetParam(me, 'Trials');
Hits   = GetParam(me, 'RewardHistory') == 'h';
for i=1:length(guys),
    trials = max(Trials-guys(i)+1, 1):Trials;
    SetParam(me, ['Last' num2str(guys(i))], mean(Hits(trials)));
end;    

side_list = GetParam(me, 'SideList');
type_list = GetParam(me, 'TypeList');
for sides = ['L' 'R'],
    for types = [0 1],
        if sides=='L', mytrials = find(side_list==0 & type_list==types); 
        else           mytrials = find(side_list==1 & type_list==types);
        end;
        mytrials = mytrials(find(mytrials<=Trials)); ntrials = length(mytrials);
        if ntrials > 0,
            for i=1:length(guys),
                trials = max(ntrials-guys(i)+1,1):ntrials;
                SetParam(me, [sides num2str(types) 'Last' num2str(guys(i))], mean(Hits(mytrials(trials)))); 
            end;
        end;
    end;
end;

            




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         update_settings_histories
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = update_settings_histories();
    ntrials = GetParam(me, 'Trials');
    rewardports   = GetParam(me, 'RewardPorts');   rpmap = 'cb';
    waterdelivery = GetParam(me, 'WaterDelivery'); wdmap = 'dno';
    SetParam(me, 'RewardPortsHistory',   [GetParam(me, 'RewardPortsHistory')   ; rpmap(rewardports)]);
    SetParam(me, 'WaterDeliveryHistory', [GetParam(me, 'WaterDeliveryHistory') ; wdmap(waterdelivery)]);
    return;
        


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         initialize_plot
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = initialize_plot
   
    ltrials = (GetParam(me, 'LastTrials')-1)*60+90;
    fig = findobj('Tag', me);
    figure(fig);
   
    % First plot rewards
    h     = findobj(fig, 'Tag', 'plot_sides');
    if ~isempty(h), delete(h); end
    
    h = axes('Position', [0.15 0.875 0.8 0.115]);
    side_list = GetParam(me, 'SideList');
    type_list = GetParam(me, 'TypeList');
    side_list = 2-side_list; % so 2 means left, 1 means right
    side_list = side_list + type_list/4 - 1/8; % to include the effects of type
    plot(side_list,'b.'); hold on
    plot(1,side_list(1),'or');
    axis([0 ltrials+1 0.7 2.3]);
    ylabel('Port'); xlabel('');
    set(h, 'YTick', [1 2], 'YTickLabel', {'Rt' 'Lt'}, 'XTickLabel', '');
    set(h,'tag','plot_sides');
   
    
    % Now central valid poke durations
    h     = findobj(fig, 'Tag', 'plot_vpds');
    if ~isempty(h), delete(h); end;

    h = axes('Position', [0.15 0.75 0.8 0.115]);
    vpds_list = GetParam(me, 'VpdsList');
    plot(vpds_list,'k.'); hold on
    plot(1,vpds_list(1),'or');
    axis([0 ltrials+1 min(vpds_list-0.01) max(vpds_list)+0.01]);
    xlabel('trials'); ylabel('VPD (secs)');
    set(h,'tag','plot_vpds');
    
    
    
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
        ltrials        = (GetParam(me, 'LastTrials')-1)*60+90;
        side_list      = GetParam(me, 'SideList'); side_list = 2 - side_list; % 2==left,  1==right
        type_list      = GetParam(me, 'TypeList'); side_list = side_list + type_list/4 - 1/8; % to include the effects of type
        reward_history = GetParam(me, 'RewardHistory');
        wd_history     = GetParam(me, 'WaterDeliveryHistory');
        rp_history     = GetParam(me, 'RewardPortsHistory');
        % fprintf(1, 'Here 1 update_plot_sides\n');
        wd_history = wd_history(1:ntrials); % if called in the middle of a trial, just look at past trials
        rp_history = rp_history(1:ntrials);
        
        if isempty(reward_history), reward_history = zeros(0,1); end;
        
        hold on;
        % First the future
        plot(ntrials+1:maxtrials, side_list(ntrials+1:maxtrials), 'b.');
        
        % Next the both-ports-reward trials-- no hit or miss defined here, what matters is just r and l
        u      = find(rp_history == 'b');
        lefts  = find((side_list(u)==2 & reward_history(u)'=='h')  |  (side_list(u)==1 & reward_history(u)'=='m'));
        rights = find((side_list(u)==1 & reward_history(u)'=='h')  |  (side_list(u)==2 & reward_history(u)'=='m'));
        % fprintf(1, 'Here 2 update_plot_sides\n');
        if ~isempty(lefts),  thl    = text(u(lefts),  1.5*ones(size(u(lefts))),  'l'); else thl = []; end;
        if ~isempty(rights), thr    = text(u(rights), 1.5*ones(size(u(rights))), 'r'); else thr = []; end;
        set([thl;thr], 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'middle', ...
            'FontSize', 8, 'FontWeight', 'bold', 'Color', 'b', 'FontName', 'Helvetica', 'Clipping', 'on');
        
        % Next the guys with direct water delivery or next correct poke: rat *always* gets water in these
        u  = find(wd_history ~= 'o' & rp_history == 'c');
        if ~isempty(u), th = text(u, side_list(u), reward_history(u)); else th = []; end;
        set(th, 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'middle', ...
            'FontSize', 8, 'FontWeight', 'bold', 'Color', 'b', 'FontName', 'Helvetica', 'Clipping', 'on');
        
        % Now the ones where hit or miss makes affects whether the rat gets water; these'll be green and red dots, resp.
        % fprintf(1, 'Here 3 update_plot_sides\n');
        u  = find(wd_history == 'o' & rp_history == 'c');
        hits = find(reward_history(u) == 'h'); misses = find(reward_history(u) == 'm');
        plot(u(hits),   side_list(u(hits)),   'g.');
        plot(u(misses), side_list(u(misses)), 'r.');

        plot(ntrials+1, side_list(ntrials+1), 'ro'); hold off;
        axmin = max(ntrials-round(2*ltrials/3),0);
        axmax = axmin+ltrials+1;
        axis([axmin axmax 0.7 2.3]);

        xlabel('trials'); ylabel('Port');
        set(h, 'YTick', [1 2], 'YTickLabel', {'Rt' 'Lt'});
        set(h,'tag','plot_sides');
        % fprintf(1, 'Ending update_plot_sides\n\n');
    end;
    
    h     = findobj(fig, 'Tag', 'plot_vpds');
    if ~isempty(h),
        axes(h); cla;
    
        ntrials        = GetParam(me, 'Trials');  % These are # of already finished trials
        ltrials        = (GetParam(me, 'LastTrials')-1)*60+90;
        vpds_list      = GetParam(me, 'VpdsList'); 
        plot(vpds_list,'k.'); hold on
        plot(ntrials+1,vpds_list(ntrials+1),'or');
        axmin = max(ntrials-round(2*ltrials/3), 0);
        axmax = axmin+ltrials+1;
        axis([axmin axmax min(vpds_list(max(1,axmin):axmax))-0.01 max(vpds_list(max(1,axmin):axmax))+0.01]);
        xlabel('trials'); ylabel('VPD (secs)');
        set(h,'tag','plot_vpds');
    end;
    
    return
    
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         initialize_centerpokes_plot
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = initialize_centerpokes_plot
    h = axes('Position', [0.25 0.6 0.67 0.12]);
    set(h, 'Tag', 'CenterPokesPlot');
    xlabel('secs');
    ylabel('CPokeDur');
    vpds_list = GetParam(me, 'VpdsList'); 
    ntrials   = GetParam(me, 'Trials');
    vpd = vpds_list(ntrials+1);
    l = line([0 100], [vpd vpd]);
    set(l, 'Color', 0.8*[1 1 1], 'Tag', 'vpdline');
    pd = line([0], [0]);
    set(pd, 'Color', 'k', 'Marker', '.', 'LineStyle', '-', 'Tag', 'pdline');

    r = line([0], [0]);
    set(r, 'Color', 'r', 'Marker', '.', 'LineStyle', 'none', 'Tag', 'rline');
    axis([0 100 0 1.5*vpd]);
    set(h, 'YAxisLocation', 'right');
    
    h2 = axes('Position', [0.05 0.6 0.175 0.12]);
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
        
            red_u = find(CenterPokeStateHist(u) == GetParam(me, 'pstart'));
            set(rline, 'XData', CenterPokeTimes(u(red_u)), 'YData', CenterPokeDurations(u(red_u)));
            
            vpds_list = GetParam(me, 'VpdsList'); 
            ntrials   = GetParam(me, 'Trials');
            vpd = vpds_list(ntrials+1);
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
%         InitializeUIEditParam
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = InitializeUIEditParam(parname, parval, rownum, colnum)
    
    InitParam(me, parname, 'ui', 'edit', 'value', parval, 'pos', position(rownum, colnum), 'user', 1);
    SetParamUI(me, parname, 'label', parname);
    return;
    


    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         InitializeUIEditHalfLeftParam
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = InitializeUIEditHalfLeftParam(parname, parval, rownum, colnum)
    
    pos = position(rownum, colnum); pos(3) = pos(3)/2;
    InitParam(me, parname, 'ui', 'edit', 'value', parval, 'pos', pos, 'user', 1);
    SetParamUI(me, parname, 'label', '');
    return;
    


    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         InitializeUIEditHalfRightParam
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = InitializeUIEditHalfRightParam(parname, parval, rownum, colnum)
    
    pos = position(rownum, colnum); pos(1) = pos(1) + pos(3)/2; pos(3) = pos(3)/2;
    InitParam(me, parname, 'ui', 'edit', 'value', parval, 'pos', pos, 'user', 1);
    SetParamUI(me, parname, 'label', parname);
    return;
    


    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         InitializeUIMenuHalfLeftParam
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = InitializeUIMenuHalfLeftParam(parname, parlist, parval, rownum, colnum)

    pos = position(rownum, colnum); pos(3) = pos(3)/2;
    InitParam(me, parname, 'ui', 'popupmenu', 'list', parlist, 'value', parval, 'pos', pos, 'user', 1);
    SetParamUI(me, parname, 'label', parname);
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
%         InitializeUIDispParam
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = InitializeUIDispParam(parname, parval, rownum, colnum)

    InitParam(me, parname, 'ui', 'disp', 'value', parval, 'pos', position(rownum, colnum));
    SetParamUI(me, parname, 'label', parname);
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
%         InitializeUIDispHalfLeftParam
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = InitializeUIDispHalfLeftParam(parname, parval, rownum, colnum)

    pos = position(rownum, colnum); pos(3) = pos(3)/2;
    InitParam(me, parname, 'ui', 'disp', 'value', parval, 'pos', pos);
    SetParamUI(me, parname, 'label', parname);
    return;

    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         InitializeUIDispHalfRightParam
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = InitializeUIDispHalfRightParam(parname, parval, rownum, colnum)

    pos = position(rownum, colnum); pos(1) = pos(1) + pos(3)/2; pos(3) = pos(3)/2;
    InitParam(me, parname, 'ui', 'disp', 'value', parval, 'pos', pos);
    SetParamUI(me, parname, 'label', parname);
    return;
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         state_transition_matrix
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [stm] = state_transition_matrix

stne  = 1; % sample tone
itne  = 4; % interstim interval tone
totne = 2; % timeout tone

iti      = GetParam(me, 'ITILength'); 
tout     = GetParam(me, 'TimeOutLength');
lwpt     = GetParam(me, 'LeftWValveTime');
rwpt     = GetParam(me, 'RightWValveTime');
drkt     = GetParam(me, 'DrinkTime');
ntrials  = GetParam(me, 'Trials');
nxitis   = length(GetParam(me, 'ExtraItiOnError', 'list'))-1;

side_list = GetParam(me, 'SideList');
this_side = side_list(ntrials+1); 
if this_side==0, SetParam(me, 'CurrentSide', 'l');
else             SetParam(me, 'CurrentSide', 'r');
end;

vpds_list = GetParam(me, 'VpdsList'); 
vpd = vpds_list(ntrials+1);

tdur = GetParam(me, 'ToneDur');
wdel = GetParam(me, 'WaterDelivery'); % 1=direct        2=next correct poke     3=only if next poke correct
rwps = GetParam(me, 'RewardPorts');   % 1=correct port  2=both ports

vlst         = GetParam(me, 'ValidSoundTime');
currbreaklen = GetParam(me, 'CurrentBreakLen');
tdur = tdur + currbreaklen/1000;
vpd  = vpd  + currbreaklen/1000;
vlst = vlst + currbreaklen/1000;
vpds_list(ntrials+1) = vpd; SetParam(me, 'VpdsList', vpds_list);

pstart      = 40;   % start of main program
rewardstart = 60;  % start of reward states program
itistart    = 75;  % start of iti and timeout parts of program

b  = pstart;      % base state for main program

%        Cin    Cout    Lin    Lout     Rin     Rout    Tup    Timer    Dout   Aout
stm = [ pstart pstart  pstart pstart   pstart  pstart  pstart   0.01     0       0 ; ... % go to start of program
    ];

stm = [stm ; zeros(pstart-size(stm,1),10)];
   
% Now to work
WpkS = pstart+5;  % state in which we're waiting for a R or L poke

LrwS = rewardstart+0;  % state that gives water on left  port
RrwS = rewardstart+2;  % state that gives water on right port
LddS = rewardstart+4;  % state for left  direct water delivery
RddS = rewardstart+6;  % state for right direct water delivery

ItiS = itistart+2*nxitis;     % intertrial interval state
TouS = itistart+2*nxitis+3;  % penalty timeout state
if tout < 0.001, TouS = pstart; end;  % timeouts of zero mean just skip that state

if     wdel==3, % only water if next poke is correct
    punish = ItiS - 2*(GetParam(me, 'ExtraITIonError')-1);
    ptnA = WpkS; % post-tone act here is to go to waiting for a R or L poke
    if     this_side==0, lpkA = LrwS;   rpkA = punish;  % lpkA and rpkA are acts (states to go to) on L and R pokes, respectively 
    elseif this_side==1, lpkA = punish; rpkA = RrwS;
    else   error([me ': state_matrix: this_side has weird value!']);
    end;
    
elseif wdel==2, % water on next correct poke, diregarding intervening incorrects
    ptnA = WpkS; % post-tone act here is to go to waiting for a R or L poke
    if     this_side==0, lpkA = LrwS; rpkA = WpkS;
    elseif this_side==1, lpkA = WpkS; rpkA = RrwS;
    else   error([me ': state_matrix: this_side has weird value!']);
    end;
    
elseif wdel==1, % direct delivery
    if     this_side==0, ptnA = LddS; % post-tone act is either the Left or Right direct water delivery
    elseif this_side==1, ptnA = RddS; 
    else   error([me ': state_matrix: this_side has weird value!']);
    end;
    lpkA = LrwS; rpkA = RrwS; % doesn't really matter, we won't reach them
end;

if rwps==2, % Both ports are reward ports! Override wdel stuff above. In particular, no direct delivery
    ptnA = WpkS;
    lpkA = LrwS;
    rpkA = RrwS;
end;


prst = vpd - vlst; % presound time
if prst < 0.02, prst = 0.02; end; % Hack for when tdur changes in the middle of a trial
if vlst < 0.02, vlst = 0.02; end; % Equal hack

fprintf(1, 'prst=%g  vlst=%g\n', prst, vlst);
global fake_rp_box;

if isempty(fake_rp_box) | fake_rp_box ~= 1,
    %      Cin    Cout    Lin    Lout    Rin    Rout   Tup    Timer   Dout    Aout
    stm = [stm ; ...
           1+b     b      b      b       b      b       b      100      0       0 ; ... %0 : Pre-state: wait for C poke
           1+b     b      b      b       b      b      2+b     0.01     0       0 ; ... %1 : if pk<10 ms, doesn't count
           TouS   TouS   TouS   TouS    TouS   TouS    3+b     prst     0       0 ; ... %2 : pre sound time
           TouS   TouS   TouS   TouS    TouS   TouS    ptnA    vlst     0    stne ; ... %3 : trigger sample sound
           TouS   TouS   TouS   TouS    TouS   TouS    ptnA    0.01     0       0 ; ... %4 : UNUSED
           WpkS   WpkS   lpkA   WpkS    rpkA   WpkS    WpkS    100      0       0 ; ... %5 : wait for r/l poke act
       ];
else 
    WtoS = pstart+6; % wait for sound over before going to the timeout state
    lost = tdur - vlst; if lost < 0.02, lost = 0.02; end; 
    
    %      Cin    Cout    Lin    Lout    Rin    Rout   Tup    Timer   Dout    Aout
    stm = [stm ; ...
           1+b     b      b      b       b      b       b      100      0       0 ; ... %0 : Pre-state: wait for C poke
           1+b     b      b      b       b      b      2+b     0.01     0       0 ; ... %1 : if pk<10 ms, doesn't count
           TouS   TouS   TouS   TouS    TouS   TouS    3+b     prst     0       0 ; ... %2 : pre sound time
           WtoS   WtoS   WtoS   WtoS    WtoS   WtoS    ptnA    vlst     0    stne ; ... %3 : trigger sample sound
           WtoS   WtoS   WtoS   WtoS    WtoS   WtoS    ptnA    lost     0       0 ; ... %4 : UNUSED
           WpkS   WpkS   lpkA   WpkS    rpkA   WpkS    WpkS    100      0       0 ; ... %5 : wait for r/l poke act
           WtoS   WtoS   WtoS   WtoS    WtoS   WtoS    TouS    tdur     0       0 ; ... %6 : wait for sound over bf timeout      
   ];
end;



stm = [stm ; zeros(rewardstart-size(stm,1),10)];

%      Cin    Cout    Lin    Lout    Rin    Rout   Tup    Timer   Dout    Aout
stm = [stm ; ...
       LrwS   LrwS   LrwS   LrwS    LrwS   LrwS   1+LrwS   lwpt     1       0 ; ... %0 : Left reward: give water
      1+LrwS 1+LrwS 1+LrwS 1+LrwS  1+LrwS 1+LrwS   ItiS    drkt     0       0 ; ... %1 : free time to enjoy water
       RrwS   RrwS   RrwS   RrwS    RrwS   RrwS   1+RrwS   rwpt     2       0 ; ... %2 : Right reward: give water
      1+RrwS 1+RrwS 1+RrwS 1+RrwS  1+RrwS 1+RrwS   ItiS    drkt     0       0 ; ... %3 : free time to enjoy water
       LddS   LddS   LddS   LddS    LddS   LddS   1+LddS   lwpt     1       0 ; ... %4 : Left direct w delivery
      1+LddS 1+LddS  ItiS  1+LddS  1+LddS 1+LddS  1+LddS   100      0       0 ; ... %5 : Wait for L water collection 
       RddS   RddS   RddS   RddS    RddS   RddS   1+RddS   rwpt     2       0 ; ... %6 : Left direct w delivery
      1+RddS 1+RddS 1+RddS 1+RddS    35   1+RddS  1+RddS   100      0       0 ; ... %7 : Wait for R water collection 
   ];

if ~isempty(fake_rp_box) & fake_rp_box==1,  % The fake rp_box crashes if a sound is triggered twice, so we must wait
    itwt = iti;  towt = tout;                % Time to wait for unriggering of the sounds
else
    itwt = 0.03; towt = 0.03;       
end;

stm = [stm ; zeros(itistart-size(stm,1),10)];

for i=1:nxitis,  % Extra Iti states: lower trig and play sound...
    b = size(stm,1);
    stm = [stm ; ...
         b     b      b      b       b      b      1+b     0.03     0       0  ; ... 
        1+b   1+b    1+b    1+b     1+b    1+b     2+b     iti      0     itne];
end;
        
stm = [stm ; ...
       ItiS   ItiS   ItiS   ItiS    ItiS   ItiS   1+ItiS   0.03     0       0 ; ... %16: lower trigs first
      2+ItiS 2+ItiS 2+ItiS 2+ItiS  2+ItiS 2+ItiS    35     0.03     0     itne; ... %17: ITI, trigger and play sound
       ItiS   ItiS   ItiS   ItiS    ItiS   ItiS    ItiS    itwt     0       0 ; ... %18: happening: lower trigger and go back to set it off anew
   ];

% stm = [stm ; ...
%        TouS   TouS   TouS   TouS    TouS   TouS   1+TouS   0.03     0       0 ; ... %19: lower all sound trigs first
%       2+TouS 2+TouS 2+TouS 2+TouS  2+TouS 2+TouS  pstart   tout     0     totne; ...%20: timeout, trig and play sound
%        TouS   TouS   TouS   TouS    TouS   TouS    TouS    towt     0       0 ; ... %21: Bad boy: go again 
%    ];

% Use the version above for lowering trigs before starting timeout sound;
% version below goes straight for the timeout sound.
stm = [stm ; ...
      1+TouS 1+TouS 1+TouS 1+TouS  1+TouS 1+TouS  pstart   tout     0     totne; ...%19: timeout, trig and play sound
       TouS   TouS   TouS   TouS    TouS   TouS    TouS    towt     0       0 ; ... %20: Bad boy: lower trigs and go again 
   ];

    

SetParam(me, 'LrwS', LrwS); SetParam(me, 'RrwS', RrwS); SetParam(me, 'pstart', pstart);
SetParam(me, 'LddS', LddS); SetParam(me, 'RddS', RddS); SetParam(me, 'WpkS',   WpkS);
SetParam(me, 'rpkA', rpkA); SetParam(me, 'lpkA', lpkA); SetParam(me, 'ptnA',   ptnA);
SetParam(me, 'itistart', itistart);

out = stm;

return;
        
    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         MakeSounds
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sounds] = MakeSounds()

SetParam(me, 'ChangeSound1', 1);

FilterPath=[GetParam('rpbox','protocol_path') '\PPfilter.mat'];
if ( size(dir(FilterPath),1) == 1 )
    PP=load(FilterPath);
    PP=PP.PP;
    % message(me,'Generating Calibrated Tones');
else
    PP=[];
    % message(me,'Generating Non-calibrated Tones');
end

SPL       = 70;               % Max=PPdB SPL
ToneDur=GetParam(me,'ToneDur');
RampDur=GetParam(me,'RampDur');
ToneAttenuation = 70 -SPL;
        
sounds = cell(3,1);

% ---- Sample Sound ------

side_list  = GetParam(me, 'SideList');
type_list  = GetParam(me, 'TypeList');
ntrials    = GetParam(me, 'Trials'); 

if side_list(ntrials+1)==1,
    if type_list(ntrials+1)==0, ttype = 'R0';
    else                        ttype = 'R1';
    end;
else 
    if type_list(ntrials+1)==0, ttype = 'L0';
    else                        ttype = 'L1';
    end;
end;

StartFreq = GetParam(me, [ttype 'Start'])*1000;
EndFreq   = GetParam(me, [ttype 'End'])*1000;
Tau       = GetParam(me, [ttype 'Tau']);
Break     = GetParam(me, [ttype 'Break']);

SetParam(me, 'CurrentBreakLen', Break);

SoundStartHistory = GetParam(me, 'SoundStartHistory');
SoundEndHistory   = GetParam(me, 'SoundEndHistory');
SoundStartHistory(ntrials+2) = StartFreq;
SoundEndHistory(  ntrials+2) = EndFreq;
SetParam(me, 'SoundStartHistory', SoundStartHistory);
SetParam(me, 'SoundEndHistory',   SoundEndHistory);


FreqMean = exp((log(StartFreq) + log(EndFreq))/2);
if isempty(PP), 
    ToneAttenuation_adj = ToneAttenuation;
else 
    ToneAttenuation_adj = ToneAttenuation - ppval(PP, log10(FreqMean));
    ToneAttenuation_adj = ToneAttenuation_adj .* (ToneAttenuation_adj > 0);
end;

ToneAttenuation_adj = ToneAttenuation;


amp = 1; % ToneAttenuation_adj,
sounds{1}  = amp*MakeSigmoidSwoop2(50e6/1024, ToneAttenuation_adj, StartFreq, EndFreq, ToneDur*1000, Tau, Break, RampDur*1000);

Nyquist = (50e6/1024)/2;
[Blow,  Alow]  = Butter(5, [0.05 5000/Nyquist]);
[Bhigh, Ahigh] = Butter(5, [5000/Nyquist 0.95]);
lownoise  = filter(Blow,  Alow,  rand(1, floor(GetParam(me, 'ITILength')*50e6/1024)));
highnoise = filter(Bhigh, Ahigh, rand(1, floor(GetParam(me, 'TimeOutLength')*50e6/1024)));
lownoise  = lownoise/max(abs(lownoise)); highnoise = highnoise/max(abs(highnoise));


itisound  = 0.145*lownoise;
if GetParam(me, 'ITISound')==1,     sounds{3} = zeros(size(itisound)); 
else                                sounds{3} = itisound;
end;

toutsound = 0.145*highnoise;
if GetParam(me, 'TimeOutSound')==1, sounds{2} = zeros(size(toutsound));
else                                sounds{2} = toutsound;
end;


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
%
%       remove_pref
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
function [] = remove_pref(str)

    user = GetParam('control', 'user'); 
    if ispref(user, [lower(me) '_' lower(str)]), rmpref(user, [lower(me) '_' lower(str)]); end;
    return;
    
    