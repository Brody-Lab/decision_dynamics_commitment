% This file contains code that will be run at the end of each trial
% in the scope of the protocol 'prepare_next_trial'.
%
% Santiago Jaramillo - 2007.09.24

%%% Note: changes actually occur in TrialNumber-1
%%% because of the weird meaning of n_done_trials.

autoRatName=get_sphandle('name','ratname');

switch value(autoRatName{1})

  %%% -------- FOR ELECTROPHYSIOLOGY (SNR=1)-------
  case {'saja000'}
    autoDistractorVolume=get_sphandle('name','DistractorVolume');
    autoRelevantSide=get_sphandle('name','RelevantSideSPH');
    autoWaterDelivery=get_sphandle('name','WaterDeliverySPH');
    autoPreStimMean=get_sphandle('name','PreStimMean');
    autoPreStimRange=get_sphandle('name','PreStimRange');
    if n_done_trials==10
        autoWaterDelivery{1}.value = 'only if nxt pke corr';
        autoPreStimMean{1}.value = 0.3;
        autoPreStimRange{1}.value = 0.1;
    elseif any(n_done_trials==[ 30:120:1000 ])   %  30 150 270 390 510
        autoDistractorVolume{1}.value = 1;
        SoundsSection(obj,'update_all_sounds');
    elseif  any(n_done_trials==[ 130:120:1000 ]) % 130 250 370 490 610
        if(strcmp(value(autoRelevantSide{1}),'left'))
            autoRelevantSide{1}.value = 'right';
        else
            autoRelevantSide{1}.value = 'left';
        end
        autoDistractorVolume{1}.value = 0.001;
        SoundsSection(obj,'update_all_sounds');
    end
    
    
  %%% -------- CHANGING DISTRACTOR VOLUME BY BLOCKS -------
  case {'saja000'}
    % -- Automating some parameters --
    autoDistractorVolume=get_sphandle('name','DistractorVolume');
    autoRelevantSide=get_sphandle('name','RelevantSideSPH');
    autoWaterDelivery=get_sphandle('name','WaterDeliverySPH');
    autoPreStimMean=get_sphandle('name','PreStimMean');
    if n_done_trials==10
        autoWaterDelivery{1}.value = 'only if nxt pke corr';
        autoPreStimMean{1}.value = 0.2;
    elseif any(n_done_trials==[ 50, 180, 310, 440, 570 ])
        autoDistractorVolume{1}.value = 1;
        SoundsSection(obj,'update_all_sounds');
    elseif any(n_done_trials==[ 170, 300, 430, 560 ])
        autoDistractorVolume{1}.value = 0.001;
        SoundsSection(obj,'update_all_sounds');
    elseif n_done_trials==430
        if(strcmp(value(autoRelevantSide{1}),'left'))
            autoRelevantSide{1}.value = 'right';
        else
            autoRelevantSide{1}.value = 'left';
        end
        autoDistractorVolume{1}.value = 0.001;
        SoundsSection(obj,'update_all_sounds');
    end

  %%% -------- CHANGING SIDES -------
  case {'saja000'}
    % -- Automating some parameters --
    autoDistractorVolume=get_sphandle('name','DistractorVolume');
    autoRelevantSide=get_sphandle('name','RelevantSideSPH');
    autoWaterDelivery=get_sphandle('name','WaterDeliverySPH');
    autoPreStimMean=get_sphandle('name','PreStimMean');
    autoPreStimRange=get_sphandle('name','PreStimRange');
    if n_done_trials==10
        autoWaterDelivery{1}.value = 'only if nxt pke corr';
        autoPreStimMean{1}.value = 0.3;
        autoPreStimRange{1}.value = 0.1;
    elseif any(n_done_trials==[ 120:120:2000 ])
        if(strcmp(value(autoRelevantSide{1}),'left'))
            autoRelevantSide{1}.value = 'right';
        else
            autoRelevantSide{1}.value = 'left';
        end
        autoDistractorVolume{1}.value = 0.001;
        SoundsSection(obj,'update_all_sounds');
    end

  %%% -------- CHANGING SIDES, INCREASING CUE TIME -------
  case {'saja010'}
    % -- Automating some parameters --
    autoSoundDuration=get_sphandle('name','SoundDuration');
    autoDistractorVolume=get_sphandle('name','DistractorVolume');
    autoRelevantSide=get_sphandle('name','RelevantSideSPH');
    autoWaterDelivery=get_sphandle('name','WaterDeliverySPH');
    autoPreStimMean=get_sphandle('name','PreStimMean');
    autoPreStimRange=get_sphandle('name','PreStimRange');
    if ~mod(n_done_trials,10)
        autoSoundDuration{1}.value_callback = value(autoSoundDuration{1})+0.020;
    end
    if n_done_trials==10
        autoWaterDelivery{1}.value = 'only if nxt pke corr';
        autoPreStimMean{1}.value = 0.3;
        autoPreStimRange{1}.value = 0.1;
    elseif any(n_done_trials==[ 120:120:2000 ])
        if(strcmp(value(autoRelevantSide{1}),'left'))
            autoRelevantSide{1}.value = 'right';
        else
            autoRelevantSide{1}.value = 'left';
        end
        autoDistractorVolume{1}.value = 0.001;
        SoundsSection(obj,'update_all_sounds');
    end

  %%% --------------- OPERANT ----------------------
  case {'saja000'}
    autoWaterDelivery=get_sphandle('name','WaterDeliverySPH');
    if n_done_trials==20
        autoWaterDelivery{1}.value = 'next corr poke';
    end        
    
  otherwise
    fprintf('No rat with a recognized name.\n');
end


%elseif 0%n_done_trials==50 || n_done_trials==280 || n_done_trials==510 || n_done_trials==640
