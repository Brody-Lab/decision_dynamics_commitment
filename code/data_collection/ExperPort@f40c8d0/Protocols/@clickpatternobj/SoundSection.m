% [x, y] = SoundSection(obj, action, x, y)
%
% Section that takes care of defining and uploading sounds
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
%           'make_sounds'   Use the current GUI params to make the
%                        sounds. Does not upload sounds.
%
%           'upload_sounds' If new sounds have been made since last
%                        upload, uploads them to the sounds machine.
%
%           'get_tone_duration'  Returns length, in milliseconds, of
%                        the sounds the rat should discriminate
%
%           'get_sound_ids'      Returns a structure with two
%                        fieldnames, 'right' and 'left'; the values of
%                        these fieldnames will be the sound numbers of
%                        the tone loaded as the Right sound and of the
%                        tone loaded as the Left sound, respectively.
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


function [x, y] = SoundSection(obj, action, x, y)
   
   GetSoloFunctionArgs;
   
   switch action
    case 'init',   % ---------- CASE INIT -------------
      
      % Save the figure and the position in the figure where we are
      % going to start adding GUI elements:
      SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);
      % Old call to initialise sound system:
      rpbox('InitRP3StereoSound');
      
%       NumeditParam(obj, 'Rtone', 2, x, y, 'label', 'Rtone (kHz)', ...
%                    'TooltipString', 'sound for correct right response');
%       next_row(y);
%       NumeditParam(obj, 'LVol_Rtone', 0, x, y, 'position', [x y 100 20], ...
%                    'labelfraction', 0.65, 'TooltipString', ['Rtone''s ' ...
%                           'volume on left speaker']);
%       NumeditParam(obj, 'RVol_Rtone', 0.8, x, y, 'position', ...
%                    [x+100 y 100 20], 'labelfraction', 0.65, ...
%                    'TooltipString', 'Rtone''s volume on right speaker');
%       next_row(y, 1.5);
%       
%       NumeditParam(obj, 'Ltone', 8, x, y, 'label', 'Ltone (kHz)', ...
%                    'TooltipString', 'sound for correct left response');
%       next_row(y);
%       NumeditParam(obj, 'LVol_Ltone', 0.8, x, y, 'position', [x y 100 20], ...
%                    'labelfraction', 0.65, ...
%                    'TooltipString', 'Ltone''s volume on left speaker');
%       NumeditParam(obj, 'RVol_Ltone', 0, x, y, 'position', ...
%                    [x+100 y 100 20], 'labelfraction', 0.65, ...
%                    'TooltipString', 'Ltone''s volume on right speaker');
%       next_row(y, 1.5);
%       
%       NumeditParam(obj, 'ToneDuration', 500, x, y, 'label', ...
%                    'ToneDuration (ms)');
%       next_row(y, 1.5);
%       
%       SubheaderParam(obj, 'title', 'Sound Definition', x, y);
%       next_row(y, 1.5);
      
      
      SubheaderParam(obj, 'title', 'Right Click Pattern', 420, 460);
      SubheaderParam(obj, 'title', 'Left Click Pattern', 420, 220);

      % Store sounds for loading during intertrial interval, not during
      % trial:
      SoloParamHandle(obj, 'left_sound');
      SoloParamHandle(obj, 'rght_sound');
      SoloParamHandle(obj, 'sound_uploaded', 'value', 0);
      
      %set_callback({Rtone, LVol_Rtone, RVol_Rtone, Ltone, LVol_Ltone, ...
                    %RVol_Ltone, ToneDuration}, {mfilename, 'make_sounds'});

      SoundSection(obj, 'make_sounds');
      SoundSection(obj, 'upload_sounds');

      % Sounds for Right will always be stored as sound #1, for Left as
      % #2:
      SoloParamHandle(obj, 'sound_ids', 'value',struct('right', 1, 'left', 2));



      
    case 'make_sounds',   % ---------- CASE MAKE_SOUNDS ------------- %Modified for clicks and beeps 1/2007 JS
      global sound_sample_rate;
      sound_sample_rate = 200000;
      

        % Converts seconds to default sample rate (200KHZ)
        total_length.value = 200000*(value(delay1)+click1+delay2+click2+delay3+click3+delay4+click4+delay5+click5);
        total_length2.value = 200000*(delay6+click6+delay7+click7+delay8+click8+delay9+click9+delay10+click10);

        click1 = click1*200000;
        delay1 = delay1*200000;
        click2 = click2*200000;
        delay2 = delay2*200000;
        click3 = click3*200000;
        delay3 = delay3*200000;
        click4 = click4*200000;
        delay4 = delay4*200000;
        click5 = click5*200000;
        delay5 = delay5*200000;
        click6 = click6*200000;
        delay6 = delay6*200000;
        click7 = click7*200000;
        delay7 = delay7*200000;
        click8 = click8*200000;
        delay8 = delay8*200000;
        click9 = click9*200000;
        delay9 = delay9*200000;
        click10 = click10*200000;
        delay10 = delay10*200000;

        % Generate and sum clicks and delays for RIGHT sound

        whitenoise = 0; 
        if strcmp(Tone_Type, 'WhiteNoise')
        snd = (1:value(total_length)); 
        sofar = 0;
        freq = Tone_Frequency;
        coeff = 100000/freq;

        tmpsnd = (1:click1); 
        for x = 1:click1
            tmpsnd(x) = 1*sin(tmpsnd(x)) + (rand);
            snd(x) = tmpsnd(x);
            sofar = x;
        end

        tmpsnd = (1:delay1);
        for x = 1:delay1
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar + delay1;

        tmpsnd = (1:click2);
        for x = 1:click2
            tmpsnd(x) = 1*sin(tmpsnd(x)) + (rand);
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar+click2;

        tmpsnd = (1:delay2);
        for x = 1:delay2
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar + delay2;

        tmpsnd = (1:click3);
        for x = 1:click3
            tmpsnd(x) = sin(tmpsnd(x)) + (rand);
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar+click3;

        tmpsnd = (1:delay3);
        for x = 1:delay3
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar + delay3;

        tmpsnd = (1:click4);
        for x = 1:click4
            tmpsnd(x) = .1*sin(tmpsnd(x)) + (rand);
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar+click4;

        tmpsnd = (1:delay4);
        for x = 1:delay4
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar + delay4;

        tmpsnd = (1:click5);
        for x = 1:click5
            tmpsnd(x) = .1*sin(tmpsnd(x)) + (rand);
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar+click5;

        tmpsnd = (1:delay5);
        for x = 1:delay5
            snd(sofar+x) = tmpsnd(x);
        end
        rght_sound.value = snd;

        end


        
        if strcmp(Tone_Type, 'Tone') 
            snd = (1:value(total_length)); 
        sofar = 0;
        freq = Tone_Frequency;
        coeff = 100000/freq;

        tmpsnd = (1:click1); 
        tmpsnd = 0.1*sin((pi/coeff)*tmpsnd);
        for x = 1:click1
            snd(x) = tmpsnd(x);
            sofar = x;
        end

        tmpsnd = (1:delay1);
        for x = 1:delay1
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar + delay1;

        tmpsnd = (1:click2);
        tmpsnd = 0.1*sin((pi/coeff)*tmpsnd);
        for x = 1:click2
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar+click2;

        tmpsnd = (1:delay2);
        for x = 1:delay2
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar + delay2;

        tmpsnd = (1:click3);
        tmpsnd = 0.1*sin((pi/coeff)*tmpsnd);
        for x = 1:click3
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar+click3;

        tmpsnd = (1:delay3);
        for x = 1:delay3
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar + delay3;

        tmpsnd = (1:click4);
        tmpsnd = 0.1*sin((pi/coeff)*tmpsnd);
        for x = 1:click4
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar+click4;

        tmpsnd = (1:delay4);
        for x = 1:delay4
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar + delay4;

        tmpsnd = (1:click5);
        tmpsnd = 0.1*sin((pi/coeff)*tmpsnd);
        for x = 1:click5
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar+click5;

        tmpsnd = (1:delay5);
        for x = 1:delay5
            snd(sofar+x) = tmpsnd(x);
        end
        rght_sound.value = snd;

        end


        % Generate and sum clicks and delays for LEFT sound

        
        if strcmp(Tone_Type, 'WhiteNoise') 
        snd = (1:value(total_length2)); 
        sofar = 0;

        tmpsnd = (1:click6); 
        for x = 1:click6
            tmpsnd(x) = .1*sin(tmpsnd(x)) + (rand);
            snd(x) = tmpsnd(x);
            sofar = x;
        end

        tmpsnd = (1:delay6);
        for x = 1:delay6
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar + delay6;

        tmpsnd = (1:click7);
        for x = 1:click7
            tmpsnd(x) = .1*sin(tmpsnd(x)) + (rand);
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar+click7;

        tmpsnd = (1:delay7);
        for x = 1:delay7
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar + delay7;

        tmpsnd = (1:click8);
        for x = 1:click8
            tmpsnd(x) = .1*sin(tmpsnd(x)) + (rand);
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar+click8;

        tmpsnd = (1:delay8);
        for x = 1:delay8
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar + delay8;

        tmpsnd = (1:click9);
        for x = 1:click9
            tmpsnd(x) = .1*sin(tmpsnd(x)) + (rand);
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar+click9;

        tmpsnd = (1:delay9);
        for x = 1:delay9
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar + delay9;

        tmpsnd = (1:click10);
        for x = 1:click10
            tmpsnd(x) = .1*sin(tmpsnd(x)) + (rand);
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar+click10;

        tmpsnd = (1:delay10);
        for x = 1:delay10
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar + delay10;
        left_sound.value = snd
        end


        
        if strcmp(Tone_Type, 'Tone') 
        freq = Tone_Frequency;
        coeff = 100000/freq;
        snd = (1:value(total_length2)); 
        sofar = 0;

        tmpsnd = (1:click6); 
        tmpsnd = 0.1*sin((pi/coeff)*tmpsnd);
        for x = 1:click6
            snd(x) = tmpsnd(x);
            sofar = x;
        end

        tmpsnd = (1:delay6);
        for x = 1:delay6
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar + delay6;

        tmpsnd = (1:click7);
        tmpsnd = 0.1*sin((pi/coeff)*tmpsnd);
        for x = 1:click7
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar+click7;

        tmpsnd = (1:delay7);
        for x = 1:delay7
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar + delay7;

        tmpsnd = (1:click8);
        tmpsnd = 0.1*sin((pi/coeff)*tmpsnd);
        for x = 1:click8
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar+click8;

        tmpsnd = (1:delay8);
        for x = 1:delay8
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar + delay8;

        
        tmpsnd = (1:click9);
        tmpsnd = 0.1*sin((pi/coeff)*tmpsnd);
        for x = 1:click9
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar+click9;

        tmpsnd = (1:delay9);
        for x = 1:delay9
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar + delay9;

        tmpsnd = (1:click10);
        tmpsnd = 0.1*sin((pi/coeff)*tmpsnd);
        for x = 1:click10
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar+click10;

        tmpsnd = (1:delay10);
        for x = 1:delay10
            snd(sofar+x) = tmpsnd(x);
        end
        sofar = sofar + delay10;
        left_sound.value = snd
        end

              % Mark the fact that the latest soudns haven't been uploaded yet
        sound_uploaded.value = 0;
      return;

      
    case 'upload_sounds',      % ---------- CASE UPLOAD_SOUNDS -------------
      if sound_uploaded==0,
         rpbox('loadrp3stereosound1', {value(rght_sound)});
         rpbox('loadrp3stereosound2', {[] ; value(left_sound)'});
         sound_uploaded.value = 1;
      end;
    return;

      
    case 'get_tone_duration',   % ---------- CASE GET_TONE_DURATION ----------
      %x = value(ToneDuration);
      return;

      
    case 'get_sound_ids',       % ---------- CASE GET_SOUND_IDS ----------
      x = value(sound_ids);

      
      
      
    case 'reinit',       % ---------- CASE REINIT -------------
      currfig = gcf; 

      % Get the original GUI position and figure:
      x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));

      % Delete all SoloParamHandles who belong to this object and whose
      % fullname starts with the name of this mfile:
      delete_sphandle('owner', ['^@' class(obj) '$'], ...
                      'fullname', ['^' mfilename]);

      % Reinitialise at the original GUI position and figure:
      [x, y] = feval(mfilename, obj, 'init', x, y);

      % Restore the current figure:
      figure(currfig);      
   end;
   
   
      