function sm = SoftSMMarkII(arg)

  
if nargin==0,

  % changeme for debug porpoises
  sm.debug = 0;

  % todo add more members here..
  sm.StateMatrix = zeros(128,10);
  sm.NextStateMatrix = [];
  sm.NextSchedWaves  = [];
  sm.SetStateMatrixOnState0 = 0;
  sm.EventList = zeros(0, 4);
  sm.EventCount = 0;
  sm.T0 = clock();
  sm.CurrentState = 0;
  sm.CurrentStateTS = 0;
  sm.ContOut = 0;
  sm.TrigOut = 0;
  sm.SoundOut = 0;
  sm.Fig = figure;
  sm.InputEvents = [1 -1 2 -2 3 -3]; % mapping of matrix col -> input channel id & polarity
  sm.UpAndComingInputEvents = sm.InputEvents; % will become .InputEvents after
                                              % a call to SetStateMatrix
  sm.SchedWaves = cell(0,1);
  sm.ReadyForTrialJumpstate = 35;
  sm.ReadyForTrialFlg = 0;
  sm.InputButtons = [];
  sm.InputState = []; % vector of input state per input
                      % channel -- we start off with empty set -- this gets
                      % setup by UpdateInputUI for us..
  sm.InputButtonHeight = 1.0/7.0;
  sm.InputButtonPos = sm.InputButtonHeight*4;
  sm.EventQueue = zeros(0, 4);
  sm.HasSchedWaves = 0;
  sm.DIOButtonPos = sm.InputButtonPos-sm.InputButtonHeight*2;
  sm.DIOState = zeros(1,0);
  sm.ToneTrigPos = sm.InputButtonHeight;
  sm.ToneTrigLabel = 0;
  sm.SchedWavePos = 0.0;
  sm.SchedWaveLabel = 0;
  sm.SMListBoxFig = 0;
  sm.SMListBox = 0;
  sm.CurrentStateLabel = 0;
  sm.TimeLabel = 0;
  sm.VTrigCallback = {};
  sm.DoutCallback = {};
  sm.DoutBypass = 0;  
  sm.DoutLines = 0;
  sm.IsRunning = 0;
  sm.ForceTUP = 0;
  sm.NeedSMListBoxUpdate = 1;
  sm.StateStrings = cell(0,1);
  sm.LongestLabel = 0;
  sm.CookedSMView = 1;
  sm.CompactCB = 0;
  sm.OutputRouting = { struct('type', 'dout', 'data', '0-15'); ...
                       struct('type', 'sound', 'data', '0') };
  sm.ContChanOffset = 0;
  sm.NumContChans = 16;
  sm.TrigChanOffset = 0;
  sm.NumTrigChans = 0;
                   
  set(sm.Fig, 'Units', 'pixels'); 
  screen_size = get(0, 'ScreenSize');
  w = 600; h = 100;
  set(sm.Fig, 'Position', [screen_size(3)-(w+20) screen_size(4)-(h+20) w h]);
      
  set(sm.Fig, 'ToolBar', 'none', 'MenuBar', 'none', ...
              'Name', 'State Machine Emulator', 'NumberTitle', 'off');
              
  sm = class(sm, 'SoftSMMarkII');

  theLabel = ...
      uicontrol(sm.Fig, 'Style', 'Text', 'Units', 'normalize', ...
                'Position', [ 0 sm.InputButtonPos+sm.InputButtonHeight 1.0 ...
                    sm.InputButtonHeight ], 'String', ['Input Line' ...
                    ' Control (Click to poke in/out)']);

  theLabel2 = ...
      uicontrol(sm.Fig, 'Style', 'Text', 'Units', 'normalize', ...
                'Position', [ 0 sm.DIOButtonPos+sm.InputButtonHeight 1.0 ...
                    sm.InputButtonHeight ], 'String', ['DIO Line' ...
                    ' State (Not Clickable)']);

  theLabel3 = ...
      uicontrol(sm.Fig, 'Style', 'Text', 'Units', 'normalize', ...
                'Position', [ 0 sm.ToneTrigPos 0.5 ...
                    sm.InputButtonHeight ], 'String', ['Last Tone ID Played' ...
                    ': ']);
  
  sm.ToneTrigLabel = ...
      uicontrol(sm.Fig, 'Style', 'Text', 'Units', 'normalize', ...
                'Position', [ 0.5 sm.ToneTrigPos 0.5 ...
                    sm.InputButtonHeight ], 'String', ['(None)']);
  set(sm.ToneTrigLabel, 'FontWeight', 'bold');
  
  w = 640; h = 480;
  sm.SMListBoxFig = figure;
  set(sm.SMListBoxFig, 'ToolBar', 'none', 'MenuBar', 'none', ...
                    'Name', 'State Machine Emulator - State Matrix', ...
                    'NumberTitle', 'off', 'Position', ...
                    [ screen_size(3)-w-20 screen_size(4)-h-150 w h ] );
  sm.CompactCB = uicontrol(sm.SMListBoxFig, 'Style', 'checkbox', 'Units', ...
                           'normalize', 'Position', [ 0 .95 1.0 0.05 ]);
  set(sm.CompactCB, 'String', 'Compact Matrix (hide state names)');
  set(sm.CompactCB, 'Value', ~sm.CookedSMView);
  set(sm.CompactCB, 'Callback', { @ToggleCookedCallback, sm });
  
  sm.SMListBox = ...
      uicontrol(sm.SMListBoxFig, 'Style', 'listbox', 'Units', 'normalize', ...
                'Position', ... 
                [ 0.0 0.0 1.0 .95 ]);
  
  set(sm.SMListBox, 'Enable', 'inactive');
  set(sm.SMListBox, 'FontName', 'FixedWidth');
  set(sm.SMListBox, 'FontSize', 10);
                    
  x = 0; y = sm.InputButtonPos+2*sm.InputButtonHeight;
  theLabel4 = ...
      uicontrol(sm.Fig, 'Style', 'Text', 'Units', 'normalize', ...
                'Position', [ x y 0.25 sm.InputButtonHeight ], ...
                'String', 'Current State:');
  x = x + 0.25;
  sm.CurrentStateLabel = ...
      uicontrol(sm.Fig, 'Style', 'Text', 'Units', 'normalize', ...
                'Position', [ x y 0.25 sm.InputButtonHeight ], ...
                'String', '(None)');
  set(sm.CurrentStateLabel, 'FontWeight', 'bold');
  x = x + 0.25;
  theLabel5 = ...
      uicontrol(sm.Fig, 'Style', 'Text', 'Units', 'normalize', ...
                'Position', [ x y 0.25 sm.InputButtonHeight ], ...
                'String', 'Current Time:');
  x = x + 0.25;
  sm.TimeLabel = ...
      uicontrol(sm.Fig, 'Style', 'Text', 'Units', 'normalize', ...
                'Position', [ x y 0.25 sm.InputButtonHeight ], ...
                'String', '0');
  set(sm.TimeLabel, 'FontWeight', 'bold');

  theLabel6 = ...
      uicontrol(sm.Fig, 'Style', 'Text', 'Units', 'normalize', ...
                'Position', [ 0 0 0.25 sm.InputButtonHeight ], ...
                'String', 'Running Sched. Waves:');
  
  sm.SchedWaveLabel = ...
      uicontrol(sm.Fig, 'Style', 'Text', 'Units', 'normalize', ...
                'Position', [ 0.25 0 0.75 sm.InputButtonHeight ], ...
                'String', '(None)');
  set(sm.SchedWaveLabel, 'FontWeight', 'bold');
  
  set(sm.Fig, 'UserData', sm);
  
  sm = UpdateInputUI(sm);
  
  sm = RecreateDIOButtons(sm);

  sm = UpdateStateUI(sm);

  sm = UpdateRunningSchedWavesGUI(sm);

  set(sm.Fig, 'UserData', sm);

elseif isa(arg, 'SoftSMMarkII'),

  sm = arg;
  return;

else

  error(['Invalid argument(s) for SoftSMMarkII.  Please pass either 0' ...
         ' arguments, or 1 argument which is another instance of' ...
         ' a SoftSMMarkII.']);

end;

return;
  


