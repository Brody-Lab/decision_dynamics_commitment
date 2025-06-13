function [] = num_check(obj, action)

   GetSoloFunctionArgs;

   switch action,
    case 'num_trains',
%      if num_trains*num_pulses > 150, 
%         num_trains.value = floor(150/num_pulses); 
%      end;
      
      
    case 'num_pulses',
%      if num_trains*num_pulses > 150, 
%         num_pulses.value = floor(150/num_trains); 
%      end;

    otherwise
      error('Huhnh??? unknown action');
   end;
   
   total_pulses.value = num_trains*num_pulses;
   