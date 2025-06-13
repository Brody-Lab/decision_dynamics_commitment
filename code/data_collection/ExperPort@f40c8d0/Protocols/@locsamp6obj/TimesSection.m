function [x, y, BadBoySound, ITISound, ITILength, ITIReinitPenalty, ...
          TimeOutSound, TimeOutLength, TimeOutReinitPenalty, ...
	  APokePenalty, ...
          ExtraITIonError, DrinkTime]=TimesSection(obj, action, x, y);
%
%[x, y, iti_sound_len, tout_sound_len, ExtraITIonError, ...
%            DrinkTime]=InitTimes(x, y, obj);
%
% args:    x, y                 current UI pos, in pixels
%          obj                  A locsamp3obj object
%
% returns: x, y                 updated UI pos
%          iti_sound_len        handle to length, in secs, of ITI sound
%          timeout_sound_len    handle to length, in secs, of timeout sound
%          ExtraITIOnError      handle to # of ITI sounds to emit on error
%          DrinkTime            handle to length of pause after correct
%
% Simply initialises (or re-initialises) all UI elements parameterising
% penalty/ITI states (states with white noise)
%
GetSoloFunctionArgs;

switch action,
 case 'init',
   cell_units = {}; for i=0:2:16, 
      cell_units = [cell_units {num2str(i)}];
   end;

   extraiti_tooltip  = 'Extra seconds of white noise upon error response';
   itilen_tooltip    = 'Seconds of white noise after the end of the trial';
   itireinit_tooltip = 'Extra seconds of white noise if poke during ITI';
   apokepen_tooltip = 'Disallow Cin after GO signal';
   % UI params controlling inter-trial-interval (ITI):
   MenuParam(obj, 'ExtraITIonError',  cell_units, 1, x, y, ...
             'TooltipString', extraiti_tooltip); next_row(y);
   MenuParam(obj, 'ITISound',  {'silence', 'white noise'}, 2, x, y, ...
             'TooltipString', 'Always white noise for now'); next_row(y);
   set(get_ghandle(ITISound), 'Enable', 'off');
   MenuParam(obj, 'ITILength',        cell_units, 2, x, y, ...
             'TooltipString', itilen_tooltip); next_row(y);
   MenuParam(obj, 'ITIReinitPenalty', cell_units, 2, x, y, ...
             'TooltipString', itireinit_tooltip); next_row(y); 
   MenuParam(obj, 'APokePenalty', {'on', 'off'}, 2, x, y, ...
        	'TooltipString', apokepen_tooltip);next_row(y);
   	     next_row(y, 0.5);
   
   % --- Now TimeOut sound: for comments, see ITISound immediately above
   
   MenuParam(obj, 'TimeOutSound',{'silence', 'white noise'}, 2, x, y, ...
             'TooltipString', 'Always white noise for now'); next_row(y);
   set(get_ghandle(TimeOutSound), 'Enable', 'off');
   MenuParam(obj, 'TimeOutLength',        cell_units, 2, x, y);   next_row(y);
   MenuParam(obj, 'TimeOutReinitPenalty', cell_units, 2, x, y);   next_row(y);
   next_row(y, 0.5);

   MenuParam(obj, 'BadBoySound', {'harsher','on', 'off'}, 2, x, y); next_row(y);
   next_row(y, 0.5);
   
   % --- Finally, set up the UI for DrinkTime
   EditParam(obj, 'DrinkTime', 1, x, y);   next_row(y);

 case 'reinit', 
   delete_sphandle('handlelist', ...
      get_sphandle('owner', class(obj), 'fullname', mfilename));
   TimesSection(obj, 'init', 186, 100);
   
 otherwise,
   error(['Don''t know how to deal with action ' action]);
   
end;

    
     
