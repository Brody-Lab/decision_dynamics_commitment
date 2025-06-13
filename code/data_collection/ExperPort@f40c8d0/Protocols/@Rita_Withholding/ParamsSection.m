function [x, y, ITIPokeTimeOut, AfterShortPoke] = ParamsSection(obj, action, x, y)

GetSoloFunctionArgs;
%SoloFunction('ParamsSection', 'rw_args', {}, 'ro_args', {});

switch action,
 case 'init',   
   EditParam(obj, 'ITIPokeTimeOut', 0.0001, x, y, 'labelfraction', 0.6); next_row(y);
   MenuParam(obj, 'AfterShortPoke', {'Try Again', 'End Trial'}, 1, ...
       x, y, 'labelfraction', 0.6); next_row(y);
   set_callback(AfterShortPoke, {'ParamsSection', 'after_short_poke'});
   SubHeaderParam(obj, 'OtherParams', 'Other Parameters',x,y);next_row(y);
   next_row(y,0.5);
   
 case 'after_short_poke',
   if strcmp(value(AfterShortPoke), 'Try Again'),
       TrialLengthSection(obj, 'after_short_poke_try_again');
   end;
   
 case 'trial_length_constant_yes',
   if strcmp(value(AfterShortPoke), 'Try Again'),
       warning('If ''TrialLengthConstant'' is ''Yes'', ''AfterShortPoke'' has to be ''End Trial!''');
       AfterShortPoke.value = 'End Trial';
   end;
            
 otherwise,
   error(['Don''t know how to deal with action ' action]);
   
end;