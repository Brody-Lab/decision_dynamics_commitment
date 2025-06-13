function [  ] = nprotocol2_gui( obj, action, x, y )
%NPROTOCOL2_GUI Summary of this function goes here
%   Detailed explanation goes here

GetSoloFunctionArgs;
switch action,
 case 'init',
% y=210;
% x=10;
% ------------------FIRST COLUMN------------------
%     x = 5; y = 5;    
%     next_column(x); y=5;     
%     next_row(y); 
    PushbuttonParam(obj, 'submit', x, y, 'label', 'SUBMIT STATE MATRIX', 'position', [x y 200 40],'BackgroundColor', [0 0 0.8]);next_row(y);
        set_callback(submit, {'StateMatrixSection2', 'next_trial'}); 
    next_row(y);    
    
    NumeditParam(obj, 'rightSuctionTime', 0.5, x, y, 'TooltipString', 'Time of right suction');next_row(y);
    NumeditParam(obj, 'leftSuctionTime', 0.5, x, y, 'TooltipString', 'Time of left suction');next_row(y);
    NumeditParam(obj, 'rightTimetoSuction', 3, x, y, 'TooltipString', 'Preamble of right suction');next_row(y);
    NumeditParam(obj, 'leftTimetoSuction', 3, x, y, 'TooltipString', 'Preamble of left suction');next_row(y);
    SubheaderParam(obj, 'suctionMenu', 'Suction Options', x, y);next_row(y);
    NumeditParam(obj, 'timeOut', 3, x, y, 'TooltipString', 'Minimum out of poke time for new trial to start');next_row(y);
    SubheaderParam(obj, 'timeOutMenu', 'Timeout', x, y); next_row(y);
    NumeditParam(obj, 'rightValve', 0.15, x, y, 'TooltipString', 'Opening time of right solenoid.');next_row(y);
    NumeditParam(obj, 'leftValve', 0.15, x, y, 'TooltipString', 'Opening time of left solenoid.');next_row(y);
    SubheaderParam(obj, 'valveMenu', 'Water Valve Time', x, y); next_row(y);
    NumeditParam(obj, 'rPokePVO', 0.01, x, y, 'TooltipString', 'Latency between right poke and valve open.');next_row(y);
    NumeditParam(obj, 'lPokePVO', 0.01, x, y, 'TooltipString', 'Latency between left poke and valve open.');next_row(y);
    SubheaderParam(obj, 'preambleMenu', 'Preamble to Valve Opening', x, y);next_row(y);
    NumeditParam(obj, 'timeto_lrPoke', 5, x, y, 'TooltipString', 'Time to left or right poke after valid cPoke');next_row(y);
    SubheaderParam(obj, 'w4bMenu', 'Time to lrPoke after cPoke', x, y);next_row(y);
    MenuParam(obj, 'click_or_sound',{'SOUND', 'CLICK'}, 1, x, y, 'TooltipString', ...
        'User Click or sound for cpoke cue',  'labelfraction', 0.5);next_row(y);
        set_callback(click_or_sound, {'paramChange', 'sound'});
 	DispParam(obj, 'cClickTime', 0.08, x, y,'position', [x+100 y 100 20], 'labelfraction', 0.6);
    NumeditParam(obj, 'cPokeTime', 0.01, x, y, 'position', [x y 100 20], 'TooltipString', ...
        'Latency between center poke and valve open.', 'labelfraction', 0.6);next_row(y);
    SubheaderParam(obj, 'poketimeMenu', 'Center Poke', x, y);next_row(y);
    NumeditParam(obj, 'volumeLossRight', 0, x, y, 'TooltipString', 'Volume of water drank on Right side.');next_row(y);
    NumeditParam(obj, 'volumeLossLeft', 0, x, y, 'TooltipString', 'Volume of water drank on Left side.');next_row(y);    
    MenuParam(obj, 'Noise_Shock_LASER',{'Shock', 'White Noise', 'LASER'}, 1, x, y);next_row(y);
    MenuParam(obj, 'beginner',{'NO', 'YES'}, 1, x, y, 'TooltipString', ...
        'Settings for beginner rat',  'labelfraction', 0.5);next_row(y);
        set_callback(beginner, {'paramChange', 'beginner'});
    NumeditParam(obj, 'ratWeight', 0, x, y, 'TooltipString', 'Rat''s weight');next_row(y);

next_row(y);
next_row(y);
next_row(y);
next_row(y);
next_row(y);
next_row(y);
next_row(y);
next_row(y);
next_row(y);
next_row(y);
next_row(y);

%     -------------------SECOND COLUMN--------------------
    %X=10&&y=410
    next_column(x); y=10;
    
    PushbuttonParam(obj, 'build', x, y, 'label', 'BUILD sounds,laser,water & shock', 'position', [x y 200 40],'BackgroundColor', [0 1 0]);next_row(y);
        set_callback(build, {'rnd_block', 'init'; ...
            'rnd_block', 'waterLeft'; 'rnd_block', 'waterRight'; ...
            'rnd_block', 'shockLeft'; 'rnd_block', 'shockRight'; ...
            'nPlot', 'build'; 'nLaser', 'build';...
            'nSound','build';}); %i, sprintf('\n')});  next_row(y);
    
    next_row(y);
    DispParam(obj, 'buildCheck', 'NO BUILD YET!!                  ', x, y, 'labelfraction', 0.01); next_row(y);
    DispParam(obj, 'ntrials_available', 0, x, y, 'labelfraction', 0.65); next_row(y);
    
       ToggleParam(obj, 'freeShock', 0, x, y, 'position', [x y 200 40], 'TooltipString', 'Unconstrained Shock', ...
    'label', 'freeShock', 'OnString', 'Shock is ON!!', 'OffString', 'Shock is OFF', 'BackgroundColor', [0.8 0.8 0.9], ...
    'ForegroundColor', [0 0 0]); next_row(y);next_row(y);   
        set_callback(freeShock, {'nLaser', 'free_shock'});
    
        file_list_shock = dir('Protocols\@nprotocol2\ShockProfiles\');
        for i=1:length(file_list_shock), if strcmp(file_list_shock(i).name,'CVS');idx = i; end;end;
        file_list_shock(idx)=[];
    MenuParam(obj, 'shockProfileRight', {file_list_shock(3:end).name}, 1, x, y, 'TooltipString', ...
        'SessionProfile, check cheat sheat.');next_row(y);
    MenuParam(obj, 'shockProfileLeft', {file_list_shock(3:end).name}, 1, x, y, 'TooltipString', ...
        'SessionProfile, check cheat sheat.');next_row(y);
        file_list_water = dir('Protocols\@nprotocol2\WaterProfiles\');
        for i=1:length(file_list_water), if strcmp(file_list_water(i).name,'CVS');idx = i; end;end;
        file_list_water(idx)=[];
    MenuParam(obj, 'waterProfileRight', {file_list_water(3:end).name}, 1, x, y, 'TooltipString', ...
        'SessionProfile, check cheat sheat.');next_row(y);
    MenuParam(obj, 'waterProfileLeft', {file_list_water(3:end).name}, 1, x, y, 'TooltipString', ...
        'SessionProfile, check cheat sheat.');next_row(y);
    NumeditParam(obj, 'blockSize', 20, x, y, 'TooltipString', 'Block Size.');next_row(y);
    SubheaderParam(obj, 'sessionMenu', 'Probabilities', x, y);next_row(y);

        SoloParamHandle(obj, 'probvec_waterLeft');
        SoloParamHandle(obj, 'probvec_waterRight');
        SoloParamHandle(obj, 'probvec_shockLeft');
        SoloParamHandle(obj, 'probvec_shockRight');
        SoloParamHandle(obj, 'laservec');
       
        sound_samp_rate = bSettings('get', 'SOUND', 'sound_sample_rate');
    DispParam(obj, 'samp_rate', sound_samp_rate, x, y, 'labelfraction', 0.4); next_row(y);
    DispParam(obj, 'amp', 0.8333, x, y, 'position', [x y 100 20], 'TooltipString', 'Pulse Amplitude between 0 & 1.');
    DispParam(obj, 'len', 1, x, y, 'position', [x+100 y 100 20], 'TooltipString', 'Pulse Length in seconds.');next_row(y);
   
    NumeditParam(obj, 'laserEnd_after', 0, x, y, 'TooltipString', 'End LASER Pulse after Trial...');next_row(y);
    NumeditParam(obj, 'laserStart_after', 0, x, y, 'TooltipString', 'Start LASER Pulse after Trial...');next_row(y);
    NumeditParam(obj, 'fractionOn', 0.025, x, y, 'TooltipString', 'Fraction of ON time (given freq), 1-fractionOn = OFF time.');next_row(y);
        set_callback(fractionOn, {'nLaser', 'fractionOn';'nLaser','build'});
    NumeditParam(obj, 'onTime', 0.005, x, y, 'TooltipString', 'UP time in sec. of pulse (given freq).');next_row(y);
        set_callback(onTime, {'nLaser', 'onTime'});

    NumeditParam(obj, 'freq', 5, x, y, 'TooltipString', 'Pulse Frequency in Hz.');next_row(y);
        set_callback(freq, {'nLaser', 'freq'});
    SubheaderParam(obj, 'laserMenu', 'LASER Options', x, y);next_row(y);
    ToggleParam(obj, 'freeLaser', 0, x, y, 'position', [x y 200 40], 'TooltipString', 'Unconstrained LASER', ...
    'label', 'freeLaser', 'OnString', 'LASER is ON!!', 'OffString', 'LASER is OFF', 'BackgroundColor', [0.8 0.8 0.9], ...
    'ForegroundColor', [0 0 0]); next_row(y);next_row(y);   
        set_callback(freeLaser, {'nLaser', 'free_laser'});
   
    

%     -------------------THIRD COLUMN--------------------
% x=216&&y=410
 next_column(x);y=10;
    PushbuttonParam(obj, 'nSwitch', x, y, 'label', 'SWICH TO OPERANT', 'position', [x y 200 40],'BackgroundColor', [1 0 0]);next_row(y);
        set_callback(nSwitch, {'nSwitch', 'init'});next_row(y);
   next_row(y);     
next_row(y); 
next_row(y);
%     MenuParam(obj, 'progressive', {'NO', 'YES'}, 1, x, y, 'TooltipString', Blocks of increasing difficoulty);
 next_row(y);     
 next_row(y); 
 next_row(y);
 next_row(y);
 next_row(y);
 NumeditParam(obj, 'shockAmp', 0, x, y);next_row(y);next_row(y);

    PushbuttonParam(obj, 'wNoise', x, y, 'label', 'PLAY WHITE NOISE', 'position', [x y 200 40],'BackgroundColor', [1 1 1]);next_row(y);
        set_callback(wNoise, {'nSound', 'wplay'});next_row(y);
    NumeditParam(obj, 'wNoiseTime', 0.08, x, y, 'TooltipString', 'Length in sec. of sound.');next_row(y);
        set_callback(wNoiseTime, {'paramChange', 'sound'; 'nSound', 'build'}); 
    NumeditParam(obj, 'wNoiseAmp', 0.5, x, y);next_row(y);
        set_callback(wNoiseAmp, {'paramChange', 'sound'; 'nSound', 'build'}); 
        
    PushbuttonParam(obj, 'Sound', x, y, 'label', 'PLAY SOUND', 'position', [x y 200 40],'BackgroundColor', [1 0 1]);next_row(y);
        set_callback(Sound, {'nSound', 'play'});
    next_row(y);
    NumeditParam(obj, 'soundFreq', 6000, x, y, 'TooltipString', 'Frequency of sound.');next_row(y);
        set_callback(soundFreq, {'nSound', 'build'});
    NumeditParam(obj, 'soundTime', 0.08, x, y, 'TooltipString', 'Length in sec. of sound.');next_row(y);
        set_callback(soundTime, {'paramChange', 'sound'; 'nSound', 'build'}); 
        SubheaderParam(obj, 'sounds', 'Sounds', x, y);next_row(y);
 next_row(y);
 next_row(y);
    NumeditParam(obj, 'xRange', 40, x, y, ...
        'TooltipString', 'Set the range of trials to display.','labelfraction', 0.65);
    set_callback(xRange, {'nPlot', 'update'});

    SoloParamHandle(obj, 'correct');
    SoloParamHandle(obj, 'grade');
    DeclareGlobals(obj, 'rw_args', {'onTime', 'fractionOn', 'amp', 'len', 'freq', 'samp_rate', ...
        'laserStart_after', 'laserEnd_after', 'click_or_sound', 'correct', 'grade'});
    
    DeclareGlobals(obj, 'rw_args', {'blockSize', 'shockProfileLeft', 'shockProfileRight', ...
        'waterProfileLeft', 'waterProfileRight', 'ntrials_available', 'buildCheck', ...
        'probvec_waterLeft', 'probvec_waterRight', 'probvec_shockLeft', 'probvec_shockRight', 'laservec'});
   
    DeclareGlobals(obj, 'rw_args', {'cClickTime', 'leftValve', 'rightValve', 'cPokeTime', 'lPokePVO', ...
        'rPokePVO', 'submit', 'timeOut', 'leftTimetoSuction', 'xRange'...
        'rightTimetoSuction', 'leftSuctionTime', 'rightSuctionTime', 'timeto_lrPoke'});% 'laserTime', 'laserProp', 'LRlaser','shockProb', 'LRshock','shockStart_after', 
    DeclareGlobals(obj, 'rw_args', {'soundTime', 'soundFreq', 'freeLaser', 'ratWeight', 'volumeLossLeft', ...
      'volumeLossRight', 'beginner', 'wNoise', 'wNoiseAmp', 'wNoiseTime', 'Noise_Shock_LASER', 'shockAmp'});
  
  nSound(obj, 'init');
  nLaser(obj, 'init');
  paramChange(obj, 'beginner');
  
    otherwise,
   error(['Don''t know how to deal with action ' action]);
end;
