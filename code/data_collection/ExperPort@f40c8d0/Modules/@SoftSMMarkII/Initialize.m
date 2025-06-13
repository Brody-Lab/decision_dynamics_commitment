function [sm] = Initialize(sm)

    sm.T0 = clock();
    sm.CurrentState = 0;
    sm.CurrentStateTS = etime(sm.T0, sm.T0);
    sm.StateMatrix = zeros(128,10);
    sm.ContOut = 0;
    sm.TrigOut = 0;
    sm.SoundOut = 0;
    sm.InputEvents = [ 1 -1 2 -2 3 -3];
    sm.UpAndComingInputEvents = sm.InputEvents;
    sm.InputState = zeros(1, 3);
    sm.EventList = zeros(0, 4);
    sm.EventCount = 0;
    sm.CurrentState = 0;
    sm.EventQueue = zeros(0,4);
    sm.SchedWaves = cell(0,1);
    sm.HasSchedWaves = 0;
    sm.IsRunning = 0;
    sm.ForceTUP = 0;
    sm.ReadyForTrialFlg = 0;      
    sm.NeedSMListBoxUpdate = 1;
    sm.StateStrings = cell(0,1);
    sm.LongestLabel = 0;
    sm.CookedSMView = 1;
    sm.OutputRouting = { struct('type', 'dout', 'data', '0-15'); ...
                           struct('type', 'sound', 'data', '0') };
    sm.ContChanOffset = 0;
    sm.NumContChans = 16;
    sm.TrigChanOffset = 0;
    sm.NumTrigChans = 0;
    
    set(sm.ToneTrigLabel, 'String', '(None)');

    set(sm.Fig, 'UserData', sm);
    
    sm = UpdateInputUI(sm);   

    for i = 1:size(sm.DIOState, 2),
      delete(sm.DIOState(1, i));
    end;
    sm.DIOState = zeros(1,0);
    sm = RecreateDIOButtons(sm);
    
    sm = UpdateStateUI(sm);
    
    sm = UpdateRunningSchedWavesGUI(sm);
    
    set(sm.Fig, 'UserData', sm);
    
    return;