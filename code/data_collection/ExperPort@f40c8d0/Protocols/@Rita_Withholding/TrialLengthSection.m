function  [x,y, TrialLengthConstant, TrialLength] ...
    =  TrialLengthSection(obj, action, x, y)

GetSoloFunctionArgs;

switch action
  case 'init',
    NumEditParam(obj, 'TrialLength',6,x,y,'labelfraction', 0.6);next_row(y);
    set_callback(TrialLength, {'TrialLengthSection','trial_length'});
    MenuParam(obj, 'Adjust_TL_If_Short',{'Yes','No'},1,x,y,'labelfraction', 0.6);next_row(y);
    MenuParam(obj, 'TrialLengthConstant',{'No(FixedITI)','Yes'},1,x,y,'labelfraction', 0.6);next_row(y);
    set_callback(TrialLengthConstant, {'TrialLengthSection','trial_length_constant'});
    SubHeaderParam(obj, 'TrialLengthSubHeader', 'Trial Length Parameters',x,y);next_row(y);
    
    set([get_ghandle(TrialLength) get_lhandle(TrialLength) ...
         get_ghandle(Adjust_TL_If_Short) get_lhandle(Adjust_TL_If_Short)], ...
         'visible','off');
    
  case 'prepare_next_trial', %adjust TrialLength if necessary

      if n_done_trials == 0, %most likey this is called when you load settings
          %do nothing
          return;
      end;

      TRIAL_LENGTH_CONSTANT = value(TrialLengthConstant);
      TRIAL_LENGTH = value(TrialLength);
      ADJUST_TL_IF_SHORT = value(Adjust_TL_If_Short);
      
      if strcmp(TRIAL_LENGTH_CONSTANT,'Yes'),
          
          %first calculate time from cpoke to time_out1_out
          if ~isempty(parsed_events.states.time_out1_out_1),
              TIME_CIN_TO_ITI = parsed_events.states.time_out1_out_1(1,1) ...
                  - parsed_events.states.ready_to_start_waiting(1,2);
          elseif ~isempty(parsed_events.states.mirror_time_out1_out_1),
              TIME_CIN_TO_ITI = parsed_events.states.mirror_time_out1_out_1(1,1) ...
                            - parsed_events.states.ready_to_start_waiting(1,2);
          elseif ~isempty(parsed_events.states.sp_time_out1_out_1),
              TIME_CIN_TO_ITI = parsed_events.states.sp_time_out1_out_1(1,1) ...
                            - parsed_events.states.ready_to_start_waiting(1,2);
          else
              error('one of ''time_out1_out_1'' states should be visited in FSM');
          end;
          
          %if [TIME_CIN_TO_ITI + 3(for iti)] is longer than TrialLength
          %print message!!
          tempo=3;
          if TRIAL_LENGTH<=TIME_CIN_TO_ITI+tempo,
              fprintf('\n Real TrialLength : %g is shorter than Set TrialLength! %g\n', ...
                  TIME_CIN_TO_ITI+tempo, TRIAL_LENGTH);
              if strcmp(ADJUST_TL_IF_SHORT,'Yes'), %if yes adjust value
                  TRIAL_LENGTH = ceil(TIME_CIN_TO_ITI+5);
              end;
          end;
      end;

      TrialLength.value = TRIAL_LENGTH;

      
  case 'trial_length_constant',
      %callback of SPH TrialLengthConstant (in this section)
      %also called from BlockControlSection when block is switched
      %also called from case 'visualize_nose_poke_block_params' in this
      %section
      
      if strcmp(value(TrialLengthConstant),'Yes'),
          %trial_length is constant, a rat has to do wait_poke
          BeginnerSection(obj, 'trial_length_constant_yes');
          ParamsSection(obj, 'trial_length_constant_yes');
          
          set([get_ghandle(TrialLength) get_lhandle(TrialLength) ...
               get_ghandle(Adjust_TL_If_Short) get_lhandle(Adjust_TL_If_Short)], ...
               'visible','on');
          
      elseif strcmp(value(TrialLengthConstant),'No(FixedITI)'),
          set([get_ghandle(TrialLength) get_lhandle(TrialLength) ...
               get_ghandle(Adjust_TL_If_Short) get_lhandle(Adjust_TL_If_Short)], ...
               'visible','off');
      end;
      
  case 'trial_length',
        %callback of SPH TrialLength (in this section)
      if value(TrialLength) < 6,
          TrialLength.value = 6;
          fpringf('\nTrialLength has to be longer than 6sec!\n')
      end;
      
    case 'trial_length_constant_no',
        %call from PramsSection, when 'multi_poke' is set to 'valid_waiting'

        %also called from AutomationSection, when
        %Beginner, Yes; WaitPokeNecessary, No;

        TrialLengthConstant.value = 'No(FixedITI)';
        set([get_ghandle(TrialLength) get_lhandle(TrialLength) ...
            get_ghandle(Adjust_TL_If_Short) get_lhandle(Adjust_TL_If_Short)], ...
            'visible','off');  
        
    case 'after_short_poke_try_again',
        if strcmp(value(TrialLengthConstant), 'Yes'),
            warning('If ''AfterShortPoke'' is ''Try Again'', ''TrialLengthConstant'' should be ''No!''');
            TrialLengthConstant.value = 'No(FixedITI)';
            set([get_ghandle(TrialLength) get_lhandle(TrialLength) ...
            get_ghandle(Adjust_TL_If_Short) get_lhandle(Adjust_TL_If_Short)], ...
            'visible','off');             
        end;
      
  otherwise,
    warning('%s : %s  don''t know action %s\n', class(obj), mfilename, action);
end;

   
      