

function [x, y] = SoundWindow(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action,
    
  % ------------------------------------------------------------------
  %              INIT
  % ------------------------------------------------------------------    

  case 'init'
    if length(varargin) < 2,
      error('Need at least two arguments, x and y position, to initialize %s', mfilename);
    end;
    x = varargin{1}; y = varargin{2};
    
    ToggleParam(obj, 'SoundsShow', 0, x, y, 'OnString', 'Sounds', ...
      'OffString', 'Sounds', 'TooltipString', 'Show/Hide Sounds panel'); 
    set_callback(SoundsShow, {mfilename, 'show_hide'}); %#ok<NODEF> (Defined just above)
    next_row(y);
    oldx=x; oldy=y;    parentfig=double(gcf);

    SoloParamHandle(obj, 'myfig', 'value', figure('Position', [ 92   170   665   587], ...
      'closerequestfcn', [mfilename '(' class(obj) ', ''hide'');'], 'MenuBar', 'none', ...
      'Name', mfilename), 'saveable', 0);
    set(gcf, 'Visible', 'off');
    x=10;y=10;
    
    
    [x,y]=SoundInterface(obj,'add','ViolationSound',x,y,...
        'Style','WhiteNoiseTone','Freq',1000,'Volume',0.02,'Duration',0.2,'WNP',0.9);
    [x,y]=SoundInterface(obj,'add','TimeoutSound',x,y,...
        'Style','WhiteNoiseTone','Freq',1132,'Volume',0.02,'Duration',0.2,'WNP',0.9);
     [x,y]=SoundInterface(obj,'add','MissSound',x,y,...
        'Style','WhiteNoiseTone','Freq',1437,'Volume',0.02,'Duration',0.2,'WNP',0.9);
     [x,y]=SoundInterface(obj,'add','ITISound',x,y,...
        'Style','WhiteNoise','Volume',0.01,'Loop',1);
   
  
  next_column(x);
    y=10;

    [x,y]=SoundInterface(obj,'add','CueHighSound',x,y,...
        'Style','Bups','Freq',130,'Balance',0,'Volume',0.08,...
        'Duration',1,'Loop',1);
    [x,y]=SoundInterface(obj,'add','CueLeftSound',x,y,...
        'Style','Bups','Freq',50,'Balance',-1,'Volume',0.08,...
        'Duration',1,'Loop',1);
    [x,y]=SoundInterface(obj,'add','CueRightSound',x,y,...
            'Style','Bups','Freq',50,'Balance',1,'Volume',0.08,...
        'Duration',1,'Loop',1);
    [x,y]=SoundInterface(obj,'add','CueStereoSound',x,y,...
            'Style','Bups','Freq',50,'Balance',0,'Volume',0.08,...
        'Duration',1,'Loop',1);
    

    next_column(x);
    y=10;
    [x,y]=SoundInterface(obj,'add','RightHitSound',x,y,...
        'Style','ToneSweep','Volume',0.08,'Freq',8000,'Duration',0.1,'Balance',1);
    SoundInterface(obj,'set','RightHitSound','Freq2',12000);
    SoundInterface(obj,'set','RightHitSound','Dur2',0.2);

    [x,y]=SoundInterface(obj,'add','LeftHitSound',x,y,...
        'Style','ToneSweep','Volume',0.08,'Freq',8000,'Duration',0.1,'Balance',-1);
    SoundInterface(obj,'set','LeftHitSound','Freq2',12000);
    SoundInterface(obj,'set','LeftHitSound','Dur2',0.2); 
    
   
    [x,y]=SoundInterface(obj,'add','GoSound',x,y,...
        'Style','Tone','Volume',0.01,'Loop',0,'Freq',11451,'Duration',0.03);

    [x,y]=SoundInterface(obj,'add','NICSound',x,y,...
        'Style','AMTone','Volume',0.01,'Loop',1,'Freq',6000,'FMFreq',6,'FMAmp',1,'Duration',1);
  

%       cue_stereo_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'CueStereoSound');
%       cue_left_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'CueLeftSound');
%       cue_right_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'CueRightSound');
%       cue_high_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'CueHighSound');
%       nic_high_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'NICSound');
%       
%       
%       hit_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'HitSound');
%       miss_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'MissSound');
%       fa_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'FalseAlarmSound');
%       cr_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'CorrectRejectSound');
%       viol_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'ViolationSound');
%       to_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'TimeoutSound');
%       
%       
    

    x=oldx; y=oldy;
    figure(parentfig);
    
  case 'hide',
    SoundsShow.value = 0; set(value(myfig), 'Visible', 'off');

  case 'show',
    SoundsShow.value = 1; set(value(myfig), 'Visible', 'on');

  case 'show_hide',
    if SoundsShow == 1, set(value(myfig), 'Visible', 'on'); %#ok<NODEF> (defined by GetSoloFunctionArgs)
    else                   set(value(myfig), 'Visible', 'off');
    end;
    
end
    