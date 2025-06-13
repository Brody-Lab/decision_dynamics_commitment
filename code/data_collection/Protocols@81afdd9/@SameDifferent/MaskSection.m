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



function [varargout] = MaskSection(obj, action, x, y)
   
GetSoloFunctionArgs(obj);

switch action
    
%% init
% ----------------------------------------------------------------
%
%       INIT
%
% ----------------------------------------------------------------
  
  case 'init', 
      
      SoloParamHandle(obj, 'my_xyfig', 'value', [x y double(gcf)]);
      ToggleParam(obj, 'MaskShow', 0, x, y, 'OnString', 'Mask showing', ...
        'OffString', 'Mask hidden', 'TooltipString', 'Show/Hide mask panel'); 
      set_callback(MaskShow, {mfilename, 'show_hide'}); %(Defined just above)
      next_row(y);
    
      SoloParamHandle(obj, 'myfig', 'value', figure('Position', [100 100 250 250], ...
        'closerequestfcn', [mfilename '(' class(obj) ', ''hide'');'], 'MenuBar', 'none', ...
        'Name', mfilename), 'saveable', 0);
      set(gcf, 'Visible', 'off');
    
      x=10;
      y=10;
      
      next_row(y);
      
      MenuParam(obj,'MaskOnSide',{'both','left','right'},1,x,y,'labelfraction',0.3); next_row(y);
      
      diolines = bSettings('get','DIOLINES', 'all');
      for i = 1:size(diolines,1); dionames{i} = diolines{i,1}; dionums(i) = diolines{i,2}; end %#ok<AGROW>
      [dionums order] = sort(dionums);
      dionames2 = cell(0);
      for i = 1:length(dionums); if ~isnan(dionums(i)); dionames2{end+1} = dionames{order(i)}; end; end %#ok<AGROW>
      
      MenuParam(obj,'MaskLine',dionames2,1,x,y,'labelfraction',0.30); next_row(y);
      
      SC = state_colors(obj);
      WC = wave_colors(obj); 
      states = fieldnames(SC);
      waves  = fieldnames(WC);
      states(2:end+1) = states;
      states{1} = 'none';
      states(end+1:end+length(waves)) = waves;
      
      MenuParam(obj,'MaskState',states,1,x,y,'labelfraction',0.30); next_row(y);
      
      NumeditParam(obj,'MaskStates', 1,x,y,'position',[x     y 100 20],'labelfraction',0.60);
      NumeditParam(obj,'MaskLines',  1,x,y,'position',[x+100 y 100 20],'labelfraction',0.60); next_row(y);
      
      NumeditParam(obj,'StartDelay', 0,x,y,'position',[x     y 100 20],'labelfraction',0.60);
      NumeditParam(obj,'MaskFreq',  20,x,y,'position',[x+100 y 100 20],'labelfraction',0.60); next_row(y);
      NumeditParam(obj,'PulseWidth',15,x,y,'position',[x     y 100 20],'labelfraction',0.60); 
      NumeditParam(obj,'NumPulses', 10,x,y,'position',[x+100 y 100 20],'labelfraction',0.60); next_row(y);
      
      DispParam(obj,'SD',0 ,x,y,'position',[x     y 50 20],'labelfraction',0.4);
      DispParam(obj,'MF',20,x,y,'position',[x+50  y 50 20],'labelfraction',0.4);
      DispParam(obj,'PW',15,x,y,'position',[x+100 y 50 20],'labelfraction',0.4);
      DispParam(obj,'NP',10,x,y,'position',[x+150 y 50 20],'labelfraction',0.4); next_row(y);
      
      NumeditParam(obj,'MaskProb',     0,x,y,'position',[x     y 100 20],'labelfraction',0.65);
      ToggleParam( obj,'ShuffleValues',0,x,y,'position',[x+100 y 100 20],'OnString','Shuffle','OffString','Lock');  next_row(y);
      
      SoloParamHandle(obj, 'mask_history',   'value', []);
          
      SubheaderParam(obj, 'title', 'Mask Section', x, y); next_row(y);
      varargout{1} = x;
      varargout{2} = y;
      MaskSection(obj,'hide');
        figure(value(my_xyfig(3)));
      
   
%% update_values
% -----------------------------------------------------------------------
%
%         UPDATE_VALUES
%
% -----------------------------------------------------------------------

  case 'update_values',
      mh = value(mask_history); %#ok<NODEF>
      %if n_done_trials == 0 || sh(end) == 0
      %    LegalCBrk_temp.value = value(LegalCBrk); %#ok<NODEF>
      %end
      
      if ~dispatcher('is_running');
          %dispatcher is not running, last stim_hist not used, lop it off
          mh = mh(1:end-1);
      end
      
      if value(MaskProb) == 0
          %LCB_nomask.value = value(LegalCBrk); %#ok<NODEF>
          mask_history.value = [mh, 0];
      elseif rand(1) <= value(MaskProb)
          mask_history.value = [mh, 1];
          %LegalCBrk.value = value(LCB_onmask);
      else
          %LegalCBrk.value = value(LCB_nomask); %#ok<NODEF>
          mask_history.value = [mh, 0];
      end
          
      
      
%% prepare_next_trial
% -----------------------------------------------------------------------
%
%         PREPARE_NEXT_TRIAL
%
% -----------------------------------------------------------------------

  case 'prepare_next_trial',
      mh = value(mask_history); %#ok<NODEF>
      
      sma = x;

      sd = value(StartDelay); 
      mf = value(MaskFreq);   
      pw = value(PulseWidth);
      np = value(NumPulses);  
      ms = value(MaskStates);
      ml = value(MaskLines);

      if value(ShuffleValues) == 1
          sd = sd(ceil(rand(1) * length(sd)));
          mf = mf(ceil(rand(1) * length(mf)));
          pw = pw(ceil(rand(1) * length(pw)));
          np = np(ceil(rand(1) * length(np)));
          ms = ms(ceil(rand(1) * length(ms)));
          ml = ml(ceil(rand(1) * length(ml)));
      else
          if length(unique([length(sd) length(mf) length(pw) length(np) length(ms) length(ml)])) > 1
              disp('Warning: param values in MaskSection have different lengths. Only first value will be used.');
              temp = 1;
          else
              temp = ceil(rand(1) * length(sd));
          end
          sd = sd(temp); mf = mf(temp); pw = pw(temp); np = np(temp); ms = ms(temp); ml = ml(temp);
      end
      
      pms = get(get_ghandle(MaskState),'String'); %#ok<NODEF>
      pml = get(get_ghandle(MaskLine), 'String'); %#ok<NODEF>
      if ms > length(pms)
          disp('MaskState value greater than list of possible mask states');
      else
          MaskState.value = ms;
      end
          
      if ml > length(pml)
          mlc = ['0',num2str(ml),'0'];
          z = find(mlc == '0');
          if length(z) > 2
              mln = [];
              for i = 1:length(z)-1
                  mln(end+1) = str2num(mlc(z(i)+1:z(i+1)-1)); %#ok<ST2NM,AGROW>
              end
              if any(mln > length(pml))
                  disp('MaskLine value greater than list of possible mask lines');
              else
                  mlname = pml{mln(1)};
                  for i=2:length(mln)
                      mlname = [mlname,'+',pml{mln(i)}]; %#ok<AGROW>
                  end
                  if sum(strcmp(pml,mlname)) == 0
                      pml{end+1} = mlname; 
                      set(get_ghandle(MaskLine),'String',pml)
                  end
                  MaskLine.value = find(strcmp(pml,mlname)==1,1,'first');
                  ml = mln;
              end
          else
              disp('MaskLine value greater than list of possible mask lines');
          end
      else
          MaskLine.value  = ml;
      end
      
      for i = 1:length(ml)
          maskline = bSettings('get','DIOLINES',pml{ml(i)}); 
      
          sma = add_scheduled_wave(sma,...
              'name',          ['mask_wave',num2str(i)],...
              'preamble',      (1/mf)-(pw/1000),...
              'sustain' ,      pw/1000,...
              'DOut',          maskline,...
              'loop',          np-1);

          if sd ~= 0
              sma = add_scheduled_wave(sma,...
                  'name',['mask_wave_pause',num2str(i)],...
                  'preamble',sd,...
                  'trigger_on_up',['mask_wave',num2str(i)]);
          else
              sma = add_scheduled_wave(sma,...
                  'name',['mask_wave_pause',num2str(i)],...
                  'preamble',1,...
                  'trigger_on_up',['mask_wave',num2str(i)]);
          end
      end
      
      for i = 1:length(ml)
          if mh(end) == 1
              if strcmp(value(MaskState),'none') == 0
                  if sd ~= 0
                      sma = add_stimulus(sma,['mask_wave_pause',num2str(i)],value(MaskState));
                  else
                      sma = add_stimulus(sma,['mask_wave',num2str(i)],value(MaskState));
                  end

                  SD.value = sd; MF.value = mf; PW.value = pw; NP.value = np;
              end
          else
              SD.value = 0; MF.value = 0; PW.value = 0; NP.value = 0;
          end
      end
      
      varargout{1} = sma; 

      
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
    
  case 'hide',
    MaskShow.value = 0; set(value(myfig), 'Visible', 'off');

  case 'show',
    MaskShow.value = 1; set(value(myfig), 'Visible', 'on');

  case 'show_hide',
    if MaskShow == 1, set(value(myfig), 'Visible', 'on'); %#ok<NODEF> (defined by GetSoloFunctionArgs)
    else              set(value(myfig), 'Visible', 'off');
    end;
    
    
    %% get_send_summary_info
case 'get_send_summary_info',
		upto=x;
        clear x;
		ml=get_history(MaskLine);
        vml=zeros(numel(ml),1);
        for tx=1:numel(ml)
            tml=sscanf(ml{tx},'stim%d');
            if ~isempty(tml)
                vml(tx)=tml;
            end
        end
        
        np=cell2mat(get_history(NP));
        vml(np==0)=0;
        
        
        x.maskline=vml(1:upto);
        varargout{1}=x;
        
end;


