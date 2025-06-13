% This file contains code that will be run whenever there is
% a call to  AutomationSection(obj,'run_autocommands');
%
% Santiago Jaramillo - 2007.09.24

%%% Note: changes actually occur in TrialNumber-1
%%% because of the weird meaning of n_done_trials.

AutoActionsList.value = {'none',...
                         'ChangeDelayByBlocks',...
                         'LongerBlocksOfShortRare',...
                         'CueingByBlocks',...
                         'ChangeSourceByBlocks',...
                         'IncreaseDelayToTarget',...
                    };


switch value(AutoCommandsMenu)

  %%% --------------- nothing ----------------------
  case {'none'}
    % DO NOTHING
    
  %%% -------- LONG/SHORT-DELAY BLOCKS -------
  case {'ChangeDelayByBlocks'}
    autoCurrentBlock=get_sphandle('name','CurrentBlock');
    autoCatchProb=get_sphandle('name','CatchProb');
    if n_done_trials<1
        autoCatchProb{1}.value_callback = 0.15;
        % -- Randomize starting block --
        if (rand(1)>0.5)
            autoCurrentBlock{1}.value_callback = 'short-delay';
        else
            autoCurrentBlock{1}.value_callback = 'long-delay';
        end            
        %autoCurrentBlock{1}.value_callback = 'short-delay'; % Fix first block
    elseif any(n_done_trials==[ 150:150:2000 ])
    %elseif any(n_done_trials==[ 200:200:2000 ])
        if (strcmp(value(autoCurrentBlock{1}),'long-delay'))
            autoCurrentBlock{1}.value_callback = 'short-delay';
        else
            autoCurrentBlock{1}.value_callback = 'long-delay';
        end
    end
      
  %%% -------- LONGER BLOCKS OF SHORT RARE -------
  case {'LongerBlocksOfShortRare'}
    autoCurrentBlock=get_sphandle('name','CurrentBlock');
    autoCatchProb=get_sphandle('name','CatchProb');
    if n_done_trials<1
        autoCatchProb{1}.value_callback = 0.15;
        % -- Randomize starting block --
        if (rand(1)>0.5)   %%% Start with short delay block
            autoCurrentBlock{1}.value_callback = 'short-delay';
            SoloParamHandle(obj, 'SwitchingPolicy','value',[],'saveable',0);
            SwitchingPolicy.value = [ 200,600,2000 ];
            disp('*** Starting with short-delay block ***');
        else               %%% Switch quickly to long delay block
            autoCurrentBlock{1}.value_callback = 'short-delay';
            SoloParamHandle(obj, 'SwitchingPolicy','value',[],'saveable',0);
            SwitchingPolicy.value = 3+[ 0,300,500,2000 ];
            disp('*** Switching quickly to long-delay block ***');
        end            
    elseif any(n_done_trials==value(SwitchingPolicy))
        if (strcmp(value(autoCurrentBlock{1}),'long-delay'))
            autoCurrentBlock{1}.value_callback = 'short-delay';
        else
            autoCurrentBlock{1}.value_callback = 'long-delay';
        end
    end
      
  %%% -------- WITH_CUEING -------
  case {'CueingByBlocks'}
    % -- Automating some parameters --
    autoCueProb=get_sphandle('name','CueProb');
    autoCueToTargetDelay=get_sphandle('name','CueToTargetDelay');
    autoCurrentBlock=get_sphandle('name','CurrentBlock');
    autoWaterDelivery=get_sphandle('name','WaterDeliverySPH');
    autoPreStimMean=get_sphandle('name','PreStimMean');
    autoPreStimHalfRange=get_sphandle('name','PreStimHalfRange');
    if n_done_trials<1
        autoCurrentBlock{1}.value = 'rand-delay';
        autoCueProb{1}.value_callback = 0.5;
        autoCueToTargetDelay{1}.value_callback = 0.3;
        autoWaterDelivery{1}.value_callback = 'only if nxt pke corr';
        autoPreStimMean{1}.value_callback = 0.3;
        autoPreStimHalfRange{1}.value_callback = 0.05;
    %elseif any(n_done_trials==[ 300:200:2000 ])
    %    if(strcmp(value(autoCueMode{1}),'off'))
    %        autoCueMode{1}.value_callback = 'on';
    %    else
    %        autoCueMode{1}.value_callback = 'off';
    %    end
    end

  %%% -------- WITH_CUEING -------
  case {'ChangeSourceByBlocks'}
    autoCurrentBlock=get_sphandle('name','CurrentBlock');
    autoCatchProb=get_sphandle('name','CatchProb');
    autoTargetSource=get_sphandle('name','TargetSource');
    autoDistractorSource=get_sphandle('name','DistractorSource');
    if n_done_trials<1
        autoCatchProb{1}.value_callback = 0.15;
        autoCurrentBlock{1}.value_callback = 'target-left';
        autoTargetSource{1}.value_callback = 'left';
        autoDistractorSource{1}.value_callback = 'monaural-random';
    %elseif any(n_done_trials==[ 150:150:2000 ])
    elseif any(n_done_trials==[ 200:200:2000 ])
        if (strcmp(value(autoCurrentBlock{1}),'target-left'))
            autoCurrentBlock{1}.value_callback = 'target-right';
        else
            autoCurrentBlock{1}.value_callback = 'target-left';
        end
    end

  %%% -------- SHAPING DETECTION -------
  case {'IncreaseDelayToTarget'}
    autoCurrentBlock=get_sphandle('name','CurrentBlock');
    autoWaterDelivery=get_sphandle('name','WaterDeliverySPH');
    autoAntiBiasMethod=get_sphandle('name','AntiBiasMethod');
    autoMaxSame=get_sphandle('name','MaxSame');
    autoDelayToTarget=get_sphandle('name','DelayToTarget');
    autoPreStimMean=get_sphandle('name','PreStimMean');
    autoPreStimHalfRange=get_sphandle('name','PreStimHalfRange');
    if n_done_trials<1
        autoAntiBiasMethod{1}.value_callback = 'repeat mistake';
        autoCurrentBlock{1}.value_callback = 'fixed-delay';
        autoWaterDelivery{1}.value_callback = 'next corr poke';
        autoMaxSame{1}.value_callback = 2;
        autoDelayToTarget{1}.value_callback = 0.001;
        autoPreStimMean{1}.value_callback = 0.1;
        autoPreStimHalfRange{1}.value_callback = 0.01;
    elseif any(n_done_trials==[20:10:80,100:20:140,170:20:210,250:20:290,330:20:370])
        autoPreStimMean{1}.value_callback = value(autoPreStimMean{1}) + 0.05;
    %         DelayToTarget =   0.001      0.151      0.301     0.451     0.601          
    elseif any(n_done_trials==[90,160,230,310,390])
        autoPreStimMean{1}.value_callback = 0.3;
        autoDelayToTarget{1}.value_callback = value(autoDelayToTarget{1}) + 0.150;
    elseif any(n_done_trials==[420])
        autoPreStimMean{1}.value_callback = 0.3;
        autoPreStimHalfRange{1}.value_callback = 0.05;
        autoCurrentBlock{1}.value_callback = 'rand-delay';        
    end
    
    
  %%% -------- OTHERWISE -------
  otherwise
    fprintf('AutoAction not recognized.\n');
end

