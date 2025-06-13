function [] = parameters_check(obj, action)

% SoloFunction('parameters_check', 'rw_args', {'ValveLeft', 'ValveRight', ...
%     'ValveCenter', 'ValidAnswerDelay', 'ITImin', 'ITImax', 'IncorITI', ...
%     'ShortPokeITI', 'VadITI'});

   GetSoloFunctionArgs;

   switch action,
    case 'ValveLeft',
      if ValveLeft > 0.2, 
         ValveLeft.value = 0.2;
         warning('ValveLeft should be shorter than 0.2s!');
      end;
      if ValveLeft < 0.002, 
         ValveLeft.value = 0.002;
         warning('ValveLeft should be longer than 0.002s!');
      end;
      
    case 'ValveRight',
      if ValveRight > 0.2, 
         ValveRight.value = 0.2;
         warning('ValveRight should be shorter than 0.2s!');
      end;
      if ValveRight < 0.002, 
         ValveRight.value = 0.002;
         warning('ValveRight should be longer than 0.002s!');
      end;
      
     case 'ValveCenter',
      if ValveCenter > 0.2, 
         ValveCenter.value = 0.2;
         warning('ValveCenter should be shorter than 0.2s!');
      end;
      if ValveCenter < 0.002, 
         ValveCenter.value = 0.002;
         warning('ValveCenter should be longer than 0.002s!');
      end;
      
       case 'ValveLeftSwitch',
           if ValveLeftSwitch > 0.2,
               ValveLeftSwitch.value = 0.2;
               warning('ValveLeftSwitch should be shorter than 0.2s!');
           end;
           if ValveLeftSwitch < 0.002,
               ValveLeftSwitch.value = 0.002;
               warning('ValveLeftSwitch should be longer than 0.002s!');
           end;

       case 'ValveRightSwitch',
           if ValveRightSwitch > 0.2,
               ValveRightSwitch.value = 0.2;
               warning('ValveRightSwitch should be shorter than 0.2s!');
           end;
           if ValveRightSwitch < 0.002,
               ValveRightSwitch.value = 0.002;
               warning('ValveRightSwitch should be longer than 0.002s!');
           end;
      
    %case 'ValidPokeDuration',
    %  if ValidPokeDuration < 0, 
    %     ValidPokeDuration.value = 0;
    %     warning('ValidPokeDuration should be positive or 0!');
    %  end; 
    case 'ValidAnswerDelay',
      if ValidAnswerDelay <= 0,
         ValidAnswerDelay.value = 0;
         warning('There is no timeout for answering. Is that OK?');
      end;
    case 'ITImin',
      if ITImin > ITImax
          ITImin.value=value(ITImax);
          warning('ITImin should be shorter than or equal to ITImax');  
      elseif ITImin < 0.002
          ITImin.value = 0.002;
         warning('ITImin should be 0.002s or longer');
      end; 
    case 'ITImax',
      if ITImax < ITImin
          ITImax.value = value(ITImin);
         warning('ITImax should be longer than or equal to ITImin');
      elseif ITImax > 100
         ITImax.value = 100;
         warning('ITImax is too long!');
      end; 
    case 'IncorITI',
        if IncorITI<1,
            IncorITI.value=1;
            warning('IncorITI should be longer than 1 s');
        end;
    case 'ShortPokeITI',
        if ShortPokeITI<1,
            ShortPokeITI.value=1;
            warning('ShortPokeITI should be longer than 1 s');
        end;
    case 'VadITI',
        if VadITI<1,
            VadITI.value=1;
            warning('VadITI should be longer than 1 s');
        end;
  
    otherwise
      error('Huhnh??? unknown action');
   end; 