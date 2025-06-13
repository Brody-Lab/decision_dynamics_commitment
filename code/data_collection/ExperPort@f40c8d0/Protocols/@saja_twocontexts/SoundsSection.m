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


function [x, y] = SoundsSection(obj, action, varargin)
   
GetSoloFunctionArgs;
%%% Imported objects (see protocol constructor):
%%%  'RelevantSide'


switch action
  case 'init',
    % Save the figure and the position in the figure where we are
    % going to start adding GUI elements:
    x = varargin{1};
    y = varargin{2};
    SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);

    % -----------------------  Sound Server -----------------------
    SoundManagerSection(obj, 'init');
    
    SoloParamHandle(obj, 'SoundStruct','value',[],'saveable',0);

    SoundDurationDefault = 0.6;                % Seconds
    SoundVolume   = 0.01;

    SoundStruct.L2.Name     = 'L2';
    SoundStruct.L2.Type     = 'AM';
    SoundStruct.L2.Duration = SoundDurationDefault;
    SoundStruct.L2.Volume   = SoundVolume;
    SoundStruct.L2.Frequency= 11000;
    SoundStruct.L2.ModFrequency= 10;    % Hz
    SoundStruct.L2.ModDepth = 0.75;     % 0-1
    SoundStruct.L2.Waveform = [];
    SoundStruct.L2.Waveform = SoundsSection(obj,'create_waveform',SoundStruct.L2);
    [x,y] = SoundsSection(obj,'make_interface',x,y,SoundStruct.L2); next_row(y,0.5);
        
    SoundStruct.L1.Name     = 'L1';
    SoundStruct.L1.Type     = 'AM';
    SoundStruct.L1.Duration = SoundDurationDefault;
    SoundStruct.L1.Volume   = SoundVolume;
    SoundStruct.L1.Frequency= 6500;
    SoundStruct.L1.ModFrequency= 10;    % Hz
    SoundStruct.L1.ModDepth = 0.75;     % 0-1
    SoundStruct.L1.Waveform = [];
    SoundStruct.L1.Waveform = SoundsSection(obj,'create_waveform',SoundStruct.L1);
    [x,y] = SoundsSection(obj,'make_interface',x,y,SoundStruct.L1); next_row(y,0.5);
    next_column(x); y = 5;

    SoundStruct.R2.Name     = 'R2';
    SoundStruct.R2.Type     = 'FM';
    SoundStruct.R2.Duration = SoundDurationDefault;% Seconds
    SoundStruct.R2.Volume   = SoundVolume;         % Arbitrary
    SoundStruct.R2.Frequency= 31000;        % Hz
    SoundStruct.R2.ModFrequency= 20/3;      % Hz
    SoundStruct.R2.ModIndex = 0.01;         % 0-1
    SoundStruct.R2.Waveform = [];
    SoundStruct.R2.Waveform = SoundsSection(obj,'create_waveform',SoundStruct.R2);
    [x,y] = SoundsSection(obj,'make_interface',x,y,SoundStruct.R2); next_row(y,0.5);
    
    SoundStruct.R1.Name     = 'R1';
    SoundStruct.R1.Type     = 'FM';
    SoundStruct.R1.Duration = SoundDurationDefault;% Seconds
    SoundStruct.R1.Volume   = SoundVolume;         % Arbitrary
    SoundStruct.R1.Frequency= 18000;        % Hz
    SoundStruct.R1.ModFrequency= 20/3;      % Hz
    SoundStruct.R1.ModIndex = 0.01;         % 0-1
    SoundStruct.R1.Waveform = [];
    SoundStruct.R1.Waveform = SoundsSection(obj,'create_waveform',SoundStruct.R1);
    [x,y] = SoundsSection(obj,'make_interface',x,y,SoundStruct.R1); next_row(y,0.5);
        
    next_row(y,0.5);
    NumeditParam(obj, 'SoundDuration', SoundDurationDefault, x,y, 'label','Duration',...
                 'TooltipString',' duration [sec]');next_row(y);
    set_callback(SoundDuration,{mfilename, 'update_duration'});
    SoloFunctionAddVars('StateMatrixSection', 'rw_args',{'SoundDuration'});

    next_row(y,0.5);
    NumeditParam(obj, 'DistractorVolume', 0.001, x,y, 'label','Distractor Vol',...
                 'TooltipString',' volume');next_row(y);
    set_callback(DistractorVolume, {'SoundsSection', 'update_all_sounds'});
    NumeditParam(obj, 'RelevantVolume', 1, x,y, 'label','Relevant Vol',...
                 'TooltipString',' volume');next_row(y);
    set_callback(RelevantVolume, {'SoundsSection', 'update_all_sounds'});

    
    %SoundManagerSection(obj, 'declare_new_sound', SoundStruct.L1.Name, SoundStruct.L1.Waveform);
    %SoundManagerSection(obj, 'declare_new_sound', SoundStruct.L2.Name, SoundStruct.L2.Waveform);
    %SoundManagerSection(obj, 'declare_new_sound', SoundStruct.R1.Name, SoundStruct.R1.Waveform);
    %SoundManagerSection(obj, 'declare_new_sound', SoundStruct.R2.Name, SoundStruct.R2.Waveform);

    SoundManagerSection(obj, 'declare_new_sound', 'L1', [0]);
    SoundManagerSection(obj, 'declare_new_sound', 'L2', [0]);
    SoundManagerSection(obj, 'declare_new_sound', 'R1', [0]);
    SoundManagerSection(obj, 'declare_new_sound', 'R2', [0]);

    SoundManagerSection(obj, 'declare_new_sound', 'SoundL1R1', [0]);
    SoundManagerSection(obj, 'declare_new_sound', 'SoundL2R1', [0]);
    SoundManagerSection(obj, 'declare_new_sound', 'SoundL1R2', [0]);
    SoundManagerSection(obj, 'declare_new_sound', 'SoundL2R2', [0]);

    % -- Make punishment noise --
    NoiseStruct.Name     = 'PunishNoise';
    NoiseStruct.Type     = 'Noise';
    NoiseStruct.Duration = 0.5;
    NoiseStruct.Volume   = 0.02;
    NoiseStruct.Waveform = SoundsSection(obj,'create_waveform',NoiseStruct);
    SoundManagerSection(obj, 'declare_new_sound', NoiseStruct.Name, NoiseStruct.Waveform);

    % -- Combine left and right stim and send to server --
    SoundsSection(obj,'combine_sounds');
    
    % -- Sound parameters graphical interface --
    if(~1)
        maxy = max(y, maxy); next_column(x); y = 5;
        [x,y]=SoundInterface(obj,'add','SoundL1',x,y); %next_row(y);
        [x,y]=SoundInterface(obj,'add','SoundL2',x,y); %next_row(y);
        maxy = max(y, maxy); next_column(x); y = 5;
        [x,y]=SoundInterface(obj,'add','SoundR1',x,y); %next_row(y);
        [x,y]=SoundInterface(obj,'add','SoundR2',x,y); %next_row(y);
                                                       %IndSound1 = SoundManagerSection(obj, 'get_sound_id', 'Sound1');
    end
    
    
  case 'update_sound'
    ThisSoundName = varargin{1};
    SoundStruct.(ThisSoundName).Duration = value(SoundDuration);
    SoundStruct.(ThisSoundName).Volume   = value(eval([ThisSoundName 'Vol']));
    SoundStruct.(ThisSoundName).Frequency= value(eval([ThisSoundName 'Freq']));
    SoundStruct.(ThisSoundName).Waveform = SoundsSection(obj,'create_waveform',SoundStruct.(ThisSoundName));

    %SoundManagerSection(obj, 'set_sound', ThisSoundName, SoundStruct.(ThisSoundName).Waveform);
    SoundsSection(obj,'update_all_sounds');

    
  case 'update_duration'
    SoundNames = {'L1','L2','R1','R2'};
    for ind=1:length(SoundNames)
        SoundStruct.(SoundNames{ind}).Duration = value(SoundDuration);
        SoundStruct.(SoundNames{ind}).Waveform = ...
            SoundsSection(obj,'create_waveform',SoundStruct.(SoundNames{ind}));
    end
    SoundsSection(obj,'update_all_sounds');

    
    
  case 'make_interface'
    x = varargin{1};
    y = varargin{2};
    ThisSound = varargin{3};
    NumeditParam(obj, [ThisSound.Name 'Freq'], ThisSound.Frequency, x,y, 'label','Frequency',...
                 'TooltipString',' frequency [Hz]');next_row(y);
    set_callback(eval([ThisSound.Name 'Freq']),{mfilename, 'update_sound', ThisSound.Name});
    %NumeditParam(obj, [ThisSound.Name 'Dur'], ThisSound.Duration, x,y, 'label','Duration',...
    %             'TooltipString',' duration [sec]');next_row(y);
    %set_callback(eval([ThisSound.Name 'Dur']),{mfilename, 'update_sound', ThisSound.Name});
    NumeditParam(obj, [ThisSound.Name 'Vol'], ThisSound.Volume, x,y, 'label','Volume',...
                 'TooltipString',' volume [0-1]');next_row(y);
    set_callback(eval([ThisSound.Name 'Vol']),{mfilename, 'update_sound', ThisSound.Name});
    SubheaderParam(obj, [ThisSound.Name 'Head'],...
                   sprintf('%s (%s)',ThisSound.Name,ThisSound.Type), x,y);
    PushbuttonParam(obj, [ThisSound.Name 'Play'], x,y, 'label', 'Play', 'position', [x y 30 20]);
    set_callback(eval([ThisSound.Name 'Play']),{'SoundManagerSection', 'play_sound', ThisSound.Name});
    PushbuttonParam(obj, [ThisSound.Name 'Stop'], x,y, 'label', 'Stop', 'position', [x+30 y 30 20]);
    set_callback(eval([ThisSound.Name 'Stop']),{'SoundManagerSection', 'stop_sound', ThisSound.Name});
    next_row(y);
    

  case 'create_waveform'
    ThisSound = varargin{1};
    srate = SoundManagerSection(obj, 'get_sample_rate');
    TimeVec = (0:1/srate:ThisSound.Duration);
    switch ThisSound.Type
      case 'Tone'
        ThisSound.Waveform = ThisSound.Volume * sin(2*pi*ThisSound.Frequency*TimeVec);  
      case 'Noise'
        ThisSound.Waveform = ThisSound.Volume * rand(1,length(TimeVec));
      case 'AM'
        SoundCarrier = sin(2*pi*ThisSound.Frequency*TimeVec);
        SoundModulatory = 1 - 0.5*ThisSound.ModDepth + ...
            0.5*ThisSound.ModDepth*sin(2*pi*ThisSound.ModFrequency*TimeVec-pi/2);
        ThisSound.Waveform = SoundCarrier.*SoundModulatory;  
        ThisSound.Waveform = ThisSound.Waveform/std(ThisSound.Waveform);
        ThisSound.Waveform = ThisSound.Volume * ThisSound.Waveform;  
      case 'FM'
        SoundModulatory = ThisSound.ModIndex * ThisSound.Frequency *...
            sin(2*pi*ThisSound.ModFrequency*TimeVec);
        ThisSound.Waveform = ThisSound.Volume * ...
            sin(2*pi*ThisSound.Frequency*TimeVec + SoundModulatory);
      otherwise
        error('Unknown sound type: %s',ThisSound.Type);
    end
    x = ThisSound.Waveform;
    %%% Replace with varargout %%%
    
    
  case 'combine_sounds'
    if(strcmp(value(RelevantSide),'left'))
        LeftVolume  = value(RelevantVolume);
        RightVolume = value(DistractorVolume);
    else
        RightVolume = value(RelevantVolume);
        LeftVolume  = value(DistractorVolume);
    end
    SoundL1R1wave = [LeftVolume*SoundStruct.L1.Waveform(:),RightVolume*SoundStruct.R1.Waveform(:)];
    SoundL2R1wave = [LeftVolume*SoundStruct.L2.Waveform(:),RightVolume*SoundStruct.R1.Waveform(:)];
    SoundL1R2wave = [LeftVolume*SoundStruct.L1.Waveform(:),RightVolume*SoundStruct.R2.Waveform(:)];
    SoundL2R2wave = [LeftVolume*SoundStruct.L2.Waveform(:),RightVolume*SoundStruct.R2.Waveform(:)];

    SoundManagerSection(obj, 'set_sound', 'SoundL1R1', SoundL1R1wave);
    SoundManagerSection(obj, 'set_sound', 'SoundL2R1', SoundL2R1wave);
    SoundManagerSection(obj, 'set_sound', 'SoundL1R2', SoundL1R2wave);
    SoundManagerSection(obj, 'set_sound', 'SoundL2R2', SoundL2R2wave);
    
    % -- Send also the sounds alone (not combined) --
    SoundL1wave = [LeftVolume*SoundStruct.L1.Waveform(:),0*SoundStruct.R1.Waveform(:)];
    SoundL2wave = [LeftVolume*SoundStruct.L2.Waveform(:),0*SoundStruct.R2.Waveform(:)];
    SoundR1wave = [0*SoundStruct.L1.Waveform(:),RightVolume*SoundStruct.R1.Waveform(:)];
    SoundR2wave = [0*SoundStruct.L2.Waveform(:),RightVolume*SoundStruct.R2.Waveform(:)];

    SoundManagerSection(obj, 'set_sound', 'L1', SoundL1wave);
    SoundManagerSection(obj, 'set_sound', 'L2', SoundL2wave);
    SoundManagerSection(obj, 'set_sound', 'R1', SoundR1wave);
    SoundManagerSection(obj, 'set_sound', 'R2', SoundR2wave);
    
    SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
   
  case 'update_all_sounds'
    SoundsSection(obj,'combine_sounds');
    %StateMatrixSection(obj,'update');  %%% Doesn't work. Weird behavior.
    
  case 'reinit',
    currfig = gcf;

    % Get the original GUI position and figure:
    x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));

    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);

    % Reinitialise at the original GUI position and figure:
    [x, y] = feval(mfilename, obj, 'init', x, y);

    % Restore the current figure:
    figure(currfig);
end;


