function [] = make_and_upload_state_matrix(obj, action, x, y)

GetSoloFunctionArgs;

switch action
    case 'init'
        SoloParamHandle(obj, 'state_matrix');
     %   SoloParamHandle(obj,'vopendur','value',5); % # seconds that water valve is open
        SoloParamHandle(obj, 'RampDur', 'value', 0.05);
        SoloParamHandle(obj, 'SPL', 'value', 65);
        SoloParamHandle(obj,'sound_len', 'value', 0);
        fig = gcf; rpbox('InitRP3StereoSound'); figure(fig);

        make_and_upload_state_matrix(obj, 'stop_matrix');
        return;
    case 'stop_matrix',
        stm = [ ; ...
            0 0   0 0   0 0   40 0.01   0 0  ; ...
            1 1   1 1   1 1   35 0.5    0 0];

        stm = [stm ; zeros(40-rows(stm), cols(stm))];
        stm = [stm ; 40 40   40 40   40 40  40 1  0 0];
        stm = [stm ; zeros(512-rows(stm), cols(stm))];

        rpbox('send_matrix', stm);
        rpbox('ForceState0');
        state_matrix.value = stm;
        return;

    case 'test_all',
        global left1water;  lvid = left1water;
        global right1water; rvid = right1water;
        BOTH_PORTS = bitor(lvid, rvid);

        make_and_upload_state_matrix(obj,'make_and_upload_sound');

        stm = [ ; ...
            0 0   0 0   0 0   40 0.01   0 0  ; ...
            1 1   1 1   1 1   35 5    0 0];
        stm = [stm ; zeros(40-rows(stm), cols(stm))];
        d = value(timedisp);
        b = rows(stm);
        stm = [stm ; ...
            b b   b b   b b   b+1  d BOTH_PORTS 0 ]; b = rows(stm);
        stm = [stm ; ...
            b b   b b   b b   b+1  0.3 0 0 ];
        b = rows(stm);
        % Now insert sound
        stm = [stm ; ...
            b b   b b   b b   b+1  1 0 0 ];
        b = rows(stm);
        stm = [stm ; ...
            b b   b b   b b   b+1  value(sound_len) 0 1 ];

        stm = [stm ; ...
            b b   b b   b b   35 0.01  0 0];
        stm = [stm ; zeros(512-rows(stm), cols(stm))];

        rpbox('send_matrix', stm);
        rpbox('ForceState0');
        state_matrix.value = stm;
    case 'test_valves',
        global left1water;  lvid = left1water;
        global right1water; rvid = right1water;
        BOTH_PORTS = bitor(lvid, rvid);

        stm = [ ; ...
            0 0   0 0   0 0   40 0.01   0 0  ; ...
            1 1   1 1   1 1   35 5    0 0];
        stm = [stm ; zeros(40-rows(stm), cols(stm))];
        d = value(timedisp);
        b = rows(stm);
        stm = [stm ; ...
            b b   b b   b b   b+1  d BOTH_PORTS 0 ]; b = rows(stm);
        stm = [stm ; ...
            b b   b b   b b   b+1  0.3 0 0 ];

        b = rows(stm);
        stm = [stm ; ...
            b b   b b   b b   35 0.01  0 0];
        stm = [stm ; zeros(512-rows(stm), cols(stm))];

        rpbox('send_matrix', stm);
        rpbox('ForceState0');
        state_matrix.value = stm;

    case 'make_and_upload_sound',
        srate = get_generic('sampling_rate');
        vol = value(SPL);
        ramp = value(RampDur);
        snd = makesound(srate, vol, ramp);
        % first make for left speaker, then for right
        leftsnd = [snd' zeros(size(snd))'];
        % right speaker
        rightsnd = [zeros(size(snd))' snd'];

        % concatenate with spacer of 0.5 sec
        silence = [zeros(srate * 0.5,1) zeros(srate*0.5,1)];
        testsound = [leftsnd;silence;rightsnd];
        global fake_rp_box;
        if fake_rp_box == 2
            LoadSound(rpbox('getsoundmachine'),1, testsound', 'both', 3,0);
        else
            rpbox('loadrp3stereosound1', {testsound'});
        end;
        sound_len.value = rows(testsound)/srate;
        fprintf(1,'Sound length is %1.1f seconds\n', value(sound_len));
        
    case 'single_leftsound',
        srate = get_generic('sampling_rate');     vol = value(SPL);
        ramp = value(RampDur);
        snd =  MakeChord2(srate, 70-sspl, sfreq*1000, 1,sdur*1000,'RiseFall',ramp*1000,'volume_factor',0.1);
        leftsnd = [snd' zeros(size(snd'))];
         global fake_rp_box;
        if fake_rp_box == 2
            LoadSound(rpbox('getsoundmachine'),1, leftsnd', 'both', 3,0);
        else
            rpbox('loadrp3stereosound1', {leftsnd'});
        end;
        sound_len.value = rows(leftsnd)/srate;
       
        % Now make the state machine
        stm = [ ; ...
            0 0   0 0   0 0   40 0.01   0 0  ; ...
            1 1   1 1   1 1   35 5    0 0];
        stm = [stm ; zeros(40-rows(stm), cols(stm))];
        b = rows(stm);
        % Now insert sound
        stm = [stm ; ...
            b b   b b   b b   b+1  value(sound_len) 0 1 ];
        b = rows(stm);
        stm = [stm ; ...
            b b   b b   b b   35 0.01  0 0];
        stm = [stm ; zeros(512-rows(stm), cols(stm))];

        rpbox('send_matrix', stm);
        rpbox('ForceState0');
        state_matrix.value = stm;

        
    case 'single_rightsound',
        srate = get_generic('sampling_rate');     vol = value(SPL);
        ramp = value(RampDur);
        snd =    MakeChord2(srate, 70-sspl, sfreq*1000, 1,sdur*1000,'RiseFall',ramp*1000,'volume_factor',0.1);
        rightsnd = [zeros(size(snd')) snd'];
         global fake_rp_box;
        if fake_rp_box == 2
            LoadSound(rpbox('getsoundmachine'),1, rightsnd', 'both', 3,0);
        else
            rpbox('loadrp3stereosound1', {rightsnd'});
        end;
        sound_len.value = rows(rightsnd)/srate;
       
        % Now make the state machine
        stm = [ ; ...
            0 0   0 0   0 0   40 0.01   0 0  ; ...
            1 1   1 1   1 1   35 5    0 0];
        stm = [stm ; zeros(40-rows(stm), cols(stm))];
        b = rows(stm);
        % Now insert sound
        stm = [stm ; ...
            b b   b b   b b   b+1  value(sound_len) 0 1 ];
        b = rows(stm);
        stm = [stm ; ...
            b b   b b   b b   35 0.01  0 0];
        stm = [stm ; zeros(512-rows(stm), cols(stm))];

        rpbox('send_matrix', stm);
        rpbox('ForceState0');
        state_matrix.value = stm;

        
    case 'test_speakers',
        make_and_upload_state_matrix(obj,'make_and_upload_sound');
        % Now make the state machine
        stm = [ ; ...
            0 0   0 0   0 0   40 0.01   0 0  ; ...
            1 1   1 1   1 1   35 5    0 0];
        stm = [stm ; zeros(40-rows(stm), cols(stm))];
        b = rows(stm);
        % Now insert sound
        stm = [stm ; ...
            b b   b b   b b   b+1  value(sound_len) 0 1 ];
        b = rows(stm);
        stm = [stm ; ...
            b b   b b   b b   35 0.01  0 0];
        stm = [stm ; zeros(512-rows(stm), cols(stm))];

        rpbox('send_matrix', stm);
        rpbox('ForceState0');
        state_matrix.value = stm;

    case 'test_timedisp'
        d = value(timedisp);
        if isstr(d), d = str2num(d); end;
        if isempty(d), errordlg('Time must be a number between 0 and 10. Resetting to 5.','Invalid value for Time'); timedisp.value = 5;
        elseif d <= 0 || d >15,
            errordlg('Time must be a number between 1 and 15. Resetting to 5.','Invalid value for Time'); timedisp.value = 5;
        end;
    otherwise
        error('Invalid action!');
        
    
end;


function [megasnd] = makesound(srate, vol, ramp)
megasnd=[];
flist = [0.5 1 2 4 8 16]; megasnd = [];
for f = 1:length(flist)
    snd =    MakeChord2(srate, 70-vol, flist(f)*1000, 1,500,'RiseFall',ramp*1000,'volume_factor',0.1);
    snd = [snd zeros(1,round(length(snd)/5))];
    megasnd = [megasnd snd];
end;
