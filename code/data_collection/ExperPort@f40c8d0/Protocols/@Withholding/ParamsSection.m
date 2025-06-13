function [x, y, ...
          MultiPokeTolerance, ITIPokeTimeOut, RewardAvailPeriod, MultiPoke] ...
    = ParamsSection(obj, action, x, y)

GetSoloFunctionArgs;
%SoloFunction('ParamsSection', 'rw_args', {}, 'ro_args', {});

switch action,
 case 'init',
   %when you change multi_poke_tolerance, check compatibility with param MultiPoke
   EditParam(obj, 'MultiPokeTolerance', 0, x, y, 'labelfraction', 0.6); next_row(y);
   set_callback(MultiPokeTolerance, {'ParamsSection', 'multi_poke_tolerance'});
   EditParam(obj, 'ITIPokeTimeOut', 0.0001, x, y, 'labelfraction', 0.6); next_row(y);
   EditParam(obj, 'RewardAvailPeriod', 20, x, y, 'labelfraction', 0.6);next_row(y);
   MenuParam(obj, 'MultiPoke', {'valid_waiting', 'just_noiseB', 'no_reward'}, ...
       1, x, y);next_row(y);
   set_callback(MultiPoke, {'ParamsSection', 'multi_poke'});
   SubHeaderParam(obj, 'OtherParams', 'Other Parameters',x,y);next_row(y);
   next_row(y,0.5);
  
    case 'multi_poke',
        %callback of SPH MultiPoke (in this section)
        if strcmp(value(MultiPoke), 'valid_waiting'),
            MultiPokeTolerance.value =0;
            sprintf('If MultiPoke is ''valid_waiting'', MultiPokeTolerance has to be 0');
            
            %TrialLengthConstant has to be no
            TrialLengthSection(obj,'trial_length_constant_no');
        end;
        
    case 'multi_poke_tolerance',
        %callback of SPH MultiPokeTolerance (in this section)
        if value(MultiPokeTolerance) ~=0,
            if strcmp(value(MultiPoke), 'valid_waiting'),
                MultiPoke.value = 'just_noiseB';
                sprintf('If multi_poke_tolerance is no-zero, ''MultiPoke'' can''t be ''valid_waiting''!');
            end;
        end;
        
    case 'multi_poke_not_valid_waiting',
        %call from TrialLengthSection, case 'trial_length_constant'
        if strcmp(value(MultiPoke), 'valid_waiting'),
            MultiPoke.value = 'just_noiseB';
            sprintf('If TrialLength is Constant, ''MultiPoke'' can''t be ''valid_waiting''!');
        end;
            
 otherwise,
   error(['Don''t know how to deal with action ' action]);
   
end;