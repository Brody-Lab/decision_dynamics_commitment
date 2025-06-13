function [x, y] = SoundSection(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action
    
    %---------------------------------------------------------------%
    %          init                                                 %
    %---------------------------------------------------------------%
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

        SoloParamHandle(obj, 'myfig', 'value', double(figure('Position', [100 100 560 440], ...
          'closerequestfcn', [mfilename '(' class(obj) ', ''hide'');'], 'MenuBar', 'none', ...
          'Name', mfilename)), 'saveable', 0);
        set(gcf, 'Visible', 'off');
        x=10;y=10;
    
        [x,y]=SoundInterface(obj,'add','ViolationSound',x,y,'Volume',0.001,'Freq',9000,'Duration',0.05); 
        [x,y]=SoundInterface(obj,'add','ErrorSound',x,y,'Style','WhiteNoise','Volume',0.001);
        [x,y]=SoundInterface(obj,'add','TimeoutSound',x,y,'Style','WhiteNoise','Volume',0.001,'Duration',0.5);
        next_column(x);
        y=10;
        [x,y]=SoundInterface(obj,'add','GoSound',x,y,'Style','Tone','Volume',0.001,'Freq',3000,'Duration',0.2);
        [x,y]=SoundInterface(obj,'add','RewardSound',x,y,'Style','Bups','Volume',.005,'Freq',5,'Duration',1.5);
        [x,y]=SoundInterface(obj,'add','SOneSound',x,y,'Style','WhiteNoise','Volume',0.001);
        [x,y]=SoundInterface(obj,'add','STwoSound',x,y,'Style','WhiteNoise','Volume',0.001);

        % ASKCHUCK added this to replace init case in PWMsma
        %     srate=SoundManagerSection(obj,'get_sample_rate');
        %     freq1=5;
        %     dur1=1.5*1000;
        %     Vol=1;
        %     tw=Vol*(MakeBupperSwoop(srate,0, freq1 , freq1 , dur1/2 , dur1/2,0,0.1));
        %     SoundManagerSection(obj, 'declare_new_sound', 'LRewardSound', [tw ; zeros(1, length(tw))])
        %     SoundManagerSection(obj, 'declare_new_sound', 'RRewardSound', [zeros(1, length(tw));tw])
        %     SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
            
        %TODO add pink noise to Sound Interface thing so I can call everything in
        %one place
        x=oldx; y=oldy;
        figure(parentfig);

    
    %---------------------------------------------------------------%
    %          hide / show / show_hide / close                      %
    %---------------------------------------------------------------%
    case 'hide',
        SoundsShow.value = 0; set(value(myfig), 'Visible', 'off');

    case 'show',
        SoundsShow.value = 1; set(value(myfig), 'Visible', 'on');

    case 'show_hide',
        if SoundsShow == 1, set(value(myfig), 'Visible', 'on'); %#ok<NODEF> (defined by GetSoloFunctionArgs)
        else                set(value(myfig), 'Visible', 'off');
        end;
        
    case 'close'
        % Delete all SoloParamHandles who belong to this object and whose
        % fullname starts with the name of this mfile:
        delete_sphandle('owner', ['^@' class(obj) '$'], ...
          'fullname', ['^' mfilename]);

end
    