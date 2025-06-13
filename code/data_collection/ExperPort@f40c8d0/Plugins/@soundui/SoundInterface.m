% varargout = SoundInterface(obj, action, sname, x,y,varargin)
% varargin{end-2}=x; varargin
%
%  actions:
%
%  add		name
%           returns [x,y]
%           This adds a bunch of sound related vars....
%  close	cleanup
%
% Sound Parameters:
%  Volume   0<Vol<1
%  Balance  -1<Bal<1     Balance 0 means play both sounds at vol.
%                        Balance <0 plays left at vol, and right at
%                           vol*(1+bal)
%                        Balance >0 plays right at vol, and left at
%                           vol*(1-bal)
%  Duration     seconds
%  Frequency    Hz
%
%
% 'set' soundname   'Vol'|'Bal'|'Freq1'|'Freq2'|'FMFreq'| ...
%                  'FMAmp'|'Style'|'Dur1'|'Dur2'|'Tau'|'Gap'|'Loop'   value
%
%               The 'set' action allows setting the parameters for any of
%               the sounds that have been created. The next argument
%               after 'set' must be a string, the name of the sound
%               that was created with 'add'; the next argument must also be
%               a string, as listed above; and the last argument should be
%               the value the corresponding setting will be changed to.
%               Example calls:
%                     SoundInterface(obj, 'set', 'myvar', 'Style', 'ToneFMWiggle');
%                 or
%                     SoundInterface(obj, 'set', 'myvar', 'Dur1', 0.5, 'Dur2', 1.5);
%               For comments on what the different settings are, see action='add'
%               above.
%
% 'get' soundname   'Vol'|'Bal'|'Freq1'|'Freq2'|'FMFreq'| ...
%                  'FMAmp'|'Style'|'Dur1'|'Dur2'|'Tau'|'Gap'|'Loop'|'total_duration'
%
%               The 'get' action returns the setting of the parameters for any of
%               the sounds that have been created. The next argument
%               after 'get' must be a string, the name of the distribution
%               that was created with 'add'; the next argument must also be
%               a string, as listed above.
%               Example call:
%                     mysndstyle = SoundInterface(obj, 'get', 'mysnd', 'Style')
%               A special case is 'get' 'total_duration', which returns a
%               value that depends on the Style. For style=Tone, Bups,
%               ToneFMWiggle, WhiteNoise, and WhiteNoiseRamp, Dur1 gets
%               returned. For style=ToneSweep or BupsSweep Dur1+Gap+Dur2 is
%               returned.
%
% 'disable' soundname   'Style'|'Vol'|'Bal'|'Freq1'|'Freq2'|'FMFreq'| ...
%                       'FMAmp'|'Style'|'Dur1'|'Dur2'|'Tau'|'Gap'|'Loop'
%
%               Disables the GUI for the SoloParamHandle given by the final
%               argument, to prevent the GUI user from changing it.
%               ** USE WITH CARE **  There is no guarantee that the inner
%               code of this section won't change one day and different
%               SoloParamHandles will be used, rendering the diabling of a
%               particular one a void action. So: use 'disable' with care.
%
% 'enable' soundname   'Style'|'Vol'|'Bal'|'Freq1'|'Freq2'|'FMFreq'| ...
%                       'FMAmp'|'Style'|'Dur1'|'Dur2'|'Tau'|'Gap'|'Loop'
%
%               Enables the GUI for the SoloParamHandle given by the final
%               argument. Thus the user can change it, using its GUI.
%               ** USE WITH CARE **  There is no guarantee that the inner
%               code of this section won't change one day and different
%               SoloParamHandles will be used, rendering the diabling of a
%               particular one a void action. So: use 'enable' with care.
%
% 'disable_all' soundname    Runs disable() on all SoloParamHandles that
%               are part of sound soundname. Thus the entire GUI for a
%               given soundname gets disabled.
%
%
% 'enable_all'  soundname    Runs enable() on all SoloParamHandles that
%               are part of sound soundname. Thus the entire GUI for a
%               given soundname gets enabled.
%
%
% Requires protocol object to be using the SoundManager Plugin.
%

% Written by Jeffrey Erlich 2007
% Modified by various authors


function [varargout] = SoundInterface(obj, action, sname, x,y , varargin)

GetSoloFunctionArgs(obj,'name',sname);

switch action,
    
    
    %% ADD
    case 'add'  %
        
        %  Check if a sound of the name already exists
        
        
        if SoundManagerSection(obj,'sound_exists', sname)
            warning('Plugins:SoundInterface:SoundExists','Sound %s already exists!', sname)
            % Added by CDB so that warning really is just a warning and
            % doesn't cause an error if return values are expected:
            varargout{1} = x; varargout{2} = y;
            return;
        end
        
        % Create SoloParams.
        
        pairs = { ...
            'ForceCount'     0; ...
            'Collisions'     1; ...
            'Volume'         0; ...
            'Vol2'         0.1; ...
            'Balance'        0; ...
            'Freq'        1000; ...
            'FMFreq'         5; ...
            'FMAmp'        200; ...
            'File'		     1; ...
            'Style'     'Tone'; ...
            'Duration'      .5; ...
            'Width'         3;  ...
            'FreqS'         0;  ...
            'Stereo_1st'    0;  ...
            'TooltipString' ''; ...
            'Tau'           0.1;...
            'Gap'           0;  ...
            'Loop'          0;  ...
            'WNP'           0;  ...
            }; parseargs(varargin, pairs);
        
        NumeditParam(obj, [sname 'Tau'],        Tau,        x,y, 'position',[x     y  70 20], 'labelfraction', 0.4, 'label', 'Tau',           'TooltipString', ' Tau in s');
        NumeditParam(obj, [sname 'FreqS'],      FreqS,      x,y, 'position',[x     y  70 20],                       'label', 'FreqS',         'TooltipString', ' The rate of stereo clicks');
        NumeditParam(obj, [sname 'Cntrst'],     500,        x,y, 'position',[x     y  70 20], 'labelfraction', 0.4, 'label', 'Cnt',           'TooltipString', ' Total contrast of Freq1 and Freq2; (C1+C2)');
        NumeditParam(obj, [sname 'Gap'],        Gap,        x,y, 'position',[x+72  y  70 20], 'labelfraction', 0.4, 'label', 'Gap',           'TooltipString', ' Gap between 1st and second part of sweep in seconds.');
        ToggleParam( obj, [sname 'Stereo_1st'], Stereo_1st, x,y, 'position',[x+72  y  70 20], 'OnString','1st Stereo','OffString','1st Mono', 'TooltipString', ' Forces first click to be stereo');
        NumeditParam(obj, [sname 'WNP'],        WNP,        x,y, 'position',[x+72  y  70 20], 'labelfraction', 0.4, 'label', 'WNP',           'TooltipString', ' Percent sound power that is white noise');
        NumeditParam(obj, [sname 'CRatio'],     5,          x,y, 'position',[x+72  y  70 20], 'labelfraction', 0.4, 'label', 'CRat',          'TooltipString', ' log of the ratio of the contrasts; log(C1/C2)');
        ToggleParam( obj, [sname 'Loop'],       Loop,       x,y, 'position',[x+142 y  60 20], 'OnString','Loop','OffString','No Loop',        'TooltipString', ' If this is selected sound will play until an explicit sound off.  Make sure to test sound for artifacts at loop boundary');  next_row(y);
        NumeditParam(obj, [sname 'Dur1'],       Duration,   x,y, 'position',[x     y 100 20],                       'label', 'Dur1',          'TooltipString', ' duration 1 in seconds');
        NumeditParam(obj, [sname 'Dur2'],       Duration,   x,y, 'position',[x+102 y 100 20],                       'label', 'Dur2',          'TooltipString', ' duration 2 in seconds');
        NumeditParam(obj, [sname 'Width'],      Width,      x,y, 'position',[x+102 y 100 20],                       'label', 'Width',         'TooltipString', ' click width in milliseconds');
        NumeditParam(obj, [sname 'Sigma'],      100,        x,y, 'position',[x+102 y 100 20],                       'label', 'Sigma',         'TooltipString', ' stdev of gaussians around Freq1 and Freq2 in frequency space');
        NumeditParam(obj, [sname 'FMAmp'],      FMAmp,      x,y, 'position',[x+102 y 100 20],                       'label', 'FMAmp',         'TooltipString', ' FM modulation ampl, in Hz');  next_row(y);
        NumeditParam(obj, [sname 'Freq1'],      Freq,       x,y, 'position',[x     y 100 20],                       'label', 'Freq1',         'TooltipString', ' frequency 1 in Hz');
        NumeditParam(obj, [sname 'Vol2'],       Vol2,       x,y, 'position',[x     y 100 20],                       'label', 'Vol2',          'TooltipString', ' final Vol in WhiteNoiseRamp');
        NumeditParam(obj, [sname 'Freq2'],      Freq,       x,y, 'position',[x+102 y 100 20],                       'label', 'Freq2',         'TooltipString', ' frequency 2 in Hz');
        NumeditParam(obj, [sname 'FMFreq'],     FMFreq,     x,y, 'position',[x+102 y 100 20],                       'label', 'FMFreq',        'TooltipString', ' FM modulation freq in Hz');  next_row(y);
        NumeditParam(obj, [sname 'Vol'],        Volume,     x,y, 'position',[x     y 100 20],                       'label', 'Vol',           'TooltipString', ' volume. 0-1');
        NumeditParam(obj, [sname 'Bal'],        Balance,    x,y, 'position',[x+102 y 100 20],                       'label', 'Bal',           'TooltipString', ' balance. -1=Left, 0=center, 1=right');  next_row(y);
        NumeditParam(obj, [sname 'Left_Click_Times'],  0,   x,y, 'position',[x     y 100 20],                       'label', 'LCT');
        NumeditParam(obj, [sname 'Right_Click_Times'], 0,   x,y, 'position',[x+102 y 100 20],                       'label', 'RCT');
        
        make_invisible(eval([sname 'FreqS']));
        make_invisible(eval([sname 'Cntrst']));
        make_invisible(eval([sname 'Stereo_1st']));
        make_invisible(eval([sname 'WNP']));
        make_invisible(eval([sname 'CRatio']));
        make_invisible(eval([sname 'Width']));
        make_invisible(eval([sname 'Sigma']));
        make_invisible(eval([sname 'FMAmp']));
        make_invisible(eval([sname 'Vol2']));
        make_invisible(eval([sname 'FMFreq']));
        make_invisible(eval([sname 'Left_Click_Times']));
        make_invisible(eval([sname 'Right_Click_Times']));
        
        set_callback(eval([sname 'Loop']),{mfilename, 'set_loop', sname;});
        
        snds=fillSoundsMenu;
        MenuParam(  obj, [sname 'SndsMenu'],   snds, File, x,y, 'label', 'SoundFile', 'labelfraction', 0.3);
        ToggleParam(obj, [sname 'Collisions'], Collisions, x,y, 'position',[x      y  100 20], 'OnString','Allow Collisions','OffString','No Collisions', 'TooltipString', ' Prevents clicks from superimposing');
        ToggleParam(obj, [sname 'ForceCount'], ForceCount, x,y, 'position',[x+102  y  100 20], 'OnString','Count',           'OffString','Frequency',         'TooltipString', ' Allows frequencys to be interpreted as click counts'); next_row(y);
        
        make_invisible(eval([sname 'Collisions']));
        make_invisible(eval([sname 'ForceCount']));
        
        MenuParam(obj, [sname 'Style'], {'Tone','Bups','ToneSweep','BupsSweep','ToneFMWiggle','WhiteNoise','WhiteNoiseRamp','WhiteNoiseTone','SpectrumNoise','PinkNoise','AMTone','PClick','PClick_Freq','PClick_Fix','PClick_Freq_Fix','File'}, Style, x,y, 'labelfraction', 0.3);next_row(y);
        set_callback(eval([sname 'Style']),{mfilename, 'set_style', sname; mfilename, 'update', sname;});
        
        SubheaderParam(obj, [sname 'Head'], sname, x,y,'TooltipString',TooltipString);
        PushbuttonParam(obj, [sname 'Play'], x,y, 'label', 'Play', 'position', [x y 30 20]);
        %set_callback(eval([sname 'Play']),{'SoundManagerSection', 'play_sound', sname});
        set_callback(eval([sname 'Play']),{mfilename,'play_sound',sname});
        
        PushbuttonParam(obj, [sname 'Stop'], x,y, 'label', 'Stop', 'position', [x+30 y 30 20]);
        set_callback(eval([sname 'Stop']),{'SoundManagerSection', 'stop_sound', sname});
        
        next_row(y);
        
        varargout{1}=x;
        varargout{2}=y;
        eval(['set_callback({' [sname 'Vol'] ',' [sname 'Bal'] ','  [sname 'Dur1'] ',' [sname 'Freq1'] ',' ...
            [sname 'Gap'] ',' [sname 'Tau'] ','  [sname 'Dur2'] ',' [sname 'Freq2'] ',' [sname 'Collisions'] ',' [sname 'ForceCount'] ','...
            [sname 'FMFreq'] ',' [sname 'FMAmp'] ',' [sname 'Vol2'] ',' [sname 'WNP'] ',' ...
            [sname 'Cntrst'] ',' [sname 'CRatio'] ',' [sname 'Sigma'] ',' [sname 'FreqS'] ',' [sname 'Stereo_1st'] ',' [sname 'Width'] ','...
            [sname 'SndsMenu'] '}, {mfilename, ''update'',''' sname '''});']);
        SoundManagerSection(obj, 'declare_new_sound', sname);
        if ~isnan(bSettings('get', 'GENERAL', 'HEADPHONE_MAX_V'))
            feval(mfilename,obj,'limit_vol',sname);
            set_callback({eval([sname 'Vol'])},{mfilename, 'limit_vol', sname});
        end
        feval(mfilename,obj,'set_style',sname);
        feval(mfilename,obj,'update',sname);
        %% SET  -- added by CDB
        
    case 'set',
        % Let's put all the args in the varargin list:
        varargin = [{x y} varargin];
        
        % Now pick them off in pairs:
        while ~isempty(varargin),
            if length(varargin)<2,
                error('SOUNDUI:BadArgs', 'In "set", need name-value pairs to know what to set');
            end;
            param = varargin{1}; newvalue = varargin{2}; varargin = varargin(3:end);
            
            try
                sph = eval([sname param]);
            catch
                warning('SOUNDUI:Not_found', 'Couldn''t find parameter named %s, nothing changed', [sname param]);
                return;
            end;
            sph.value = newvalue;
            
            
            % A callback on a ToggleParam is like clicking it, so we avoid it for
            % the special case of the toggle param, otherwise we call it.
            if ~strcmp(param, 'Loop'), callback(sph);
            else                       %feval(mfilename, obj, 'Loop', sname);
            end;
        end;
        
        
        %% GET  -- added by CDB
        
    case 'get',
        param = x;
        
        % 'total_duration' is a special case:
        if isequal(param, 'total_duration'),
            switch eval(['value(' sname 'Style)']);
                case {'Tone', 'Bups', 'ToneFMWiggle', 'WhiteNoise', 'WhiteNoiseRamp', 'WhiteNoiseTone', 'SpectrumNoise','PClick'}
                    varargout{1} = eval(['value(' sname 'Dur1)']);
                case {'ToneSweep', 'BupsSweep'},
                    varargout{1} = eval(['value(' sname 'Dur1)']) + eval(['value(' sname 'Gap)']) + ...
                        eval(['value(' sname 'Dur2)']);
                otherwise,
                    warning('SoundInterface:Invalid', 'get total_duration: Don''t know style "%s"', eval(['value(' sname 'Style)']));
                    varargout{1} = 0;
            end;
            return;
        end;
        
        try
            sph = eval([sname param]);
            varargout{1} = value(sph);
        catch
            warning('SOUNDUI:Not_found', 'Couldn''t find parameter named %s, returning NaN', [sname param]);
            varargout{1} = NaN;
        end;
        
        
        %% DISABLE -- added by CDB
        
    case 'disable',
        param = x;
        try
            sph = eval([sname param]);
            disable(sph)
        catch
            warning('SOUNDUI:Not_found', 'Couldn''t find SoloParamHandle named "%s", not doing anything', [sname param]);
        end;
        
        
        %% ENABLE -- added by CDB
        
    case 'enable',
        param = x;
        try
            sph = eval([sname param]);
            enable(sph)
        catch
            warning('SOUNDUI:Not_found', 'Couldn''t find SoloParamHandle named "%s", not doing anything', [sname param]);
        end;
        
        
        
        %% DISABLE_ALL  -- added by CDB
        
    case 'disable_all'
        varnames = GetSoloFunctionArgs('arglist', ['@' class(obj)], 'SoundInterface');
        matching_names = strmatch(sname, varnames);
        for xi=1:numel(matching_names)
            sp = eval(varnames{matching_names(xi)});
            disable(sp);
        end
        
        
        
        %% ENABLE_ALL  -- added by CDB
        
    case 'enable_all'
        varnames = GetSoloFunctionArgs('arglist', ['@' class(obj)], 'SoundInterface');
        matching_names = strmatch(sname, varnames);
        for xi=1:numel(matching_names)
            sp = eval(varnames{matching_names(xi)});
            enable(sp);
        end
        
        
        %% GET_SOLOPARAMHANDLES
        % Added by CDB. Users should be able to get access to SPHs without knowing
        % about get_sphandle. Note that if one sound has the name of another sound
        % plus extra characters, this will not work properly, for asking for the
        % SPHs of the shorter-named sound will get both sets of SPHs back.
    case 'get_soloparamhandles',
        if nargin < 3,
            error('Need the sound name to return all the SoloParamHandles');
        end;
        
        sp = get_sphandle('owner', ['@' class(obj)], 'fullname', ['^SoundInterface_' sname]);
        varargout(1) = {sp};
        
        
        %% save_to_struct
        % Added by BWB.  Identifies all the soloparamhandles whose names start with
        % sname, then returns a struct with a field for each soloparahandle (minus
        % sname) and whose value is its current value.
        % PushbuttonParams are ignored, since they don't really have a value.
    case 'save_to_struct',
        x = {};
        p = whos([sname '*']);
        for i = 1:rows(p),
            pname   = p(i).name;
            phandle = eval(pname);
            if is_validhandle(phandle) && ~strcmp(get_type(phandle), 'pushbutton') ...
                    && ~strcmp(get_type(phandle), 'subheader'),
                name_str = pname(length(sname)+1:end);
                val      = value(phandle);
                x.(name_str) = val;
            end;
        end;
        varargout(1) = {x};
        
        %% load_from_struct
        % Added by BWB.  Loads a struct of the format described in
        % save_to_cellaray.  Assigns the values stored to the appropriate
        % soloparamhandles for sname, then calls update to make the sound.
    case 'load_from_struct'
        saved = x;
        pnames = fieldnames(saved);
        for i = 1:rows(pnames),
            % There was a uper/lowercase typo-- the following line is a
            % backwards compatibility hack after the fix. If we have the
            % old-style FMfreq and don't have the new-style FMFreq, then
            % use the old-style:
            if strcmp(pnames{i}, 'FMfreq'),
                if ~ismember('FMFreq', pnames)
                    phandle = eval([sname 'FMFreq']);
                    phandle.value = saved.FMfreq;
                else
                    % don't do anything-- there's a proper new-style entry,
                    % we'll get to that in time.
                end;
                
            else % ok, a normal case:
                phandle = eval([sname pnames{i}]);
                phandle.value = saved.(pnames{i});
            end;
        end;
        
        feval(mfilename,obj,'set_style',sname);
        feval(mfilename,obj,'update',sname);
        
        
        %% UPDATE
    case 'update',
        
        sr=SoundManagerSection(obj,'get_sample_rate');
        
        
        vol  =eval(['value(' sname 'Vol)']);
        vol2 =eval(['value(' sname 'Vol2)']);
        loop =eval(['value(' sname 'Loop)']);
        style=eval(['value(' sname 'Style)']);
        
        % Only WhiteNoiseRamp has a vol2:
        if (strcmp(style,  'WhiteNoiseRamp') && vol==0 && vol2==0) || ...
                ~strcmp(style, 'WhiteNoiseRamp') && vol==0,
            w=[0;0];
            % I can't think of a reason not to do this.
        else
            bal        = eval(['value(' sname 'Bal)']);
            dur1       = eval(['value(' sname 'Dur1)'])*1000;
            dur2       = eval(['value(' sname 'Dur2)'])*1000;
            freq1      = eval(['value(' sname 'Freq1)']);
            freq2      = eval(['value(' sname 'Freq2)']);
            tau        = eval(['value(' sname 'Tau)'])*1000;
            gap        = eval(['value(' sname 'Gap)'])*1000;
            fmfreq     = eval(['value(' sname 'FMFreq)']);
            fmamp      = eval(['value(' sname 'FMAmp)']);
            wnp        = eval(['value(' sname 'WNP)']);
            cntrst     = eval(['value(' sname 'Cntrst)']);
            cratio     = eval(['value(' sname 'CRatio)']);
            sigma      = eval(['value(' sname 'Sigma)']);
            freqs      = eval(['value(' sname 'FreqS)']);
            stereo_1st = eval(['value(' sname 'Stereo_1st)']);
            width      = eval(['value(' sname 'Width)']);
            collision  = eval(['value(' sname 'Collisions)']);
            forcecount = eval(['value(' sname 'ForceCount)']);
            
            RVol=vol*min(1,(1+bal));
            LVol=vol*min(1,(1-bal));
            
            
            switch style, %{'Tone','Bups','ToneSweep','BupsSweep','ToneFMWiggle',PClick','File'}
                case 'Tone',
                    
                    t=0:(1/sr):(dur1/1000); t = t(1:end-1);
                    tw=sin(t*2*pi*freq1);
                    RW=RVol*tw;
                    LW=LVol*tw;
                    clear tw;
                    eval([sname,'Left_Click_Times.value  = 0;']);
                    eval([sname,'Right_Click_Times.value = 0;']);
                case 'Bups',
                    tw=MakeBupperSwoop(sr,0, freq1 , freq1 , dur1/2 , dur1/2,0,0.1);
                    RW=RVol*tw;
                    LW=LVol*tw;
                    clear tw;
                    eval([sname,'Left_Click_Times.value  = 0;']);
                    eval([sname,'Right_Click_Times.value = 0;']);
                case 'ToneSweep',
                    tw=MakeSigmoidSwoop3(sr,0,freq1, freq2, dur1, dur2, gap, tau);
                    RW=RVol*tw;
                    LW=LVol*tw;
                    clear tw;
                    eval([sname,'Left_Click_Times.value  = 0;']);
                    eval([sname,'Right_Click_Times.value = 0;']);
                case 'ToneFMWiggle',
                    if (freq1-fmfreq)<0
                        warning('SOUNDUI:ToneFMWiggle','Please make the FM freq less than carrier freq.');
                        return;
                    end
                    if (freq1-fmamp)<=0
                        warning('SOUNDUI:ToneFMWiggle','Please make the FMAmp less than carrier freq.');
                        return;
                    end
                    tw=MakeFMWiggle(sr,0, dur1/1000, freq1, fmfreq, fmamp);
                    RW=RVol*tw;
                    LW=LVol*tw;
                    clear tw;
                    
                    
                    eval([sname,'Left_Click_Times.value  = 0;']);
                    eval([sname,'Right_Click_Times.value = 0;']);
                case 'AMTone',
                    if (freq1-fmfreq)<0
                        warning('SOUNDUI:AMTone','Please make the AM freq less than carrier freq.');
                        return;
                    end
                    if  fmamp<0
                        warning('SOUNDUI:AMTone','Please make the AM Amp greater than zero.');
                        return;
                    end
                    params.carrier_frequency      = freq1;
                    params.carrier_phase          = 0;
                    params.modulation_frequency	= fmfreq;
                    params.modulation_phase       = 0;
                    params.modulation_depth       = fmamp;
                    params.amplitude              = 80;
                    params.duration               = dur1;
                    if loop
                        params.ramp                   = 0;
                    else
                        params.ramp=5;
                    end
                    tw=MakeAMTone(params, sr);
                    RW=RVol*tw;
                    LW=LVol*tw;
                    clear tw;
                    
                    eval([sname,'Left_Click_Times.value  = 0;']);
                    eval([sname,'Right_Click_Times.value = 0;']);
                    
                case 'BupsSweep',
                    tw=MakeBupperSwoop(sr,0,freq1, freq2, dur1, dur2, gap, tau);
                    RW=RVol*tw;
                    LW=LVol*tw;
                    clear tw;
                    
                    eval([sname,'Left_Click_Times.value  = 0;']);
                    eval([sname,'Right_Click_Times.value = 0;']);
                    
                case 'WhiteNoise',
                    t=0:(1/sr):(dur1/1000); t = t(1:end-1);
                    RW=RVol*randn(size(t));
                    LW=LVol*randn(size(t));
                    clear t;
                    
                    eval([sname,'Left_Click_Times.value  = 0;']);
                    eval([sname,'Right_Click_Times.value = 0;']);
                    
                case 'WhiteNoiseRamp',
                    if dur1==0,
                        RW = []; LW = [];
                    else
                        t=0:(1/sr):(dur1/1000); t = t(1:end-1);
                        if vol>0,
                            vramp = vol*exp((t/t(end)).*log(vol2/vol));
                        else
                            vramp = vol + (t/t(end))*(vol2 - vol);
                            warning('SOUNDUI:LogOfZero', 'WhiteNoiseRamp: vol==0, using linear instead of log volume scale');
                        end;
                        RW=vramp.*randn(size(t));
                        LW=vramp.*randn(size(t));
                        clear t; clear vramp;
                    end;
                    
                    eval([sname,'Left_Click_Times.value  = 0;']);
                    eval([sname,'Right_Click_Times.value = 0;']);
                    
                case 'WhiteNoiseTone',
                    t=0:(1/sr):(dur1/1000); t = t(1:end-1);
                    tw=sin(t*2*pi*freq1)+1;
                    wn=rand(size(tw))*2;
                    
                    tw=tw*(1-wnp);
                    wn=wn*wnp;
                    tw=tw+wn;
                    tw=tw-min(tw);
                    tw=tw*(2/max(tw));
                    tw=tw-1;
                    
                    RW=RVol*tw;
                    LW=LVol*tw;
                    clear tw;
                    
                    eval([sname,'Left_Click_Times.value  = 0;']);
                    eval([sname,'Right_Click_Times.value = 0;']);
                    
                case 'SpectrumNoise',
                    tw = MakeSpectrumNoise(sr, freq1, freq2, dur1, cntrst, cratio, 'stdev', sigma, 'baseline', 0.05);
                    RW = RVol * tw;
                    LW = LVol * tw;
                    clear tw;
                    eval([sname,'Left_Click_Times.value  = 0;']);
                    eval([sname,'Right_Click_Times.value = 0;']);

                case 'PinkNoise'
                    t=0:(1/sr):(dur1/1000); t = t(1:end-1);
                    RW = RVol * pinknoise(size(t));
                    LW = LVol * pinknoise(size(t));
                    clear t;
                    eval([sname,'Left_Click_Times.value  = 0;']);
                    eval([sname,'Right_Click_Times.value = 0;']);

                case 'PClick',
                    [SW lrate rrate data] = make_pbup(freq1 + freq2, log(freq2 / freq1), sr, dur1/1e3,...
                        'bup_width', width, 'first_bup_stereo', stereo_1st, 'distractor_rate', freqs,...
                        'avoid_collisions',~collision, 'force_count',forcecount); %#ok<NASGU>
                    LW = SW(1,:) * LVol;
                    RW = SW(2,:) * RVol;
                    if isempty(data.left);  data.left  = nan; end
                    if isempty(data.right); data.right = nan; end
                    eval([sname,'Left_Click_Times.value  = data.left;']);
                    eval([sname,'Right_Click_Times.value = data.right;']);
                    
                case 'PClick_Freq'    
                    [SW,lrate,rrate,data] = make_pbup(freq1 + freq2, log(freq2 / freq1), sr, dur1/1e3,...
                        'bup_width', width, 'first_bup_stereo', 0, 'task_type', 0, 'base_freq', freqs,...
                        'avoid_collisions',~collision, 'force_count',forcecount,'ntones',1); %#ok<NASGU>
                    LW = SW(1,:) * LVol;
                    RW = SW(2,:) * RVol;
                    if isempty(data.left);  data.left  = nan; end
                    if isempty(data.right); data.right = nan; end
                    eval([sname,'Left_Click_Times.value  = data.left;']);
                    eval([sname,'Right_Click_Times.value = data.right;']);

                case 'PClick_Fix',
                    [SW lrate rrate data] = make_pbup_fixed(freq1 + freq2, log(freq2 / freq1), sr, dur1/1e3,...
                        'bup_width', width, 'first_bup_stereo', stereo_1st, 'distractor_rate', freqs,...
                        'avoid_collisions',~collision, 'force_count',forcecount,'is_fixed', 1); %#ok<NASGU>
                    LW = SW(1,:) * LVol;
                    RW = SW(2,:) * RVol;
                    if isempty(data.left);  data.left  = nan; end
                    if isempty(data.right); data.right = nan; end
                    eval([sname,'Left_Click_Times.value  = data.left;']);
                    eval([sname,'Right_Click_Times.value = data.right;']);        

                case 'PClick_Freq_Fix'    
                    [SW,lrate,rrate,data] = make_pbup_fixed(freq1 + freq2, log(freq2 / freq1), sr, dur1/1e3,...
                        'bup_width', width, 'first_bup_stereo', 0, 'task_type', 0, 'base_freq', freqs,...
                        'avoid_collisions',~collision, 'force_count',forcecount,'ntones',1,'is_fixed', 1); %#ok<NASGU>
                    LW = SW(1,:) * LVol;
                    RW = SW(2,:) * RVol;
                    if isempty(data.left);  data.left  = nan; end
                    if isempty(data.right); data.right = nan; end
                    eval([sname,'Left_Click_Times.value  = data.left;']);
                    eval([sname,'Right_Click_Times.value = data.right;']);
                                 
                case 'File',
                    % warning('Plugins:SoundInterface:SoundFilesNotDone','Loading sounds from files not implemented yet');
                    [LW, RW]=getWavefromFile(value(eval([sname 'SndsMenu'])), sr, LVol, RVol);
                    
                    
                otherwise
                    warning('Plugins:SoundInterface:UnknownStyle','Unknown style %s',style);
                    
            end
            w=[LW;RW];
        end
        
        curr_sound=SoundManagerSection(obj,'get_sound',sname);
        if isequal(w,curr_sound)
            % 'nothing to do'
        else
            SoundManagerSection(obj,'set_sound',sname,w,loop);
        end
        
        
        %% set_balance
    case 'set_balance',
        if abs(x)>1, warning('SOUNDINTERFACE:illegal_value', 'Balance must be within [-1, 1]'); end;
        bal = eval([sname 'Bal']);
        bal.value = x;
        callback(bal);
        
        
        %% set_loop
    case 'set_loop',
        loop=eval(['value(' sname 'Loop)']);
        SoundManagerSection(obj,'loop_sound',sname,loop);
        % Unnecessary line? :
        % style=value(eval([sname 'Style']));
        
        
        %% set_style
    case 'set_style',
        %hide stuff, show stuff.....
        varnames = GetSoloFunctionArgs('arglist', ['@' class(obj)], 'SoundInterface');
        matching_names = strmatch(sname, varnames);
        for xi=1:numel(matching_names)
            sp = eval(varnames{matching_names(xi)});
            disable(sp);
        end
        style=value(eval([sname 'Style']));
        
        switch style %{'Tone','Bups','ToneSweep','BupsSweep','File'}
            case {'Tone', 'Bups'}
                val_flag=1;
            case {'ToneFMWiggle','AMTone'}
                val_flag=1.1;
            case 'WhiteNoise',
                val_flag=1.2;
            case 'WhiteNoiseRamp',
                val_flag=1.3;
            case 'WhiteNoiseTone',
                val_flag=1.4;
            case 'SpectrumNoise',
                val_flag=1.5;
            case 'PinkNoise',
                val_flag=1.6;
            case {'ToneSweep', 'BupsSweep'}
                val_flag=2;
            case {'PClick'}
                val_flag=2.1;
            case {'PClick_Freq'}
                val_flag=2.1; 
            case {'PClick_Fix'}
                val_flag = 2.1;
            case {'PClick_Freq_Fix'}
                val_flag=2.1;   
            case {'File'}
                val_flag=0;
            otherwise
                warning('SoundInterface:Invalid', 'Unknown style "%s"', style);
        end
        
        if val_flag==0
            enable(eval([sname 'SndsMenu']));
            set(get_ghandle(eval([sname 'SndsMenu'])),'String',fillSoundsMenu);
        end
        
        if val_flag>=0
            
            enable(eval([sname 'Style']));
            enable(eval([sname 'Play']));
            enable(eval([sname 'Stop']));
            enable(eval([sname 'Loop']));
            enable(eval([sname 'Head']));
            enable(eval([sname 'Vol']));
            enable(eval([sname 'Vol2']));
            enable(eval([sname 'Bal']));
        end
        
        if val_flag>=1
            enable(eval([sname 'Dur1']));
            enable(eval([sname 'Freq1']));
            enable(eval([sname 'FMFreq']));
            enable(eval([sname 'FMAmp']));
            enable(eval([sname 'WNP']));
            enable(eval([sname 'Sigma']));
            enable(eval([sname 'Cntrst']));
            enable(eval([sname 'CRatio']));
        end
        
        if val_flag==1.1
            make_invisible(eval([sname 'Freq2']));
            make_invisible(eval([sname 'Dur2']));
            make_visible(eval([sname 'FMFreq']));
            make_visible(eval([sname 'FMAmp']));
        else
            make_visible(eval([sname 'Freq2']));
            make_visible(eval([sname 'Dur2']));
            make_invisible(eval([sname 'FMFreq']));
            make_invisible(eval([sname 'FMAmp']));
        end;
        
        if val_flag==1.2 || val_flag==1.3
            disable(eval([sname 'Freq1']));
        end
        
        if val_flag==1.3
            make_visible(eval([sname 'Vol2']));
            make_invisible(eval([sname 'Freq1']));
        else
            make_invisible(eval([sname 'Vol2']));
            make_visible(eval([sname 'Freq1']));
        end;
        
        if val_flag==1.4
            make_invisible(eval([sname 'Gap']));
            make_visible(eval([sname 'WNP']));
        else
            make_visible(eval([sname 'Gap']));
            make_invisible(eval([sname 'WNP']));
        end
        
        if val_flag==1.5,
            make_invisible(eval([sname 'Gap']));
            make_invisible(eval([sname 'WNP']));
            make_visible(eval([sname 'Cntrst']));
            make_visible(eval([sname 'CRatio']));
            make_visible(eval([sname 'Sigma']));
            enable(eval([sname 'Freq2']));
        else
            make_visible(eval([sname 'Gap']));
            make_visible(eval([sname 'WNP']));
            make_invisible(eval([sname 'Cntrst']));
            make_invisible(eval([sname 'CRatio']));
            make_invisible(eval([sname 'Sigma']));
        end;
        
        if val_flag==1.6
            disable(eval([sname 'Freq1']));
            make_invisible(eval([sname 'WNP']));
        end
        
        if val_flag==2
            make_visible(eval([sname 'Gap']));
            make_invisible(eval([sname 'WNP']));
            
            enable(eval([sname 'Dur2']));
            enable(eval([sname 'Freq2']));
            enable(eval([sname 'Tau']));
            enable(eval([sname 'Gap']));
        end
        
        if val_flag == 2.1
            make_visible(eval([sname 'FreqS']));
            make_visible(eval([sname 'Stereo_1st']));
            make_visible(eval([sname 'Width']));
            make_visible(eval([sname 'Collisions']));
            make_visible(eval([sname 'ForceCount']));
            enable(      eval([sname 'FreqS']));
            enable(      eval([sname 'Stereo_1st']));
            enable(      eval([sname 'Width']));
            enable(      eval([sname 'Freq2']));
            enable(      eval([sname 'Collisions']));
            enable(      eval([sname 'ForceCount']));
            make_invisible(eval([sname 'WNP']));
            
        else
            make_invisible(eval([sname 'FreqS']));
            make_invisible(eval([sname 'Stereo_1st']));
            make_invisible(eval([sname 'Width']));
            make_invisible(eval([sname 'Collisions']));
            make_invisible(eval([sname 'ForceCount']));
            disable(       eval([sname 'FreqS']));
            disable(       eval([sname 'Stereo_1st']));
            disable(       eval([sname 'Width']));
            disable(       eval([sname 'Collisions']));
            disable(       eval([sname 'ForceCount']));
            %make_visible(  eval([sname 'WNP']));
        end
        %% limit_vol - added by TZL
    case 'limit_vol'
        hp_max_V = bSettings('get', 'GENERAL', 'HEADPHONE_MAX_V');
        if ~isnan(hp_max_V)
            % The Lynx L22 sound card generates a maximumal signal level of +20
            % dBU, which is equivalent to a  maximum voltage level of:  
            L22_max_V = sqrt(2) * sqrt(0.6) *10^(20/20);
            max_vol = hp_max_V / L22_max_V;
            eval([sname 'Vol.value = min(max_vol, value(' sname 'Vol));'])
        end
        feval(mfilename,obj,'update',sname);
        
        %% play_sound
    case 'play_sound'
        
        if bSettings('get','RIGS','bpod') == 1 && ...
           strcmp(bSettings('get','RIGS','sound_machine_server'),'localhost')
            global BpodSystem
            
            if strcmp(class(BpodSystem.PluginObjects.SoundServer),'BpodAudioPlayer')
                SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
                BpodSystem.PluginObjects.SoundServer.push;
            end
        end
        pause(3);
        SoundManagerSection(obj,'play_sound', sname);
        
        
        %% close
    case 'close'
        % delete all SoloParamHandles who belong to this object and whose
        % name starts with sname
        delete_sphandle('owner', ['^@' class(obj) '$'], ...
            'fullname', ['^SoundInterface_' sname]);
        
        % delete the sound
        SoundManagerSection(obj, 'delete_sound', sname);
        
        
        
        %% reinit
    case 'reinit',       % ---------- CASE REINIT -------------
        % Delete all SoloParamHandles who belong to this object and whose
        % fullname starts with the name of this mfile:
        delete_sphandle('owner', ['^@' class(obj) '$'], ...
            'fullname', ['^' mfilename]);
        
        feval(mfilename, obj, 'init');
    otherwise
        warning('%s : action "%s" is unknown!', mfilename, action); %#ok<WNTAG> (This line OK.)
end;

return;


