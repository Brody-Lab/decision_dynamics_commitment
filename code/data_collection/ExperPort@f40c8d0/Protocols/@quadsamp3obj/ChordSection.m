function  [x,  y,  chord_sound_len, go_dur, Sound_type, ...
           LegalSkipOut] = ChordSection(obj, action, x, y)
% 
% This section is responsible for the relevant sounds plus the Go
% Chord. Possible actions:
%
% 'init'      Sets up params, then calls 'make' and 'upload' below. Returns
%               x and y,         updated positions on the protocol figure;
%               chord_sound_len, an SPH holding the length, in seconds,
%                                of the relevant_sound +
%                                postrelevant_gap + go_chord;
%               go_dur,          an SPH with length of Go chord, in secs;
%               Sound_type,      an SPH whose value is a structure with
%                                two fields: 'go' and 'relevant'; each
%                                of these can take one of two possible
%                                values, 'localised' or 'surround'.
%
% 'make'               No args. Makes sounds and sets values for SPHs above
% 'upload'             No args. Uploads sounds to sound machine.
% 'chord_param_view'   No args. Controls visibility of ChordParam figure.
% 'chord_param_hide'   No args. Makes ChordParam figure invisible.
% 'delete'             No args. Deletes ChordParam figure.
% 'reinit'             No args. Deletes ChordParam figure and all of this
%                               section's SPHs and calls 'init'
% 'getValidSoundTime'  No args. Returns length of Go chord that must
%                               elapse before center poke out for legal
%                               poke.
%

global fake_rp_box;
global softsound_play_sounds


GetSoloFunctionArgs;
% SoloFunction('ChordSection', ...
%  'rw_args', {'priors'},    ...
%  'ro_args', {'side_list', 'n_done_trials', 'n_started_trials', 'vpd_list'});
% Deals with chord generation and uploading for a protocol.
% Note: This function does not generate the sounds for white-noise (ITI,
% Timeout, etc.,)
% init: Initialises UI parameters specifying types of sound; calls 'make' and 'upload'
% make: Generates chord for the upcoming trial
% upload: The chord is set to be sound type "1" in the RPBox


switch action,
    case 'init'
        fig = gcf; rpbox('InitRP3StereoSound');
        if fake_rp_box==2, % If on RT Linux rigs, we can set sample rate
            rpbox('setsoundmachine', ...
                 SetSampleRate(rpbox('getsoundmachine'), get_generic('sampling_rate')));
        end;
        SoloParamHandle(obj, 'my_xyfig', 'value', [x y fig]);
        
        oldx = x; oldy = y;  x = 5; y = 5;
        gui_position('set_width', 140);
        SoloParamHandle(obj, 'myfig', 'value', figure, 'saveable', 0);
        set(value(myfig), 'Position', [833    53   470   460]);

        next_row(y,0.5);
        NumeditParam(obj, 'SoundSPL_R',        60,    x, y, 'label', 'GO SPL (Right)', 'TooltipString', 'GO Signal Sound Intensity (volume): Right channel'); next_row(y);
        NumeditParam(obj, 'SoundSPL_L',        60,    x, y, 'label', 'GO SPL (Left)', 'TooltipString', 'GO Signal Sound Intensity (volume): Left channel');   next_row(y);
        next_row(y,0.5);

        NumeditParam(obj, 'SoundDur',        0.2,   x, y, 'label', 'GO Duration');   next_row(y);
        NumeditParam(obj, 'BaseFreq',        1,     x, y);   next_row(y);
        NumeditParam(obj, 'NTones',          16,    x, y);   next_row(y);
        NumeditParam(obj, 'RampDur',         0.005, x, y);   next_row(y, 1.5);
        NumeditParam(obj, 'ValidSoundTime',  0.03,  x, y, 'TooltipString', sprintf( ...
            ['\nDuration of the GO signal after which the rat can\n' ...
            'make a Cout without penalty.']));
        next_row(y);
        SubheaderParam(obj, 'go_subheader', 'GO Chord', x, y);
        next_row(y, 1.25);
        ToggleParam(obj, 'playsounds', 1, x, y, ...
                    'position', [x+20 y 16 16], ...
                    'OnString', ' ', 'OffString', ' ', 'TooltipString', ...
                    sprintf(['Irrelevant for actual rigs-- relevant only\n'...
                            'for simulations on PCs. When this is ON, ' ...
                            'sounds get played. When OFF, they don''t.']));
        set_callback(playsounds, {mfilename, 'playsounds'});
        ToggleParam(obj, 'deadtime_noise', 1, x, y, ...
                    'position', [x+45 y 100 20], ...
                    'OnString', 'Dead noise ON', ...
                    'OffString', 'Dead time silent', ...
                    'TooltipString', ...
                    sprintf(['Determines whether dead time has\nwhite ' ...
                            'noise (ON) or silence (off)']));
        SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args', ...
                            'deadtime_noise');
        next_row(y, 1.25);
        NumeditParam(obj, 'LegalSkipOut', 75, x, y, 'TooltipString', ...
            sprintf(['\nTime, in milliseconds, that rat can\n' ...
            'move out of Center port without incurring\n' ...
            'in a TimeOut. If he moves back in before\n' ...
            'this number of ms elapses, all is well.']));
        next_row(y); LegalSkipOut = LegalSkipOut; % this last just to quiet mlint down.
        SubheaderParam(obj, 'nameless3', 'Poke Out hysteresis', x, y);


        % Column 2
        y = 1; next_column(x);
        next_row(y,0.5);
        MenuParam(obj, 'Tone_Loc', {'on', 'off'}, 2, x,y, 'label', ...
            'Localise F1/F2', 'TooltipString', sprintf(['\n' ...
            '''on'' sets F1-F2 to play in reward-side speaker ' ...
            '(localised);\n''off'' makes it surround-sound'])); 
        ToggleParam(obj, 'ReplayRelevant', 0, x, y, ...
                    'position', [x+160 y+20 100 20], ...
                    'OnString', 'ReplayRelevant', ...
                    'OffString', 'Normal', ...
                    'TooltipString', ...
                    sprintf(['If set to ReplayRelevant, the full\nrelevant '...
                            'sound gets re-triggered on entering\na ' ...
                            'reward state (regular reward, not dirdel).\n' ...
                            'Normally the relevant sound is turned off ' ...
                            'then']));               
        ToggleParam(obj, 'DefaultLeft1LED', 0, x, y, ...
                    'position', [x+160 y 12 12], ...
                    'OnString', '', ...
                    'OffString', '', ...
                    'TooltipString', ...
                    sprintf(['\nBrown=LED off all the time\nBlack = LED on all the time']));               
        ToggleParam(obj, 'DefaultCenter1LED', 0, x, y, ...
                    'position', [x+175 y 12 12], ...
                    'OnString', '', ...
                    'OffString', '', ...
                    'TooltipString', ...
                    sprintf(['\nBrown=LED off all the time\nBlack = LED on all the time']));               
        ToggleParam(obj, 'DefaultRight1LED', 0, x, y, ...
                    'position', [x+190 y 12 12], ...
                    'OnString', '', ...
                    'OffString', '', ...
                    'TooltipString', ...
                    sprintf(['\nBrown=LED off all the time\nBlack = LED on all the time']));               
        SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args', ...
                            {'ReplayRelevant', ...
                            'DefaultLeft1LED', 'DefaultCenter1LED', 'DefaultRight1LED'});
        next_row(y);
        NumEditParam(obj, 'Loc_Factor', 1, x, y); next_row(y);
        next_row(y,0.5);

        gpos = gui_position(x, y);
        NumeditParam(obj, 'Left1_F1', 8, x, y, 'position', ...
            [gpos(1) gpos(2) gpos(3)/2 gpos(4)], ...
            'TooltipString', 'kHz');
        NumeditParam(obj, 'Left1_F2', 2, x, y, 'position', ...
            [gpos(1)+gpos(3)/2 gpos(2) gpos(3)/2 gpos(4)], ...
            'TooltipString', 'kHz');
        NumeditParam(obj, 'L1F1_loc', 0, x, y, 'position', ...
            [gpos(1)+gpos(3)+5 gpos(2) gpos(3)/2 gpos(4)], ...
            'TooltipString', sprintf(['1 is Left, 0, center, -1 right'])); 
        NumeditParam(obj, 'L1F2_loc', 0, x, y, 'position', ...
            [gpos(1)+gpos(3)*3/2+5 gpos(2) gpos(3)/2 gpos(4)], ...
            'TooltipString', sprintf(['1 is Left, 0, center, -1 right'])); 
        
        next_row(y); gpos = gui_position(x, y);
        NumeditParam(obj, 'Left2_F1', 8, x, y, 'position', ...
            [gpos(1) gpos(2) gpos(3)/2 gpos(4)], ...
            'TooltipString', 'kHz');
        NumeditParam(obj, 'Left2_F2', 2, x, y, 'position', ...
            [gpos(1)+gpos(3)/2 gpos(2) gpos(3)/2 gpos(4)], ...
            'TooltipString', 'kHz');
        NumeditParam(obj, 'L2F1_loc', 0, x, y, 'position', ...
            [gpos(1)+gpos(3)+5 gpos(2) gpos(3)/2 gpos(4)], ...
            'TooltipString', sprintf(['1 is Left, 0, center, -1 right'])); 
        NumeditParam(obj, 'L2F2_loc', 0, x, y, 'position', ...
            [gpos(1)+gpos(3)*3/2+5 gpos(2) gpos(3)/2 gpos(4)], ...
            'TooltipString', sprintf(['1 is Left, 0, center, -1 right'])); 
        next_row(y);
        next_row(y, 0.5);

        gpos = gui_position(x, y); gpos(3) = gpos(3)+22;
        NumeditParam(obj, 'Right1_F1', 2, x, y, 'position', ...
            [gpos(1) gpos(2) gpos(3)/2 gpos(4)], ...
            'TooltipString', 'kHz');
        NumeditParam(obj, 'Right1_F2', 8, x, y, 'position', ...
            [gpos(1)+gpos(3)/2 gpos(2) gpos(3)/2 gpos(4)], ...
            'TooltipString', 'kHz');
        NumeditParam(obj, 'R1F1_loc', 0, x, y, 'position', ...
            [gpos(1)+gpos(3)+5 gpos(2) gpos(3)/2 gpos(4)], ...
            'TooltipString', sprintf(['1 is Left, 0, center, -1 right'])); 
        NumeditParam(obj, 'R1F2_loc', 0, x, y, 'position', ...
            [gpos(1)+gpos(3)*3/2+5 gpos(2) gpos(3)/2 gpos(4)], ...
            'TooltipString', sprintf(['1 is Left, 0, center, -1 right'])); 
        
        next_row(y); gpos = gui_position(x, y); gpos(3) = gpos(3)+22;
        NumeditParam(obj, 'Right2_F1', 2, x, y, 'position', ...
            [gpos(1) gpos(2) gpos(3)/2 gpos(4)], ...
            'TooltipString', 'kHz');
        NumeditParam(obj, 'Right2_F2', 8, x, y, 'position', ...
            [gpos(1)+gpos(3)/2 gpos(2) gpos(3)/2 gpos(4)], ...
            'TooltipString', 'kHz');
        NumeditParam(obj, 'R2F1_loc', 0, x, y, 'position', ...
            [gpos(1)+gpos(3)+5 gpos(2) gpos(3)/2 gpos(4)], ...
            'TooltipString', sprintf(['1 is Left, 0, center, -1 right'])); 
        NumeditParam(obj, 'R2F2_loc', 0, x, y, 'position', ...
            [gpos(1)+gpos(3)*3/2+5 gpos(2) gpos(3)/2 gpos(4)], ...
            'TooltipString', sprintf(['1 is Left, 0, center, -1 right'])); 
        next_row(y);
        next_row(y,0.5);
        set(get_ghandle({Right2_F1;Right2_F2;Left2_F1;Left2_F2; ...
                        R2F1_loc;R2F2_loc;L2F1_loc;L2F2_loc}), ...
            'Enable', 'off');

        NumeditParam(obj, 'CueSPL_R', 60, x, y, 'label', 'Cue SPL (Right)',...
                     'TooltipString', ['Relevant cue Sound Intensity ' ...
                            '(volume): Right channel']); next_row(y); 
        NumeditParam(obj, 'CueSPL_L', 60, x, y, 'label', 'Cue SPL (Left)',...
                     'TooltipString', ['Relevant cue Sound Intensity ' ...
                            '(volume): Left channel']);  next_row(y); 
        next_row(y,0.5);

        next_row(y);
        NumeditParam(obj, 'F1_Duration', 0.2, x, y, 'position', ...
                     [x y 130 20], 'labelfraction', 0.5); 
        NumeditParam(obj, 'F1_volume_factor', 1, x, y, 'position', ...
                     [x+135 y-10 80 40], 'labelpos', 'bottom', ...
                     'TooltipString', sprintf(['F1 amplitude gets\n' ...
                            'multiplied by this much'])); next_row(y);
        NumeditParam(obj, 'F1_F2_Gap', 0, x, y, 'position', ...
            [x y 130 20], 'labelfraction', 0.5, 'TooltipString', ...
            sprintf('\nsilent gap (secs) between F1 and F2'));   next_row(y);
        NumeditParam(obj, 'F2_Duration', 0.2, x, y, 'position', ...
                     [x y 130 20], 'labelfraction', 0.5); 
        NumeditParam(obj, 'F2_volume_factor', 1, x, y, 'position', ...
                     [x+135 y 80 40], 'labelpos', 'top', ...
                     'TooltipString', sprintf(['F2 amplitude gets\n' ...
                            'multiplied by this much'])); next_row(y);
        NumeditParam(obj, 'RelevantSoundDur', 0.4, x, y, ...
                     'position', [1 1 4 4]); set_saveable(RelevantSoundDur,0);
        NumeditParam(obj, 'Tau', 1, x, y, 'position', ...
                     [x y 130 20], 'labelfraction', 0.5, ...
                     'TooltipString', ['Tau of sigmoid, in millisecs']); ...
          next_row(y);
        NumeditParam(obj, 'PostRelevantGap', 0.1, x, y, 'position', ...
                     [x y 130 20], 'labelfraction', 0.5, 'label', ...
                     'F2-GO Gap', 'TooltipString', ...
                     sprintf(['\nsecs of silence between relevant sound ' ...
                            'and Go Chord'])); next_row(y);

        next_row(y,0.5);
        NumeditParam(obj, 'CenterProb', 0, x, y, 'TooltipString', ...
            'Probability that Go Chord plays on both speakers'); ...
          next_row(y);
        MenuParam(obj, 'RelevantType', {'pure tones', 'bups'}, 1, x, y); ...
          next_row(y); 
        set_callback(RelevantType, {mfilename, 'RelevantType'});
        next_row(y, 0.5);
        
        SubheaderParam(obj, 'relevant_subheader', 'Relevant Sound', x, y);
        next_row(y); next_row(y,0.2);

        MenuParam(obj, 'Cluck', {'on','off'}, 2, x, y, 'label', 'Cin Sound',...
                  'TooltipString',[ 'When ''on'', plays cluck sound on ' ...
                  'initiatory poke'], 'position', [x+40 y 120 20], ...
                  'labelfraction', 0.55, 'labelpos', 'left');
        NumeditParam(obj, 'CluckVol', 0.7, x, y, 'label', 'vol', ...
                  'TooltipString', 'Cluck volume, on scale from 0 to 1', ...
                  'position', [x+160 y 62 20], 'labelpos', 'left', ...
                  'labelfraction', 0.4);
        ToggleParam(obj, 'CluckLoc', 0, x, y, 'OnString', 'loc', ...
                    'OffString', 'surr', 'OnFontWeight', 'normal', ...
                    'OffFontWeight', 'normal', 'position', [x+5 y 35 20], ...
                    'TooltipString', ['Make Cin sound either surround ' ...
                            'or localised']);
        set(get_ghandle(CluckLoc), 'Enable', 'off');
        set_callback(Cluck, {'ChordSection', 'change_cluck'});
        
        set(value(myfig), ...
            'Visible', 'on', 'MenuBar', 'none', 'Name', 'Chord Parameters', ...
            'NumberTitle', 'off', 'CloseRequestFcn', ...
            ['ChordSection(' class(obj) '(''empty''), ''chord_param_hide'')']);
        x = oldx; y = oldy; figure(fig);
        MenuParam(obj, 'ChordParameters', {'hidden', 'view'}, 2, x, y); next_row(y);
        set_callback({ChordParameters}, {'ChordSection', 'chord_param_view'});

        SoloParamHandle(obj, 'chord_sound_data', 'saveable', 0);
        SoloParamHandle(obj, 'chord_sound_len');
        SoloParamHandle(obj, 'go_dur');
        SoloParamHandle(obj, 'chord_uploaded', 'value', 0);
        SoloParamHandle(obj, 'Sound_type');

        set_callback({SoundSPL_L, SoundSPL_R, SoundDur, BaseFreq, NTones, ...
            RampDur,  ValidSoundTime, F1_F2_Gap, ...
            Tone_Loc, F1_Duration, F2_Duration,PostRelevantGap, Tau, ...
            F1_volume_factor, F2_volume_factor, ...                      
            CenterProb, CluckLoc, CluckVol}, {mfilename, 'all_changed'; mfilename, 'make'});

        add_callback({Right1_F1, Right1_F2, R1F1_loc, R1F2_loc}, {mfilename, 'Right1_changed'});
        add_callback({Left1_F1,  Left1_F2,  L1F1_loc, L1F2_loc}, {mfilename, 'Left1_changed'});
        add_callback({Right2_F1, Right2_F2, R2F1_loc, R2F2_loc}, {mfilename, 'Right2_changed'});
        add_callback({Left2_F1,  Left2_F2,  L2F1_loc, L2F2_loc}, {mfilename, 'Left2_changed'});

        add_callback({Left1_F1, Left1_F2, Left2_F1, Left2_F2, ...
                      Right1_F1, Right1_F2, Right2_F1, Right2_F2, ...
                      R1F1_loc, R1F2_loc, R2F1_loc, R2F2_loc, ...
                      L1F1_loc, L1F2_loc, L2F1_loc, L2F2_loc}, ...
                     {'ChordSection', 'make' ; ...
                     'ReportHitsSection', 'update_chooser'});
                    
        SoloParamHandle(obj, 'Right1_changed', 'value', 1);
        SoloParamHandle(obj, 'Left1_changed',  'value', 1);
        SoloParamHandle(obj, 'Right2_changed', 'value', 1);
        SoloParamHandle(obj, 'Left2_changed',  'value', 1);

        
        set_callback(RelevantSoundDur, ...
                     {'ChordSection', 'rsd_backwards_compatibility'});
        
        SoundManager(obj, 'init');
        SoundManager(obj, 'declare_new_sound', 'Left1');
        SoundManager(obj, 'declare_new_sound', 'Left2');
        SoundManager(obj, 'declare_new_sound', 'Right1');
        SoundManager(obj, 'declare_new_sound', 'Right2');
        
        gui_position('reset_width');
        ChordSection(obj, 'make');
        ChordSection(obj, 'upload');

        
        
    case 'all_changed',
      Right1_changed.value = 1;
      Right2_changed.value = 1;
      Left1_changed.value  = 1;
      Left2_changed.value  = 1;

    case 'Right1_changed',  Right1_changed.value = 1;      
    case 'Right2_changed',  Right2_changed.value = 1;      
    case 'Left1_changed',   Left1_changed.value  = 1;      
    case 'Left2_changed',   Left2_changed.value  = 1;      
      
    case 'change_cluck',
      if strcmp(value(Cluck), 'on'), set(get_ghandle(CluckLoc),'Enable','on');
      else                           set(get_ghandle(CluckLoc),'Enable','off');
      end;
      ChordSection(obj, 'make');

      
    case 'playsounds'     % ----------- case PLAYSOUNDS ----
      softsound_play_sounds = value(playsounds);
      
    case 'RelevantType'     % ----------- case RELEVANT_TYPE ----
      switch value(RelevantType),
       
       case 'pure tones',
         set(get_ghandle({CueSPL_L;CueSPL_R}), 'Enable', 'on');
       
       case 'bups',
         set(get_ghandle({CueSPL_L;CueSPL_R}), 'Enable', 'off');
      end;
 
    case 'enable_type_twos'     % ----------- case ENABLE_TYPE_TWOS ----
        switch x,
            case 0,
                set(get_ghandle({Right2_F1;Right2_F2;Left2_F1;Left2_F2; ...
                        R2F1_loc;R2F2_loc;L2F1_loc;L2F2_loc}), ...
                    'Enable', 'off');

            case 1,
                set(get_ghandle({Right2_F1;Right2_F2;Left2_F1;Left2_F2; ...
                        R2F1_loc;R2F2_loc;L2F1_loc;L2F2_loc}), ...
                    'Enable', 'on');

            otherwise,
                error('enable_type_twos: what???');
        end;

    case 'make'                 % ----------- case MAKE ----------------
        if side_list(n_done_trials+1)==0     &&  Right1_changed==0, return; end;
        if side_list(n_done_trials+1)==0.25  &&  Right2_changed==0, return; end;
        if side_list(n_done_trials+1)==1     &&  Left1_changed==0,  return; end;
        if side_list(n_done_trials+1)==1.25  &&  Left2_changed==0,  return; end;
      
        if fake_rp_box==2, srate = GetSampleRate(rpbox('getsoundmachine'));
        else               srate = 50e6/1024;
        end;

        Sound_type.value = struct('relevant', [], 'go', [], ...
            'f1', [], 'f2', [], 'cluck', [], 'cluck_loc', [], ...
            'vpd', []);

        priors(1,1:2) = [value(Right1_F1) value(Right1_F2)];
        priors(2,1:2) = [value(Right2_F1) value(Right2_F2)];
        priors(3,1:2) = [value(Left1_F1)  value(Left1_F2)];
        priors(4,1:2) = [value(Left2_F1)  value(Left2_F2)];        
        
        prst = vpd_list(n_done_trials+1);
        pre_sound = zeros(1, floor(prst*srate));
        if strcmp(value(Cluck),'on')
            cluck_sound = MakeClick*CluckVol;
            pre_sound(1,1:length(cluck_sound)) = cluck_sound;   % put cluck at start of pre-sound time.
        end;
        Sound_type.cluck = value(Cluck);
        Sound_type.vpd   = prst;

        chord_L = MakeChord(srate,  70-SoundSPL_L, ...
            BaseFreq*1000, value(NTones), SoundDur*1000, RampDur*1000);
        chord_R = MakeChord(srate,  70-SoundSPL_R, ...
            BaseFreq*1000, value(NTones), SoundDur*1000, RampDur*1000);

        gap = zeros(1, floor(PostRelevantGap*srate));

        % construct F1 + F1_F2_Gap + F2
        if     side_list(n_done_trials+1) == 0,    % RIGHT 1
            first     = Right1_F1*1000; second     = Right1_F2*1000;
            first_loc = R1F1_loc;       second_loc = R1F2_loc;
        elseif side_list(n_done_trials+1) == 0.25, % RIGHT 2
            first     = Right2_F1*1000; second     = Right2_F2*1000;
            first_loc = R2F1_loc;       second_loc = R2F2_loc;
        elseif side_list(n_done_trials+1) == 1,    % LEFT 1
            first     = Left1_F1*1000;  second     = Left1_F2*1000;
            first_loc = L1F1_loc;       second_loc = L1F2_loc;
        elseif side_list(n_done_trials+1) == 1.25, % LEFT 2
            first     = Left2_F1*1000;  second     = Left2_F2*1000;
            first_loc = L2F1_loc;       second_loc = L2F2_loc;
        else
            error(['What''s this side_list? ' ...
                num2str(side_list(n_done_trials+1))]);
        end;
        Sound_type.f1 = first/1000; Sound_type.f2 = second/1000;

        between_f1_f2 = F1_F2_Gap * 1000;
        switch value(RelevantType),
         case 'pure tones',
           if CueSPL_L == CueSPL_R,
              relevant = MakeSigmoidSwoop3(srate, 70-CueSPL_L, ...
                                first, second, ...
                                F1_Duration*1000, F2_Duration*1000, ...
                                between_f1_f2, Tau, 3, ...
                                'F1_volume_factor',value(F1_volume_factor),...
                                'F2_volume_factor',value(F2_volume_factor));
              relevant_L = relevant;
              relevant_R = relevant;
           else
              relevant_L = MakeSigmoidSwoop3(srate, 70-CueSPL_L, ...
                                first, second, ...
                                F1_Duration*1000, F2_Duration*1000, ...
                                between_f1_f2, Tau, 3, ...
                                'F1_volume_factor',value(F1_volume_factor),...
                                'F2_volume_factor',value(F2_volume_factor));
        
              relevant_R = MakeSigmoidSwoop3(srate, 70-CueSPL_R, ...
                                first, second, ...
                                F1_Duration*1000, F2_Duration*1000, ...
                                between_f1_f2, Tau, 3, ...
                                'F1_volume_factor',value(F1_volume_factor),...
                                'F2_volume_factor',value(F2_volume_factor));

           end;
         
         
         case 'bups', 
           first = first/1000; second = second/1000;

           relevant = MakeBupperSwoop(srate, 0, first,second,...
                                F1_Duration*1000, F2_Duration*1000, ...
                                F1_F2_Gap*1000, Tau, ...
                                'F1_volume_factor',value(F1_volume_factor),...
                                'F2_volume_factor',value(F2_volume_factor),...
                                'F1_loc_factor',   first_loc, ...
                                'F2_loc_factor',   second_loc, ...
                                'Stereo', 1);

           if ~isempty(relevant),
              relevant_L = relevant(1,:);
              relevant_R = relevant(2,:);
           else
              relevant_L = [];
              relevant_R = [];
           end;
         
         otherwise,
           error('which type of Relevant sound???');
        end;

        if CluckLoc == 1,
           if side_list(n_done_trials+1) >= 1, % left
              pre_sound_L = pre_sound; pre_sound_R = zeros(size(pre_sound));
           else
              pre_sound_R = pre_sound; pre_sound_L = zeros(size(pre_sound));
           end;
           Sound_type.cluck_loc = 'localised';
        else
           pre_sound_L = pre_sound; pre_sound_R = pre_sound;
           Sound_type.cluck_loc = 'surround';
        end;
        
        main_tone_L = [relevant_L gap];
        main_tone_R = [relevant_R gap]; % f1 + f1_f2_gap + f2 + postrelevant"gap"

        % Localise relevant tone if desired
        if strcmp(value(Tone_Loc), 'on')
            if side_list(n_done_trials+1) >= 1  % left
               if Loc_Factor>=0,
                  main_tone = ...
                      [[pre_sound_L' ; main_tone_L'] ...
                       [pre_sound_R' ; (1-Loc_Factor)*main_tone_R']];
               else
                  main_tone = ...
                      [[pre_sound_L' ; (1+Loc_Factor)*main_tone_L'] ...
                       [pre_sound_R' ; main_tone_R']];
               end;
            else            % right
               if Loc_Factor>=0,
                  main_tone = ...
                      [[pre_sound_L' ; (1-Loc_Factor)*main_tone_L'] ...
                       [pre_sound_R' ; main_tone_R']];
               else
                  main_tone = ...
                      [[pre_sound_L' ; main_tone_L'] ...
                       [pre_sound_R' ; (1+Loc_Factor)*main_tone_R']];
               end;
            end;
            % Record what type of relevant sound this was:
            Sound_type.relevant = 'localised';
        else                                    
            % only make stereo if necessary:
            main_tone = ...
                [[pre_sound_L' ; main_tone_L'] ...
                 [pre_sound_R' ; main_tone_R']];      
            % Record what type of relevant sound this was:
            Sound_type.relevant = 'surround';
        end;

        chord_sound_data.value = main_tone;           % set

        centergo = rand(1) < CenterProb;
        if centergo, % Play go chord on both speakers
            chord_sound_data.value = [value(chord_sound_data) ; ...
                [chord_L', chord_R']];
            % Record what type of go chord this was:
            Sound_type.go = 'surround';
        else % Play go chord on a side
            if side_list(n_done_trials+1) < 0.5,    % RIGHT
                chord_sound_data.value = [value(chord_sound_data) ; ...
                    [zeros(length(chord_R), 1), chord_R']];
            else   % LEFT
                chord_sound_data.value = [value(chord_sound_data) ; ...
                    [chord_L', zeros(length(chord_L), 1)]];
            end;
            % Record what type of go chord this was:
            Sound_type.go = 'localised';
        end;
        chord_sound_len.value = prst + F1_Duration + F1_F2_Gap + ...
            F2_Duration + PostRelevantGap + SoundDur; 
        go_dur.value = SoundDur;
        chord_uploaded.value = 0;
        
        amp = 0.03;
        switch side_list(n_done_trials+1),
          case 0,    
            SoundManager(obj, 'set_sound', 'Right1', amp*value(chord_sound_data));
            Right1_changed.value = 0;
          case 0.25, 
            SoundManager(obj, 'set_sound', 'Right2', amp*value(chord_sound_data));
            Right2_changed.value = 0;
          case 1,    
            SoundManager(obj, 'set_sound', 'Left1',  amp*value(chord_sound_data));
            Left1_changed.value  = 0;
          case 1.25, 
            SoundManager(obj, 'set_sound', 'Left2',  amp*value(chord_sound_data));
            Left2_changed.value  = 0;
        end;
        
    case 'upload'              % ---------- case UPLOAD ----------
      doneit = 0; while ~doneit,
        try,
          % rpbox('loadrp3stereosound1', {value(chord_sound_data)});
          SoundManager(obj, 'send_not_yet_uploaded_sounds');
          doneit = 1;
        catch,
          warning(sprintf('Error on loading sound: %s', lasterr));
          pause(1);
        end;
      end;
      

    case 'get_ValidSoundTime', % ----- case GET_VALIDSOUNDTIME
        x = value(ValidSoundTime);




    case 'rsd_backwards_compatibility', % - case RSD_BACKWARDS_COMPATIBILITY -
      % Say we loaded from a settings file that had RelevantSoundDur in
      % it, but not F1_Duration or F2_Duration. Then deduce:
      F1_Duration.value = RelevantSoundDur/2;
      F2_Duration.value = RelevantSoundDur/2;
      ChordSection(obj, 'make');

    case 'delete'            , % ------------ case DELETE ----------
        delete(value(myfig));


    case 'chord_param_view',   % ------- case CHORD_PARAM_VIEW
        switch value(ChordParameters)
            case 'hidden',
                set(value(myfig), 'Visible', 'off');

            case 'view',
                set(value(myfig), 'Visible', 'on');
        end;

    case 'chord_param_hide',
        ChordParameters.value = 'hidden';
        set(value(myfig), 'Visible', 'off');


    case 'reinit',  % ----  CASE REINIT
      x = my_xyfig(1); y = my_xyfig(2); fig = my_xyfig(3);
      
      delete(value(myfig));
      delete_sphandle('handlelist', ...
           get_sphandle('owner', class(obj), 'fullname', mfilename));

      figure(fig);
      ChordSection(obj, 'init', x, y);

    otherwise
        error(['Don''t know how to handle action ' action]);
end;

return;




