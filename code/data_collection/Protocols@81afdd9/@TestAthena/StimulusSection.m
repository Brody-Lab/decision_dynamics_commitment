

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
    set(value(myfig),'Position',[1 screen_size(4)-740, 750 700]); % put fig at top right
    set(gcf, 'Visible', 'off');
    x=10;y=10;
         
    SoloParamHandle(obj, 'ax', 'saveable', 0, ...
                   'value', axes('Position', [0.05 0.45 0.6 0.5]));
    Ylabel('log_e \sigma_2','FontSize',16,'FontName','Cambria Math');  
    set(value(ax),'Fontsize',15)
    Xlabel('log_e \sigma_1','FontSize',16,'FontName','Cambria Math')

    SoundManagerSection(obj, 'declare_new_sound', 'StimAUD1')
    SoundManagerSection(obj, 'declare_new_sound', 'StimAUD2')
    SoloParamHandle(obj, 'thesepairs', 'value', []);
    SoloParamHandle(obj, 'pairs_d', 'value', []);
    SoloParamHandle(obj, 'pairs_u', 'value', []);
    SoloParamHandle(obj, 'h1', 'value', []); 
    
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
    
    next_column(x);
    y=5;
    MenuParam(obj, 'filter_type', {'GAUS','LPFIR', 'FIRLS','BUTTER','MOVAVRG','KAISER','EQUIRIP','HAMMING'}, ...
      'GAUS', x, y, 'labelfraction', 0.35, 'TooltipString', sprintf(['\nDifferent filters. ''LPFIR'': lowpass FIR ''FIRLS'': Least square linear-phase FIR filter design\n', ...
      '\n''BUTTER'': IIR Butterworth lowpass filter ''GAUS'': Gaussian filter (window)\n', ...
      '\n''MOVAVRG'': Moving average FIR filter ''KAISER'': Kaiser-window FIR filtering\n', ...
      '\n''EQUIRIP'':Eqiripple FIR filter ''HAMMING'': Hamming-window based FIR'])); 
    next_row(y, 1.3)
    DispParam(obj, 'A1_sigma', 0.01, x,y,'label','AUD1_Sigma','TooltipString','Sigma value for the first stimulus');
	next_row(y);
    DispParam(obj, 'A2_sigma', 0.01, x,y,'label','AUD2_Sigma','TooltipString','Sigma value for the first stimulus');
	next_row(y);
	NumeditParam(obj,'fcut',110,x,y,'label','CutOff Freq','TooltipString','Cut off frequency on the original white noise');
    next_row(y);
	NumeditParam(obj,'lfreq',3000,x,y,'label','Modulator_LowFreq','TooltipString','Lower bound for the frequency modulator');
	next_row(y);
	NumeditParam(obj,'hfreq',4000,x,y,'label','Modulator_HighFreq','TooltipString','Upper bound for the frequency modulator');	
    next_row(y);
% 	NumeditParam(obj,'outband',60,x,y,'label','Outband','TooltipString','outband on the distribution from which white noise is produced');
%     next_row(y);
	NumeditParam(obj,'minS1',0.02,x,y,'label','min A1_sigma','TooltipString','min sigma value for AUD1');
    next_row(y);
	DispParam(obj,'maxS',40,x,y,'label','max A_sigma','TooltipString','max sigma value for AUD1');
    NumeditParam(obj,'s2_s1_ratio',2,x,y,'label','S2_S1 ratio','TooltipString','Intensity index i.e. Ind=(S1-S2)/(S1+S2)');
    next_row(y);
    %next_row(y);
	%NumeditParam(obj,'seed',0,x,y,'label','Seed','TooltipString','Seed number for random generator');
    
    disable(nPatt);
    
    
    next_column(x);
    y=5;
    SoloParamHandle(obj, 'existing_numClass', 'value', 0, 'saveable', 0);
    SoloParamHandle(obj, 'my_window_info', 'value', [x, y, value(myfig)], 'saveable', 0);
    NumeditParam(obj,'numClass',4,x,y,'label','Num Class','TooltipString','Number of stimulus pairs');
    set_callback_on_load(numClass, 6); %#ok<NODEF>
    set_callback(numClass, {mfilename, 'numClass'});
    numClass.value = 6; callback(numClass);
    
    StimulusSection(obj,'plot_pairs');

    


case 'prepare_next_trial' 

    %% d or u?
SideSection(obj,'get_current_side');

if strcmp(ThisTrial, 'LEFT')
    bag=[];
    for cc=1:value(numClass)
    eval(sprintf('pr=value(prob%d);',cc+value(numClass))); 
    bag=[bag ones(1,pr)*value(cc)];
    end
    
    pp=randsample(bag,length(bag));
	thispair=[pairs_u(pp(1),1) pairs_u(pp(1),2)];
else
    bag=[];
    for cc=1:value(numClass)
    eval(sprintf('pr=value(prob%d);',cc));
    bag=[bag ones(1,pr)*value(cc)];
    end
    pp=randsample(bag,length(bag));
	thispair=[pairs_d(pp(1),1) pairs_d(pp(1),2)];
end;
	
A1_sigma.value=thispair(1);
A2_sigma.value=thispair(2);

set(value(h1), 'XData', log(value(A1_sigma)), 'Ydata', log(value(A2_sigma)));
%LOGplotPairs(thesepairs(:,1),thesepairs(:,2),'s',15,'k',1,16,thispair(1),thispair(2),value(ax),'update_pair')

%% produce noise pattern 
srate=SoundManagerSection(obj,'get_sample_rate');
Fs=srate;
T=max(value(A2_time),value(A1_time));
[rawA1 rawA2 normA1 normA2]=noisestim(1,1,T,value(fcut),Fs,value(filter_type));
modulator=singlenoise(1,T,[value(lfreq) value(hfreq)],Fs,'BUTTER');
AUD1=normA1(1:A1_time*srate).*modulator(1:A1_time*srate).*A1_sigma;
AUD2=normA2(1:A2_time*srate).*modulator(1:A2_time*srate).*A2_sigma;
%AUD2=0.2*sin(2*pi*4000*(1:srate)/srate);

if ~isempty(AUD1)
    SoundManagerSection(obj, 'set_sound', 'StimAUD1', [AUD1';  AUD1'])
end
if ~isempty(AUD2)
SoundManagerSection(obj, 'set_sound', 'StimAUD2', [AUD2';  AUD2'])
end

SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');

    %% Case new_numClass
    case 'new_numClass'
    for cc=1:20    
        eval(sprintf('disable(prob%d)',cc)) 
    end
    for cc=1:2*value(numClass)
        eval(sprintf('enable(prob%d)',cc)) 
    end
    
    %% case numClass
   case 'numClass',
      if numClass > existing_numClass,        %#ok<NODEF>
         % If asking for more sounds than exist, make them:
         orig_fig = double(gcf);
         my_window_visibility = get(my_window_info(3), 'Visible');
         x = my_window_info(1); y = my_window_info(2); figure(my_window_info(3));
         set(my_window_info(3), 'Visible', my_window_visibility);
         
         next_row(y, 1+ value(existing_numClass*2));
                 
         new_class = (existing_numClass*2 + 1):value(numClass*2);
         for newnum = new_class,
            ToggleParam(obj, ['pair_' num2str(newnum) '_header'], 0, x, y, ...
               'OnString', ['StimPair ' num2str(newnum)], 'OffString', ['StimPair ' num2str(newnum)], ...
               'position', [x y 80 20], 'TooltipString', sprintf(['\nToggle on to play stimulus; ' ...
               'toggle off to stop it.'])); x = x +80;
            %set_callback(eval(['pair_' num2str(newnum) '_header']), {mfilename, 'play_stimulus', newnum});

            NumeditParam(obj,['prob',num2str(newnum)],1,x,y,'label',['Pair ',num2str(newnum)],'TooltipString','Probability of this pair');
            next_row(y);  x = my_window_info(1);
         end;
         existing_numClass.value = value(numClass);
         figure(orig_fig);
         
      elseif numClass < existing_numClass,
         % If asking for fewer vars than exist, delete excess:
         for oldnum = (numClass*2+1):value(existing_numClass*2);
            delete(eval(['pair_' num2str(oldnum) '_header']));
            sphname = ['prob' num2str(oldnum)];
            delete(eval(sphname));
         end;
         existing_numClass.value = value(numClass);
      end;
      
      % Now check for whether we are in the middle of load settings or load
      % data.
      
      varhandles = {};
      for i = 1:value(numClass), 
            varhandles = [varhandles ; {eval(['prob' num2str(i)])}]; %#ok<AGROW>
      end;
      load_solouiparamvalues(obj, 'ratname', 'rescan_during_load', varhandles);
      StimulusSection(obj,'plot_pairs');
      
    %% Case StimulusType  
    case 'StimulusType'
    if strcmp(StimulusType, 'library');
        enable((nPatt));
        %disable(seed);
        %set(get_ghandle(seed), 'Enable', 'off');    
    else
        disable(nPatt);
    end
    
    %% Case plot_pais
    case 'plot_pairs'
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

    thesepairs.value=pairs(2:end-1,:);
    pairs_d.value=thesepairs(1:value(numClass),:);
    pairs_u.value=thesepairs(value(numClass+1):value(numClass)*2,:);

    maxS.value=max(thesepairs(:));


    %% plot the pair set
    cla(value(ax))
    xd=log(thesepairs(:,1));
    yd=log(thesepairs(:,2));
    for ii=1:length(xd)
        axes(value(ax));
        plot(xd(ii),yd(ii),'s','MarkerSize',15,'MarkerEdgeColor',[0 0 0],'LineWidth',2)
        hold on
        text(xd(ii),yd(ii),num2str(ii));
        hold on
    end
    axis square
%      Ytick=get(value(ax),'YtickLabel');
%      Xtick=get(value(ax),'XtickLabel');
    set(value(ax),'ytick',((yd(1:value(numClass)))),'xtick',((xd(1:value(numClass)))));
    set(value(ax),'yticklabel',num2str(exp(yd(1:value(numClass))),2),'xticklabel',num2str(exp(xd(1:value(numClass))),2));
    Ylabel('\sigma_2 in log scale','FontSize',16,'FontName','Cambria Math');  
    set(value(ax),'Fontsize',15)
    Xlabel('\sigma_1 in log scale','FontSize',16,'FontName','Cambria Math')
    %% d or u?
    SideSection(obj,'get_current_side');

    if strcmp(ThisTrial, 'LEFT')
        bag=[];
        for cc=1:value(numClass)
        eval(sprintf('pr=value(prob%d);',cc+value(numClass))); 
        bag=[bag ones(1,pr)*value(cc)];
        end
    
        pp=randsample(bag,length(bag));
        thispair=[pairs_u(pp(1),1) pairs_u(pp(1),2)];
    else
        bag=[];
        for cc=1:value(numClass)
        eval(sprintf('pr=value(prob%d);',cc)); 
        bag=[bag ones(1,pr)*value(cc)];
        end
        pp=randsample(bag,length(bag));
        thispair=[pairs_d(pp(1),1) pairs_d(pp(1),2)];
    end;
	
        A1_sigma.value=thispair(1);
        A2_sigma.value=thispair(2);

        %% plot the pairs
        h1.value=plot(log(value(A1_sigma)),log(value(A2_sigma)),'s','color',[0.8 0.4 0.1],'markerfacecolor',[0.8 0.4 0.1],'MarkerSize',15,'LineWidth',3);

        %LOGplotPairs(thesepairs(:,1),thesepairs(:,2),'s',15,'k',1,16,thispair(1),thispair(2),value(ax),'init')

    %% Case update_pairs
    case 'update_pairs'
        StimulusSection(obj,'plot_pairs');

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
    