% [num] = get_wavenumber(sma, wavename)
%
% Returns the wavenumber of an already-declared scheduled wave. If a
% shceduled wave with the name wavename has not yet been declared through
% the add_scheduled_wave.m function, returns NaN. 
%
% get_wavenumber.m is useful only for low-level commands such as
% add_happening_spec.m. Most users will not need to use get_wavenumber.m
%
% PARAMETERS:
% -----------
%
% sma          The obligatory StateMachineAssembler object
%
% wavename     A string, specifying the name of the scheduled wave. If no
%              wave with this name has been declared using
%              add_scheduled_wave, NaN will be returned.
%
%
% RETURNS:
% --------
%
% num          The internal wavenumber that corresponds to wavename
% 
%
% EXAMPLE:
% --------
%
% >> sma = add_happening_spec(sma, struct(...
%            'name', 'mywave_went_high', ...
%            'detectorFunctionName', 'wave_high', ...
%            'input_number', get_wavenumber('mywave')));
%
%


% Written by Carlos Brody Mar 2010

function [num] = get_wavenumber(sma, wavename)
   
   [names{1:numel(sma.sched_waves)}] = deal(sma.sched_waves.name);
   
   u = find(strcmp(wavename, names));
   if isempty(u),
      num = NaN;
      return;
   else
      num = sma.sched_waves(u).id;
   end;
   
   