function [x, y, iti_sound_len, tout_sound_len, ExtraITIonError, DrinkTime]=...
    InitTimes(obj, action, x, y);
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

switch action,
    case 'init',
        % UI params controlling inter-trial-interval (ITI):
        MenuParam(obj, 'ExtraITIonError', {'0', '1', '2', '3', '4', '5', '6'},   1, x, y); next_row(y);
        MenuParam(obj, 'ITISound',    {'silence', 'white noise'}, 2, x, y);   next_row(y);
        EditParam(obj, 'ITILength',                               2, x, y);   next_row(y);

        % If user changes params, re-create iti sound:
        set_callback({ITILength, ITISound}, {'TimesSection', 'make_iti_sound'});
    
        SoloParamHandle(obj, 'iti_sound_data');  % actual iti sound data vector
        SoloParamHandle(obj, 'iti_sound_len');   % in secs
        SoloParamHandle(obj, 'iti_sound_uploaded');  % if 1, current sound is not yet uploaded
    
        TimesSection(obj, 'make_iti_sound'); % Run this to make iti sound for the first time
        next_row(y, 0.5);
    
        % --- Now TimeOut sound: for comments, see ITISound immediately above
    
        MenuParam(obj, 'TimeOutSound',{'silence', 'white noise'}, 2, x, y);   next_row(y);
        EditParam(obj, 'TimeOutLength',                        0.25, x, y);   next_row(y);
        set_callback({TimeOutLength, TimeOutSound}, {'TimesSection', 'make_timeout_sound'});

        SoloParamHandle(obj, 'tout_sound_data');
        SoloParamHandle(obj, 'tout_sound_len');
        SoloParamHandle(obj, 'tout_sound_uploaded');
    
        TimesSection(obj, 'make_timeout_sound');

    
        % --- Finally, set up the UI for DrinkTime
        EditParam(obj, 'DrinkTime', 1, x, y);   next_row(y);

     
    return;
    
     
