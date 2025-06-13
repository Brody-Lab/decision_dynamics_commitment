

function [obj] = IRSystemTester(varargin)

obj = class(struct, mfilename);

%---------------------------------------------------------------
%   BEGIN SECTION COMMON TO ALL PROTOCOLS, DO NOT MODIFY
%---------------------------------------------------------------

% If creating an empty object, return without further ado:
if nargin==0 || (nargin==1 && ischar(varargin{1}) && strcmp(varargin{1}, 'empty')), 
   return; 
end;

if isa(varargin{1}, mfilename), % If first arg is an object of this class itself, we are 
                                % Most likely responding to a callback from  
                                % a SoloParamHandle defined in this mfile.
  if length(varargin) < 2 || ~ischar(varargin{2}), 
    error(['If called with a "%s" object as first arg, a second arg, a ' ...
      'string specifying the action, is required\n']);
  else action = varargin{2}; varargin = varargin(3:end); %#ok<NASGU>
  end;
else % Ok, regular call with first param being the action string.
       action = varargin{1}; varargin = varargin(2:end); %#ok<NASGU>
end;
if ~ischar(action), error('The action parameter must be a string'); end;

GetSoloFunctionArgs(obj);

%---------------------------------------------------------------
%   END OF SECTION COMMON TO ALL PROTOCOLS, MODIFY AFTER THIS LINE
%---------------------------------------------------------------


switch action,

  %---------------------------------------------------------------
  %          CASE INIT
  %---------------------------------------------------------------
%% INIT 
  case 'init'
    dispatcher('set_trialnum_indicator_flag');  
    
    hackvar = 10; SoloFunctionAddVars('SessionModel', 'ro_args', 'hackvar'); %#ok<NASGU>
    
    SoloParamHandle(obj, 'myfig', 'saveable', 0); myfig.value = double(figure);

    % Make the title of the figure be the protocol name, and if someone tries
    % to close this figure, call dispatcher's close_protocol function, so it'll know
    % to take it off the list of open protocols.
    name = mfilename;
    set(value(myfig), 'Name', name, 'Tag', name, ...
      'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');

    % At this point we have one SoloParamHandle, myfig
    % Let's put the figure where we want it and give it a reasonable size:
    set(value(myfig), 'Position', [100 100 350 500]); 
    x = 5; y = 5;
    
    SubheaderParam(obj,'Dur1',  '10ms',  0,0,'position',[  5   50 60 30]);
    SubheaderParam(obj,'Test11', '',     0,0,'position',[ 70   50 60 30]);
    SubheaderParam(obj,'Test12', '',     0,0,'position',[135   50 60 30]);
    SubheaderParam(obj,'Test13', '',     0,0,'position',[200   50 60 30]);

    SubheaderParam(obj,'Dur2',  '30ms',  0,0,'position',[  5  100 60 30]);
    SubheaderParam(obj,'Test21', '',     0,0,'position',[ 70  100 60 30]);
    SubheaderParam(obj,'Test22', '',     0,0,'position',[135  100 60 30]);
    SubheaderParam(obj,'Test23', '',     0,0,'position',[200  100 60 30]);
    
    SubheaderParam(obj,'Dur3',  '100ms', 0,0,'position',[  5  150 60 30]);
    SubheaderParam(obj,'Test31', '',     0,0,'position',[ 70  150 60 30]);
    SubheaderParam(obj,'Test32', '',     0,0,'position',[135  150 60 30]);
    SubheaderParam(obj,'Test33', '',     0,0,'position',[200  150 60 30]);
    
    SubheaderParam(obj,'Dur4',  '300ms', 0,0,'position',[  5  200 60 30]);
    SubheaderParam(obj,'Test41', '',     0,0,'position',[ 70  200 60 30]);
    SubheaderParam(obj,'Test42', '',     0,0,'position',[135  200 60 30]);
    SubheaderParam(obj,'Test43', '',     0,0,'position',[200  200 60 30]);
    
    SubheaderParam(obj,'Dur5',  '1s',    0,0,'position',[  5  250 60 30]);
    SubheaderParam(obj,'Test51', '',     0,0,'position',[ 70  250 60 30]);
    SubheaderParam(obj,'Test52', '',     0,0,'position',[135  250 60 30]);
    SubheaderParam(obj,'Test53', '',     0,0,'position',[200  250 60 30]);

    SubheaderParam(obj,'Test',  'Test',  0,0,'position',[  5  300 60 30]);
    SubheaderParam(obj,'Test1', 'Count', 0,0,'position',[ 70  300 60 30]);
    SubheaderParam(obj,'Test2', 'P_In',  0,0,'position',[135  300 60 30]);
    SubheaderParam(obj,'Test3', 'P_Out', 0,0,'position',[200  300 60 30]);
    
    SubheaderParam(obj,'Main', 'Test 1', 0,0,'position',[  5  350 195 100]);
    
    
    set(get_ghandle(Dur1),'BackgroundColor',[1 1 1],'fontsize',14);
    set(get_ghandle(Dur2),'BackgroundColor',[1 1 1],'fontsize',14);
    set(get_ghandle(Dur3),'BackgroundColor',[1 1 1],'fontsize',14);
    set(get_ghandle(Dur4),'BackgroundColor',[1 1 1],'fontsize',14);
    set(get_ghandle(Dur5),'BackgroundColor',[1 1 1],'fontsize',14);

    set(get_ghandle(Test11),'BackgroundColor',[1 1 1],'fontsize',14);
    set(get_ghandle(Test12),'BackgroundColor',[1 1 1],'fontsize',14);
    set(get_ghandle(Test13),'BackgroundColor',[1 1 1],'fontsize',14);
    set(get_ghandle(Test21),'BackgroundColor',[1 1 1],'fontsize',14);
    set(get_ghandle(Test22),'BackgroundColor',[1 1 1],'fontsize',14);
    set(get_ghandle(Test23),'BackgroundColor',[1 1 1],'fontsize',14);
    set(get_ghandle(Test31),'BackgroundColor',[1 1 1],'fontsize',14);
    set(get_ghandle(Test32),'BackgroundColor',[1 1 1],'fontsize',14);
    set(get_ghandle(Test33),'BackgroundColor',[1 1 1],'fontsize',14);
    set(get_ghandle(Test41),'BackgroundColor',[1 1 1],'fontsize',14);
    set(get_ghandle(Test42),'BackgroundColor',[1 1 1],'fontsize',14);
    set(get_ghandle(Test43),'BackgroundColor',[1 1 1],'fontsize',14);
    set(get_ghandle(Test51),'BackgroundColor',[1 1 1],'fontsize',14);
    set(get_ghandle(Test52),'BackgroundColor',[1 1 1],'fontsize',14);
    set(get_ghandle(Test53),'BackgroundColor',[1 1 1],'fontsize',14);
    set(get_ghandle(Test1), 'BackgroundColor',[1 1 1],'fontsize',14);
    set(get_ghandle(Test2), 'BackgroundColor',[1 1 1],'fontsize',14);
    set(get_ghandle(Test3), 'BackgroundColor',[1 1 1],'fontsize',14);
    set(get_ghandle(Test),  'BackgroundColor',[1 1 1],'fontsize',14);
    
    set(get_ghandle(Main),  'BackgroundColor',[1 1 1],'fontsize',48);
    
    SoloParamHandle(obj,'Count',   'value',0);
    SoloParamHandle(obj,'AnyFail', 'value',0);
    
    c = get(value(myfig),'children');
    for i=1:length(c); 
        t=get(c(i),'type'); 
        if strcmp(t,'uipanel'); set(c(i),'backgroundcolor',[1 1 1]); end
    end
    
    figure(1);
    set(gcf,'visible','off');
    
    feval(mfilename, obj, 'prepare_next_trial');
        
    
%% prepare_next_trial    
  %---------------------------------------------------------------
  %          CASE PREPARE_NEXT_TRIAL
  %---------------------------------------------------------------
  case 'prepare_next_trial'
    
    Count.value = value(Count) + 1; %#ok<NODEF>
    D = [0.01 0.03 0.1 0.3 1];
    T = [1.2 1.1 1.05 1.05 1.05];
    N = [20 20 20 15 10];
    
    set(get_ghandle(Main),'string',['Test ',num2str(value(Count))]);
    
    if value(Count) > 1
        x = parsed_events.pokes.L;
        if size(x,1) == N(value(Count)-1)+1; pass(1) = 1; else pass(1) = 0; end
        
        if size(x,1) > 1
            d = nanmedian(x(:,2) - x(:,1));
            if d >= D(value(Count)-1)/T(value(Count)-1) && d <= D(value(Count)-1)*T(value(Count)-1)
                 pass(2) = 1; 
            else pass(2) = 0; 
            end

            d = nanmedian(x(2:end,1) - x(1:end-1,2));
            if d >= D(value(Count)-1)/T(value(Count)-1) && d <= D(value(Count)-1)*T(value(Count)-1)
                 pass(3) = 1; 
            else pass(3) = 0; 
            end
        else
            pass(2) = 0;
            pass(3) = 0;
        end
        
        for i=1:3
            H = eval(['get_ghandle(Test',num2str(value(Count-1)),num2str(i),')']);
            if pass(i) == 1; set(H(1),'string','pass','ForegroundColor',[0 1 0]);
            else             set(H(1),'string','FAIL','ForegroundColor',[1 0 0]);
            end
        end
        pause(0.1);
        
        if any(pass == 0); AnyFail.value = 1; end
    end
        
    if value(Count) > length(D)
        RunningSection(dispatcher,'RunButtonCallback')
        if value(AnyFail) == 1
            set(get_ghandle(Main),'string','FAIL','ForegroundColor',[1 0 0]);
        else
            set(get_ghandle(Main),'string','PASS','ForegroundColor',[0 1 0]);
        end
    else
        sma = StateMachineAssembler('full_trial_structure');
        left1led = bSettings('get','DIOLINES','left1led');   

        dur = D(value(Count));

        sma = add_scheduled_wave(sma,...
            'name',          'stim_wave',...
            'preamble',      dur,...
            'sustain' ,      dur,...
            'DOut',          left1led,...
            'loop',          N(value(Count))-1,...
            'no_wave_events',0);

        sma = add_state(sma, 'name', 'stim', 'self_timer',(dur*2*N(value(Count))) + (dur*4) + 1,...
                'output_actions', {'SchedWaveTrig', 'stim_wave'},...
                'input_to_statechange', {'Tup', 'complete'});

        sma = add_state(sma, 'name','complete','self_timer', dur,...
                    'input_to_statechange', {'Tup','check_next_trial_ready'});

        dispatcher('send_assembler', sma, 'complete');
        
        if value(Count) == 1
            RunningSection(dispatcher,'RunButtonCallback')
        end
    end
    

    
%% trial_completed    
  %---------------------------------------------------------------
  %          CASE TRIAL_COMPLETED
  %---------------------------------------------------------------
  case 'trial_completed'
    % Do any updates in the protocol that need doing:
    feval(mfilename, 'update');

  
%% update    
  %---------------------------------------------------------------
  %          CASE UPDATE
  %---------------------------------------------------------------
  case 'update'
    

%% end_session    
  %---------------------------------------------------------------
  %          CASE END_SESSION
  %---------------------------------------------------------------
  case 'end_session'
     prot_title.value = [value(prot_title) ', Ended at ' datestr(now, 'HH:MM')]; %#ok<NODEF>
     getSessID(obj);
    
%% pre_saving_settings
  %---------------------------------------------------------------
  %          CASE PRE_SAVING_SETTINGS
  %---------------------------------------------------------------
  case 'pre_saving_settings'

 		
    
%% after_load_callbacks
  %---------------------------------------------------------------
  %          CASE AFTER_LOAD_CALLBACKS
  %---------------------------------------------------------------
  case 'after_load_callbacks'
    

    

%% close    
  %---------------------------------------------------------------
  %          CASE CLOSE
  %---------------------------------------------------------------
  case 'close'

    if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)), %#ok<NODEF>
      delete(value(myfig));
    end;
    delete_sphandle('owner', ['^@' class(obj) '$']);

  otherwise,
    warning('Unknown action! "%s"\n', action); %#ok<WNTAG>
end;

return;

