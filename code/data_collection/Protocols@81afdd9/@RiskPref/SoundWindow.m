

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
    [x,y]=SoundInterface(obj,'add','ViolationSound',x,y,'Style','WhiteNoise','Volume', 0.04); 
    [x,y]=SoundInterface(obj,'add','ErrorSound',x,y,'Style','Tone','Volume',0.03, 'Freq', 750, 'Duration', 0);
    [x,y]=SoundInterface(obj,'add','TimeoutSound',x,y,'Style','WhiteNoise','Volume',0.06);
    next_column(x);
    y=10;
   % [x,y]=SoundInterface(obj,'add','NICSound',x,y,'Style','ToneFMWiggle','Volume',0.03);
    [x,y]=SoundInterface(obj,'add','HitHighSound',x,y,'Style','Tone','Volume',0.03, 'Freq', 1500, 'Duration', 0.1);
    [x,y]=SoundInterface(obj,'add','HitLowSound',x,y,'Style','Tone','Volume',0.03, 'Freq', 750, 'Duration', 0.1);
    [x,y]=SoundInterface(obj,'add','GoSound',x,y,'Style','Tone', 'Volume', 0.01,'Freq', 2500, 'Duration', 0.1);
   
    [x,y] = SoundInterface(obj, 'add', 'LeftLow', x, y, 'Style', 'ToneFMWiggle', 'Volume', .02, 'Freq', 1000, ...
        'FMAmp', 100, 'Duration', .3, 'Balance', -1);
    next_column(x);
    y=10;
    [x,y] = SoundInterface(obj, 'add', 'LeftHigh', x, y, 'Style', 'ToneFMWiggle', 'Volume', .02, 'Freq', 2000, ...
        'FMAmp', 1000, 'Duration', .3, 'Balance', -1);
    
    [x,y] = SoundInterface(obj, 'add', 'RightLow', x, y, 'Style', 'ToneFMWiggle', 'Volume', .02, 'Freq', 1000, ...
        'FMAmp', 100, 'Duration', .3, 'Balance', 1);
    [x,y] = SoundInterface(obj, 'add', 'RightHigh', x, y, 'Style', 'ToneFMWiggle', 'Volume', .02, 'Freq', 2000, ...
        'FMAmp', 1000, 'Duration', .3, 'Balance', 1);
    

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
    