% Typical section code-- this file may be used as a template to be added 
% on to. The code below stores the current figure and initial position when
% the action is 'init'; and, upon 'reinit', deletes all SoloParamHandles 
% belonging to this section, then calls 'init' at the proper GUI position 
% again.


% [x, y] = YOUR_SECTION_NAME(obj, action, x, y)
%
% Section that takes care of YOUR HELP DESCRIPTION
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%            'init'      To initialise the section and set up the GUI
%                        for it
%
%            'reinit'    Delete all of this section's GUIs and data,
%                        and reinit, at the same position on the same
%                        figure as the original section GUI was placed.
%
% x, y     Relevant to action = 'init'; they indicate the initial
%          position to place the GUI at, in the current figure window
%
% RETURNS:
% --------
%
% [x, y]   When action == 'init', returns x and y, pixel positions on
%          the current figure, updated after placing of this section's GUI. 
%
%
%%% CVS version control block - do not edit manually
%%%  $Revision$
%%%  $Date$
%%%  $Source$

%%% NOTES: %%%
% - The size of ProbeFrequencies is defined on 'init' so the number of distractors
%   has to be fixed during the whole session.



function [xpos, ypos] = SoundsSection(obj, action, varargin)

GetSoloFunctionArgs;
%%% Imported objects (see protocol constructor):
%%%  'CurrentBlock'  NOT NEEDED!!!
%%%  'MaxTrials'
%%%  'PsychCurveMode'
%%%  'TargetDuration','TargetVolume','TargetModIndex',...
%%%  'TargetFreqL','TargetFreqR','StimulusDuration',...
%%%  'DistractorDuration','DistractorGap','DistractorVolume',... 
%%%  'PunishSoundDuration'
%%%  'DelayToTarget'
%%%  'RecMode'


% -- Necessary to access speaker calibration data --
global Solo_rootdir;


switch action
  case 'init',
    % Save the figure and the position in the figure where we are
    % going to start adding GUI elements:
    xpos = varargin{1};
    ypos = varargin{2};
    SoloParamHandle(obj, 'my_gui_info', 'value', [xpos ypos gcf]);
    
    % -- Extra GUI elements --
    MenuParam(obj, 'Calibration', {'speakers','earphones'}, 'speakers', xpos, ypos,...
              'TooltipString','Calibration file to use.'); next_row(ypos,1.0);
    set_callback(Calibration, {mfilename, 'update_calibration'});
    SubheaderParam(obj, 'title', 'Sounds Section', xpos, ypos); next_row(ypos, 1.5);
    
    % -- Setting up speaker calibration --
    SoloParamHandle(obj, 'SpeakerCalibration','value',[],'saveable',0);    
    SoundsSection(obj,'update_calibration');
    
    % -- Make punishment noise --
    NoiseStruct.Name     = 'PunishNoise';
    NoiseStruct.Type     = 'Noise';
    NoiseStruct.Duration = value(PunishSoundDuration);
    NoiseStruct.Attenuation   = 0.005;
    NoiseStruct.Waveform = SoundsSection(obj,'create_waveform',NoiseStruct);

    % --- Sound Server (and declare sounds) ---
    SoundManagerSection(obj, 'init');
    SoundManagerSection(obj, 'declare_new_sound', 'DistractorsSound', [0]);
    SoundManagerSection(obj, 'declare_new_sound', 'TargetSound', [0]);
    SoundManagerSection(obj, 'declare_new_sound', 'PunishNoise', NoiseStruct.Waveform);

    % -- Upload sounds --
    SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
    %SoundsSection(obj,'update_all_sounds');

    % -- Define length of stimulus --
    SoloParamHandle(obj, 'MaxNtonesPerTrial','value', 0);    
    MaxNtonesPerTrial.value = ceil(value(StimulusDuration)/...
                                (value(DistractorDuration)+value(DistractorGap)));
     
    % -- Distractor frequencies --
    SoloParamHandle(obj, 'ProbeFrequencies','value', []);
    ProbeFrequencies.value = logspace(log10(5010),log10(40200),9)';
    ProbeFrequencies.value = ProbeFrequencies([1:3,5,7:9]);    
    %SoloParamHandle(obj, 'NtonesPerTrial', 'value', 0);
    %NtonesPerTrial.value = ceil(value(StimulusDuration)/...
    %                            (value(DistractorDuration)+value(DistractorGap)));
    SoloParamHandle(obj, 'FrequencyOrder','value', ...
                    nan(value(MaxTrials),value(MaxNtonesPerTrial)));    

    % -- Distractor source --
    SoloParamHandle(obj, 'EachDistractorSource','value', []);    
    EachDistractorSource.labels.Binaural = 0;
    EachDistractorSource.labels.Left = 1;
    EachDistractorSource.labels.Right = 2;
    EachDistractorSource.values = nan(value(MaxTrials),value(MaxNtonesPerTrial));

    
  %-----------------------------------------------------------------------------%
  case 'update_calibration'
    % --- Speaker calibration data ---
    SettingsDir = fullfile(Solo_rootdir,'Settings');
    switch(value(Calibration))
      case 'speakers'
        SpeakerCalibrationFile = fullfile(SettingsDir,'SpeakerCalibration.mat');        
      case 'earphones'
        SpeakerCalibrationFile = fullfile(SettingsDir,'EarphoneCalibration.mat');
      otherwise
        SpeakerCalibrationFile = fullfile(SettingsDir,'NOFILE');        
    end
    if(exist(SpeakerCalibrationFile,'file'));
        SpeakerCalibration.value = load(SpeakerCalibrationFile);
        fprintf('Calibration data loaded from: %s\n',SpeakerCalibrationFile);
    else
        SpeakerCalibration.FrequencyVector = [1,1e5];
        SpeakerCalibration.AttenuationVector = 0.0032*[1,1]; % Around 70dB-SPL
        SpeakerCalibration.TargetSPL = 70;
        warning('No calibration file found: %s\n  sound intensity will not be accurate!',...
                SpeakerCalibrationFile),
    end
    
    
  %-----------------------------------------------------------------------------%
  case 'update_sound_this_trial'
    
    FreqFactor = 1;

    %%% Note: NextRewardSide is not used in this localization protocol
    %%%       the type of target is set by TargetSource
    NextRewardSide = varargin{1};
    srate = SoundManagerSection(obj, 'get_sample_rate');
    
    %TargetFrequencies = [value(TargetFreqL),value(TargetFreqR)];
    %ThisTrialTargetFrequency = TargetFrequencies(NextRewardSide)*FreqFactor;
    ThisTrialTargetFrequency = value(TargetFreqL)*FreqFactor;
    
    % -- Create target --
    GenericSound.Name     = 'TargetSound';
    %GenericSound.Type     = 'FM';
    GenericSound.Type     = value(TargetType);
    GenericSound.Source   = value(TargetSource);         % binaural/left/right
    GenericSound.Duration = value(TargetDuration);       % sec
    GenericSound.Volume   = value(TargetVolume);         % dB
    GenericSound.Frequency= ThisTrialTargetFrequency;    % Hz
    GenericSound.ModFrequency= 15;                       % Hz
    GenericSound.ModIndex = value(TargetModIndex);       % Around 0.01
    GenericSound.Waveform = [];
    GenericSound.Attenuation = SoundsSection(obj,'calculate_attenuation',SpeakerCalibration,...
                                             GenericSound.Frequency,GenericSound.Volume);
    TargetAttenuation.value_callback = GenericSound.Attenuation;
    TargetWaveform = SoundsSection(obj,'create_waveform',GenericSound);

    % -- Define order of distractors --
    if(~1)
    switch value(RecMode)
      case 'off'
        TonesOrder = ceil(length(value(ProbeFrequencies))*rand(1,value(NtonesPerTrial)));
      case 'tuning'
        FirstTwo = [7,7];
        TonesOrder = [FirstTwo,ceil(length(value(ProbeFrequencies))*...
                                    rand(1,value(NtonesPerTrial)-2))];
      case 'fix first three'
        FirstThree = [3,5,4];
        TonesOrder = [FirstThree,ceil(length(value(ProbeFrequencies))*...
                                    rand(1,value(NtonesPerTrial)-3))];
    end
    end
    
    % -- Define length of stimulus --
    NtonesThisTrial = ceil(value(StimulusDuration)/...
                                (value(DistractorDuration)+value(DistractorGap)));
    TonesOrder = repmat(4,1,NtonesThisTrial);
    FrequencyOrder(n_done_trials+1,1:NtonesThisTrial) = TonesOrder;
    
    
    % -- Define spatial source for each distractor --
    if strcmp(value(DistractorSource),'monaural-random');
         EachDistractorSourceThisTrial = ceil(2*rand(size(TonesOrder)));
    else
         EachDistractorSourceThisTrial = zeros(size(TonesOrder));
    end
    EachDistractorSource.values(n_done_trials+1,1:NtonesThisTrial) = EachDistractorSourceThisTrial;
        
    % -- Create distractors --
    GenericSound.Name     = 'DistractorsSound';
    %GenericSound.Type     = 'TonesTrain';
    GenericSound.Type     = value(DistractorType);
    GenericSound.Source   = value(DistractorSource);
    GenericSound.TonesSource  = EachDistractorSourceThisTrial;
    GenericSound.Duration = value(DistractorDuration);       % sec
    GenericSound.SOA = GenericSound.Duration + value(DistractorGap);      % Seconds
    GenericSound.Volume   = value(DistractorVolume);         % dB
    GenericSound.TonesFrequency= ProbeFrequencies(TonesOrder)*FreqFactor;    % Hz
    GenericSound.Waveform = [];
    GenericSound.Attenuation = SoundsSection(obj,'calculate_attenuation',SpeakerCalibration,...
                                             GenericSound.TonesFrequency,GenericSound.Volume);
    DistractorsWaveform = SoundsSection(obj,'create_waveform',GenericSound);
    
    TargetFirstIndex = round(DelayToTarget*srate);
    TargetIndexes = [TargetFirstIndex+1:TargetFirstIndex+length(TargetWaveform)];
    DistractorsWaveform(TargetIndexes,:) = 0;
        
    
    %%% NOTE: DelayToTarget in samples doesn't match exactly the time when a tone
    %         will be presented so some extra samples will remain at the end of the
    %         deleted tone (from DistractorsWaveform)
    
    SoundManagerSection(obj, 'set_sound', 'DistractorsSound', DistractorsWaveform);
    SoundManagerSection(obj, 'set_sound', 'TargetSound', TargetWaveform);
    SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');

    if(~1)
        warning('off','MATLAB:log:logOfZero');
        StimulusWaveform = sum(DistractorsWaveform,2);
        TargetFirstIndex = round(DelayToTarget*srate);
        TargetIndexes = [TargetFirstIndex+1:TargetFirstIndex+length(TargetWaveform)];
        StimulusWaveform(TargetIndexes) = StimulusWaveform(TargetIndexes) + sum(TargetWaveform,2);
        [S,F,T] = spectrogram(StimulusWaveform,hanning(2048),1024,[],srate);
        figure(10); imagesc(T,F,20*log(abs(S))); axis xy;
        ylim([0,50e3*FreqFactor])
        %figure(11); for ind=1:2, subplot(2,1,ind); plot(DistractorsWaveform(:,ind)); end
        warning('on','MATLAB:log:logOfZero');
    end

    
    
  %-----------------------------------------------------------------------------%
  case 'calculate_attenuation'
    SpeakerCalibration = varargin{1};
    SoundFrequency = varargin{2};
    SoundIntensity = varargin{3};
    % -- Find attenuation for this intensity and frequency --
    % Note that the attenuation was measured for a given peak amplitude
    % value of a sinusoidal.  The conversion to RMS values has to be done
    % if necessary (e.g. for noise).
    SoundAttenuation = zeros(size(SoundFrequency));
    for ind=1:length(SoundFrequency)
        StimInterpAtt = interp1(SpeakerCalibration.FrequencyVector,...
                                SpeakerCalibration.AttenuationVector,SoundFrequency(ind),'linear');
        if(isnan(StimInterpAtt))
            StimInterpAtt = 0.0032;
            warning(['Sound parameters (%0.1f Hz, %0.1f dB-SPL) out of range!\n',...
                     'Set to default intensity(%0.4f).'],...
                    SoundFrequency(ind),SoundIntensity,StimInterpAtt);
        end
        DiffSPL = SoundIntensity-SpeakerCalibration.TargetSPL;
        AttFactor = sqrt(10^(DiffSPL/10));
        SoundAttenuation(ind) = StimInterpAtt * AttFactor;
    end
    xpos = SoundAttenuation;

    
  %-----------------------------------------------------------------------------%
  case 'create_waveform'
    ThisSound = varargin{1};
    srate = SoundManagerSection(obj, 'get_sample_rate');
    TimeVec = (0:1/srate:ThisSound.Duration)';
    RaiseFallDuration = 0.002;
    NtonesPerChords = 7;
    ChordTonesRelativeFreqs = 1.297.^linspace(-0.5,0.5,NtonesPerChords);
    switch ThisSound.Type
      case 'Tone'
        ThisSound.Waveform = ThisSound.Attenuation * sin(2*pi*ThisSound.Frequency*TimeVec);  
        ThisSound.Waveform = apply_raisefall(ThisSound.Waveform,RaiseFallDuration,srate);
      case 'Noise'
        ThisSound.Waveform = ThisSound.Attenuation * rand(size(TimeVec));
        ThisSound.Waveform = apply_raisefall(ThisSound.Waveform,RaiseFallDuration,srate);
      case 'AM'
        SoundCarrier = sin(2*pi*ThisSound.Frequency*TimeVec);
        SoundModulatory = 1 - 0.5*ThisSound.ModDepth + ...
            0.5*ThisSound.ModDepth*sin(2*pi*ThisSound.ModFrequency*TimeVec-pi/2);
        ThisSound.Waveform = SoundCarrier.*SoundModulatory;  
        ThisSound.Waveform = ThisSound.Waveform/std(ThisSound.Waveform);
        ThisSound.Waveform = apply_raisefall(ThisSound.Waveform,RaiseFallDuration,srate);
        ThisSound.Waveform = ThisSound.Attenuation/sqrt(2) * ThisSound.Waveform;  
      case 'FM'
        SoundModulatory = ThisSound.ModIndex * ThisSound.Frequency *...
            sin(2*pi*ThisSound.ModFrequency*TimeVec);
        ThisSound.Waveform = ThisSound.Attenuation * ...
            sin(2*pi*ThisSound.Frequency*TimeVec + SoundModulatory);
        ThisSound.Waveform = apply_raisefall(ThisSound.Waveform,RaiseFallDuration,srate);
      case 'FMchord'
        FreqsThisChord = ThisSound.Frequency * ChordTonesRelativeFreqs;
        SoundModulatory = ThisSound.ModIndex *...
            sin(2*pi*ThisSound.ModFrequency*TimeVec) * FreqsThisChord;
        ThisSound.Waveform = ThisSound.Attenuation * ...
            sin(2*pi*TimeVec*FreqsThisChord + SoundModulatory);
        ThisSound.Waveform = apply_raisefall(mean(ThisSound.Waveform,2),RaiseFallDuration,srate);
      case 'OLD_TonesTrain'
        %%% DOESN'T ALLOW OVERLAPPING TONES YET %%%
        SilenceDuration = ThisSound.SOA-ThisSound.Duration;
        SilencePeriod = zeros(1,round(SilenceDuration*srate));
        ThisSound.Waveform = [];
        for indtone=1:length(ThisSound.TonesFrequency)
            ThisTone = ThisSound.Attenuation(indtone) * ...
                sin(2*pi*ThisSound.TonesFrequency(indtone)*TimeVec);
            ThisTone = apply_raisefall(ThisTone,RaiseFallDuration,srate);
            ThisSound.Waveform = [ThisSound.Waveform, ThisTone, SilencePeriod];
        end        
      case 'TonesTrain'
        %%% DOESN'T ALLOW OVERLAPPING TONES YET %%%
        GapDuration = ThisSound.SOA-ThisSound.Duration;
        Ntones = length(ThisSound.TonesFrequency);
        OneToneLength = length(TimeVec);
        OneGapLength = round(GapDuration*srate);
        WaveformLength = Ntones*(OneToneLength+OneGapLength);
        ThisSound.Waveform = zeros(WaveformLength,2);
        
        for indtone=1:length(ThisSound.TonesFrequency)
            ThisTone = ThisSound.Attenuation(indtone) * ...
                sin(2*pi*ThisSound.TonesFrequency(indtone)*TimeVec);
            ThisTone = apply_raisefall(ThisTone,RaiseFallDuration,srate);
            FirstIndexThisTone = (indtone-1)*(OneToneLength+OneGapLength);
            if(strcmp(ThisSound.Source,'monaural-random'))
                ThisSound.Waveform([FirstIndexThisTone+1:FirstIndexThisTone+OneToneLength],...
                                   ThisSound.TonesSource(indtone)) = ThisTone;
            else
                ThisSound.Waveform([FirstIndexThisTone+1:FirstIndexThisTone+OneToneLength],...
                                   :) = repmat(ThisTone,1,2);
            end
        end        
      case 'ChordsTrain'
        GapDuration = ThisSound.SOA-ThisSound.Duration;
        Ntones = length(ThisSound.TonesFrequency);
        OneToneLength = length(TimeVec);
        OneGapLength = round(GapDuration*srate);
        WaveformLength = Ntones*(OneToneLength+OneGapLength);
        ThisSound.Waveform = zeros(WaveformLength,2);
        
        for indchord=1:length(ThisSound.TonesFrequency)
            FreqsThisChord = ThisSound.TonesFrequency(indchord)*ChordTonesRelativeFreqs;
            ThisChord = ThisSound.Attenuation(indchord) * sin(2*pi*TimeVec*FreqsThisChord);
            ThisChord = apply_raisefall(mean(ThisChord,2),RaiseFallDuration,srate);
            FirstIndexThisChord = (indchord-1)*(OneToneLength+OneGapLength);
            if(strcmp(ThisSound.Source,'monaural-random'))
                ThisSound.Waveform([FirstIndexThisChord+1:FirstIndexThisChord+OneToneLength],...
                                   ThisSound.TonesSource(indchord)) = ThisChord;
            else
                ThisSound.Waveform([FirstIndexThisChord+1:FirstIndexThisChord+OneToneLength],...
                                   :) = repmat(ThisChord,1,2);
            end
        end        
      case 'Sweep'
        %%% Not finished %%%
        ThisSound.Waveform = ThisSound.Attenuation * ...
            sin(2*pi*ThisSound.Frequency*TimeVec + SoundModulatory);
        ThisSound.Waveform = apply_raisefall(ThisSound.Waveform,RaiseFallDuration,srate);
      otherwise
        error('Unknown sound type: %s',ThisSound.Type);
    end
    if(~isfield(ThisSound,'Source'))
        ThisSound.Source = 'binaural';
    end
    switch ThisSound.Source
      case 'binaural'
        ThisSound.Waveform = ThisSound.Waveform(:,1); % Only one column
      case 'left'
        ThisSound.Waveform = [ThisSound.Waveform(:),zeros(length(ThisSound.Waveform),1)];
      case 'right'
        ThisSound.Waveform = [zeros(length(ThisSound.Waveform),1),ThisSound.Waveform(:)];
      case 'monaural-random'
        % only for trains (do nothing)
      otherwise
        % do nothing
    end
    xpos = ThisSound.Waveform;
    %%% Replace with varargout %%%

    
  %-----------------------------------------------------------------------------%
  case 'reinit',
    currfig = gcf;

    % Get the original GUI position and figure:
    xpos = my_gui_info(1); ypos = my_gui_info(2); figure(my_gui_info(3));

    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);

    % Reinitialise at the original GUI position and figure:
    [xpos, ypos] = feval(mfilename, obj, 'init', xpos, ypos);

    % Restore the current figure:
    figure(currfig);

end %%% SWITCH


    
% -------------------- FUNCTION -------------------------
function SoundWaveform = apply_raisefall(SoundWaveform,RaiseFallDuration,SamplingRate)

TimeVec = (0:1/SamplingRate:RaiseFallDuration)';
RaiseVec = linspace(0,1,length(TimeVec))';

if(length(RaiseVec)<length(SoundWaveform))
    SoundWaveform(1:length(TimeVec)) = RaiseVec.*SoundWaveform(1:length(TimeVec));
    SoundWaveform(end-length(TimeVec)+1:end) = RaiseVec(end:-1:1).*SoundWaveform(end-length(TimeVec)+1:end);
else
    warning('Sound length is too short to apply raise and fall envelope');
end
return
% ----------------- END OF FUNCTION ----------------------
