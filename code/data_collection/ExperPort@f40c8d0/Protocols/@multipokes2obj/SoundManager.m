% [] = SoundManager(obj, action)
%
% Section that takes care of keeping track of sounds
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%            'init'      To initialise the section and set up the GUI
%                        for it
%
%            'reinit'    Delete all of this section's GUIs and data,
%                        and reinit, at the same position on the same
%                        figure as the original section GUI was placed.
%
%           
% x, y     Relevant to action = 'init'; they indicate the initial
%          position to place the GUI at, in the current figure window
%
% RETURNS:
% --------
%
% [x, y]   When action == 'init', returns x and y, pixel positions on
%          the current figure, updated after placing of this section's GUI. 
%
% x        When action == 'get_tone_duration', x is length, in
%          milliseconds, of the sounds the rat should discriminate.
%
% x        When action == 'get_sound_ids', x is a structure with two
%          fieldnames, 'right' and 'left'; the values of these fieldnames
%          will be the sound numbers of the tone loaded as the Right sound
%          and of the tone loaded as the Left sound, respectively.
%           


function [out] = SoundManager(obj, action, arg1, arg2)
   
   GetSoloFunctionArgs;
   if exist('the_sounds', 'var'),
     uploadCol = findCol(the_sounds, 'uploaded');
     idCol     = findCol(the_sounds, 'id');
     valueCol  = findCol(the_sounds, 'value');
     nameCol   = findCol(the_sounds, 'soundname');
     
     nsounds   = size(value(the_sounds),1) - 1;
   end;
   
   
   switch action
     case 'init',   % ---------- CASE INIT -------------

       % First delete all previous (now obsolete) instances of the SoundManager:
       delete_sphandle('owner', ['^@' class(obj) '$'], ...
         'fullname', ['^' mfilename]);


       % Old call to initialise sound system:
       rpbox('InitRP3StereoSound');
       SoloParamHandle(obj, 'sound_machine', 'value', rpbox('getsoundmachine'), 'saveable', 0);
       Initialize(value(sound_machine)); % Direct initialize to clear all sounds, make room for new
       SoloParamHandle(obj, 'the_sounds', 'saveable', 0, 'value', ...
         {'soundname', 'id', 'uploaded', 'value'});
       
       
      
     case 'send_not_yet_uploaded_sounds',  % -------- CASE SEND_NOT_YET_UPLOADED_SOUNDS -------       
       for i=2:rows(the_sounds(:,:)),
         if the_sounds{i, uploadCol} == 0,
           if min(size(the_sounds{i, valueCol}))==1,
             LoadSound(value(sound_machine), the_sounds{i, idCol}, the_sounds{i, valueCol}, 'both');
           else
             LoadSound(value(sound_machine), the_sounds{i, idCol}, the_sounds{i, valueCol});
           end;
           the_sounds{i, uploadCol} = 1;
         end;
       end;
       
       
     case 'set_sound',    % ---------- CASE SET_SOUND --------
       name = arg1; val = arg2;
       
       rownum = find(strcmp(the_sounds(2:nsounds+1,nameCol), name));
       if isempty(rownum)
         error('No sound with name %s declared yet', name);
       end;
       rownum = rownum+1;
       if size(val, 1) > 2, val = val'; end;
       the_sounds{rownum, valueCol}  = val;
       the_sounds{rownum, uploadCol} = 0;
       
       
       
     case 'declare_new_sound',  % ------ DECLARE_NEW_SOUND ------
       name = arg1;
       new_id = max(cell2mat(the_sounds(2:nsounds+1,idCol))) + 1;
       if isempty(new_id), new_id = 1; end;  % No sounds existed before.
       sz = size(value(the_sounds));
       newrow = sz(1)+1;
       
       the_sounds.value = [value(the_sounds) ; cell(1, sz(2))];
       
       the_sounds{newrow, nameCol}    = name;
       the_sounds{newrow, idCol}      = new_id;
       the_sounds{newrow, uploadCol}  = 0;
       
       if nargin >= 4, 
         if size(arg2,1) > 2, arg2 = arg2'; end;
         the_sounds{newrow, valueCol} = arg2;
       end;
       
    
     case 'sound_exists',   % ------- CASE SOUND_EXISTS -------
       rownum = find(strcmp(the_sounds(2:nsounds+1,nameCol), arg1));
       out = ~isempty(rownum);
       
       
     case 'get_sample_rate',  % -----  CASE GET_SAMPLE_RATE -------
       out = GetSampleRate(value(sound_machine));
       
       
     case 'get_sound_id',   %  -------- CASE GET_SOUND_ID -------------------
       name = arg1;
       rownum = find(strcmp(the_sounds(2:nsounds+1,1), name));
       if isempty(rownum),
         error('No sound with name %s declared yet', name);
       else
         out = the_sounds{rownum+1, idCol};
       end;

       
     case 'get_sound_duration',   % ------- CASE GET_SOUND_DURATION ---------
       name = arg1;
       rownum = find(strcmp(the_sounds(2:nsounds+1,1), name));
       if isempty(rownum),
         error('No sound with name %s declared yet', name);
       else
         out = max(size(the_sounds{rownum+1, valueCol}))/GetSampleRate(value(sound_machine));
       end;
       
       
       
    case 'reinit',       % ---------- CASE REINIT -------------
      % Delete all SoloParamHandles who belong to this object and whose
      % fullname starts with the name of this mfile:
      delete_sphandle('owner', ['^@' class(obj) '$'], ...
                      'fullname', ['^' mfilename]);

      feval(mfilename, obj, 'init');
   end;
   
   return;
   
   
% ----------------------------
   
function [num] = findCol(db, name)

num = find(strcmp(db(1,:), name));



      