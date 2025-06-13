%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%
%            'prepare_next_trial'   
%
%            'init'
%
%
% RETURNS:
% --------
%
%
%
%
% 
%



function [varargout] = PsychSection(obj, action, x, y)
   
GetSoloFunctionArgs(obj);

switch action
    
%% init
% ----------------------------------------------------------------
%
%       INIT
%
% ----------------------------------------------------------------
  
  case 'init', 
      MenuParam(obj,'PsychType',{'Balance';'Frequency'},1,x,y,'position',[x     y 130 20],'labelfraction',0.5);
      DispParam(obj,'ThisTrial',0,x,y,    'position',[x+130 y  70 20],'labelfraction',0.70); next_row(y);
      
      NumeditParam(obj,'Left_End', -1,x,y,'position',[x     y 100 20],'labelfraction',0.60);
      NumeditParam(obj,'Midpoint',  0,x,y,'position',[x+100 y 100 20],'labelfraction',0.60); next_row(y);
      NumeditParam(obj,'Right_End', 1,x,y,'position',[x     y 100 20],'labelfraction',0.60); 
      NumeditParam(obj,'Spread',    2,x,y,'position',[x+100 y 100 20],'labelfraction',0.60); next_row(y);
      
      set_callback(Left_End,  {mfilename, 'CalcMidSpread'}); %#ok<NODEF>
      set_callback(Right_End, {mfilename, 'CalcMidSpread'}); %#ok<NODEF>
      set_callback(Midpoint,  {mfilename, 'CalcEnds'}); %#ok<NODEF>
      set_callback(Spread,    {mfilename, 'CalcEnds'}); %#ok<NODEF>
      
      MenuParam(obj,'SpreadType',{'Linear';'Log'},1,x,y,'position',[x     y 130 20],'labelfraction',0.5);
      NumeditParam(obj,'Num',                     2,x,y,'position',[x+130 y  70 20],'labelfraction',0.5); next_row(y);
          
      SoloParamHandle(obj, 'PsychValues', 'value', []);
      
      SubheaderParam(obj, 'title', 'Psych Section', x, y); next_row(y);
      varargout{1} = x;
      varargout{2} = y;
      
%% calcmidspread
% -----------------------------------------------------------------------
%
%         CALCMIDSPREAD
%
% -----------------------------------------------------------------------

  case 'CalcMidSpread',
      if strcmp(value(PsychType),'Balance')
          Midpoint.value = 0;
          Spread.value   = value(Right_End) - value(Left_End); %#ok<NODEF>
      else
          Spread.value   = value(Right_End) / value(Left_End); %#ok<NODEF>
          if strcmp(SpreadType,'Linear'); Midpoint.value = mean([value(Left_End) value(Right_End)]);
          else                            Midpoint.value = sqrt(value(Left_End) * value(Right_End));
          end
      end
      
      
%% calcends
% -----------------------------------------------------------------------
%
%         CALCENDS
%
% -----------------------------------------------------------------------

  case 'CalcEnds',
       if strcmp(value(PsychType),'Balance')
           if Midpoint ~= 0; Midpoint.value = 0; end %#ok<NODEF>
           Left_End.value  = -Spread / 2; %#ok<NODEF>
           Right_End.value =  Spread / 2;
           if Left_End  < -1; Left_End.value  = -1; end
           if Right_End >  1; Right_End.value =  1; end
           Spread.value = Right_End - Left_End;
       else
           if strcmp(SpreadType,'Linear'); Left_End.value  = (2 * Midpoint) / (Spread + 1); %#ok<NODEF>
           else                            Left_End.value = Midpoint / sqrt(value(Spread)); %#ok<NODEF>
           end
           Right_End.value = Spread * Left_End;
       end
      
      
%% prepare_next_trial
% -----------------------------------------------------------------------
%
%         PREPARE_NEXT_TRIAL
%
% -----------------------------------------------------------------------

  case 'prepare_next_trial',
    
    if n_done_trials > 0 && isfield(parsed_events.states,'start_new_trial')
        if ~isempty(parsed_events.states.start_new_trial); lasttrial_failednic = 1;
        else                                               lasttrial_failednic = 0;
        end
    else
        lasttrial_failednic = 0;
    end
    
    if strcmp(SpreadType,'Linear') || strcmp(PsychType,'Balance')
        temp = (Right_End - Left_End) / (Num - 1); %#ok<NODEF>
        PsychValues.value = value(Left_End):temp:value(Right_End);
    else
        temp = (log10(value(Right_End)) - log10(value(Left_End))) / (Num - 1); %#ok<NODEF>
        tempvals   = log10(value(Left_End)):temp:log10(value(Right_End));
        PsychValues.value = 10 .^ tempvals;
    end
            
    if lasttrial_failednic == 1
        currside = SidesSection(obj,'get_current_side');
        if     (strcmp(currside,'l') && ThisTrial - 1 > (Num - 1) / 2) ||...
               (strcmp(currside,'r') && ThisTrial - 1 < (Num - 1) / 2) 
            ThisTrial.value = Num - ThisTrial + 1;
        end
    else
        temp1 = rand(1);
        probs = (1/value(Num)):(1/value(Num)):1;
        currside = SidesSection(obj,'get_current_side');
        if strcmp(currside,'l'); temp2 = temp1 / 2;
        else                     temp2 = (temp1 / 2) + 0.5;
        end
        
        ThisTrial.value = find(probs >= temp2,1,'first');
    end
      
    psychvals = value(PsychValues);
    if strcmp(PsychType,'Balance')
        SoundInterface(obj, 'set', 'StimSound', 'Freq1', 50);
        SoundInterface(obj, 'set', 'StimSound', 'Bal',   psychvals(value(ThisTrial)));
    else
        SoundInterface(obj, 'set', 'StimSound', 'Freq1', psychvals(value(ThisTrial)));
        SoundInterface(obj, 'set', 'StimSound', 'Bal',   0);
    end
      
      
      
%% set
% -----------------------------------------------------------------------
%
%         SET
%
% -----------------------------------------------------------------------      
  case 'set'
    varname = x;
    newval  = y;
    
    try
        temp = 'SoloParamHandle';  %#ok<NASGU>
        eval(['test = isa(',varname,',temp);']);
        if test == 1
            eval([varname,'.value = newval;']);
        end
    catch  %#ok<CTCH>
        showerror;
        warning(['Unable to assign value: ',num2str(newval),' to SoloParamHandle: ',varname]);  %#ok<WNTAG>
    end

    
%% get
% -----------------------------------------------------------------------
%
%         GET
%
% -----------------------------------------------------------------------     
  case 'get'  
    varname = x;
    
    try
        temp = 'SoloParamHandle'; %#ok<NASGU>
        eval(['test = isa(',varname,',temp);']);
        if test == 1
            eval(['varargout{1} = value(',varname,');']);
        end
    catch %#ok<CTCH>
        showerror;
        warning(['Unable to get value from SoloParamHandle: ',varname]);  %#ok<WNTAG>
    end

    
%% reinit
% -----------------------------------------------------------------------
%
%         REINIT
%
% -----------------------------------------------------------------------     
  case 'reinit',
    currfig = double(gcf);

    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);
    

    % Reinitialise at the original GUI position and figure:
    feval(mfilename, obj, 'init');

    % Restore the current figure:
    figure(currfig);
end;


