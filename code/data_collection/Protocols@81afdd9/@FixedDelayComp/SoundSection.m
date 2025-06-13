

function [x, y] = SoundSection(obj, action, varargin)

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
    
    [x,y] = SoundInterface(obj, 'add', 'ViolationSound', x, y);
    SoundInterface(obj,'set','ViolationSound','Vol',0.01,'Freq',9000,'Dur1',0.5); 
    [x,y] = SoundInterface(obj, 'add', 'ErrorSound', x, y);
    SoundInterface(obj,'set','ErrorSound','Style','WhiteNoise','Vol',0.08);
    [x,y] = SoundInterface(obj, 'add', 'TimeoutSound', x, y);
    SoundInterface(obj,'set','TimeoutSound','Style','WhiteNoise','Vol',0.08,'Dur1',0.5);
    next_column(x);
    y=10;
    [x,y] = SoundInterface(obj, 'add', 'ViolationSound', x, y);
    SoundInterface(obj,'set','ViolationSound','Style','Tone','Vol',0.01,'Freq',3000,'Dur1',0);
	SoundInterface(obj, 'disable', 'GoSound', 'Dur1');
    
    [x,y] = SoundInterface(obj, 'add', 'SOneSound', x, y);
    SoundInterface(obj,'set','SOneSound','Style','WhiteNoise','Vol',0.08);
    [x,y] = SoundInterface(obj, 'add', 'STwoSound', x, y);
    SoundInterface(obj,'set','STwoSound','Style','WhiteNoise','Vol',0.08);
    next_column(x);
    y=20;
    [x,y] = SoundInterface(obj, 'add', 'NICSound', x, y);
    SoundInterface(obj, 'set','NICSound','Style','AMTone', 'Vol', 0.003, 'Dur1', 20);
    %[x, y] = SoundInterface(obj, 'add', 'NICSound', x, y);
    %SoundInterface(obj,'set','NICSound','Style','AMTone','Vol',0.003,'Dur1',20);
    
    [x,y] = SoundInterface(obj, 'add', 'RewardSound', x, y);
    SoundInterface(obj,'set','RewardSound','Style','Bups','Vol',0.004,'Freq',5,'Dur1',1.5);
    [x,y] = SoundInterface(obj, 'add', 'GoSound', x, y);
    SoundInterface(obj,'set','GoSound','Style','Tone','Vol',0.01,'Freq',3000,'Dur1',0.2);
    
    x=oldx; y=oldy;
    figure(parentfig);
    
%   case 'prepare_next_trial'
%     SoundInterface(obj, 'set','NICSound','Style','AMTone', 'Vol', 0.003, 'Dur1', CP_duration);
    
  case 'hide',
    SoundsShow.value = 0; set(value(myfig), 'Visible', 'off');

  case 'show',
    SoundsShow.value = 1; set(value(myfig), 'Visible', 'on');

  case 'show_hide',
    if SoundsShow == 1, set(value(myfig), 'Visible', 'on'); %#ok<NODEF> (defined by GetSoloFunctionArgs)
    else                   set(value(myfig), 'Visible', 'off');
    end;
    
end
    