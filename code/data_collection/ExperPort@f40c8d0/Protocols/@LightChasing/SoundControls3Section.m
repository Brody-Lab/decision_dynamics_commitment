% [x, y] = SoundControls3Section(obj, action, varargin)

function [x, y] = SoundControls3Section(obj, action, varargin)

GetSoloFunctionArgs(obj);
    
switch action

%% init    
  % ------------------------------------------------------------------
  %              INIT
  % ------------------------------------------------------------------    

  case 'init'
    if length(varargin) < 3
      error('Need at least three arguments,sound name and x and y position, to initialize %s', mfilename);
    end;
    x = varargin{2}; y = varargin{3}; 
    SoloParamHandle(obj, 'sname');
    sname.value = varargin{1};
    
    if nargin > 3,  varargin = {varargin{4:length(varargin)}};
    end;
    pairs = { ...
      'width'      200 ;     ...
      'SVol'       0 ;       ...
      'SFreq'      0 ;       ...
      'SDur'       0 ;       ...
      'SSide'      0 ;       ...
      'SBal'       0 ;       ...
      'SLoop'      0 ;       ...
      'setvol'     0.03;     ...
      'setfreq'    10000;    ...
      'setdur'     5 ;       ...
      'setside'    'Center'; ...
      'setbal'     1 ;       ...
      'setloop'    1 ;       ...
    }; parseargs(varargin, pairs);    

    SoloParamHandle(obj, 'ShowVol' ); ShowVol.value  = SVol;
    SoloParamHandle(obj, 'ShowFreq'); ShowFreq.value = SFreq;
    SoloParamHandle(obj, 'ShowDur' ); ShowDur.value  = SDur;
    SoloParamHandle(obj, 'ShowSide'); ShowSide.value = SSide;
    SoloParamHandle(obj, 'ShowBal' ); ShowBal.value  = SBal;
    SoloParamHandle(obj, 'ShowLoop'); ShowLoop.value = SLoop;

    SoloParamHandle(obj, 'I_am_SoundControlSection');
    SoloParamHandle(obj, 'my_xyfig', 'value', [x y gcf]);
    
    %----------------------------------------------------------------------
    %
    %                 TO BE DISPLAYED ON MAIN PROTOCOL
    %
    %----------------------------------------------------------------------
    
    %Toggle Detailed Controls ---------------------------------------------
    ToggleParam(obj, 'soundcontrols', 0, x, y, 'position', [x y width 20], 'TooltipString', ...
      sprintf('\nON = Sound Controls Visible  \nOFF = Hidden.'), ...
      'OnString', 'Sound Controls Visible', 'OffString', 'Sound Controls Hidden'); next_row(y);
    set_callback(soundcontrols, {mfilename, 'show_hide'}); %#ok<NODEF> (Defined just above)
  
    % Volume Control ------------------------------------------------------
    if ShowVol == 1, NumeditParam(obj, 'Vol', setvol, x, y, 'position', [x y width 20], 'TooltipString', sprintf(['\nVolume of ', value(sname)])); ...
        set_callback(Vol, {mfilename, 'set_volume'}); next_row(y); end; %#ok<NODEF>
    
    %Frequency Control ----------------------------------------------------
    if ShowFreq == 1, NumeditParam(obj, 'Freq', setfreq, x, y, 'position', [x y width 20], 'TooltipString', sprintf(['\nFrequency of ', value(sname)]));...
        set_callback(Freq, {mfilename, 'set_frequency'}); next_row(y); end; %#ok<NODEF>
    
    %Duration Control -----------------------------------------------------
    if ShowDur == 1, NumeditParam(obj, 'Dur', setdur, x, y, 'position', [x y width 20], 'TooltipString', sprintf(['\nDuration of ', value(sname)]));...
        set_callback(Dur, {mfilename, 'set_duration'}); next_row(y); end; %#ok<NODEF>
    
    %Balance Control ------------------------------------------------------
    if ShowBal == 1, NumeditParam(obj, 'Bal', setbal, x, y, 'position', [x y width 20], 'TooltipString', sprintf(['\nBalance of ', value(sname)]));...
        set_callback(Bal, {mfilename, 'set_balance'}); next_row(y);  %#ok<ALIGN,NODEF>
    elseif ShowSide == 1, Bal = SoloParamHandle(obj, 'Bal'); %#ok<NODEF>
    end; 
    
    %Side Control ------------------------------------------------------
    if ShowSide == 1, MenuParam(obj, 'Side', {'Left', 'Center', 'Right', 'Other'}, setside, x, y, 'position', [x y width 20]); %#ok<ALIGN>
        feval(mfilename, obj, 'set_side');  %#ok<NODEF>
        set_callback(Side, {mfilename, 'set_side'}); next_row(y); %#ok<NODEF>
    end;

    %Loop Control ---------------------------------------------------------
    if ShowLoop == 1, ToggleParam(obj, 'Loop', setloop, x,y, 'OnString','Loop','OffString','No Loop', 'position', [x y width 20], 'TooltipString',  ...
        ' If this is selected sound will play until an explicit sound off.  Make sure to test sound for artifacts at loop boundary');...
        set_callback(Loop, {mfilename, 'set_loop'}); next_row(y); %#ok<NODEF>
    end;
    
    %Header
    SubheaderParam(obj, 'Title', [value(sname), ' Controls'], x, y, 'position', [x y width 20]);
    next_row(y);
    
    %----------------------------------------------------------------------
    %
    %                            POPUP WINDOW
    %
    %----------------------------------------------------------------------
    
    SoloParamHandle(obj, 'myfig', 'value', figure('Position', [100 100 210 150], ...
      'closerequestfcn', [mfilename '(' class(obj) ', ''hide'');'], 'MenuBar', 'none', ...
      'Name', mfilename), 'saveable', 0);
    origfig_xy = [x y];
    x = 3; y = 3;
    
    %Sound UI Plugin
    [x, y] = SoundInterface(obj, 'add', value(sname), x, y);
    next_row(y, 0.5);
    
    x = origfig_xy(1); y = origfig_xy(2);
    figure(value(my_xyfig(3)));
    
    
    %Default State is hidden on startup
    feval(mfilename, obj, 'hide');
    
    %Update Values from Protocol GUI
    if exist('Vol'  ,  'var'), SoundInterface(obj, 'set', value(sname), 'Vol',   value(Vol )); end;   %#ok<NODEF>
    if exist('Freq' ,  'var'), SoundInterface(obj, 'set', value(sname), 'Freq1', value(Freq)); end;   %#ok<NODEF>
    if exist('Dur'  ,  'var'), SoundInterface(obj, 'set', value(sname), 'Dur1',  value(Dur )); end;   %#ok<NODEF>
    if exist('Bal'  ,  'var'), SoundInterface(obj, 'set', value(sname), 'Bal',   value(Bal )); end;   %#ok<NODEF>
    if exist('Loop' ,  'var'), SoundInterface(obj, 'set', value(sname), 'Loop',  value(Loop)); end;   %#ok<NODEF>
    
    feval(mfilename, obj, 'update');

    
%% set_volume
    
  % ------------------------------------------------------------------
  %              SET_VOLUME
  % ------------------------------------------------------------------    


case 'set_volume'
        SoundInterface(obj, 'set', value(sname), 'Vol',   value(Vol)); %#ok<NODEF,NODEF>
        
%% set_frequency

  % ------------------------------------------------------------------
  %              SET_FREQUENCY
  % ------------------------------------------------------------------    

case 'set_frequency'
        SoundInterface(obj, 'set', value(sname), 'Freq1', value(Freq)); %#ok<NODEF,NODEF>
        
        
%% set_duration
    
  % ------------------------------------------------------------------
  %              SET_DURATION
  % ------------------------------------------------------------------    

case 'set_duration'
        SoundInterface(obj, 'set', value(sname), 'Dur1',   value(Dur)); %#ok<NODEF,NODEF>
        
        
%% set_side
    
  % ------------------------------------------------------------------
  %              SET_SIDE
  % ------------------------------------------------------------------    


case 'set_side'
        if strcmp(value(Side), 'Left') %#ok<NODEF>
            Bal.value = -1;
            feval(mfilename, obj, 'set_balance');
        elseif strcmp(value(Side), 'Right')
            Bal.value = 1;
            feval(mfilename, obj, 'set_balance');
        elseif strcmp(value(Side), 'Center')
            Bal.value = 0;
            feval(mfilename, obj, 'set_balance');
        end;
        

%% set_balance
    
  % ------------------------------------------------------------------
  %              SET_BALANCE
  % ------------------------------------------------------------------    


case 'set_balance'
        SoundInterface(obj, 'set', value(sname), 'Bal', value(Bal)); %#ok<NODEF>


        
%% set_loop
    
  % ------------------------------------------------------------------
  %              SET_LOOP
  % ------------------------------------------------------------------    


case 'set_loop'
        SoundInterface(obj, 'set', value(sname), 'Loop',  value(Loop)); %#ok<NODEF>
        
    
%% hide    
    
  % ------------------------------------------------------------------
  %              HIDE
  % ------------------------------------------------------------------    

  case 'hide',
    soundcontrols.value = 0; set(value(myfig), 'Visible', 'off');
    
    
%% show_hide    
    
  % ------------------------------------------------------------------
  %              SHOW HIDE
  % ------------------------------------------------------------------    
  
  case 'show_hide',
    if value(soundcontrols) == 1,  %#ok<NODEF>
      set(value(myfig), 'Visible', 'on'); %#ok<NODEF> (defined by GetSoloFunctionArgs)
    else
      set(value(myfig), 'Visible', 'off');
    end;
    
    feval(mfilename, obj, 'update');
    
%% update    
    
  % ------------------------------------------------------------------
  %              UPDATE
  % ------------------------------------------------------------------    

  case 'update',
%       name     = scsets.name;
%       Vol      = scsets.vol;
%       Freq     = scsets.freq;
%       Dur      = scsets.dur;
%       Loop     = scsets.loop;
%       Bal      = scsets.bal;
%       Side     = scsets.side;
%       ShowVol  = scsets.ShowVol;
%       ShowFreq = scsets.ShowFreq;
%       ShowDur  = scsets.ShowDur;
%       ShowLoop = scsets.ShowLoop;
%       ShowBal  = scsets.ShowBal;
%       ShowSide = scsets.ShowSide;
      
      if ShowVol  == 1, Vol.value  = SoundInterface(obj, 'get', value(sname), 'Vol'  ); end %#ok<NODEF>
      if ShowFreq == 1, Freq.value = SoundInterface(obj, 'get', value(sname), 'Freq1'); end
      if ShowDur  == 1, Dur.value  = SoundInterface(obj, 'get', value(sname), 'Dur1' ); end
      if ShowLoop == 1, Loop.value = SoundInterface(obj, 'get', value(sname), 'Loop' ); end
      if ShowBal  == 1 || ShowSide == 1,
          Bal.value  = SoundInterface(obj, 'get', value(sname), 'Bal'  );
          if ShowSide == 1
              if     value(Bal) == -1, Side.value = 'Left'  ;
              elseif value(Bal) ==  0, Side.value = 'Center';
              elseif value(Bal) ==  1; Side.value = 'Right' ;
              else                     Side.value = 'Other' ;
              end;            
          end;
      end;
    
%% close

  % ------------------------------------------------------------------
  %              CLOSE
  % ------------------------------------------------------------------    
  case 'close'    
    if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)),
      delete(value(myfig));
    end;    
    delete_sphandle('owner', ['^@' class(obj) '$'], 'fullname', [mfilename '_']);

    
%% reinit    
  % ------------------------------------------------------------------
  %              REINIT
  % ------------------------------------------------------------------    
  case 'reinit'
    currfig = gcf;
    
    feval(mfilename, obj, 'close');
    
    figure(origfig);
    feval(mfilename, obj, 'init', x, y, scolors); %#ok<NODEF>
    figure(currfig);

end;    
    

