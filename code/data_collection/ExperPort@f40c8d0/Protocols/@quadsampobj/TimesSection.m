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
   SoloParamHandle(obj, 'myxyfig', 'value', [x y gcf]);
   
   cell_units = {}; for i=0:2:16, 
      cell_units = [cell_units {num2str(i)}];
   end;

   extraiti_tooltip  = 'Extra seconds of white noise upon error response';
   itilen_tooltip    = 'Seconds of white noise after the end of the trial';
   itireinit_tooltip = 'Extra seconds of white noise if poke during ITI';
   apokepen_tooltip = 'Disallow Cin after GO signal';
   % UI params controlling inter-trial-interval (ITI):
   MenuParam(obj, 'ExtraITIonError',  cell_units, 1, x, y, ...
             'TooltipString', extraiti_tooltip); 
   ToggleParam(obj, 'OffRelevant', 1, x, y, 'label', ' ', ...
            'position',[x+180 y 20 20],...
            'TooltipString', sprintf(['Toggle that chooses between turning '...
                       'relevant sound off\non entering reward or error ' ...
                       'state (Toggle black),\nand letting it play ' ...
                       '(brown) '])); next_row(y);
   SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args', ...
                       'OffRelevant');
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
   MenuParam(obj, 'TimeOutLength',        cell_units, 2, x, y, ...
             'TooltipString', ['Total time out length, including firm and ' ...
                       'portion that reinits w/BadBoySound']);   next_row(y);
   MenuParam(obj, 'TimeOutFirm',          cell_units, 2, x, y, ...
             'TooltipString', ...
             sprintf(['Length of time for which TimeOut is steady\n' ...
                      'white noise, without reinit checks or BadBoySound\n'...
                      '   (can''t be longer than TimeOutLength)']));   
   SoloFunctionAddVars('make_and_upload_state_matrix', ...
                       'ro_args', 'TimeOutFirm');
   next_row(y);
   set_callback({TimeOutLength, TimeOutFirm}, {mfilename, 'to_length_firm'});
   MenuParam(obj, 'TimeOutReinitPenalty', cell_units, 2, x, y);   next_row(y);
   next_row(y, 0.5);

   MenuParam(obj, 'BadBoySound', {'harsher','on', 'off'}, 2, x, y); next_row(y);
   next_row(y, 0.5);
   
   % --- Finally, set up the UI for DrinkTime
   EditParam(obj, 'DrinkTime', 1, x, y);   next_row(y);

   
 case 'to_length_firm'
   if TimeOutFirm > TimeOutLength, 
      TimeOutFirm.value = value(TimeOutLength);
   end;
   
 case 'reinit', 
   currfig = gcf; x = myxyfig(1); y = myxyfig(2); figure(myxyfig(3));
   
   delete_sphandle('handlelist', ...
      get_sphandle('owner', class(obj), 'fullname', mfilename));

   feval(mfilename, obj, 'init', x, y);

   figure(currfig);
 otherwise,
   error(['Don''t know how to deal with action ' action]);
   
end;

    
     
