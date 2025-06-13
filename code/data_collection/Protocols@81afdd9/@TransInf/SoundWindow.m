

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
        [x,y]=SoundInterface(obj,'add','ViolationSound',x,y,'Style','WhiteNoise','Volume', 0.04);
        [x,y]=SoundInterface(obj,'add','ErrorSound',x,y,'Style','Tone','Volume',0.03, 'Freq', 750);
        [x,y]=SoundInterface(obj,'add','TimeoutSound',x,y,'Style','WhiteNoise','Volume',0.06);
        next_column(x);
        y=10;
        [x,y]=SoundInterface(obj,'add','NICSound',x,y,'Style','ToneFMWiggle','Volume',0.03);
        [x,y]=SoundInterface(obj,'add','HitSound',x,y,'Style','Tone','Volume',0.02, 'Freq', 1500, 'Duration', 0.1);
        [x,y]=SoundInterface(obj,'add','GoSound',x,y,'Style','Tone', 'Volume', 0.01,'Freq', 2000, 'Duration', 0.2);
        
         sdur=0.4;
        [x,y]=SoundInterface(obj, 'add','ToneSound',x,y,'Style','Tone', 'Volume', 0.01, 'Freq', 2500, 'Duration', sdur);
        
        SoundInterface(obj, 'set','NICSound','Style','ToneSweep', 'Vol', 0.02, 'Dur1', sdur,...
            'Dur2', sdur, 'Freq1', 500,'Freq2', 5000);

        SoundInterface(obj, 'set','ErrorSound','Style','ToneFMWiggle', 'Vol', 0.015, 'Dur1', sdur,...
            'FMfreq',5,'FMamp',200, 'Freq1', 2500);
        SoundInterface(obj, 'set','GoSound','Style','AMTone', 'Vol', 0.015, 'Dur1', sdur,...
            'Freq1', 1000,'FMFreq',50,'FMAmp',200);
        SoundInterface(obj, 'set','TimeoutSound','Style','ToneSweep', 'Vol', 0.02, 'Dur1', sdur,...
            'Dur2', sdur, 'Freq1', 5000,'Freq2', 500);
        
        %according to the brody lab wiki documentation
        %looping is not supported by emulator, but should work on a rig.
        %see:
        %http://brodywiki.princeton.edu/bcontrol/index.php/Plugins-soundmanager
        %actualy it seems like you need to set this in the sound window
        
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
