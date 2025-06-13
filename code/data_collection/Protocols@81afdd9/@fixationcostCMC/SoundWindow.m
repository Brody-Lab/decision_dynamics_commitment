

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
    [x,y]=SoundInterface(obj,'add','NICSound',x,y,'Style','AMTone','Volume',0.01,'Duration', 10);
    [x,y]=SoundInterface(obj,'add','HitSound',x,y,'Style','ToneSweep','Volume',0.04,'Duration',0.01);
    
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
    