

function [x, y] = StimulusSection(obj, action, varargin)

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
    
    ToggleParam(obj, 'StimulusShow', 0, x, y, 'OnString', 'Stimuli', ...
      'OffString', 'Stimuli', 'TooltipString', 'Show/Hide Stimulus panel'); 
    set_callback(StimulusShow, {mfilename, 'show_hide'}); %#ok<NODEF> (Defined just above)
    next_row(y);
    
    SoloParamHandle(obj, 'myfig', 'value', figure('closerequestfcn', [mfilename '(' class(obj) ', ''hide'');'], 'MenuBar', 'none', ...
      'Name', mfilename), 'saveable', 0);
    screen_size = get(0, 'ScreenSize');
    set(value(myfig),'Position',[1 screen_size(4)-740, 1000 1000]); % put fig at top right
    set(gcf, 'Visible', 'off');
    x=10;y=10;
         
    SoloParamHandle(obj, 'ax', 'saveable', 0, ...
                   'value', axes('Position', [0.01 0.5 0.45 0.45]));
    ylabel('log_e \sigma_2','FontSize',16,'FontName','Cambria Math');  
    set(value(ax),'Fontsize',15)
    xlabel('log_e \sigma_1','FontSize',16,'FontName','Cambria Math')

    SoloParamHandle(obj, 'axperf', 'saveable', 0, ...
                   'value', axes('Position', [0.5 0.5 0.45 0.45]));
    ylabel('log_e \sigma_2','FontSize',16,'FontName','Cambria Math');  
    set(value(axperf),'Fontsize',15)
    xlabel('log_e \sigma_1','FontSize',16,'FontName','Cambria Math')
    
    SoundManagerSection(obj, 'declare_new_sound', 'StimAUD1')
    SoundManagerSection(obj, 'declare_new_sound', 'StimAUD2')
    SoloParamHandle(obj, 'thesepairs', 'value', []);
    SoloParamHandle(obj, 'pairs_d', 'value', []);
    SoloParamHandle(obj, 'pairs_u', 'value', []);
    SoloParamHandle(obj, 'pairs_d_psych', 'value', []);
    SoloParamHandle(obj, 'pairs_u_psych', 'value', []);
    SoloParamHandle(obj, 'h1', 'value', []); 
    SoloParamHandle(obj, 'thisclass', 'value', []);

    y=5;
    MenuParam(obj, 'StimulusType', {'library', 'new'}, ...
      'new', x, y, 'labelfraction', 0.35, 'TooltipString', sprintf(['\nnew means at each trial, a new noise pattern will be generated,\n' ...
      '"library" means for each trial stimulus is loaded from a library with limited number of noise patterns'])); next_row(y, 1.3)
    set_callback(StimulusType, {mfilename, 'StimulusType'});
	NumeditParam(obj,'nPatt',50,x,y,'label','Num Nois Patt','TooltipString','Number of Noise Patters for the library');
    
    next_row(y);
    next_row(y);
    PushbuttonParam(obj, 'refresh_pairs', x,y , 'TooltipString', 'Instantiates the pairs given the new set of parameters');
    set_callback(refresh_pairs, {mfilename, 'plot_pairs'});
    
    next_row(y);
    PushbuttonParam(obj, 'plot_performance', x,y , 'TooltipString', 'Plots the class design with mean performance for each class');
    set_callback(plot_performance, {mfilename, 'plot_perf'});
    
    next_row(y);
    next_row(y);
    MenuParam(obj, 'Rule', {'S2>S1 Left','S2>S1 Right'}, ...
      'S2>S1 Left', x, y, 'labelfraction', 0.35, 'TooltipString', sprintf(['\nThis bottom determines the rule\n', ...
      '\n''S2>S1 Left'' means if Aud2 > Aud1 then reward will be delivered from the left water spout and if Aud2 < Aud1 then water comes form right\n',...
      '\n''S2>S1 Right'' means if Aud2 < Aud1 then reward will be delivered from the left water spout and if Aud2 > Aud1 then water comes from right\n'])); 
    next_row(y, 1)
    ToggleParam(obj, 'midclass_pairs', 0, x,y,...
			'OnString', 'Mid Class Pairs ON',...
			'OffString', 'Mid Class Pairs OFF',...
			'TooltipString', sprintf('If on (Yellow) then stimulus pairs between the main class pairs will be included'));
    
    next_column(x);
    y=5;
    MenuParam(obj, 'filter_type', {'GAUS','LPFIR', 'FIRLS','BUTTER','MOVAVRG','KAISER','EQUIRIP','HAMMING'}, ...
      'GAUS', x, y, 'labelfraction', 0.35, 'TooltipString', sprintf(['\nDifferent filters. ''LPFIR'': lowpass FIR ''FIRLS'': Least square linear-phase FIR filter design\n', ...
      '\n''BUTTER'': IIR Butterworth lowpass filter ''GAUS'': Gaussian filter (window)\n', ...
      '\n''MOVAVRG'': Moving average FIR filter ''KAISER'': Kaiser-window FIR filtering\n', ...
      '\n''EQUIRIP'':Eqiripple FIR filter ''HAMMING'': Hamming-window based FIR'])); 
    next_row(y, 1)
    DispParam(obj, 'A1_sigma', 0.01, x,y,'label','A1_sigma','TooltipString','Sigma value for the first stimulus');
	next_row(y);
    DispParam(obj, 'A2_sigma', 0.01, x,y,'label','A2_sigma','TooltipString','Sigma value for the first stimulus');
	next_row(y);
	NumeditParam(obj,'fcut',110,x,y,'label','fcut','TooltipString','Cut off frequency on the original white noise');
    next_row(y);
	NumeditParam(obj,'lfreq',2000,x,y,'label','Modulator_LowFreq','TooltipString','Lower bound for the frequency modulator');
	next_row(y);
	NumeditParam(obj,'hfreq',20000,x,y,'label','Modulator_HighFreq','TooltipString','Upper bound for the frequency modulator');	
    next_row(y);
% 	NumeditParam(obj,'outband',60,x,y,'label','Outband','TooltipString','outband on the distribution from which white noise is produced');
%     next_row(y);
	NumeditParam(obj,'minS1',0.007,x,y,'label','minS1','TooltipString','min sigma value for AUD1');
    next_row(y);
	DispParam(obj,'maxS',40,x,y,'label','maxS','TooltipString','max sigma value for AUD1');
    NumeditParam(obj,'s2_s1_ratio',2.6,x,y,'label','s2_s1_ratio','TooltipString','Intensity index i.e. Ind=(S1-S2)/(S1+S2)');
    next_row(y);
    ToggleParam(obj, 'psych_pairs', 0, x,y,...
        'OnString', 'Psych Pairs ON',...
        'OffString', 'Psych Pairs OFF',...
        'TooltipString', sprintf('If on (black) then it disable the presentation of psychometric pairs'));
 	next_row(y);
    NumeditParam(obj,'nPsych',6,x,y,'label','Num Psych Pairs','TooltipString','Number of psychometric pairs');
    next_row(y);
    NumeditParam(obj,'from',0.047,x,y,'label','lowest pair','TooltipString','Psychometric pairs will be put between this pair, and an upper pair based on Ratio');
    next_row(y);
    MenuParam(obj, 'psych_type', {'horizpairs', 'vertpairs'}, ...
      'horizpairs', x, y, 'labelfraction', 0.35, 'TooltipString', sprintf(['\nhorizpairs means psychometric pairs will be built with "from" as their fixed S2 while S1 will increase,\n' ...
      '"vertpairs" means psychometric pairs will be built with "from" as their fixed S1 while S2 will increase'])); next_row(y, 1.3)
    NumeditParam(obj,'probpsych',0.9,x,y,'label','probpsych','TooltipString','probability of having a psychometric pair as the stimulus pair at each trial');
    disable(nPatt);
    next_column(x);
    y=5;
    SoloParamHandle(obj, 'existing_numClassPsych', 'value', 0, 'saveable', 0);
    SoloParamHandle(obj, 'existing_numClass', 'value', 0, 'saveable', 0);
    SoloParamHandle(obj, 'my_window_info', 'value', [x, y, 200 200], 'saveable', 0);
    NumeditParam(obj,'numClass',4,x,y,'label','numClass','TooltipString','Number of stimulus pairs');
    
    set_callback_on_load(numClass, 4); %#ok<NODEF>
    set_callback(numClass, {mfilename, 'numClass'});
    numClass.value = 4; callback(numClass);
    StimulusSection(obj,'plot_pairs');
    set_callback(psych_pairs, {mfilename, 'PsychPairs'});


  case 'prepare_next_trial' 

    %% d or u?
    SideSection(obj,'get_current_side');

    if strcmp(Rule,'S2>S1 Left')
        if strcmp(ThisTrial, 'LEFT')
            bag=[];
            for cc=1:value(numClass)+(numClass-1)*value(midclass_pairs)
                eval(sprintf('pr=value(probClass%d);',cc+value(numClass))); 
                bag=[bag ones(1,(10-floor(10*probpsych))*pr)*value(cc)];
            end
            
            if psych_pairs ==1
                for cc=value(numClass)+1:value(numClass)+value(nPsych)/2
                    bag = [bag ones(1,(floor(probpsych*10)))*value(cc)];
                end 
            end
            pp=randsample(bag,length(bag));
            thispair=[pairs_u(pp(1),1) pairs_u(pp(1),2)];
            if pp(1) > value(numClass)
                thisclass(n_done_trials+1)=pp(1)+numClass+nPsych/2;   
            else
                thisclass(n_done_trials+1)=pp(1)+numClass;
            end
        else
            
            bag=[];
            for cc=1:value(numClass)+(numClass-1)*value(midclass_pairs)
                eval(sprintf('pr=value(probClass%d);',cc));
                bag=[bag ones(1,(10-floor(10*probpsych))*pr)*value(cc)];
            end
            
            if psych_pairs ==1
                for cc=value(numClass)+1:value(numClass)+value(nPsych)/2
                    bag = [bag ones(1,(floor(probpsych*10)))*(value(cc))];
                end 
            end
            pp=randsample(bag,length(bag));
            thispair=[pairs_d(pp(1),1) pairs_d(pp(1),2)];
            if pp(1) > value(numClass)
                thisclass(n_done_trials+1)=pp(1)+numClass;   
            else
            thisclass(n_done_trials+1)=pp(1);
            end            
        end;
    elseif strcmp(Rule,'S2>S1 Right')
        if strcmp(ThisTrial, 'RIGHT')
            bag=[];
            for cc=1:value(numClass)+(numClass-1)*value(midclass_pairs)
            eval(sprintf('pr=value(probClass%d);',cc+value(numClass))); 
            bag=[bag ones(1,(10-floor(10*probpsych))*pr)*value(cc)];
            end
    
            if psych_pairs ==1
                for cc=value(numClass)+1:value(numClass)+value(nPsych)/2
                    bag = [bag ones(1,(floor(floor(probpsych*10))))*(value(cc)+numClass*2)];
                end 
            end
            
            pp=randsample(bag,length(bag));
            thispair=[pairs_u(pp(1),1) pairs_u(pp(1),2)];
            if pp(1) > value(numClass*2)
                thisclass(n_done_trials+1)=pp(1)+numClass*2;   
            else
                thisclass(n_done_trials+1)=pp(1)+numClass;
            end
            
        else
            bag=[];
            for cc=1:value(numClass)+(numClass-1)*value(midclass_pairs)
            eval(sprintf('pr=value(probClass%d);',cc));
            bag=[bag ones(1,(10-floor(10*probpsych))*pr)*value(cc)];
            end
            
            if psych_pairs ==1
                for cc=value(numClass)+1:value(numClass)+value(nPsych)/2
                    bag = [bag ones(1,(floor(floor(probpsych*10))))*(value(cc)+numClass)];
                end 
            end
            
            pp=randsample(bag,length(bag));
            thispair=[pairs_d(pp(1),1) pairs_d(pp(1),2)];
            
            if pp(1) > value(numClass)
                thisclass(n_done_trials+1)=pp(1)+numClass;   
            else
            thisclass(n_done_trials+1)=pp(1);
            end
        end;
    end
      
    A1_sigma.value=thispair(1);
    A2_sigma.value=thispair(2);

 
    set(value(h1), 'XData', log(value(A1_sigma)), 'Ydata', log(value(A2_sigma)));

    %% produce noise pattern 
    srate=SoundManagerSection(obj,'get_sample_rate');
    Fs=srate;
    T=max(value(A2_time),value(A1_time));
    [rawA1 rawA2 normA1 normA2]=noisestim(1,1,T,value(fcut),Fs,value(filter_type));
    modulator=singlenoise(1,T,[value(lfreq) value(hfreq)],Fs,'BUTTER');
    AUD1=normA1(1:A1_time*srate).*modulator(1:A1_time*srate).*A1_sigma;
    AUD2=normA2(1:A2_time*srate).*modulator(1:A2_time*srate).*A2_sigma;

    if ~isempty(AUD1)
        SoundManagerSection(obj, 'set_sound', 'StimAUD1', [AUD1';  AUD1'])
    end
    if ~isempty(AUD2)
    SoundManagerSection(obj, 'set_sound', 'StimAUD2', [AUD2';  AUD2'])
    end

    SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');

    if n_done_trials >0
        
        if ~violation_history(n_done_trials) && ~timeout_history(n_done_trials) 
            eval(sprintf('nTrialsClass%d.value=nTrialsClass%d+1;',thisclass(n_done_trials),thisclass(n_done_trials)));
            eval(sprintf('nt = value(nTrialsClass%d);',thisclass(n_done_trials)));
            if nt == 1
                eval(sprintf('perfClass%d.value = 0;',thisclass(n_done_trials)))
            end
            eval(sprintf('perfClass%d.value=(perfClass%d * (nTrialsClass%d - 1) +%d)/nTrialsClass%d;',thisclass(n_done_trials),thisclass(n_done_trials),thisclass(n_done_trials),hit_history(n_done_trials),thisclass(n_done_trials)));
        end
        StimulusSection(obj,'update_pair_history');

%         xd=log(thispair(1));
%         yd=log(thispair(2));
%         axes(value(axperf));
%         eval(sprintf('delete(hperf%d);',thisclass(n_done_trials)));
%         eval(sprintf('text(xd,yd,num2str(value(perfClass%d)));',thisclass(n_done_trials)));
%         %eval(sprintf('set(value(hperf%d), ''XData'', %f, ''Ydata'', %f);',thisclass(n_done_trials),xd,yd));

    end

    
    %% Case new_numClass
  case 'new_numClass'
    for cc=1:20    
        eval(sprintf('disable(probClass%d)',cc)) 
    end
    for cc=1:2*value(numClass)
        eval(sprintf('enable(probClass%d)',cc)) 
    end
    
    %% case numClass
  case 'numClass',
      if numClass > existing_numClass,        %#ok<NODEF>
         orig_fig = double(gcf);
         %my_window_visibility = get(my_window_info(3), 'Visible');
         %x = my_window_info(1); y = my_window_info(2); figure(my_window_info(3));
         x = 200; y = 200;
         %set(my_window_info(3), 'Visible', my_window_visibility);
         
         next_row(y, 1+ value(existing_numClass*2));
         new_class = (existing_numClass*2 + 1):value(numClass*2);
         for newnum = new_class,

            NumeditParam(obj,['probClass',num2str(newnum)],1,x,y,'label',['probClass ',num2str(newnum)],'TooltipString','Probability of this pair');
            next_column(x); 
            DispParam(obj,['perfClass',num2str(newnum)],nan,x,y,'label',['perfClass ',num2str(newnum)],'TooltipString','Performance on this pair');
            next_column(x); 
            DispParam(obj,['nTrialsClass',num2str(newnum)],0,x,y,'label',['nTrialsClass ',num2str(newnum)],'TooltipString','Number of trials on this pair');
            next_row(y);  x = my_window_info(1);
            SoloParamHandle(obj, ['hperf',num2str(newnum)], 'value', 0);

         end;
         
         existing_numClass.value = value(numClass);
         figure(orig_fig);
         
      elseif numClass < existing_numClass,
         % If asking for fewer vars than exist, delete excess:
         for oldnum = (numClass*2+1):value(existing_numClass*2);
            sphname = ['probClass' num2str(oldnum)];
            delete(eval(sphname));
            sphname = ['perfClass' num2str(oldnum)];
            delete(eval(sphname));
            sphname = ['nTrialsClass' num2str(oldnum)];
            delete(eval(sphname));
         end;
         existing_numClass.value = value(numClass);
     
      else
          x = my_window_info(1); y = my_window_info(2);
          new_class = (1):value(numClass*2);
            for newnum = new_class,
                next_row(y);
            end;
      end
       
      % Now check for whether we are in the middle of load settings or load
      % data.
   
      varhandles = {};varhandles1 = {};varhandles2 = {};
      for i = 1:value(numClass), 
            varhandles = [varhandles ; {eval(['probClass' num2str(i)])}]; %#ok<AGROW>
            varhandles1 = [varhandles1 ; {eval(['perfClass' num2str(i)])}]; %#ok<AGROW>
            varhandles2 = [varhandles2 ; {eval(['nTrialsClass' num2str(i)])}]; %#ok<AGROW>
      end;
       load_solouiparamvalues(obj, 'ratname', 'rescan_during_load', varhandles);
       load_solouiparamvalues(obj, 'ratname', 'rescan_during_load', varhandles1);
       load_solouiparamvalues(obj, 'ratname', 'rescan_during_load', varhandles2);
      
      if value(psych_pairs) ==1
          SoloParamHandle(obj, 'my_window_info', 'value', [x, y, 200, 200], 'saveable', 0);
          StimulusSection(obj,'PsychClass');
      end
      StimulusSection(obj,'plot_pairs');
      
    %% Case PsychClass
    case 'PsychClass' 
         orig_fig = double(gcf);
         %my_window_visibility = get(my_window_info(3), 'Visible');
         x = my_window_info(1); y = my_window_info(2); figure(my_window_info(3));
         %set(my_window_info(3), 'Visible', my_window_visibility);
         
      if nPsych > existing_numClassPsych,        %#ok<NODEF>

         next_row(y, 1+ value(existing_numClassPsych));
         new_class = (existing_numClassPsych + 1):value(nPsych);
         for newnum = new_class,
            DispParam(obj,['perfClass',num2str(newnum+numClass*2)],nan,x,y,'label',['perfClass ',num2str(newnum+numClass*2)],'TooltipString','Performance on this pair');
            next_column(x); 
            DispParam(obj,['nTrialsClass',num2str(newnum+numClass*2)],0,x,y,'label',['nTrialsClass ',num2str(newnum+numClass*2)],'TooltipString','Number of trials on this pair');
            next_row(y);  x = my_window_info(1);
            SoloParamHandle(obj, ['hperf',num2str(newnum+numClass*2)], 'value', 0);

         end;
         
         existing_numClassPsych.value = value(nPsych);
         figure(orig_fig);
         
      elseif nPsych < existing_numClassPsych,
         % If asking for fewer vars than exist, delete excess:
         for oldnum = (nPsych+1):value(existing_numClassPsych);
            sphname = ['perfClass' num2str(oldnum+numClass*2)];
            delete(eval(sphname));
            sphname = ['nTrialsClass' num2str(oldnum+numClass*2)];
            delete(eval(sphname));
         end;
         existing_numClassPsych.value = value(nPsych);
     
      end;
       
   
      varhandles = {};varhandles1 = {};varhandles2 = {};
      for i = 1:value(nPsych), 
            varhandles1 = [varhandles1 ; {eval(['perfClass' num2str(i+numClass*2)])}]; %#ok<AGROW>
            varhandles2 = [varhandles2 ; {eval(['nTrialsClass' num2str(i+numClass*2)])}]; %#ok<AGROW>
      end;
       load_solouiparamvalues(obj, 'ratname', 'rescan_during_load', varhandles1);
       load_solouiparamvalues(obj, 'ratname', 'rescan_during_load', varhandles2);

    %% Case StimulusType  
    case 'StimulusType'
    if strcmp(StimulusType, 'library');
        enable((nPatt));
        %disable(seed);
        %set(get_ghandle(seed), 'Enable', 'off');    
    else
        disable(nPatt);
    end
        
    
    %% Case make_pairs
    case 'make_pairs'
   %% make numClass pairs of sigma values -pairs are high to low (d) and low to high (u)   
    Ind=(value(s2_s1_ratio-1))/(1+value(s2_s1_ratio));
    S1_d(1)=value(minS1);
    S2_d(1)=S1_d(1)*(1-Ind)/(1+Ind);
    S1_u(1)=S1_d;
    S2_u(1)=S1_u(1)*(1+Ind)/(1-(Ind));
    for ii=2:value(numClass+1)
    S1_d(ii)=S2_u(ii-1);    
    S2_d(ii)=S1_d(ii)*(1-Ind)/(1+Ind);
    S1_u(ii)=S1_d(ii);    
    S2_u(ii)=S1_u(ii)*(1+Ind)/(1-Ind);
    end
    pairs=[];
    pairs(:,1)=[S1_d S1_u];
    pairs(:,2)=[S2_d S2_u];

    mainpairs=pairs(2:end-1,:);
    if midclass_pairs
        
        for ii=1:length(S1_u)-1
            mS1_d(ii)=0.5*(log(S1_d(ii)*S1_d(ii+1)));
            mS2_d(ii)=0.5*(log(S2_d(ii)*S2_d(ii+1)));
            mS1_u(ii)=0.5*(log(S1_u(ii)*S1_u(ii+1)));
            mS2_u(ii)=0.5*(log(S2_u(ii)*S2_u(ii+1)));
        end
        mS1_d(ii+1)=mS1_d(ii);
        mS2_d(ii+1)=mS2_d(ii);
        mS1_u(ii+1)=mS1_u(ii);
        mS2_u(ii+1)=mS2_u(ii);

        mpairs(:,1)=exp([mS1_d mS1_u]);
        mpairs(:,2)=exp([mS2_d mS2_u]);
        midpairs=mpairs(2:end-1,:);
        
        [m,n]=size(midpairs');
        thesepairs.value=reshape(permute(cat(3,mainpairs',midpairs'), [1 3 2]), [m 2*n]);
        thesepairs.value=value(thesepairs)';
        pairs_d.value=thesepairs(1:value(numClass)*2-1,:);
        pairs_u.value=thesepairs(value(numClass)*2+1:value(numClass)*4-1,:);
        
        thesepairs.value=[value(pairs_d);value(pairs_u)];
        if psych_pairs
            StimulusSection(obj,'PsychPairs'); 
            thesepairs.value=[value(thesepairs);value(pairs_d_psych);value(pairs_u_psych)];
        end
        
    else
        thesepairs.value=pairs(2:end-1,:);
        pairs_d.value=thesepairs(1:value(numClass),:);
        pairs_u.value=thesepairs(value(numClass)+1:value(numClass)*2,:);
        
        thesepairs.value=[value(pairs_d);value(pairs_u)];
        if psych_pairs
            StimulusSection(obj,'PsychPairs'); 
            thesepairs.value=[value(thesepairs);value(pairs_d_psych);value(pairs_u_psych)];
        end
    end
      
    %% Case plot_pais
    case 'plot_pairs'  
    StimulusSection(obj,'make_pairs');     
    maxS.value=max(thesepairs(:));
    %% plot the pair set
    cla(value(ax))
    xd=log(thesepairs(:,1));
    yd=log(thesepairs(:,2));
    for ii=1:length(xd)
        axes(value(ax));
        plot(xd(ii),yd(ii),'s','MarkerSize',15,'MarkerEdgeColor',[0 0 0],'LineWidth',2)
        hold on
        eval(sprintf('hperf%d=text(xd(ii),yd(ii),num2str(ii));',ii));
        hold on
    end
    axis square
%      Ytick=get(value(ax),'YtickLabel');
%      Xtick=get(value(ax),'XtickLabel');
    set(value(ax),'ytick',((yd(1:1+value(midclass_pairs):(end-nPsych*psych_pairs)/2))),'xtick',((xd(1:1+value(midclass_pairs):(end-nPsych*psych_pairs)/2))));
    set(value(ax),'yticklabel',num2str(exp(yd(1:1+value(midclass_pairs):(end-nPsych*psych_pairs)/2)),2),'xticklabel',num2str(exp(xd(1:1+value(midclass_pairs):(end-nPsych*psych_pairs)/2)),2));
    ylabel('\sigma_2 in log scale','FontSize',16,'FontName','Cambria Math');  
    set(value(ax),'Fontsize',15)
    xlabel('\sigma_1 in log scale','FontSize',16,'FontName','Cambria Math')

    SideSection(obj,'get_current_side');
    if strcmp(Rule,'S2>S1 Left')
        if strcmp(ThisTrial, 'LEFT')
            bag=[];
            for cc=1:value(numClass)+(numClass-1)*value(midclass_pairs)
                eval(sprintf('pr=value(probClass%d);',cc+value(numClass))); 
                bag=[bag ones(1,(10-floor(10*value(probpsych)))*pr)*value(cc)];
            end
            pp=1;
            if psych_pairs ==1
                for cc=value(numClass)+1:value(numClass)+value(nPsych)/2
                    bag = [bag ones(1,(floor(probpsych*10)))*value(cc)];
                end 
            end
            pp=randsample(bag,length(bag));
            thispair=[pairs_u(pp(1),1) pairs_u(pp(1),2)];
            if pp(1) > value(numClass*2)
                thisclass(n_done_trials+1)=pp(1)+numClass*2;   
            else
                thisclass(n_done_trials+1)=pp(1)+numClass;
            end
        else
            
            bag=[];
            for cc=1:value(numClass)+(numClass-1)*value(midclass_pairs)
                eval(sprintf('pr=value(probClass%d);',cc));
                bag=[bag ones(1,(10-floor(10*value(probpsych)))*pr)*value(cc)];
            end
            pp=1;
            if psych_pairs ==1
                for cc=value(numClass)+1:value(numClass)+value(nPsych)/2
                    bag = [bag ones(1,(floor(probpsych*10)))*(value(cc))];
                end 
            end
            pp=randsample(bag,length(bag));
            thispair=[pairs_d(pp(1),1) pairs_d(pp(1),2)];
            if pp(1) > value(numClass)
                thisclass(n_done_trials+1)=pp(1)+numClass;   
            else
            thisclass(n_done_trials+1)=pp(1);
            end            
        end;
    elseif strcmp(Rule,'S2>S1 Right')
        if strcmp(ThisTrial, 'RIGHT')
            bag=[];
            for cc=1:value(numClass)+(numClass-1)*value(midclass_pairs)
            eval(sprintf('pr=value(probClass%d);',cc+value(numClass))); 
            bag=[bag ones(1,(10-floor(10*value(probpsych)))*pr)*value(cc)];
            end
    
            if psych_pairs ==1
                for cc=value(numClass)+1:value(numClass)+value(nPsych)/2
                    bag = [bag ones(1,(floor(probpsych*10)))*(value(cc)+numClass*2)];
                end 
            end
            
            pp=randsample(bag,length(bag));
            thispair=[pairs_u(pp(1),1) pairs_u(pp(1),2)];
            if pp(1) > value(numClass*2)
                thisclass(n_done_trials+1)=pp(1)+numClass*2;   
            else
                thisclass(n_done_trials+1)=pp(1)+numClass;
            end
            
        else
            bag=[];
            for cc=1:value(numClass)+(numClass-1)*value(midclass_pairs)
            eval(sprintf('pr=value(probClass%d);',cc));
            bag=[bag ones(1,(10-floor(10*value(probpsych)))*pr)*value(cc)];
            end
            
            if psych_pairs ==1
                for cc=value(numClass)+1:value(numClass)+value(nPsych)/2
                    bag = [bag ones(1,(floor(probpsych*10)))*(value(cc)+numClass)];
                end 
            end
            
            pp=randsample(bag,length(bag));
            thispair=[pairs_d(pp(1),1) pairs_d(pp(1),2)];
            
            if pp(1) > value(numClass)
                thisclass(n_done_trials+1)=pp(1)+numClass;   
            else
            thisclass(n_done_trials+1)=pp(1);
            end
        end;
    end
        A1_sigma.value=thispair(1);
        A2_sigma.value=thispair(2);

        %% plot the pair
        h1.value=plot(log(value(A1_sigma)),log(value(A2_sigma)),'s','color',[0.8 0.4 0.1],'markerfacecolor',[0.8 0.4 0.1],'MarkerSize',15,'LineWidth',3);
        %LOGplotPairs(thesepairs(:,1),thesepairs(:,2),'s',15,'k',1,16,thispair(1),thispair(2),value(ax),'init')

  %% Case Plot_perf
    case 'plot_perf'
    %% make numClass pairs of sigma values -pairs are high to low (d) and low to high (u)   
        Ind=(value(s2_s1_ratio-1))/(1+value(s2_s1_ratio));
    S1_d(1)=value(minS1);
    S2_d(1)=S1_d(1)*(1-Ind)/(1+Ind);
    S1_u(1)=S1_d;
    S2_u(1)=S1_u(1)*(1+Ind)/(1-(Ind));
    for ii=2:value(numClass+1)
    S1_d(ii)=S2_u(ii-1);    
    S2_d(ii)=S1_d(ii)*(1-Ind)/(1+Ind);
    S1_u(ii)=S1_d(ii);    
    S2_u(ii)=S1_u(ii)*(1+Ind)/(1-Ind);
    end
    pairs=[];
    pairs(:,1)=[S1_d S1_u];
    pairs(:,2)=[S2_d S2_u];

    mainpairs=pairs(2:end-1,:);
    if midclass_pairs
        
        for ii=1:length(S1_u)-1
            mS1_d(ii)=0.5*(log(S1_d(ii)*S1_d(ii+1)));
            mS2_d(ii)=0.5*(log(S2_d(ii)*S2_d(ii+1)));
            mS1_u(ii)=0.5*(log(S1_u(ii)*S1_u(ii+1)));
            mS2_u(ii)=0.5*(log(S2_u(ii)*S2_u(ii+1)));
        end
        mS1_d(ii+1)=mS1_d(ii);
        mS2_d(ii+1)=mS2_d(ii);
        mS1_u(ii+1)=mS1_u(ii);
        mS2_u(ii+1)=mS2_u(ii);

        mpairs(:,1)=exp([mS1_d mS1_u]);
        mpairs(:,2)=exp([mS2_d mS2_u]);
        midpairs=mpairs(2:end-1,:);
        
        [m,n]=size(midpairs');
        thesepairs.value=reshape(permute(cat(3,mainpairs',midpairs'), [1 3 2]), [m 2*n]);
        thesepairs.value=value(thesepairs)';
        pairs_d.value=thesepairs(1:value(numClass)*2-1,:);
        pairs_u.value=thesepairs(value(numClass)*2+1:value(numClass)*4-1,:);
        
        thesepairs.value=[value(pairs_d);value(pairs_u)];
        if psych_pairs
            StimulusSection(obj,'PsychPairs'); 
            thesepairs.value=[value(thesepairs);value(pairs_d_psych);value(pairs_u_psych)];
        end
        
    else
        thesepairs.value=pairs(2:end-1,:);
        pairs_d.value=thesepairs(1:value(numClass),:);
        pairs_u.value=thesepairs(value(numClass)+1:value(numClass)*2,:);
        
        thesepairs.value=[value(pairs_d);value(pairs_u)];
        if psych_pairs
            StimulusSection(obj,'PsychPairs'); 
            thesepairs.value=[value(thesepairs);value(pairs_d_psych);value(pairs_u_psych)];
        end
    end
    
    %% plot the pair set
    cla(value(axperf))
    xd=log(thesepairs(:,1));
    yd=log(thesepairs(:,2));
    for ii=1:length(xd)
        axes(value(axperf));
        plot(xd(ii),yd(ii),'s','MarkerSize',31,'MarkerEdgeColor',[0 0 0],'LineWidth',1.5)
        hold on
        eval(sprintf('perf=value(perfClass%d);',ii))
        text(xd(ii)-0.14,yd(ii),num2str(round(perf*1000)/10));
        hold on
    end
    axis square
    set(value(ax),'ytick',((yd(1:1+value(midclass_pairs):(end-nPsych*psych_pairs)/2))),'xtick',((xd(1:1+value(midclass_pairs):(end-nPsych*psych_pairs)/2))));
    set(value(ax),'yticklabel',num2str(exp(yd(1:1+value(midclass_pairs):(end-nPsych*psych_pairs)/2)),2),'xticklabel',num2str(exp(xd(1:1+value(midclass_pairs):(end-nPsych*psych_pairs)/2)),2));
    ylabel('\sigma_2 in log scale','FontSize',16,'FontName','Cambria Math');  
    set(value(axperf),'Fontsize',15)
    xlabel('\sigma_1 in log scale','FontSize',16,'FontName','Cambria Math')

       
    %% Case psych_pairs
    case 'PsychPairs'
        if psych_pairs == 1
            enable(nPsych);
            enable(from);
            enable(psych_type);
            Ind=(value(s2_s1_ratio-1))/(1+value(s2_s1_ratio));
            if strcmp(psych_type,'horizpairs')
                s2=value(from);
                s1_first=s2*(1-Ind)/(1+Ind);
                s1_last=s2*(1+Ind)/(1-Ind);
                s1_first=log(s1_first);
                s1_last=log(s1_last);
                s2=log(s2);
                psych_diff=(s1_last-s1_first)/(value(nPsych)-1);
                s1_psych(1)=s1_first;
                s2_psych(1)=s2;
                for nn = 1:value(nPsych)-1
                    s1_psych(nn+1)=s1_psych(nn)+psych_diff;
                    s2_psych(nn+1)=s2_psych(1);
                end
                
                pairs_u_psych.value = [s1_psych(1:value(nPsych)/2);s2_psych(1:value(nPsych)/2)];
                pairs_d_psych.value = [s1_psych(value(nPsych)/2+1:end);s2_psych(value(nPsych)/2+1:end)];
                                
            else
                s1=value(from);
                s2_first=s1*(1-Ind)/(1+Ind);
                s2_last=s1*(1+Ind)/(1-Ind);
                s2_first=log(s2_first);
                s2_last=log(s2_last);
                s1=log(s1);
                psych_diff=(s2_last-s2_first)/(value(nPsych)-1);
                s2_psych(1)=s2_first;
                s1_psych(1)=s1;
                for nn = 1:value(nPsych)-1
                    s2_psych(nn+1)=s2_psych(nn)+psych_diff;
                    s1_psych(nn+1)=s1_psych(1);
                end
                pairs_d_psych.value = [s1_psych(1:value(nPsych)/2);s2_psych(1:value(nPsych)/2)];
                pairs_u_psych.value = [s1_psych(value(nPsych)/2+1:end);s2_psych(value(nPsych)/2+1:end)];
            end
            pairs_d_psych.value=exp(value(pairs_d_psych))';
            pairs_u_psych.value=exp(value(pairs_u_psych))';
            pairs_d.value=[value(pairs_d); value(pairs_d_psych)];
            pairs_u.value=[value(pairs_u); value(pairs_u_psych)];
            %StimulusSection(obj,'plot_pairs');
        else
            disable(nPsych);
            disable(from);
            disable(psych_type);
            StimulusSection(obj,'plot_pairs');
        end
     

    %% Case get_class_perform
    case 'get_class_perform'
        if nargout > 0,
            for ii=1:numClass*2+(numClass-1)*midclass_pairs+(nPsych)*psych_pairs
            eval(sprintf('final_perf(ii)=value(perfClass%d);',ii));
            end
            eval(sprintf('x=[value(perfClass%d) value(perfClass%d) value(perfClass%d) value(perfClass%d);]',1,value(numClass), value(numClass)+1,value(numClass)*2));
            y=final_perf;
        end
       
    %% Case get_pairs
    case 'get_pairs'
        if nargout>0
            x=value(pairs_u);
            y=value(pairs_d);
        end
        
    %% Case close    
    case 'close'
		% Delete all SoloParamHandles who belong to this object and whose
		% fullname starts with the name of this mfile:
        if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)), %#ok<NODEF>
            delete(value(myfig));
        end;
		delete_sphandle('owner', ['^@' class(obj) '$'], ...
			'fullname', ['^' mfilename]);
        
    %% Case update_pairs
    case 'update_pairs'
        StimulusSection(obj,'plot_pairs');

    case 'update_pair_history'
        ps=value(pair_history);
        ps(n_done_trials)=value(thisclass(n_done_trials));
        pair_history.value=ps;

    %% Case hide
    case 'hide',
        StimulusShow.value = 0; set(value(myfig), 'Visible', 'off');
    %% Case show
    case 'show',
        StimulusShow.value = 1; set(value(myfig), 'Visible', 'on');
    %% Case Show_hide
    case 'show_hide',
        if StimulusShow == 1, set(value(myfig), 'Visible', 'on'); %#ok<NODEF> (defined by GetSoloFunctionArgs)
        else                   set(value(myfig), 'Visible', 'off');
        end;
    end
    