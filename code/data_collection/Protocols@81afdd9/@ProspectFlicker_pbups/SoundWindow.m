

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

    SoloParamHandle(obj, 'myfig', 'value', figure('Position', [100 100 560 440], ...
      'closerequestfcn', [mfilename '(' class(obj) ', ''hide'');'], 'MenuBar', 'none', ...
      'Name', mfilename), 'saveable', 0);
    set(gcf, 'Visible', 'off');
    x=10;y=10;
    [x,y]=SoundInterface(obj,'add','ViolationSound',x,y,'Style','WhiteNoise','Volume',0.03); 
    [x,y]=SoundInterface(obj,'add','ErrorSound',x,y,'Style','WhiteNoise','Volume',0.02);
    [x,y]=SoundInterface(obj,'add','TimeoutSound',x,y,'Style','WhiteNoise','Volume',0.02);
    [x,y]=SoundInterface(obj,'add','HitSound',x,y,'Style','ToneSweep','Volume',0.04);

   
    
     %nic_freqs = [625 938 1250 1875 2500 3750 5000];
     next_column(x);
     y=10;
     [x,y] = SoundInterface(obj, 'add', 'GoSound', x, y);
     SoundInterface(obj, 'set','GoSound','Style','Tone', 'Vol', 0.01,'Freq1', 2000, 'Dur1', 0.2);
%      [x,y] = SoundInterface(obj, 'add', 'right_neutral_nic', x, y);
%      SoundInterface(obj, 'set','right_neutral_nic','Style','Tone', 'Vol', 0.02, 'Freq1', 1875, 'Dur1', .1, 'Bal', 1, 'Loop', 1);
      [x,y]=SoundInterface(obj,'add','NICSound',x,y,'Style','Tone','Volume',0.04);
      
%      [x,y] = SoundInterface(obj, 'add', 'three_nic_left', x, y);
%      SoundInterface(obj, 'set','three_nic_left','Style','Tone', 'Vol', 0.02, 'Freq1', nic_freqs(1), 'Dur1', 3, 'Bal', -1);
%      [x,y] = SoundInterface(obj, 'add', 'ten_nic_left', x, y);
%      SoundInterface(obj, 'set','ten_nic_left','Style','Tone', 'Vol', 0.02, 'Freq1', nic_freqs(2), 'Dur1', 3, 'Bal', -1);
%      [x,y] = SoundInterface(obj, 'add', 'seventeen_nic_left', x, y);
%      SoundInterface(obj, 'set','seventeen_nic_left','Style','Tone', 'Vol', 0.02, 'Freq1', nic_freqs(3), 'Dur1', 3, 'Bal', -1);
%      [x,y] = SoundInterface(obj, 'add', 'twentyfour_nic_left', x, y);
%      SoundInterface(obj, 'set','twentyfour_nic_left','Style','Tone', 'Vol', 0.02, 'Freq1', nic_freqs(4), 'Dur1', 3, 'Bal', -1);
%      next_column(x);
%      y=10;
%      [x,y] = SoundInterface(obj, 'add', 'thirtyone_nic_left', x, y);
%      SoundInterface(obj, 'set','thirtyone_nic_left','Style','Tone', 'Vol', 0.02, 'Freq1', nic_freqs(5), 'Dur1', 3, 'Bal', -1);
%      [x,y] = SoundInterface(obj, 'add', 'thirtyeight_nic_left', x, y);
%      SoundInterface(obj, 'set','thirtyeight_nic_left','Style','Tone', 'Vol', 0.02, 'Freq1', nic_freqs(6), 'Dur1', 3, 'Bal', -1);
%      [x,y] = SoundInterface(obj, 'add', 'fortyfive_nic_left', x, y);
%       SoundInterface(obj, 'set','fortyfive_nic_left','Style','Tone', 'Vol', 0.02, 'Freq1', nic_freqs(7), 'Dur1', 3, 'Bal', -1);
       
       
     
%      [x,y] = SoundInterface(obj, 'add', 'three_nic_right', x, y);
%      SoundInterface(obj, 'set','three_nic_right','Style','Tone', 'Vol', 0.02, 'Freq1', nic_freqs(1), 'Dur1', 3, 'Bal', 1);
%      next_column(x);
%      y=10;
%      [x,y] = SoundInterface(obj, 'add', 'ten_nic_right', x, y);
%      SoundInterface(obj, 'set','ten_nic_right','Style','Tone', 'Vol', 0.02, 'Freq1', nic_freqs(2), 'Dur1', 3, 'Bal', 1);
%      [x,y] = SoundInterface(obj, 'add', 'seventeen_nic_right', x, y);
%      SoundInterface(obj, 'set','seventeen_nic_right','Style','Tone', 'Vol', 0.02, 'Freq1', nic_freqs(3), 'Dur1', 3, 'Bal', 1);
%      [x,y] = SoundInterface(obj, 'add', 'twentyfour_nic_right', x, y);
%      SoundInterface(obj, 'set','twentyfour_nic_right','Style','Tone', 'Vol', 0.02, 'Freq1', nic_freqs(4), 'Dur1', 3, 'Bal', 1);
%     
%      [x,y] = SoundInterface(obj, 'add', 'thirtyone_nic_right', x, y);
%      SoundInterface(obj, 'set','thirtyone_nic_right','Style','Tone', 'Vol', 0.02, 'Freq1', nic_freqs(5), 'Dur1', 3, 'Bal', 1);
%      [x,y] = SoundInterface(obj, 'add', 'thirtyeight_nic_right', x, y);
%      SoundInterface(obj, 'set','thirtyeight_nic_right','Style','Tone', 'Vol', 0.02, 'Freq1', nic_freqs(6), 'Dur1', 3, 'Bal', 1);
%      [x,y] = SoundInterface(obj, 'add', 'fortyfive_nic_right', x, y);
%      SoundInterface(obj, 'set','fortyfive_nic_right','Style','Tone', 'Vol', 0.02, 'Freq1', nic_freqs(7), 'Dur1', 3, 'Bal', 1);
%       
      
      
       % [x,y] = SoundInterface(obj, 'add', 'HitSound', x, y, 'Style','ToneFMWiggle','Volume',0.03, 'Freq1', 2000, 'Duration', .2);
   % [x,y] = SoundInterface(obj, 'add', 'ErrorSound', x, y, 'Style','ToneFMWiggle','Volume',0.03, 'Freq1', 500, 'Dur1', .3);

    
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
    