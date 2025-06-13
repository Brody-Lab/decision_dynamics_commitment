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


function [x, y] = AnalysisSection(obj, action, x, y)
   
GetSoloFunctionArgs;

switch action

%% init  
  case 'init',
    % Save the figure and the position in the figure where we are
    % going to start adding GUI elements:
    SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);

    DispParam(obj, 'Hit_Frac',               0, x, y, 'labelfraction', 0.7); next_row(y);
    DispParam(obj, 'Choose_Left',            0, x, y, 'labelfraction', 0.7); next_row(y);
    DispParam(obj, 'Choose_Right',           0, x, y, 'labelfraction', 0.7); next_row(y,1.5);
    
    DispParam(obj, 'Free_Trials',            0, x, y, 'labelfraction', 0.7); next_row(y);
    DispParam(obj, 'Forced_Trials',          0, x, y, 'labelfraction', 0.7); next_row(y);
    DispParam(obj, 'Trial_Count',            0, x, y, 'labelfraction', 0.7); next_row(y,1.5);
    
    NumeditParam(obj, 'MultiDay_Free',       0, x, y, 'labelfraction', 0.7); next_row(y);
    NumeditParam(obj, 'MultiDay_Forced',     0, x, y, 'labelfraction', 0.7); next_row(y);
    NumeditParam(obj, 'MultiDay_Total',      0, x, y, 'labelfraction', 0.7); next_row(y);
    NumeditParam(obj, 'MultiDay_NoReward_L', 0, x, y, 'labelfraction', 0.7); next_row(y);
    NumeditParam(obj, 'MultiDay_NoReward_R', 0, x, y, 'labelfraction', 0.7); next_row(y,1.5);
    
    DispParam(obj, 'Duration_Ratio',         0, x, y, 'labelfraction', 0.7); next_row(y);
    DispParam(obj, 'Reward_Ratio',           0, x, y, 'labelfraction', 0.7); next_row(y);
    
    SubheaderParam(obj, 'title', 'Analysis Section', x, y);
    next_row(y, 0.5);
    
    SoloParamHandle(obj, 'Indifference1', 'value', [], 'save_with_settings',1);
    SoloParamHandle(obj, 'Indifference2', 'value', [], 'save_with_settings',1);
    SoloParamHandle(obj, 'Indifference3', 'value', [], 'save_with_settings',1);
    SoloParamHandle(obj, 'Indifference4', 'value', [], 'save_with_settings',1);
    SoloParamHandle(obj, 'Indifference5', 'value', [], 'save_with_settings',1);
    SoloParamHandle(obj, 'Indifference6', 'value', [], 'save_with_settings',1);
    SoloParamHandle(obj, 'Indifference7', 'value', [], 'save_with_settings',1);
    SoloParamHandle(obj, 'Indifference8', 'value', [], 'save_with_settings',1);
    
    SoloParamHandle(obj, 'Start_PIP_1', 'value', [], 'save_with_settings',1);
    SoloParamHandle(obj, 'Stop_PIP_1',  'value', [], 'save_with_settings',1);
    SoloParamHandle(obj, 'Start_PIP_2', 'value', [], 'save_with_settings',1);
    SoloParamHandle(obj, 'Stop_PIP_2',  'value', [], 'save_with_settings',1);
    SoloParamHandle(obj, 'Start_PIP_3', 'value', [], 'save_with_settings',1);
    SoloParamHandle(obj, 'Stop_PIP_3',  'value', [], 'save_with_settings',1);
    SoloParamHandle(obj, 'Start_PIP_4', 'value', [], 'save_with_settings',1);
    SoloParamHandle(obj, 'Stop_PIP_4',  'value', [], 'save_with_settings',1);
    SoloParamHandle(obj, 'Start_PIP_5', 'value', [], 'save_with_settings',1);
    SoloParamHandle(obj, 'Stop_PIP_5',  'value', [], 'save_with_settings',1);
    SoloParamHandle(obj, 'Start_PIP_6', 'value', [], 'save_with_settings',1);
    SoloParamHandle(obj, 'Stop_PIP_6',  'value', [], 'save_with_settings',1);
    SoloParamHandle(obj, 'Start_PIP_7', 'value', [], 'save_with_settings',1);
    SoloParamHandle(obj, 'Stop_PIP_7',  'value', [], 'save_with_settings',1);
    SoloParamHandle(obj, 'Start_PIP_8', 'value', [], 'save_with_settings',1);
    SoloParamHandle(obj, 'Stop_PIP_8',  'value', [], 'save_with_settings',1);
    
    SoloParamHandle(obj, 'DoneWithStage', 'value', 0,  'save_with_settings',1);
    

%% update_values
% -----------------------------------------------------------------------
%
%         UPDATE_VALUES
%
% -----------------------------------------------------------------------

  case 'update_values',
    
      if n_done_trials > 0
        Hit_Frac.value = mean(hit_history);
        
        free_trials         = find(sides_history(1:length(hit_history)) == 'f');
        forced_trials       = find(sides_history(1:length(hit_history)) ~= 'f');
        Choose_Left.value   = length(find(choice_history(free_trials) == 'l')) / length(free_trials);
        Choose_Right.value  = length(find(choice_history(free_trials) == 'r')) / length(free_trials);
    
        Free_Trials.value   = length(free_trials);
        Forced_Trials.value = length(forced_trials);
        Trial_Count.value   = value(Free_Trials) + value(Forced_Trials);
        
        l_gap = DistribInterface(obj, 'get_current_sample', 'left_gap');
        r_gap = DistribInterface(obj, 'get_current_sample', 'right_gap');
        Duration_Ratio.value = r_gap / l_gap;
        
        Reward_Ratio.value = value(R_Reward_Multiply) / value(L_Reward_Multiply);
      end
    
%% update_trial_count
% -----------------------------------------------------------------------
%
%         UPDATE_TRIAL_COUNT
%
% -----------------------------------------------------------------------

  case 'update_trial_count',
      MultiDay_Total.value   = value(MultiDay_Total) + 1; %#ok<NODEF>
      if strcmp(SidesSection(obj, 'get_trial_type'),'Free')
          MultiDay_Free.value = value(MultiDay_Free) + 1; %#ok<NODEF>
      else
          MultiDay_Forced.value = value(MultiDay_Forced) + 1; %#ok<NODEF>
      end
      
      if ~isempty(nonreward_history)
          if strcmp(nonreward_history(end),'l') %#ok<COLND>
              MultiDay_NoReward_L.value = value(MultiDay_NoReward_L) + 1; %#ok<NODEF>
          elseif strcmp(nonreward_history(end),'r') %#ok<COLND>
              MultiDay_NoReward_R.value = value(MultiDay_NoReward_R) + 1; %#ok<NODEF>
          end
      end
      
      
      
    
%% reinit      
% -----------------------------------------------------------------------
%
%         REINIT
%
% -----------------------------------------------------------------------

  case 'reinit',
    currfig = gcf;
    
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
end;

