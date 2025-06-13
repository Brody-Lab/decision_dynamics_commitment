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



function [varargout] = StimulatorSection(obj, action, x, y)
   
GetSoloFunctionArgs(obj);

switch action
    
%% init
% ----------------------------------------------------------------
%
%       INIT
%
% ----------------------------------------------------------------
  
  case 'init', 
 
      
      diolines = bSettings('get','DIOLINES', 'all');
      for i = 1:size(diolines,1); dionames{i} = diolines{i,1}; dionums(i) = diolines{i,2}; end %#ok<AGROW>
      [dionums order] = sort(dionums);
      dionames2 = cell(0);
      for i = 1:length(dionums); if ~isnan(dionums(i)); dionames2{end+1} = dionames{order(i)}; end; end %#ok<AGROW>
      
      MenuParam(obj,'StimLine',dionames2,length(dionames2),x,y,'labelfraction',0.30); next_row(y);
      NumeditParam(obj, 'StimLines', [6 6], x,y); next_row(y);
      
      SC = state_colors(obj);
      WC = wave_colors(obj); 
      states = fieldnames(SC);
      waves  = fieldnames(WC);
      states(2:end+1) = states;
      states{1} = 'none';
      states(end+1:end+length(waves)) = waves;
      
      MenuParam(obj,'StimState',states,1,x,y,'labelfraction',0.30); next_row(y);
      
      NumeditParam(obj,'StimStates', [3 9], x,y);
      NumeditParam(obj,'NumStimStates', 2,x,y); next_row(y);
      NumeditParam(obj, 'WhichStimState', 1, x,y); next_row(y);
      NumeditParam(obj,'StartDelay', [0 0],x,y); next_row(y);
      nic = delay_time+settling_time+nic_time;
      
      
      NumeditParam(obj, 'Pulsed', 0, x, y); next_row(y);
      if value(Pulsed)==0
         % NumeditParam(obj,'PulseWidth',[value(nic_time*1000) 4000],x,y);  next_row(y);
       %  NumeditParam(obj,'PulseWidth',[nic*1000 4000],x,y);  next_row(y); 
         NumeditParam(obj,'PulseWidth',[5000 4000],x,y);  next_row(y); 
         t = 1./(value(PulseWidth)/1000);
          NumeditParam(obj,'StimFreq',t,x,y); next_row(y);
          NumeditParam(obj,'NumPulses',[1 1],x,y); next_row(y);
      elseif value(Pulsed)==1
          NumeditParam(obj,'PulseWidth', 10, x, y);  next_row(y);
          NumeditParam(obj,'StimFreq', 20, x, y); next_row(y);
         % NP = [ceil(nic*value(StimFreq))];
          NP = 5*value(StimFreq); %make it longer than necessary and have SMA kill the wave.
          NumeditParam(obj,'NumPulses',[NP 4*value(StimFreq)],x,y); next_row(y);
      end
 
      NumeditParam(obj,'StimProb', [0 0],x,y); next_row(y);
      SoloParamHandle(obj, 'stimulator_history',   'value', []);
      NumeditParam(obj, 'laser_on', 0, x, y); next_row(y);
      
      SubheaderParam(obj, 'title', 'Stimulator Section', x, y); next_row(y);
      varargout{1} = x;
      varargout{2} = y;
      
      
      SoloFunctionAddVars('SidesSection', 'rw_args', ...
            {'StimState'; 'stimulator_history'}); 
      SoloFunctionAddVars('SMA1', 'rw_args', ...
            {'StimState'; 'stimulator_history'; 'PulseWidth'}); 
   
%% update_values
% -----------------------------------------------------------------------
%
%         UPDATE_VALUES
%
% -----------------------------------------------------------------------

  case 'update_values',
      sh = value(stimulator_history); %#ok<NODEF>
      sma = x;
      if ~dispatcher('is_running');
          %dispatcher is not running, last stim_hist not used, lop it off
          sh = sh(1:end-1);
      end
      
      if value(StimProb) == 0
          stimulator_history.value = [sh, 0];
          laser_on.value = 0;
          sma = add_scheduled_wave(sma,...
              'name',          'stimulatorwave1',...
              'preamble',      0, ...
              'sustain' ,      0, ...
              'loop',          0);
          
          sma = add_scheduled_wave(sma,...
              'name',          'stimulatorwave2',...
              'preamble',      0, ...
              'sustain' ,      0, ...
              'loop',          0);
          
      elseif rand(1) <= value(StimProb(1)); %roll the die to see if it's a laser trial.
          stimulator_history.value = [sh, 1];
          laser_on.value = 1;
          
          %okay figure out which part of the trial we are stimulating here,
          %so that we can adjust ITIs before the SMA assembles the state
          %matrix.
          sd = value(StartDelay);
          sf = value(StimFreq);
          pw = value(PulseWidth);
        %  np = value(NumPulses);
          ss = value(StimStates);
          
          if value(Pulsed)==1
              nic = delay_time+settling_time+nic_time;
             % NP = [ceil(nic*value(StimFreq(1)))];
              NP = [5*value(StimFreq(1))];
              np=[NP 4*value(StimFreq(2))];
          elseif value(Pulsed)==0;
              np = [1 1];
              pw = [5000 4000];
              PulseWidth.value = [5000 4000];
              StimFreq.value = [1/5 1/4];
          end
          NumPulses.value = np;
          
          %sl = [value(StimLine) value(StimLine)]; %[1 1];%value(StimLines); cmc commented this out...
          
         % if length(unique([length(sd) length(sf) length(pw) length(np) length(ss) length(sl)])) > 1
         if length(unique([length(sd) length(sf) length(pw) length(np) length(ss)])) > 1
              disp('Warning: param values in StimulatorSection have different lengths. Only first value will be used.');
              WhichStimState.value = 1;
          else
              WhichStimState.value = ceil(rand(1) * length(sd));
          end
          StimState.value = ss(value(WhichStimState));
          
          sd = sd(value(WhichStimState));
          sf = sf(value(WhichStimState));
          pw = pw(value(WhichStimState));
          np = np(value(WhichStimState));
          
          if value(Pulsed)==1
            sd = 1/sf-pw/1000;
          end
          
          psl = get(get_ghandle(StimLine), 'String');
          slind = find(strcmp(psl, value(StimLine)));
          stimline = bSettings('get','DIOLINES',psl{slind}); 
          
          if value(WhichStimState)==1
              sma = add_scheduled_wave(sma,...
                  'name',          'stimulatorwave1',...
                  'preamble',      sd, ...%(1/sf)-(pw/1000),...
                  'sustain' ,      pw/1000,...
                  'DOut',          stimline,...
                  'loop',          np-1);
%             sma = add_scheduled_wave(sma,...
%                 'name',          'stimulatorwave1',...
%                 'preamble',      0, ...
%                 'sustain' ,      1, ...
%                 'loop',          0);

            sma = add_scheduled_wave(sma,...
                'name',          'stimulatorwave2',...
                'preamble',      0, ...
                'sustain' ,      0, ...
                'loop',          0);
            
         elseif value(WhichStimState)==2;
              sma = add_scheduled_wave(sma,...
                  'name',          'stimulatorwave1',...
                  'preamble',      0, ...
                  'sustain' ,      0, ...
                  'loop',          0);
              sma = add_scheduled_wave(sma,...
                  'name',          'stimulatorwave2',...
                  'preamble',      sd, ...%(1/sf)-(pw/1000),...
                  'sustain' ,      pw/1000,...
                  'DOut',          stimline,...
                  'loop',          np-1);
          end
          
      else
          stimulator_history.value = [sh, 0];
          laser_on.value = 0;
          sma = add_scheduled_wave(sma,...
              'name',          'stimulatorwave1',...
              'preamble',      0, ...
              'sustain' ,      0, ...
              'loop',          0);
          
          sma = add_scheduled_wave(sma,...
              'name',          'stimulatorwave2',...
              'preamble',      0, ...
              'sustain' ,      0, ...
              'loop',          0);
      end
      
      varargout{1} = sma; 
      
      
%% prepare_next_trial
% -----------------------------------------------------------------------
%
%         PREPARE_NEXT_TRIAL
%
% -----------------------------------------------------------------------

  case 'prepare_next_trial',
      sh = value(stimulator_history); %#ok<NODEF>
      
      t = value(PulseWidth);
      PulseWidth.value = [value(nic_time*1000), t(2)];
      t = 1./(value(PulseWidth)/1000);
      StimFreq.value = t;      
      
      sma = x;

      sd = value(StartDelay); 
      sf = value(StimFreq);   
      pw = value(PulseWidth);
      np = value(NumPulses);  
      ss = value(StimStates);
      sl = value(StimLines); %cmc commented this out...


%           if length(unique([length(sd) length(sf) length(pw) length(np) length(ss) length(sl)])) > 1
%               disp('Warning: param values in StimulatorSection have different lengths. Only first value will be used.');
%               temp = 1;

%   case 'prepare_next_trial',
%       sh = value(stimulator_history); %#ok<NODEF>
%       
%       t = value(PulseWidth);
%       PulseWidth.value = [value(nic_time*1000), t(2)];
%       t = 1./(value(PulseWidth)/1000);
%       StimFreq.value = t;      
%       
%       sma = x;
% 
%       sd = value(StartDelay); 
%       sf = value(StimFreq);   
%       pw = value(PulseWidth);
%       np = value(NumPulses);  
%       ss = value(StimStates);
%       %sl = [value(StimLine) value(StimLine)]; %cmc commented this out...
% 
% 
% %           if length(unique([length(sd) length(sf) length(pw) length(np) length(ss) length(sl)])) > 1
% %               disp('Warning: param values in StimulatorSection have different lengths. Only first value will be used.');
% %               temp = 1;
% %           else
% %               temp = ceil(rand(1) * length(sd));
% %           end
%        temp = value(WhichStimState);
%        sd = sd(temp); sf = sf(temp); pw = pw(temp); np = np(temp); ss = ss(temp); %sl = sl(temp);
%        sl = value(StimLine);
% 
%       
%       pss = get(get_ghandle(StimState),'String'); %#ok<NODEF>
%       psl = get(get_ghandle(StimLine), 'String'); %#ok<NODEF>
%       if ss > length(pss)
%           disp('StimState value greater than list of possible stim states');
%       else
%           StimState.value = ss;
%       end
%          
%       
%       slind = find(strcmp(psl, value(StimLine)));
%       if slind > length(psl)
%           slc = ['0',num2str(sl),'0'];
%           z = find(slc == '0');
%           if length(z) > 2
%               sln = [];
%               for i = 1:length(z)-1
%                   sln(end+1) = str2num(slc(z(i)+1:z(i+1)-1)); %#ok<ST2NM,AGROW>
%               end
%               if any(sln > length(psl))
%                 %  disp('StimLine value greater than list of possible stim
%                 %  lines');CMC COMMENTED OUT!
%               else
%                   slname = psl{sln(1)};
%                   for i=2:length(sln)
%                       slname = [slname,'+',psl{sln(i)}]; %#ok<AGROW>
%                   end
%                   if sum(strcmp(psl,slname)) == 0
%                       psl{end+1} = slname; 
%                       set(get_ghandle(StimLine),'String',psl)
%                   end
%                   StimLine.value = find(strcmp(psl,slname)==1,1,'first');
%                   sl = sln;
%               end

%           else
%               disp('StimLine value greater than list of possible stim lines');
%           end
%               sl = value(StimLine);
%       else
%          % StimLine.value  = sl;
%        %   StimLine.value = find(strcmp(psl, value(StimLine)));
%           sl = value(StimLine);
%       end
%       
%    %   for i = 1;%:2;%:length(sl)
%           slind = find(strcmp(psl, value(StimLine)));
%           stimline = bSettings('get','DIOLINES',psl{slind}); 
%       
% %           sma = add_scheduled_wave(sma,...
% %               'name',          ['stimulator_wave',num2str(i)],...
% %               'preamble',      sd, ...%(1/sf)-(pw/1000),...
% %               'sustain' ,      pw/1000,...
% %               'DOut',          stimline,...
% %               'loop',          np-1);
%             sma = add_scheduled_wave(sma,...
%                 'name',          'stimulator_wave',...
%                 'preamble',      sd, ...%(1/sf)-(pw/1000),...
%                 'sustain' ,      pw/1000,...
%                 'DOut',          stimline,...
%                 'loop',          np-1);
% 
% %           if sd ~= 0 %%WHY DID CHUCK PUT THIS IN HERE?
% %               sma = add_scheduled_wave(sma,...
% %                   'name',['stimulator_wave_pause',num2str(i)],...
% %                   'preamble',sd,...
% %                   'trigger_on_up',['stimulator_wave',num2str(i)]);
% %           else
% %               sma = add_scheduled_wave(sma,...
% %                   'name',['stimulator_wave_pause',num2str(i)],...
% %                   'preamble',1,...
% %                   'trigger_on_up',['stimulator_wave',num2str(i)]);
% %           end
%      % end
%       
% %       for i = 1; %:length(sl) CMC COMMENTED THIS OUT
% %           if sh(end) == 1
% %               if strcmp(value(StimState),'none') == 0
% %                   if sd ~= 0
% %                       sma = add_stimulus(sma,['stimulator_wave_pause',num2str(i)],value(StimState));
% %                   else
% %                       sma = add_stimulus(sma,['stimulator_wave',num2str(i)],value(StimState));
% %                   end
% % 
% %                   SD.value = sd; SF.value = sf; PW.value = pw; NP.value = np;
% %               end
% %           else
% %               SD.value = 0; SF.value = 0; PW.value = 0; NP.value = 0;
% %           end
% %       end
%       
%       varargout{1} = sma; 

      
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


