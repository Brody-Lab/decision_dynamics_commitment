% Typical section code-- this file may be used as a template to be added 
% on to. The code below stores the current figure and initial position when
% the action is 'init'; and, upon 'reinit', deletes all SoloParamHandles 
% belonging to this section, then calls 'init' at the proper GUI position 
% again.


% [x, y] = YOUR_SECTION_NAME(obj, action, x, y)
%
% Section that takes care of YOUR HELP DESCRIPTION
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%            'init'      To initialise the section and set up the GUI
%                        for it
%
%            'reinit'    Delete all of this section's GUIs and data,
%                        and reinit, at the same position on the same
%                        figure as the original section GUI was placed.
%
% x, y     Relevant to action = 'init'; they indicate the initial
%          position to place the GUI at, in the current figure window
%
% RETURNS:
% --------
%
% [x, y]   When action == 'init', returns x and y, pixel positions on
%          the current figure, updated after placing of this section's GUI. 
%


function [x, y] = PsychSection(obj, action, x, y)
   
GetSoloFunctionArgs;

switch action

%% init  
  case 'init',
    % Save the figure and the position in the figure where we are
    % going to start adding GUI elements:
    SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);

    DispParam(   obj, 'T1_HitFrac',   0, x, y, 'position', [x     y 110 20], 'labelfraction', 0.6);
    DispParam(   obj, 'T1_TriNum' ,   0, x, y, 'position', [x+110 y  90 20], 'labelfraction', 0.7); next_row(y);
    DispParam(   obj, 'T2_HitFrac',   0, x, y, 'position', [x     y 110 20], 'labelfraction', 0.6);
    DispParam(   obj, 'T2_TriNum' ,   0, x, y, 'position', [x+110 y  90 20], 'labelfraction', 0.7); next_row(y);
    DispParam(   obj, 'T3_HitFrac',   0, x, y, 'position', [x     y 110 20], 'labelfraction', 0.6);
    DispParam(   obj, 'T3_TriNum' ,   0, x, y, 'position', [x+110 y  90 20], 'labelfraction', 0.7); next_row(y);
    DispParam(   obj, 'T4_HitFrac',   0, x, y, 'position', [x     y 110 20], 'labelfraction', 0.6);
    DispParam(   obj, 'T4_TriNum' ,   0, x, y, 'position', [x+110 y  90 20], 'labelfraction', 0.7); next_row(y);
    DispParam(   obj, 'T5_HitFrac',   0, x, y, 'position', [x     y 110 20], 'labelfraction', 0.6);
    DispParam(   obj, 'T5_TriNum' ,   0, x, y, 'position', [x+110 y  90 20], 'labelfraction', 0.7); next_row(y);
    DispParam(   obj, 'T6_HitFrac',   0, x, y, 'position', [x     y 110 20], 'labelfraction', 0.6);
    DispParam(   obj, 'T6_TriNum' ,   0, x, y, 'position', [x+110 y  90 20], 'labelfraction', 0.7); next_row(y);
    DispParam(   obj, 'T7_HitFrac',   0, x, y, 'position', [x     y 110 20], 'labelfraction', 0.6);
    DispParam(   obj, 'T7_TriNum' ,   0, x, y, 'position', [x+110 y  90 20], 'labelfraction', 0.7); next_row(y);
    DispParam(   obj, 'T8_HitFrac',   0, x, y, 'position', [x     y 110 20], 'labelfraction', 0.6);
    DispParam(   obj, 'T8_TriNum' ,   0, x, y, 'position', [x+110 y  90 20], 'labelfraction', 0.7); next_row(y);
    DispParam(   obj, 'T9_HitFrac',   0, x, y, 'position', [x     y 110 20], 'labelfraction', 0.6);
    DispParam(   obj, 'T9_TriNum' ,   0, x, y, 'position', [x+110 y  90 20], 'labelfraction', 0.7); next_row(y);
    DispParam(   obj, 'T10_HitFrac',  0, x, y, 'position', [x     y 110 20], 'labelfraction', 0.6);
    DispParam(   obj, 'T10_TriNum' ,  0, x, y, 'position', [x+110 y  90 20], 'labelfraction', 0.7); next_row(y,1.2);
    
    ToggleParam( obj,'ShowSecondaryPsych',0,x,y, 'OnString', 'Show 2nd Psych', 'OffString', 'Hide 2nd Psych', 'position',[x     y 110 20]); 
    ToggleParam( obj, 'UseSecondaryPsych',0,x,y, 'OnString', 'Active',         'OffString', 'Inactive',       'position',[x+110 y  90 20]); next_row(y);
    
    %Start SecondaryPsych Window
        oldx = x; oldy = y; oldfigure = double(gcf);
        SoloParamHandle(obj, 'SecondaryPsychFigure', 'saveable', 0, 'value', figure('Position', [120 120 350 350]));
        sfig = value(eval('SecondaryPsychFigure'));
        set(sfig, 'MenuBar', 'none', 'NumberTitle', 'on', ...
          'Name', 'SecondaryPsych Settings', ...
          'UserData', obj);
        x = 5; y = 5;  
        
        DispParam(   obj, 'S_T1_HitFrac',   0, x, y, 'position', [x     y 150 20], 'labelfraction', 0.6);
        DispParam(   obj, 'S_T1_TriNum' ,   0, x, y, 'position', [x+150 y 110 20], 'labelfraction', 0.7); next_row(y);
        DispParam(   obj, 'S_T2_HitFrac',   0, x, y, 'position', [x     y 150 20], 'labelfraction', 0.6);
        DispParam(   obj, 'S_T2_TriNum' ,   0, x, y, 'position', [x+150 y 110 20], 'labelfraction', 0.7); next_row(y);
        DispParam(   obj, 'S_T3_HitFrac',   0, x, y, 'position', [x     y 150 20], 'labelfraction', 0.6);
        DispParam(   obj, 'S_T3_TriNum' ,   0, x, y, 'position', [x+150 y 110 20], 'labelfraction', 0.7); next_row(y);
        DispParam(   obj, 'S_T4_HitFrac',   0, x, y, 'position', [x     y 150 20], 'labelfraction', 0.6);
        DispParam(   obj, 'S_T4_TriNum' ,   0, x, y, 'position', [x+150 y 110 20], 'labelfraction', 0.7); next_row(y);
        DispParam(   obj, 'S_T5_HitFrac',   0, x, y, 'position', [x     y 150 20], 'labelfraction', 0.6);
        DispParam(   obj, 'S_T5_TriNum' ,   0, x, y, 'position', [x+150 y 110 20], 'labelfraction', 0.7); next_row(y);
        DispParam(   obj, 'S_T6_HitFrac',   0, x, y, 'position', [x     y 150 20], 'labelfraction', 0.6);
        DispParam(   obj, 'S_T6_TriNum' ,   0, x, y, 'position', [x+150 y 110 20], 'labelfraction', 0.7); next_row(y);
        DispParam(   obj, 'S_T7_HitFrac',   0, x, y, 'position', [x     y 150 20], 'labelfraction', 0.6);
        DispParam(   obj, 'S_T7_TriNum' ,   0, x, y, 'position', [x+150 y 110 20], 'labelfraction', 0.7); next_row(y);
        DispParam(   obj, 'S_T8_HitFrac',   0, x, y, 'position', [x     y 150 20], 'labelfraction', 0.6);
        DispParam(   obj, 'S_T8_TriNum' ,   0, x, y, 'position', [x+150 y 110 20], 'labelfraction', 0.7); next_row(y);
        DispParam(   obj, 'S_T9_HitFrac',   0, x, y, 'position', [x     y 150 20], 'labelfraction', 0.6);
        DispParam(   obj, 'S_T9_TriNum' ,   0, x, y, 'position', [x+150 y 110 20], 'labelfraction', 0.7); next_row(y);
        DispParam(   obj, 'S_T10_HitFrac',  0, x, y, 'position', [x     y 150 20], 'labelfraction', 0.6);
        DispParam(   obj, 'S_T10_TriNum' ,  0, x, y, 'position', [x+150 y 110 20], 'labelfraction', 0.7); next_row(y,1.2);
    
        DispParam(   obj, 'Snd_TrialType',    1, x, y);                                                     next_row(y);
        NumeditParam(obj, 'Snd_LeftEndPsych', 1, x, y, 'position', [x     y 170 20], 'labelfraction', 0.7);
        NumeditParam(obj, 'Snd_Spread',       2, x, y, 'position', [x+170 y 130 20], 'labelfraction', 0.65); next_row(y);
        NumeditParam(obj, 'Snd_RightEndPsych',2, x, y, 'position', [x     y 170 20], 'labelfraction', 0.7);
        NumeditParam(obj, 'Snd_Mid',      1.366, x, y, 'position', [x+170 y 130 20], 'labelfraction', 0.45); next_row(y);

        MenuParam(   obj, 'Snd_NumPsych',  {'1','2','3','4','5'},     1, x, y); next_row(y);
        MenuParam(   obj, 'Snd_PsychType', {'Duration', 'Frequency','Phantom'}, 1, x, y); next_row(y);
        
        set(sfig, 'Visible', 'off');

        x = oldx; y = oldy; figure(oldfigure);
    %Finish SecondaryPsych Window
    
    NumeditParam(obj, 'RewardAround', 0, x, y, 'position', [x     y 125 20], 'labelfraction', 0.66);
    DispParam(   obj, 'TrialType',    1, x, y, 'position', [x+125 y  75 20], 'labelfraction', 0.65); next_row(y);
    NumeditParam(obj, 'LeftEndPsych', 1, x, y, 'position', [x     y 125 20], 'labelfraction', 0.66);
    NumeditParam(obj, 'Spread',       2, x, y, 'position', [x+125 y  75 20], 'labelfraction', 0.55); next_row(y);
    NumeditParam(obj, 'RightEndPsych',2, x, y, 'position', [x     y 125 20], 'labelfraction', 0.66);
    NumeditParam(obj, 'Mid',      1.366, x, y, 'position', [x+125 y  75 20], 'labelfraction', 0.35); next_row(y);
    
    MenuParam(   obj, 'NumPsych',  {'1','2','3','4','5'},     1, x, y, 'position', [x y 125 20], 'labelfraction', 0.6); 
    ToggleParam( obj, 'PsychPad', 1,x,y, 'OnString', 'Force10', 'OffString', 'StretchNum', 'position',[x+125 y 75 20]); next_row(y);
    MenuParam(   obj, 'PsychType', {'Duration', 'Frequency','Phantom'}, 1, x, y); next_row(y);
    SoloParamHandle(obj, 'psych_history', 'value', []);
    SoloParamHandle(obj, 'snd_psych_history', 'value', []);
    
    SoloParamHandle(obj, 'PsychTypeHist','value', []);
    SoloParamHandle(obj, 'Current',      'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'Order',        'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'EndPoints',    'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'LeftRewards',  'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'RightRewards', 'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'Counter',      'value', [],'save_with_settings',1);
    
    SoloParamHandle(obj, 'start_r1',     'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_r2',     'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_r3',     'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_r4',     'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_r5',     'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_r6',     'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_r7',     'value', [],'save_with_settings',1);
    
    SoloParamHandle(obj, 'stop_r1',      'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_r2',      'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_r3',      'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_r4',      'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_r5',      'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_r6',      'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_r7',      'value', [],'save_with_settings',1);
    
    
    SoloParamHandle(obj, 'start_final_data_date_w1',        'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_final_data_trial_w1',       'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_final_data_date_w1',         'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_final_data_trial_w1',        'value', [],'save_with_settings',1);
    
    SoloParamHandle(obj, 'start_final_data_date_w1L',       'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_final_data_trial_w1L',      'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_final_data_date_w1L',        'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_final_data_trial_w1L',       'value', [],'save_with_settings',1);
    
    SoloParamHandle(obj, 'start_final_data_date_w1NIC',     'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_final_data_trial_w1NIC',    'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_final_data_date_w1NIC',      'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_final_data_trial_w1NIC',     'value', [],'save_with_settings',1);
    
    SoloParamHandle(obj, 'start_final_data_date_w1long',    'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_final_data_trial_w1long',   'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_final_data_date_w1long',     'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_final_data_trial_w1long',    'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_endpoint_data_date_w1long', 'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_endpoint_data_trial_w1long','value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_endpoint_data_date_w1long',  'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_endpoint_data_trial_w1long', 'value', [],'save_with_settings',1);
    
    SoloParamHandle(obj, 'start_final_data_date_w2',        'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_final_data_trial_w2',       'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_final_data_date_w2',         'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_final_data_trial_w2',        'value', [],'save_with_settings',1);
    
    SoloParamHandle(obj, 'start_final_data_date_w2L',       'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_final_data_trial_w2L',      'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_final_data_date_w2L',        'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_final_data_trial_w2L',       'value', [],'save_with_settings',1);
    
    SoloParamHandle(obj, 'start_final_data_date_w2p5',      'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_final_data_trial_w2p5',     'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_final_data_date_w2p5',       'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_final_data_trial_w2p5',      'value', [],'save_with_settings',1);
    
    SoloParamHandle(obj, 'start_final_data_date_w3',        'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_final_data_trial_w3',       'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_final_data_date_w3',         'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_final_data_trial_w3',        'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_endpoint_data_date_w3',     'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_endpoint_data_trial_w3',    'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_endpoint_data_date_w3',      'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_endpoint_data_trial_w3',     'value', [],'save_with_settings',1);
    
    SoloParamHandle(obj, 'start_final_data_date_w3L',       'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_final_data_trial_w3L',      'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_final_data_date_w3L',        'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_final_data_trial_w3L',       'value', [],'save_with_settings',1);
    
    SoloParamHandle(obj, 'start_final_data_date_w3NIC',     'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_final_data_trial_w3NIC',    'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_final_data_date_w3NIC',      'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_final_data_trial_w3NIC',     'value', [],'save_with_settings',1);
    
    SoloParamHandle(obj, 'start_final_data_date_w4',        'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_final_data_trial_w4',       'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_final_data_date_w4',         'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_final_data_trial_w4',        'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_endpoint_data_date_w4',     'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_endpoint_data_trial_w4',    'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_endpoint_data_date_w4',      'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_endpoint_data_trial_w4',     'value', [],'save_with_settings',1);
    
    SoloParamHandle(obj, 'start_final_data_date_w4long',    'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_final_data_trial_w4long',   'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_final_data_date_w4long',     'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_final_data_trial_w4long',    'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_endpoint_data_date_w4long', 'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_endpoint_data_trial_w4long','value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_endpoint_data_date_w4long',  'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_endpoint_data_trial_w4long', 'value', [],'save_with_settings',1);
    
    SoloParamHandle(obj, 'start_final_data_date_w5',        'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_final_data_trial_w5',       'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_final_data_date_w5',         'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_final_data_trial_w5',        'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_endpoint_data_date_w5',     'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_endpoint_data_trial_w5',    'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_endpoint_data_date_w5',      'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_endpoint_data_trial_w5',     'value', [],'save_with_settings',1);
    
    SoloParamHandle(obj, 'start_final_data_date_w6',        'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_final_data_trial_w6',       'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_final_data_date_w6',         'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_final_data_trial_w6',        'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_endpoint_data_date_w6',     'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_endpoint_data_trial_w6',    'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_endpoint_data_date_w6',      'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_endpoint_data_trial_w6',     'value', [],'save_with_settings',1);
    
    SoloParamHandle(obj, 'start_NIC_TempBis_Linear_date',   'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_NIC_TempBis_Linear_trial',  'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_NIC_TempBis_Linear_date',    'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_NIC_TempBis_Linear_trial',   'value', [],'save_with_settings',1);
    
    SoloParamHandle(obj, 'start_NIC_TempBis_Linear2_date',  'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_NIC_TempBis_Linear2_trial', 'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_NIC_TempBis_Linear2_date',   'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_NIC_TempBis_Linear2_trial',  'value', [],'save_with_settings',1);
    
    SoloParamHandle(obj, 'start_TempBis_Linear_date',  'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_TempBis_Linear_trial', 'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_TempBis_Linear_date',   'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_TempBis_Linear_trial',  'value', [],'save_with_settings',1);
    
    SoloParamHandle(obj, 'start_TempBis_Linear2_date',  'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_TempBis_Linear2_trial', 'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_TempBis_Linear2_date',   'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_TempBis_Linear2_trial',  'value', [],'save_with_settings',1);
    
    SoloParamHandle(obj, 'start_TempBis_Linear3_date',  'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_TempBis_Linear3_trial', 'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_TempBis_Linear3_date',   'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_TempBis_Linear3_trial',  'value', [],'save_with_settings',1);
    
    SoloParamHandle(obj, 'start_NIC_TempBis_FullExp1_date',  'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_NIC_TempBis_FullExp1_trial', 'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_NIC_TempBis_FullExp1_date',   'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_NIC_TempBis_FullExp1_trial',  'value', [],'save_with_settings',1);
    
    SoloParamHandle(obj, 'start_NIC_TempBis_FullExp2_date',  'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_NIC_TempBis_FullExp2_trial', 'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_NIC_TempBis_FullExp2_date',   'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_NIC_TempBis_FullExp2_trial',  'value', [],'save_with_settings',1);
    
    SoloParamHandle(obj, 'start_NIC_TempBis_FullExp3_date',  'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_NIC_TempBis_FullExp3_trial', 'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_NIC_TempBis_FullExp3_date',   'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_NIC_TempBis_FullExp3_trial',  'value', [],'save_with_settings',1);
    
    SoloParamHandle(obj, 'start_NIC_TempBis_FullExp4_date',  'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_NIC_TempBis_FullExp4_trial', 'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_NIC_TempBis_FullExp4_date',   'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_NIC_TempBis_FullExp4_trial',  'value', [],'save_with_settings',1);
    
    SoloParamHandle(obj, 'start_NIC_TempBis_FullExp5_date',  'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_NIC_TempBis_FullExp5_trial', 'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_NIC_TempBis_FullExp5_date',   'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_NIC_TempBis_FullExp5_trial',  'value', [],'save_with_settings',1);
    
    SoloParamHandle(obj, 'start_NIC_TempBis_FullExp6_date',  'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'start_NIC_TempBis_FullExp6_trial', 'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_NIC_TempBis_FullExp6_date',   'value', [],'save_with_settings',1);
    SoloParamHandle(obj, 'stop_NIC_TempBis_FullExp6_trial',  'value', [],'save_with_settings',1);
    
    
    SoloParamHandle(obj, 'PsycSounds', 'value', []);
    SoloParamHandle(obj, 'LastLeft',   'value', []);
    SoloParamHandle(obj, 'FirstRight', 'value', []);
    
    set_callback({LeftEndPsych, RightEndPsych}, {mfilename, 'update_mid_spread'}); %#ok<NODEF>
    set_callback({Mid, Spread},                 {mfilename, 'update_endpoints'}); %#ok<NODEF>
    set_callback({PsychType, Snd_PsychType},    {mfilename, 'update_sound_type'});
    
    set_callback({ShowSecondaryPsych},          {mfilename, 'disp_secondarypsych'});
    set_callback({UseSecondaryPsych},           {mfilename, 'update_secondarypsych'});
    
    set_callback({Snd_LeftEndPsych, Snd_RightEndPsych}, {mfilename, 'update_sndmid_sndspread'}); %#ok<NODEF>
    set_callback({Snd_Mid, Snd_Spread},                 {mfilename, 'update_sndendpoints'}); %#ok<NODEF>
    
    SubheaderParam(obj, 'title', 'Psych Section', x, y);
    next_row(y, 1.5);

        
%% get_numpsych   
% -----------------------------------------------------------------------
%
%         GET_NUMPSYCH
%
% -----------------------------------------------------------------------

  case 'get_numpsych',
      x = value(NumPsych);
      
      
%% get_spread  
% -----------------------------------------------------------------------
%
%         GET_SPREAD
%
% -----------------------------------------------------------------------

  case 'get_spread',
      x = value(Spread); %#ok<NODEF>
     
      
%% get_mid  
% -----------------------------------------------------------------------
%
%         GET_MID
%
% -----------------------------------------------------------------------

  case 'get_mid',
      x = value(Mid);       %#ok<NODEF>
      
      
%% get_lastchange   
% -----------------------------------------------------------------------
%
%         GET_LASTCHANGE
%
% -----------------------------------------------------------------------

  case 'get_lastchange',
      x = value(lastchange);      

      
%% get_trialtype  
% -----------------------------------------------------------------------
%
%         GET_TRIALTYPE
%
% -----------------------------------------------------------------------

  case 'get_trialtype',
      x = value(TrialType); %#ok<NODEF>

      
%% get_psychtype  
% -----------------------------------------------------------------------
%
%         GET_PSYCHTYPE
%
% -----------------------------------------------------------------------

  case 'get_psychtype',
      x = value(PsychType);
      

%% get_psychtypehist  
% -----------------------------------------------------------------------
%
%         GET_PSYCHTYPEHIST
%
% -----------------------------------------------------------------------

  case 'get_psychtypehist',
      x = value(PsychTypeHist); %#ok<NODEF>
      
      
%% get_psych_history  
% -----------------------------------------------------------------------
%
%         GET_PSYCH_HISTORY
%
% -----------------------------------------------------------------------

  case 'get_psych_history',
      x = value(psych_history);      %#ok<NODEF>
      
      
%% get_psych_pad 
% -----------------------------------------------------------------------
%
%         GET_PSYCH_PAD
%
% -----------------------------------------------------------------------

  case 'get_psychpad',
      x = value(PsychPad);   
      
      
%% get_rewardaround
% -----------------------------------------------------------------------
%
%         GET_REWARDAROUND
%
% -----------------------------------------------------------------------

  case 'get_rewardaround',
      x = value(RewardAround);    
      
      
%% get_psycsounds
% -----------------------------------------------------------------------
%
%         GET_PSYCSOUNDS
%
% -----------------------------------------------------------------------

  case 'get_psycsounds',
      x = value(PsycSounds);   %#ok<NODEF>
      
      
%% get_lastleft
% -----------------------------------------------------------------------
%
%         GET_LASTLEFT
%
% -----------------------------------------------------------------------

  case 'get_lastleft',
      x = value(LastLeft);   %#ok<NODEF>
      
   
%% get_firstright
% -----------------------------------------------------------------------
%
%         GET_FIRSTRIGHT
%
% -----------------------------------------------------------------------

  case 'get_firstright',
      x = value(FirstRight);   %#ok<NODEF>
      
      
%% update_psych_values  
% -----------------------------------------------------------------------
%
%         UPDATE_PYCH_VALUES
%
% -----------------------------------------------------------------------

  case 'update_psych_values',
      if n_done_trials > 1
        ph = value(psych_history); %#ok<NODEF>
        
        if length(ph) > 1
            for t = 1:10
                tr = find(ph(1:end-1) == t);
                sc = nanmean(hit_history(tr));
                tn = length(tr);
                if     t == 1;  T1_HitFrac.value = sc;    T1_TriNum.value = tn;
                elseif t == 2;  T2_HitFrac.value = sc;    T2_TriNum.value = tn;
                elseif t == 3;  T3_HitFrac.value = sc;    T3_TriNum.value = tn;
                elseif t == 4;  T4_HitFrac.value = sc;    T4_TriNum.value = tn;       
                elseif t == 5;  T5_HitFrac.value = sc;    T5_TriNum.value = tn;
                elseif t == 6;  T6_HitFrac.value = sc;    T6_TriNum.value = tn;
                elseif t == 7;  T7_HitFrac.value = sc;    T7_TriNum.value = tn;   
                elseif t == 8;  T8_HitFrac.value = sc;    T8_TriNum.value = tn;
                elseif t == 9;  T9_HitFrac.value = sc;    T9_TriNum.value = tn;
                elseif t == 10; T10_HitFrac.value = sc;   T10_TriNum.value = tn;
                end
            end
        end
        
        sndph = value(snd_psych_history); %#ok<NODEF>
        if length(sndph) > 1
            for t = 1:10
                tr = find(sndph(1:end-1) == t);
                if isempty(tr); sc = nan;
                else            sc = nanmean(hit_history(tr));
                end
                tn = length(tr);
                if     t == 1;  S_T1_HitFrac.value = sc;    S_T1_TriNum.value = tn;
                elseif t == 2;  S_T2_HitFrac.value = sc;    S_T2_TriNum.value = tn;
                elseif t == 3;  S_T3_HitFrac.value = sc;    S_T3_TriNum.value = tn;
                elseif t == 4;  S_T4_HitFrac.value = sc;    S_T4_TriNum.value = tn;       
                elseif t == 5;  S_T5_HitFrac.value = sc;    S_T5_TriNum.value = tn;
                elseif t == 6;  S_T6_HitFrac.value = sc;    S_T6_TriNum.value = tn;
                elseif t == 7;  S_T7_HitFrac.value = sc;    S_T7_TriNum.value = tn;   
                elseif t == 8;  S_T8_HitFrac.value = sc;    S_T8_TriNum.value = tn;
                elseif t == 9;  S_T9_HitFrac.value = sc;    S_T9_TriNum.value = tn;
                elseif t == 10; S_T10_HitFrac.value = sc;   S_T10_TriNum.value = tn;
                end
            end
        end
      end 
    
%% prepare_next_trial    
% -----------------------------------------------------------------------
%
%         PREPARE_NEXT_TRIAL
%
% -----------------------------------------------------------------------

  case 'prepare_next_trial',
    
    oldph    = value(psych_history); %#ok<NODEF>
    oldsndph = value(snd_psych_history); %#ok<NODEF>
    oldpth   = value(PsychTypeHist); %#ok<NODEF>
    if ~dispatcher('is_running') && ~isempty(oldph)
      % We're not running, last side wasn't used, lop it off:
      oldph    = oldph(1:end-1); 
      oldsndph = oldsndph(1:end-1);
      oldpth   = oldpth(1:end-1);
    end;
    
    psych_history.value     = oldph;
    snd_psych_history.value = oldsndph;
    PsychTypeHist.value     = oldpth;        
    
    if isequal(PsychType,'Duration')
        PsychTypeHist.value = [value(PsychTypeHist) 1];
    elseif isequal(PsychType,'Frequency')
        PsychTypeHist.value = [value(PsychTypeHist) 2];
    else
        PsychTypeHist.value = [value(PsychTypeHist) 3];
    end
            
    leftend  = value(LeftEndPsych); %#ok<NODEF>
    rightend = value(RightEndPsych); %#ok<NODEF>
    
    if isequal(PsychType,'Phantom')
        phantomparam = PhantomSection(obj, 'get_phantomparam');
        if phantomparam == 0
          psycsounds = [(0:4) (4:-1:0)]*(rightend-leftend)*0.25+leftend;
        else
          psycsounds = (1-exp(-(0:4)*phantomparam))*(rightend-leftend)/(1-exp(-4*phantomparam)) + leftend;
          psycsounds = [psycsounds psycsounds(5:-1:1)];
        end
    else
        if strcmp(value(Stimuli_Spacing),'Logarithmic') == 1
            if PsychPad == 1
                psycsounds = 10.^(log10(leftend):(log10(rightend)-log10(leftend))/9:log10(rightend));
            else
                temp = 10.^(log10(leftend):(log10(rightend)-log10(leftend))/((value(NumPsych)*2)-1):log10(rightend)); %#ok<NODEF>
                psycsounds(1:value(NumPsych))       = temp(1:value(NumPsych));
                psycsounds(10-value(NumPsych)+1:10) = temp(value(NumPsych)+1:end);
            end
        else
            if PsychPad == 1
                psycsounds = leftend:(rightend - leftend)/9:rightend;
            else
                temp = leftend:(rightend - leftend)/((value(NumPsych)*2)-1):rightend;
                psycsounds(1:value(NumPsych))       = temp(1:value(NumPsych));
                psycsounds(10-value(NumPsych)+1:10) = temp(value(NumPsych)+1:end);
            end
        end
    end
    PsycSounds.value = psycsounds;
    
    thistrial = value(sides_history);
    thistrial = thistrial(end);
    posterior = AntibiasSection(obj, 'get_posterior_probs');
    
    if length(psych_history) < n_done_trials
        temp = value(sides_history);
        temp = temp(1:end-1);
        psych_history = zeros(length(temp),1);
        psych_history(temp == 'l') = 1;
        psych_history(temp == 'r') = 10;
    end
    
    ft = SidesSection(obj,'get_forcetrial');
    if value(RewardAround) == 0
        lastleft = value(NumPsych);
        firstright = 10 - value(NumPsych) + 1;
    else
        temppsyc = psycsounds; temppsyc(value(NumPsych)+1:10-value(NumPsych)) = 0;
        lastleft = find(temppsyc < value(RewardAround),1,'last');
        firstright = find(temppsyc > value(RewardAround),1,'first');
        %if lastleft   > value(NumPsych); lastleft   = value(NumPsych);          end
        %if firstright < value(NumPsych); firstright = 10 - value(NumPsych) + 1; end
        
    end
    LastLeft.value = lastleft;
    FirstRight.value = firstright;
    
    if isempty(ft)
        if isequal(thistrial, 'l')
            pL        = zeros(lastleft,2);
            pL(:,1)   = posterior(1:lastleft) / sum(posterior(1:lastleft));
            pL(:,2)   = 1:lastleft;
            pL        = sortrows(pL,1);
            for t = 1:size(pL,1);
                if t > 1; pL(t,1) = pL(t,1) + pL(t-1,1); end
            end
            
            
            temp1 = find(pL(:,1) >= rand(1));
            TrialType.value = pL(temp1(1),2);
            ph = value(psych_history);
            psych_history.value = [ph value(TrialType)];
            if isequal(PsychType, 'Duration')
                SoundInterface(obj, 'set', 'left_stimulus', 'Dur1',  psycsounds(value(TrialType)));
            elseif isequal(PsychType, 'Frequency')
                if strcmp(SoundInterface(obj, 'get', 'left_stimulus', 'Style'),'Tone')
                    SoundInterface(obj, 'set', 'left_stimulus', 'Freq1', psycsounds(value(TrialType)));
                else
                    SoundInterface(obj, 'set', 'left_stimulus', 'FreqS', psycsounds(value(TrialType)));
                end
            else
                SoundInterface(obj, 'set', 'left_stimulus', 'WNP', psycsounds(value(TrialType)));
            end
        else
            pR        = zeros(10-firstright+1,2);
            pR(:,1)   = posterior(firstright:10) / sum(posterior(firstright:10));
            pR(:,2)   = firstright:10;
            pR        = sortrows(pR,1);
            for t = 1:size(pR,1)
                if t > 1; pR(t,1) = pR(t,1) + pR(t-1,1); end
            end
            
            
            temp1 = find(pR(:,1) >= rand(1));
            TrialType.value = pR(temp1(1),2);
            ph = value(psych_history);
            psych_history.value = [ph value(TrialType)];
            if isequal(PsychType, 'Duration')
                SoundInterface(obj, 'set', 'right_stimulus', 'Dur1',  psycsounds(value(TrialType)));
            elseif isequal(PsychType, 'Frequency')
                if strcmp(SoundInterface(obj, 'get', 'right_stimulus', 'Style'),'Tone')
                    SoundInterface(obj, 'set', 'right_stimulus', 'Freq1', psycsounds(value(TrialType)));
                else
                    SoundInterface(obj, 'set', 'right_stimulus', 'FreqS', psycsounds(value(TrialType)));
                end    
            else
                SoundInterface(obj, 'set', 'right_stimulus', 'WNP', psycsounds(value(TrialType)));
            end
        end
    else
        ph = value(psych_history);
        psych_history.value = [ph ft];
        TrialType.value = ft;
        
        if     ft <= lastleft && isequal(PsychType, 'Duration')
            SoundInterface(obj, 'set', 'left_stimulus',  'Dur1', psycsounds(ft));
        elseif ft <= lastleft && isequal(PsychType, 'Frequency') 
            if strcmp(SoundInterface(obj, 'get', 'left_stimulus', 'Style'),'Tone')
                SoundInterface(obj, 'set', 'left_stimulus', 'Freq1', psycsounds(ft));
            else
                SoundInterface(obj, 'set', 'left_stimulus','FreqS', psycsounds(ft));
            end
        elseif ft <= lastleft && isequal(PsychType, 'Phantom')
            SoundInterface(obj, 'set', 'left_stimulus', 'WNP', psycsounds(ft));
        elseif ft >= firstright && isequal(PsychType, 'Duration')
            SoundInterface(obj, 'set', 'right_stimulus', 'Dur1', psycsounds(ft));
        elseif ft >= firstright && isequal(PsychType, 'Frequency') 
            if strcmp(SoundInterface(obj, 'get', 'right_stimulus', 'Style'),'Tone')
                SoundInterface(obj, 'set', 'right_stimulus','Freq1', psycsounds(ft));
            else
                SoundInterface(obj, 'set', 'right_stimulus','FreqS', psycsounds(ft));
            end
        elseif ft >= firstright && isequal(PsychType, 'Phantom')
            SoundInterface(obj, 'set', 'right_stimulus', 'WNP', psycsounds(ft));
        else
            if isequal(PsychType,'Duration')
                SoundInterface(obj, 'set', 'left_stimulus',  'Dur1', psycsounds(ft));
                SoundInterface(obj, 'set', 'right_stimulus', 'Dur1', psycsounds(ft));
            elseif isequal(PsychType,'Frequency')
                if strcmp(SoundInterface(obj, 'get', 'right_stimulus', 'Style'),'Tone')
                    SoundInterface(obj, 'set', 'left_stimulus', 'Freq1', psycsounds(ft));
                    SoundInterface(obj, 'set', 'right_stimulus','Freq1', psycsounds(ft));
                else
                    SoundInterface(obj, 'set', 'left_stimulus', 'FreqS', psycsounds(ft));
                    SoundInterface(obj, 'set', 'right_stimulus','FreqS', psycsounds(ft));
                end
            elseif isequal(PsychType,'Phantom')
                SoundInterface(obj, 'set', 'left_stimulus', 'WNP', psycsounds(ft));
                SoundInterface(obj, 'set', 'right_stimulus', 'WNP', psycsounds(ft));
            end
        end
    end
    
    SidesSection(obj,'set_forcetrial',[]);
    
    if value(UseSecondaryPsych) == 1
        leftend  = value(Snd_LeftEndPsych); %#ok<NODEF>
        rightend = value(Snd_RightEndPsych); %#ok<NODEF>
    
        if isequal(Snd_PsychType,'Phantom')
            phantomparam = PhantomSection(obj, 'get_phantomparam');
            if phantomparam == 0
              psycsounds = [(0:4) (4:-1:0)]*(rightend-leftend)*0.25+leftend;
            else
              psycsounds = (1-exp(-(0:4)*phantomparam))*(rightend-leftend)/(1-exp(-4*phantomparam)) + leftend;
              psycsounds = [psycsounds psycsounds(5:-1:1)];
            end
        else
            psycsounds = 10.^(log10(leftend):(log10(rightend)-log10(leftend))/9:log10(rightend));
        end
        
        if     value(Snd_NumPsych == 1); good = [1 10];
        elseif value(Snd_NumPsych == 2); good = [1 2 9 10];
        elseif value(Snd_NumPsych == 3); good = [1:3 8:10];
        elseif value(Snd_NumPsych == 4); good = [1:4 7:10];
        elseif value(Snd_NumPsych == 5); good = [1:5 6:10];
        end
        
        rt = randperm(length(good)); nt = good(rt(1));
        
        Snd_TrialType.value = nt;
        
        if isequal(Snd_PsychType,'Duration')
            SoundInterface(obj, 'set', 'left_stimulus',  'Dur1', psycsounds(nt));
            SoundInterface(obj, 'set', 'right_stimulus', 'Dur1', psycsounds(nt));
        elseif isequal(Snd_PsychType,'Frequency')
            SoundInterface(obj, 'set', 'left_stimulus',  'Freq1', psycsounds(nt));
            SoundInterface(obj, 'set', 'right_stimulus', 'Freq1', psycsounds(nt));
        end
        
        sndph = value(snd_psych_history);
        snd_psych_history.value = [sndph nt];
    else
        sndph = value(snd_psych_history);
        snd_psych_history.value = [sndph 1];
    end
    
        
    
%% reinit      
% -----------------------------------------------------------------------
%
%         REINIT
%
% -----------------------------------------------------------------------

  case 'reinit',
    currfig = double(gcf);
    
    % Get the original GUI position and figure:
    x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));

    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);

    % Reinitialise at the original GUI position and figure:
    [x, y] = feval(mfilename, obj, 'init', x, y);

    % Restore the current figure:
    figure(currfig);

%% update_endpoints
% -----------------------------------------------------------------------
%
%         UPDATE_ENDPOINTS
%
% -----------------------------------------------------------------------

    case 'update_endpoints',
        if strcmp(value(Stimuli_Spacing),'Logarithmic') == 1
            LeftEndPsych.value = sqrt((value(Mid)^2) / value(Spread)); %#ok<NODEF>
        else
            LeftEndPsych.value = (2 * value(Mid)) / (value(Spread) + 1);   %#ok<NODEF>
        end
        RightEndPsych.value = value(LeftEndPsych) * value(Spread); 
        
        
%% update_mid_spread
% -----------------------------------------------------------------------
%
%         UPDATE_MID_SPREAD
%
% -----------------------------------------------------------------------

    case 'update_mid_spread',       
        if strcmp(value(Stimuli_Spacing),'Logarithmic') == 1
            Mid.value = 10 ^ (log10(value(LeftEndPsych)) + (4.5 * ((log10(value(RightEndPsych)) - log10(value(LeftEndPsych))) / 9))); %#ok<NODEF>
        else
            Mid.value = mean([value(LeftEndPsych) value(RightEndPsych)]); %#ok<NODEF>
        end
        Spread.value = value(RightEndPsych) / value(LeftEndPsych);
      
        
%% update_sndendpoints
% -----------------------------------------------------------------------
%
%         UPDATE_SNDENDPOINTS
%
% -----------------------------------------------------------------------

    case 'update_sndendpoints',
        Snd_LeftEndPsych.value  = sqrt((value(Snd_Mid)^2) / value(Snd_Spread)); %#ok<NODEF>
        Snd_RightEndPsych.value = value(Snd_LeftEndPsych) * value(Snd_Spread); 
        
        
%% update_sndmid_sndspread
% -----------------------------------------------------------------------
%
%         UPDATE_SNDMID_SNDSPREAD
%
% -----------------------------------------------------------------------

    case 'update_sndmid_sndspread',       
        Snd_Mid.value = 10 ^ (log10(value(Snd_LeftEndPsych)) + (4.5 * ((log10(value(Snd_RightEndPsych)) - log10(value(Snd_LeftEndPsych))) / 9))); %#ok<NODEF>
        Snd_Spread.value = value(Snd_RightEndPsych) / value(Snd_LeftEndPsych);
        
        
%% update_sound_type
% -----------------------------------------------------------------------
%
%         UPDATE_SOUND_TYPE
%
% -----------------------------------------------------------------------

    case 'update_sound_type',  
      if isequal(PsychType,'Phantom') || isequal(Snd_PsychType,'Phantom')
        SoundInterface(obj,'set','right_stimulus','Style','WhiteNoiseTone');
        SoundInterface(obj,'set','left_stimulus', 'Style','WhiteNoiseTone');
      else
        %SoundInterface(obj,'set','right_stimulus','Style','Tone');
        %SoundInterface(obj,'set','left_stimulus', 'Style','Tone');
      end
      
%% disp_secondarypsych
% -----------------------------------------------------------------------
%
%         DISP_SECONDARYPSYCH
%
% -----------------------------------------------------------------------

    case 'disp_secondarypsych'
        myfig = value(eval('SecondaryPsychFigure'));
        if ShowSecondaryPsych == 1; set(myfig, 'Visible', 'on');
        else                        set(myfig, 'Visible', 'off');
        end
        

%% update_secondarypsych
% -----------------------------------------------------------------------
%
%         UPDATE_SECONDARYPSYCH
%
% -----------------------------------------------------------------------

    case 'update_secondarypsych'
        if UseSecondaryPsych == 1; enable(eval('ShowSecondaryPsych'));
        else                      disable(eval('ShowSecondaryPsych'));
        end

end;
        
        
        
        
        
        
        