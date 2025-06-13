% [non_v, saveable] = CPokeEODSection(obj, action, varargin)
%
% Code that can be run at the end of a session. Uses cpoke_diagnostics to
% ask what would happen if we increased legal_cbreak by a certain amount;
% increases it if it looks like it would help to reduce cpoke violations.
% This makes sense when we are in the "one cpoke/w legal breaks" mode (see
% toggle button StimulusSection.m/count_cpokes).
%
% EXAMPLE:
% 
% In your SessionDefinition End-of-Day logic code, simply add the line:
%
%   CpokeEODSection(SameDifferent, 'eod');
%
%
% This code auto-adds a variety of diagnostic statements to the Comments
% section. These include fraction of cpoke violation trials, as well as
% fraction of "saveable" trials (saveable by increasing legal_cbreak).
%
% Internally created SPHs, saved and loaded with settings (use 
% change_settings.m to access them and change them if you need to) are:
%
% legal_cbreak_max  Default 0.25. Maximum value that legal_cbreak may take.
%                   Will not increase beyond this value, no matter what.
%
% legal_cbreak_min_trials   Default 150. Don't even consider increasing
%                   legal_cbreak unless this many trials have been done.
%
% savetau           Default 0.05 secs. How much to consider increasing
%                   legal_cbreak by.
%
% saveable_thresh   Default 0.15. If the fraction of broken trials that
%                   would be saveable by increasing legal_cbreak by savetau
%                   is bigger than this, then legal_cbreak is increased.
%
% legal_cbreak_delta Default 0.05. How much to increase legal_cbreak by
%                   once we decide to increase it. Usually same as savetau.
%
%
% OPTIONAL PARAMETERS:
% --------------------
%
% The following may be passed as name-value pairs:
%
% 'legal_cbreak_max'         Default = value(legal_cbreak_max)  
% 'legal_cbreak_min_trials'  Default = value(legal_cbreak_min_trials) 
% 'savetau'                  Default = value(savetau)           
% 'saveable_thresh'          Default =value(saveable_thresh)
% 'legal_cbreak_delta'       Default =value(legal_cbreak_delta) 
%
% 
%
% RETURNS:
% -------
%
% non_v     Fraction of trials where no cpoke violation occurred
%
% saveable  Fraction of violation cpokes that would have been saved by
%           extending legal_cbreak by savetau secs
%
%
% EXAMPLE:
% --------
% 
% In your SessionDefinition End-of-Day logic code, simply add the line:
%
%   CpokeEODSection(SameDifferent, 'eod');
%

% Carlos Brody May 2009

function [varargout] = CpokeEODSection(obj, action, varargin)
   
GetSoloFunctionArgs(obj);

switch action
%% init    
  case 'init',
  
    SoloParamHandle(obj, 'legal_cbreak_max', 'value', 0.05, 'save_with_settings', 1);

    SoloParamHandle(obj, 'legal_cbreak_min_trials', 'value', 0.05, 'save_with_settings', 1);

    SoloParamHandle(obj, 'savetau', 'value', 0.05, 'save_with_settings', 1);
    
    SoloParamHandle(obj, 'saveable_thresh', 'value', 0.05, 'save_with_settings', 1);
    
    SoloParamHandle(obj, 'legal_cbreak_delta', 'value', 0.05, 'save_with_settings', 1);
    

%% eod
  case 'eod',
     
    pairs = { ...
       'legal_cbreak_max',        value(legal_cbreak_max)   ;  ...
       'legal_cbreak_min_trials', value(legal_cbreak_min_trials)   ;  ...
       'savetau',                 value(savetau)            ;  ...
       'saveable_thresh',         value(saveable_thresh)    ;  ...
       'legal_cbreak_delta',      value(legal_cbreak_delta) ;  ...
    }; parseargs(varargin, pairs);
 
    non_v_rate = (1 - cpoke_violations/n_done_trials);                              
    CommentsSection(obj, 'append_line', sprintf('cpoke_eod: non_v is %.1f%%', 100*non_v_rate));
    
    if count_cpokes==1,
      fprintf(1, 'CpokeEODSection: I only run when StimulusSection_count_cpokes is 0, i.e., one cpoke w/legal breaks mode\n');
      CommentsSection(obj, 'append_line', 'CpokeEODSection: I only run when StimulusSection_count_cpokes is');
      CommentsSection(obj, 'append_line', '0, i.e., one cpoke w/legal breaks mode');
      return;
    end;
      
    [trash, trash, saveable] = cpoke_diagnostics(obj, parsed_events_history, ...
      'savetau', savetau*1);
    saveable = nanmean(saveable);
    CommentsSection(obj, 'append_line', sprintf('cpoke_eod: saveablefrac = %.2f', saveable));                                              
                                                                                               
    if saveable > saveable_thresh && n_done_trials > legal_cbreak_min_trials && ...
        legal_cbreak < legal_cbreak_max, %#ok<NODEF>
      oldvalue = legal_cbreak*1;
      legal_cbreak.value = legal_cbreak + legal_cbreak_delta; 
      if legal_cbreak > legal_cbreak_max,
          legal_cbreak.value = legal_cbreak_max*1;
      end;
      CommentsSection(SameDifferent, 'append_line', ...
        sprintf('cpoke_eod: legal_cbreak increased from %.2f to = %.2f', oldvalue, legal_cbreak*1));
    end;

    if nargout > 0, varargout{1} = non_v_rate; end;
    if nargout > 1, varargout{2} = saveable; end;
      
    
%% otherwise    
  otherwise,
    fprintf(1, 'CpokeEODSection: Don''t know action %s\n', action);
    CommentsSection(obj, 'append_line', sprintf('CpokeEODSection: Don''t know action %s', action));

    
end;
