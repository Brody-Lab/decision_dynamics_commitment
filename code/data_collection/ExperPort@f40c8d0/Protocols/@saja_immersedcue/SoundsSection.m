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

%%% BUGS:
%
% [2007.10.04] If the duration of sound is changed, the State Matrix is not
% updated but the sound duration is.  This is a problem if Duration is changed
% from large value to a small one, since there will still be punishment after
% the sound off-set.  Updating the matrix on update_sounds didn't work.


function [xpos, ypos] = SoundsSection(obj, action, varargin)
   
GetSoloFunctionArgs;
%%% Imported objects (see protocol constructor):
%%%  'RelevantSide'
global Solo_rootdir;


switch action
  case 'init',
    % Save the figure and the position in the figure where we are
    % going to start adding GUI elements:
    xpos = varargin{1};
    ypos = varargin{2};
    SoloParamHandle(obj, 'my_gui_info', 'value', [xpos ypos gcf]);

    % ----------------- Speaker calibration data ------------------
    SettingsDir = fullfile(Solo_rootdir,'Settings');
    SoloParamHandle(obj, 'SpeakerCalibration','value',[],'saveable',0);
    SpeakerCalibrationFile = fullfile(SettingsDir,'SpeakerCalibration.mat');
    if(exist(SpeakerCalibrationFile,'file'));
        SpeakerCalibration.value = load(SpeakerCalibrationFile);
    else
        SpeakerCalibration.FrequencyVector = [1,1e5];
        SpeakerCalibration.AttenuationVector = 0.0032*[1,1]; % Around 70dB-SPL
        SpeakerCalibration.TargetSPL = 70;
        warning('No calibration file found: %s\n  sound intensity will not be accurate!',...
                SpeakerCalibrationFile),
    end
    
    % -----------------------  Sound Server -----------------------
    SoundManagerSection(obj, 'init');
    
    SoloParamHandle(obj, 'SoundStruct','value',[],'saveable',0);

    SoundDurationDefault = 1.1;                % Seconds
    SoundVolume   = 75;                 % dB-SPL

    SoundStruct.L2.Name     = 'L2';
    SoundStruct.L2.Type     = 'FM';
    SoundStruct.L2.Duration = SoundDurationDefault;% Seconds
    SoundStruct.L2.Volume   = SoundVolume;         % dB-SPL
    SoundStruct.L2.Attenuation = 0;         % 0-1
    SoundStruct.L2.Frequency= 11000;        % Hz
    SoundStruct.L2.ModFrequency= 20/3;      % Hz
    SoundStruct.L2.ModIndex = 0.01;         % 0-1
    SoundStruct.L2.Waveform = [];
    SoundStruct.L2.Attenuation = SoundsSection(obj,'calculate_attenuation',SpeakerCalibration,...
                                               SoundStruct.L2.Frequency,SoundStruct.L2.Volume);
    SoundStruct.L2.Waveform = SoundsSection(obj,'create_waveform',SoundStruct.L2);
    [xpos,ypos] = SoundsSection(obj,'make_interface',xpos,ypos,SoundStruct.L2); next_row(ypos,0.5);
    
    SoundStruct.L1.Name     = 'L1';
    SoundStruct.L1.Type     = 'FM';
    SoundStruct.L1.Duration = SoundDurationDefault;% Seconds
    SoundStruct.L1.Volume   = SoundVolume;         % dB-SPL
    SoundStruct.L1.Attenuation = 0;         % 0-1
    SoundStruct.L1.Frequency= 6500;        % Hz
    SoundStruct.L1.ModFrequency= 20/3;      % Hz
    SoundStruct.L1.ModIndex = 0.01;         % 0-1
    SoundStruct.L1.Waveform = [];
    SoundStruct.L1.Attenuation = SoundsSection(obj,'calculate_attenuation',SpeakerCalibration,...
                                               SoundStruct.L1.Frequency,SoundStruct.L1.Volume);
    SoundStruct.L1.Waveform = SoundsSection(obj,'create_waveform',SoundStruct.L1);
    [xpos,ypos] = SoundsSection(obj,'make_interface',xpos,ypos,SoundStruct.L1); next_row(ypos,0.5);
    next_column(xpos); ypos = 5;
        
    SoundStruct.R2.Name     = 'R2';
    SoundStruct.R2.Type     = 'FM';
    SoundStruct.R2.Duration = SoundDurationDefault;% Seconds
    SoundStruct.R2.Volume   = SoundVolume;         % dB-SPL
    SoundStruct.R2.Attenuation = 0;         % 0-1
    SoundStruct.R2.Frequency= 31000;        % Hz
    SoundStruct.R2.ModFrequency= 20/3;      % Hz
    SoundStruct.R2.ModIndex = 0.01;         % 0-1
    SoundStruct.R2.Waveform = [];
    SoundStruct.R2.Attenuation = SoundsSection(obj,'calculate_attenuation',SpeakerCalibration,...
                                               SoundStruct.R2.Frequency,SoundStruct.R2.Volume);
    %SoundStruct.R2.Attenuation = SoundsSection(obj,'calculate_attenuation',SoundStruct.R2);
    SoundStruct.R2.Waveform = SoundsSection(obj,'create_waveform',SoundStruct.R2);
    %[SoundStruct.R2.Waveform, SoundStruct.R2.Attenuation] = ...
    %    SoundsSection(obj,'create_waveform',SoundStruct.R2);
    [xpos,ypos] = SoundsSection(obj,'make_interface',xpos,ypos,SoundStruct.R2); next_row(ypos,0.5);
    
    SoundStruct.R1.Name     = 'R1';
    SoundStruct.R1.Type     = 'FM';
    SoundStruct.R1.Duration = SoundDurationDefault;% Seconds
    SoundStruct.R1.Volume   = SoundVolume;         % dB-SPL
    SoundStruct.R1.Attenuation = 0;         % 0-1
    SoundStruct.R1.Frequency= 18400;        % Hz
    SoundStruct.R1.ModFrequency= 20/3;      % Hz
    SoundStruct.R1.ModIndex = 0.01;         % 0-1
    SoundStruct.R1.Waveform = [];
    SoundStruct.R1.Attenuation = SoundsSection(obj,'calculate_attenuation',SpeakerCalibration,...
                                               SoundStruct.R1.Frequency,SoundStruct.R1.Volume);
    SoundStruct.R1.Waveform = SoundsSection(obj,'create_waveform',SoundStruct.R1);
    [xpos,ypos] = SoundsSection(obj,'make_interface',xpos,ypos,SoundStruct.R1); next_row(ypos,0.5);
        
    % --- Probe and Cue volume and durations ---
    next_row(ypos,0.5);
    NumeditParam(obj, 'ProbeDuration', 0.2, xpos,ypos, 'label','Probe duration',...
                 'TooltipString',' duration [sec]');next_row(ypos);
    %set_callback(ProbeDuration,{mfilename, 'update_probeduration'});
    set(get_ghandle(ProbeDuration),'Enable','off');
    SoloFunctionAddVars('StateMatrixSection', 'rw_args',{'ProbeDuration'});
    NumeditParam(obj, 'ProbeVolume', 65, xpos,ypos, 'label','Probe (dB-SPL)',...
                 'TooltipString',' volume');next_row(ypos);
    %set_callback(ProbeVolume, {'SoundsSection', 'update_all_sounds'});
    %set(get_ghandle(ProbeVolume),'Enable','off');

    next_row(ypos,0.5);
    NumeditParam(obj, 'TargetDuration', 0.2, xpos,ypos, 'label','Target duration',...
                 'TooltipString',' duration [sec]');next_row(ypos);
    %set_callback(TargetDuration,{mfilename, 'update_duration'});
    set(get_ghandle(TargetDuration),'Enable','off');
    SoloFunctionAddVars('StateMatrixSection', 'rw_args',{'TargetDuration'});
    NumeditParam(obj, 'TargetVolume', 75, xpos,ypos, 'label','Target (dB-SPL)',...
                 'TooltipString',' volume');next_row(ypos);
    %set_callback(TargetVolume, {'SoundsSection', 'update_volumes'});

    SoundManagerSection(obj, 'declare_new_sound', 'L1', [0]);
    SoundManagerSection(obj, 'declare_new_sound', 'L2', [0]);
    SoundManagerSection(obj, 'declare_new_sound', 'R1', [0]);
    SoundManagerSection(obj, 'declare_new_sound', 'R2', [0]);

    % -- Make punishment noise --
    NoiseStruct.Name     = 'PunishNoise';
    NoiseStruct.Type     = 'Noise';
    NoiseStruct.Duration = 0.5;
    NoiseStruct.Attenuation   = 0.02;
    NoiseStruct.Waveform = SoundsSection(obj,'create_waveform',NoiseStruct);
    SoundManagerSection(obj, 'declare_new_sound', NoiseStruct.Name, NoiseStruct.Waveform);

    % -- Make probe sound --
    NprobeFreqs = 6;
    ProbeOrder = [3,5,1,6,4,2];%randperm(NprobeFreqs);
    ProbeFrequencies = logspace(log10(6500),log10(31000),NprobeFreqs);
    ProbeStruct.Name     = 'ProbeSound';
    ProbeStruct.Type     = 'TonesTrain';
    ProbeStruct.Duration = 0.05;
    ProbeStruct.SilenceDuration = 0.100;          % Seconds
    ProbeStruct.Volume   = value(ProbeVolume);                    % dB-SPL
    ProbeStruct.TonesFrequency = ProbeFrequencies(ProbeOrder);        % Hz
    ProbeStruct.Attenuation = SoundsSection(obj,'calculate_attenuation',SpeakerCalibration,...
                                               ProbeStruct.TonesFrequency,ProbeStruct.Volume);
    ProbeStruct.Waveform = SoundsSection(obj,'create_waveform',ProbeStruct);
    SoundManagerSection(obj, 'declare_new_sound', ProbeStruct.Name, ProbeStruct.Waveform);

    % -- Combine left and right stim and send to server --
    %SoundsSection(obj,'combine_sounds');
    
    % -- Upload sounds --
    SoundsSection(obj,'update_all_sounds');
    
    % -- Sound parameters graphical interface --
    if(~1)
        maxy = max(ypos, maxy); next_column(xpos); ypos = 5;
        [xpos,ypos]=SoundInterface(obj,'add','SoundL1',xpos,ypos); %next_row(ypos);
        [xpos,ypos]=SoundInterface(obj,'add','SoundL2',xpos,ypos); %next_row(ypos);
        maxy = max(ypos, maxy); next_column(xpos); ypos = 5;
        [xpos,ypos]=SoundInterface(obj,'add','SoundR1',xpos,ypos); %next_row(ypos);
        [xpos,ypos]=SoundInterface(obj,'add','SoundR2',xpos,ypos); %next_row(ypos);
                                                       %IndSound1 = SoundManagerSection(obj, 'get_sound_id', 'Sound1');
    end
    
    
  case 'update_sound'
    ThisSoundName = varargin{1};
    SoundStruct.(ThisSoundName).Duration = value(TargetDuration);
    SoundStruct.(ThisSoundName).Volume   = value(eval([ThisSoundName 'Vol']));
    SoundStruct.(ThisSoundName).Frequency= value(eval([ThisSoundName 'Freq']));
    SoundStruct.(ThisSoundName).Attenuation = SoundsSection(obj,'calculate_attenuation',...
                                                      SpeakerCalibration,...
                                                      SoundStruct.(ThisSoundName).Frequency,...
                                                      SoundStruct.(ThisSoundName).Volume);
    %-- Bad Solo programming, it shouldn't use get_sphandle! --%
    AttenuationGUI = get_sphandle('name',[SoundStruct.(ThisSoundName).Name,'Attenuation']);
    AttenuationGUI{1}.value_callback = SoundStruct.(ThisSoundName).Attenuation;
    SoundStruct.(ThisSoundName).Waveform = SoundsSection(obj,'create_waveform',SoundStruct.(ThisSoundName));

    %SoundManagerSection(obj, 'set_sound', ThisSoundName, SoundStruct.(ThisSoundName).Waveform);
    SoundsSection(obj,'update_all_sounds');
    
    
  case 'update_duration'
    SoundNames = {'L1','L2','R1','R2'};
    for ind=1:length(SoundNames)
        SoundStruct.(SoundNames{ind}).Duration = value(TargetDuration);
        SoundStruct.(SoundNames{ind}).Waveform = ...
            SoundsSection(obj,'create_waveform',SoundStruct.(SoundNames{ind}));
    end
    SoundsSection(obj,'update_all_sounds');

    
  case 'update_volumes'
    SoundNames = {'L1','L2','R1','R2'};
    for ind=1:length(SoundNames)
        SoundStruct.(SoundNames{ind}).Volume = value(TargetVolume);
        %SoundStruct.(SoundNames{ind}).Waveform = ...
        %    SoundsSection(obj,'create_waveform',SoundStruct.(SoundNames{ind}));
    end
    %SoundsSection(obj,'update_all_sounds');

    
    
  case 'make_interface'
    xpos = varargin{1};
    ypos = varargin{2};
    ThisSound = varargin{3};
    NumeditParam(obj, [ThisSound.Name 'Freq'], ThisSound.Frequency, xpos,ypos, 'label','Frequency',...
                 'TooltipString',' frequency [Hz]');next_row(ypos);
    %%%set_callback(eval([ThisSound.Name 'Freq']),{mfilename, 'update_sound', ThisSound.Name});
    %NumeditParam(obj, [ThisSound.Name 'Dur'], ThisSound.Duration, xpos,ypos, 'label','Duration',...
    %             'TooltipString',' duration [sec]');next_row(ypos);
    %set_callback(eval([ThisSound.Name 'Dur']),{mfilename, 'update_sound', ThisSound.Name});
    NumeditParam(obj, [ThisSound.Name 'Vol'], ThisSound.Volume, xpos,ypos, 'label','dB-SPL',...
                 'TooltipString',' volume [60-85 dB-SPL]','position',[xpos,ypos,100,20]);
    %%%set_callback(eval([ThisSound.Name 'Vol']),{mfilename, 'update_sound', ThisSound.Name});
    NumeditParam(obj, [ThisSound.Name 'Attenuation'], ThisSound.Attenuation, xpos,ypos, 'label','Att',...
                 'TooltipString','Attenuation [0-1]','position',[xpos+100,ypos,100,20]);
    set(get_ghandle(eval([ThisSound.Name 'Attenuation'])),'Enable','off');
    next_row(ypos);
    SubheaderParam(obj, [ThisSound.Name 'Head'],...
                   sprintf('%s (%s)',ThisSound.Name,ThisSound.Type), xpos,ypos);
    PushbuttonParam(obj, [ThisSound.Name 'Play'], xpos,ypos, 'label', 'Play', 'position', [xpos ypos 30 20]);
    set_callback(eval([ThisSound.Name 'Play']),{'SoundManagerSection', 'play_sound', ThisSound.Name});
    PushbuttonParam(obj, [ThisSound.Name 'Stop'], xpos,ypos, 'label', 'Stop', 'position', [xpos+30 ypos 30 20]);
    set_callback(eval([ThisSound.Name 'Stop']),{'SoundManagerSection', 'stop_sound', ThisSound.Name});
    next_row(ypos);
    
  
  case 'calculate_attenuation'
    SpeakerCalibration = varargin{1};
    SoundFrequency = varargin{2};
    SoundIntensity = varargin{3};
    % -- Find attenuation for this intensity and frequency --
    % Note that the attenuation was measured for peak values. The conversion
    % to RMS values has to be done if necessary (e.g. for noise).
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
    

  case 'create_waveform'
    ThisSound = varargin{1};
    srate = SoundManagerSection(obj, 'get_sample_rate');
    TimeVec = (0:1/srate:ThisSound.Duration);
    RaiseFallDuration = 0.002;
    switch ThisSound.Type
      case 'Tone'
        ThisSound.Waveform = ThisSound.Attenuation * sin(2*pi*ThisSound.Frequency*TimeVec);  
        ThisSound.Waveform = apply_raisefall(ThisSound.Waveform,RaiseFallDuration,srate);
      case 'Noise'
        ThisSound.Waveform = ThisSound.Attenuation * rand(1,length(TimeVec));
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
      case 'TonesTrain'
        SilencePeriod = zeros(1,round(ThisSound.SilenceDuration*srate));
        ThisSound.Waveform = [];
        for indtone=1:length(ThisSound.TonesFrequency)
            ThisTone = ThisSound.Attenuation(indtone) * ...
                sin(2*pi*ThisSound.TonesFrequency(indtone)*TimeVec);
            ThisTone = apply_raisefall(ThisTone,RaiseFallDuration,srate);
            ThisSound.Waveform = [ThisSound.Waveform, ThisTone, SilencePeriod];
        end        
      case 'Sweep'
        %%% Not finished %%%
        ThisSound.Waveform = ThisSound.Attenuation * ...
            sin(2*pi*ThisSound.Frequency*TimeVec + SoundModulatory);
        ThisSound.Waveform = apply_raisefall(ThisSound.Waveform,RaiseFallDuration,srate);
      otherwise
        error('Unknown sound type: %s',ThisSound.Type);
    end
    xpos = ThisSound.Waveform;
    %%% Replace with varargout %%%

    
  case 'update_all_sounds'
    SoundManagerSection(obj, 'set_sound', 'L1', SoundStruct.L1.Waveform(:));
    SoundManagerSection(obj, 'set_sound', 'L2', SoundStruct.L2.Waveform(:));
    SoundManagerSection(obj, 'set_sound', 'R1', SoundStruct.R1.Waveform(:));
    SoundManagerSection(obj, 'set_sound', 'R2', SoundStruct.R2.Waveform(:));
    
    SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
    
    
    
    
  case 'update_sound_this_trial'
    IndSoundThisTrial = varargin{1};
    srate = SoundManagerSection(obj, 'get_sample_rate');
   
    GenericSound.Name     = 'GenericSound';
    GenericSound.Type     = 'Tone';
    GenericSound.Duration = 0.200;          % Seconds
    GenericSound.Volume   = value(TargetVolume);         % 0-1
    GenericSound.Frequency= 14000;        % Hz
    GenericSound.ModFrequency= 10;%20/3;        % Hz
    GenericSound.ModIndex = 0.02;         % ???
    GenericSound.Waveform = [];

    FreqFactor = 1;
    FreqVec = logspace(log10(5010/FreqFactor),log10(40200/FreqFactor),9)';
    %FreqVec = logspace(log10(6500/FreqFactor),log10(31000/FreqFactor),7)';
    Nfreq = length(FreqVec);

    TargetFreq = [6500,11000,18400,31000]/FreqFactor;
    TargetFreqInd=[];
    for indf=1:length(TargetFreq)
        [tempmin,TargetFreqInd(indf)] = min(abs(TargetFreq(indf)-FreqVec));
    end

    % -- Repeat blocks of probes (double or triple size of FreqVec) --
    Nprobeblocks = 3;
    FreqVec = repmat(FreqVec,Nprobeblocks,1);
    TargetFreqInd = TargetFreqInd+(Nprobeblocks-1)*Nfreq;
    Nfreq = Nprobeblocks*Nfreq;
    
    DelayToNextTone = 0.06667;
    PossibleOnsets = floor([0:Nfreq-1]*DelayToNextTone*srate + 1);
    TonesOnset = [];
    for indb=1:Nprobeblocks
        %TonesOnset = [PossibleOnsets(randperm(Nfreq/2)), PossibleOnsets(randperm(Nfreq/2)+Nfreq/2)];
        FirstIndex = (indb-1)*(Nfreq/Nprobeblocks);
        TonesOnset = [TonesOnset,PossibleOnsets(randperm(Nfreq/Nprobeblocks)+FirstIndex)];
    end
    
    TimeVecEachTone = (0:1/srate:GenericSound.Duration);
    EachToneWaveform = zeros(Nfreq,length(TimeVecEachTone));

    ThisSound.Duration = DelayToNextTone*Nfreq+(GenericSound.Duration-DelayToNextTone);
    TimeVec = (0:1/srate:ThisSound.Duration);
    ProbeWaveform = zeros(size(TimeVec));

    TargetThisTrial = IndSoundThisTrial;
    
    
    % --- Generate target ---
    GenericSound.Frequency= FreqVec(TargetFreqInd(TargetThisTrial));
    GenericSound.Volume   = value(TargetVolume);         % dB-SPL
    GenericSound.Type     = 'FM';
    GenericSound.Attenuation = SoundsSection(obj,'calculate_attenuation',SpeakerCalibration,...
                                             GenericSound.Frequency,GenericSound.Volume);
    TargetWaveform = SoundsSection(obj,'create_waveform',GenericSound);
    
    % -- Send to Sound Server --
    SoundLabels = {'L1','L2','R1','R2'};
    SoundManagerSection(obj, 'set_sound', SoundLabels{IndSoundThisTrial}, TargetWaveform);
    
    
    % --- Generate probe ---
    for ind=1:Nfreq
        GenericSound.Frequency= FreqVec(ind);
        if ind==TargetFreqInd(TargetThisTrial) % Make it a warble/FM
            %GenericSound.Attenuation   = 0.2;         % 0-1
            %GenericSound.Volume   = value(TargetVolume);         % dB-SPL
            GenericSound.Volume   = -60;         % dB-SPL
            GenericSound.Type     = 'FM';
            TargetOnsetTime = (TonesOnset(ind)-1)/srate; % In seconds
        else 
            %GenericSound.Attenuation   = 0.05;         % 0-1
            GenericSound.Volume   = value(ProbeVolume);         % dB-SPL
            GenericSound.Type     = 'Tone';
        end
        GenericSound.Attenuation = SoundsSection(obj,'calculate_attenuation',SpeakerCalibration,...
                                               GenericSound.Frequency,GenericSound.Volume);
        EachToneWaveform(ind,:) = SoundsSection(obj,'create_waveform',GenericSound);
        ThisRange = [TonesOnset(ind):TonesOnset(ind)+length(TimeVecEachTone)-1];
        
        ProbeWaveform(ThisRange) = ProbeWaveform(ThisRange)+EachToneWaveform(ind,:);
    end

    SoundManagerSection(obj, 'set_sound', 'ProbeSound', ProbeWaveform);
    SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
    xpos = TargetOnsetTime;
    ypos = ThisSound.Duration;
    
    %%% plot stimulus %%%
    %figure(10); plot(TimeVec,ProbeWaveform);
    %[S,F,T] = spectrogram(ProbeWaveform,hanning(2048),1024,[],srate);
    %figure(11); imagesc(T,F,20*log(abs(S))); axis xy;
    %fprintf('Sound duration: %0.4f\n',TimeVec(end));
    
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
end;


% -------------------- FUNCTION -------------------------
function SoundWaveform = apply_raisefall(SoundWaveform,RaiseFallDuration,SamplingRate)

TimeVec = (0:1/SamplingRate:RaiseFallDuration);
RaiseVec = linspace(0,1,length(TimeVec));

if(length(RaiseVec)<length(SoundWaveform))
    SoundWaveform(1:length(TimeVec)) = RaiseVec.*SoundWaveform(1:length(TimeVec));
    SoundWaveform(end-length(TimeVec)+1:end) = RaiseVec(end:-1:1).*SoundWaveform(end-length(TimeVec)+1:end);
else
    warning('Sound length is too short to apply raise and fall envelope');
end
return
% ----------------- END OF FUNCTION ----------------------
