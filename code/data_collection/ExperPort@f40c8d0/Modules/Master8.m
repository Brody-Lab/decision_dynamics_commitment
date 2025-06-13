function out = Master8(varargin)
% Master8
% 
% This module will control the Master8 from the serial port.
% The full functionality of the Master8 is not implemented,
% notably, we are only dealing with channels 1, 2 in triggered or train mode.
%

global exper

out = lower(mfilename); 
if nargin > 0
	action = lower(varargin{1});
else
	action = lower(get(gcbo,'tag'));
end

switch action
	
case 'init'
	
	fig = ModuleFigure(me,'visible','off');	
	
	SetParam(me,'priority',7);

	hs = 60;
	h = 5;
	vs = 20;
	n = 0;

    InitParam(me,'M','ui','edit','value',1,'all',ones(1,8),'range',[1 59900],'save',1,'pos',[h n*vs hs vs]); n=n+1;
    InitParam(me,'inter','ui','edit','value',20,'all',ones(1,8)*20,'range',[60e-6 3999],'save',1,'pos',[h n*vs hs vs]); n=n+1;
    InitParam(me,'freq','ui','edit','value',50,'all',ones(1,8)*50,'range',[0.25 1.66e7],'save',1,'pos',[h n*vs hs vs]); n=n+1;
    InitParam(me,'delay','ui','edit','value',1e-4,'all',ones(1,8)*1e-4,'range',[100e-6 3999],'save',1,'pos',[h n*vs hs vs]); n=n+1;
    InitParam(me,'dura','ui','edit','value',1e-3,'all',ones(1,8)*1e-3,'range',[40e-6 3999],'save',1,'pos',[h n*vs hs vs]); n=n+1;
    InitParam(me,'mode','ui','popupmenu','list',{'off','trig','train','free','dc','gate'},...
        'm8',{'O','G','N','F','C','T'},'all',ones(1,8),'value',1,'save',1,'pos',[h n*vs hs vs]); n=n+1;
    n=n+1;
    InitParam(me,'chan','ui','popupmenu','list',num2cell(1:8),'value',1,'pos',[h n*vs hs vs]); n=n+1;

    InitParam(me,'comm','list',{'com1','com2','com3','com4'},'value',1,'pos',[h n*vs hs vs]);
    n=n+1;
    uicontrol(fig,'style','pushbutton','string','reset','callback',[me ';'],'tag','reset','pos',[h n*vs hs vs]); n=n+1;

    % message box
    uicontrol('parent',fig,'tag','message','style','edit',...
        'enable','inact','horiz','left','pos',[h n*vs hs*2 vs]); n=n+1;
    
	set(fig,'pos',[142 480-n*vs 128 n*vs],'visible','on');
    
    master8('reset');
    
case 'reinit'
	
	fig = ModuleFigure(me,'visible','off');	
	
	SetParam(me,'priority',7);

	hs = 60;
	h = 5;
	vs = 20;
	n = 0;

    InitParam(me,'M','ui','disp','value',1,'range',[1 59900],'pos',[h n*vs hs vs]); n=n+1;
    SetParam(me,'M','all',ones(1,8)*GetParam(me,'M'));
    InitParam(me,'inter','ui','disp','value',0.02,'range',[60e-6 3999],'pos',[h n*vs hs vs]); n=n+1;
    SetParam(me,'inter','all',ones(1,8)*GetParam(me,'inter'));
    InitParam(me,'freq','ui','disp','value',1/GetParam(me,'inter'),'range',[2.5e-4 1.66e4],'save',1,'pos',[h n*vs hs vs]); n=n+1;
    SetParam(me,'freq','all',ones(1,8)*GetParam(me,'freq'));
    InitParam(me,'delay','ui','disp','value',5,'range',[100e-6 3999],'pos',[h n*vs hs vs]); n=n+1;
    SetParam(me,'delay','all',ones(1,8)*GetParam(me,'delay'));
    InitParam(me,'dura','ui','disp','value',0.2e-3,'range',[40e-6 3999],'pos',[h n*vs hs vs]); n=n+1;
    SetParam(me,'dura','all',ones(1,8)*GetParam(me,'dura'));
    InitParam(me,'mode','ui','popupmenu','list',{'trig','train','free','dc','gate','off'},'m8',{'G','N','F','C','T','O'},'all',ones(1,8),...
        'value',1,'pos',[h n*vs hs vs]); n=n+1;
    SetParamUI(me,'mode','enable','off');
    n=n+1;
    InitParam(me,'chan','ui','popupmenu','list',num2cell(1:8),'value',1,'pos',[h n*vs hs vs]); n=n+1;

    InitParam(me,'comm','list',{'com1','com2','com3','com4'},'value',1,'pos',[h n*vs hs vs]);
    n=n+1;

    % message box
    uicontrol('parent',fig,'tag','message','style','edit',...
        'enable','inact','horiz','left','pos',[h n*vs hs*2 vs]); n=n+1;
    
	set(fig,'pos',[142 480-n*vs 128 n*vs],'visible','on');
    

case 'slice'
	
case 'trialready'
    
case 'trialend'
    
%   	SaveParamsTrial(me,GetParam('control','trial'));
    tr = GetParam('control','trial');
    exper.master8.param.mode.trial{tr} = GetParam(me,'mode','all');
    exper.master8.param.dura.trial{tr} = GetParam(me,'dura','all');
    exper.master8.param.delay.trial{tr} = GetParam(me,'delay','all');
    exper.master8.param.inter.trial{tr} = GetParam(me,'inter','all');
    exper.master8.param.M.trial{tr} = GetParam(me,'M','all');
    
case 'trialreview'    
    

if 0
    tr = GetParam('control','trial');
    mode = exper.master8.param.mode.trial{tr};
    dura = exper.master8.param.dura.trial{tr};
    delay = exper.master8.param.delay.trial{tr};
    inter = exper.master8.param.inter.trial{tr};
    M = exper.master8.param.M.trial{tr};
    chan = GetParamList(me,'chan');
    
    SetParam(me,'mode',mode(chan));
    SetParam(me,'inter',inter(chan));
    SetParam(me,'delay',delay(chan));
    SetParam(me,'dura',dura(chan));
    SetParam(me,'M',M(chan));
else
    tr = GetParam('control','trial');
    if length(exper.master8.param.inter.trial) >= tr
        inter = exper.master8.param.inter.trial{tr};
        chan = GetParamList(me,'chan');
        SetParam(me,'inter',inter(chan));
        SetParam(me,'freq',1/GetParam(me,'inter'));
    end
end
    
case 'close'
	
case 'load'
    LoadParams(me);
	
% handle UI parameter callbacks

case 'reset'
%      if ~strcmp(questdlg('Reset all Master 8 programming!?'),'Yes')
%          return;
%      end
      
      % reset master8
%      writem8('O A A A E');

      % let Master 8 display the values sent
      writem8('B 0 E');
      
      ch = GetParamList(me,'chan');
      
      % set all channel values
      for n=1:8
          SetParam(me,'chan',n);
          master8('chan');
          master8('mode');
          master8('dura');
          master8('delay');
          master8('inter');
          master8('m');
      end
      SetParam(me,'chan',ch);
      
case 'chan'
    chan = GetParam(me,'chan','value');
    mode = GetParam(me,'mode','all');
    SetParam(me,'mode',mode(chan));
    
    dura = GetParam(me,'dura','all');
    SetParam(me,'dura',dura(chan));
    
    delay = GetParam(me,'delay','all');
    SetParam(me,'delay',delay(chan));
    
    inter = GetParam(me,'inter','all');
    SetParam(me,'inter',inter(chan));
    SetParam(me,'freq',1/GetParam(me,'inter'));
    
    M = GetParam(me,'M','all');
    SetParam(me,'M',M(chan));
    message(me,'');
    
    
case 'mode'
    chan = GetParamList(me,'chan');
%    mode = GetParam(me,'mode');
    mode_n = GetParam(me,'mode','value');
    modestr = GetParam(me,'mode','m8');
    
    all = GetParam(me,'mode','all');    
    
    writem8(sprintf('%s %d E E',modestr{mode_n},chan));
    
    all(chan) = mode_n;
    SetParam(me,'mode','all',all);
    
    
case 'dura'
    check_params;
    
    chan = GetParamList(me,'chan');
    dura = GetParam(me,'dura');
    all = GetParam(me,'dura','all');    
    
    writem8(sprintf('D %d %s E',chan,num2m8(dura)));
    
    all(chan) = dura;
    SetParam(me,'dura','all',all);
    

case 'delay'
    check_params;

    chan = GetParamList(me,'chan');
    delay = GetParam(me,'delay');
    all = GetParam(me,'delay','all');    
    
    writem8(sprintf('L %d %s E',chan,num2m8(delay)));
    
    all(chan) = delay;
    SetParam(me,'delay','all',all);

case 'inter'
    check_params;
    
    chan = GetParamList(me,'chan');
    inter = GetParam(me,'inter');
    all = GetParam(me,'inter','all');    
    
    SetParam(me,'freq',1/inter);
    
    writem8(sprintf('I %d %s E',chan,num2m8(inter)));
    
    all(chan) = inter;
    SetParam(me,'inter','all',all);
    
case 'freq'
    SetParam(me,'inter',1/GetParam(me,'freq'));
    check_params;
    SetParam(me,'freq',1/GetParam(me,'inter'));
    Master8('inter');
    
    
case 'm'    
    check_params;
    
    chan = GetParamList(me,'chan');
    M = GetParam(me,'M');
    all = GetParam(me,'M','all');    
    
    writem8(sprintf('M %d %d E E',chan,M));
    
    all(chan) = M;
    SetParam(me,'M','all',all);
      
case 'set_trial'
    param = varargin{2};
    chan = varargin{3};   % must be a scalar
    trial = varargin{4};  % may be a vector
    val = varargin{5};    % must correspond to trial
    
    
    
    for n=1:length(trial)
        eval(sprintf('l = exper.%s.param.%s.trial;',me,param));
        if length(l) >= trial(n)
            eval(sprintf('x = exper.%s.param.%s.trial{%d};',me,param,trial(n)));
        else 
            x = ones(1,8)*GetParam(me,param);
        end
        x(chan) = val(n);
        eval(sprintf('exper.%s.param.%s.trial{%d} = x;',me,param,trial(n)));
    end
        
    
case 'send'
    str = varargin{2};
    writem8(str);
    
	
otherwise
	
end

% begin local functions

function out = me
	out = lower(mfilename); 
	
function out = callback
	out = [lower(mfilename) ';'];

function check_params
global exper
    if GetParam(me,'delay') <= GetParam(me,'dura')/10000
        SetParam(me,'delay',GetParam(me,'dura')/10000+1e-6);
    end
    switch GetParamList(me,'mode')
    case 'train'
        if GetParam(me,'inter') <= GetParam(me,'dura')+59e-6
            SetParam(me,'inter',GetParam(me,'dura')+60e-6);
        end
    otherwise
        if GetParam(me,'inter') <= GetParam(me,'dura')+9e-6
            SetParam(me,'inter',GetParam(me,'dura')+10e-6);
        end
    end    
    
function s = num2m8(x)

    if x < 0.001
        x = x*1000;
        s = [num2str(x) 'E3 E'];
    else
        s = [num2str(x) ' E'];
    end


function writem8(str)
   	com = get_com(GetParamList(me,'comm'));
    
	fprintf(com,str);	
    
%    resp = fscanf(com);
%    [t,r]= strtok(resp,'!')
%    message(me,t);
%    message(me,resp);

    message(me,str);
%    fclose(com);
    
 
function com = get_com(port)
	com = [];
	c = instrfind('tag','m8');
	for n=1:length(c)
		if ~strcmp(get(c(n),'status'),'open')
            fopen(c(n));
        end            
    	com = c(n);
        break;
	end
	if isempty(com)

% Master 8 wants 19200 baud, no parity, 8 bits per char, 1 stop but, no control lines
% If there is a problem, be sure to check these: press 'all' twice on m8
		com = serial(port,'tag','m8');
		fopen(com);
    end
    set(com,'baudrate',19200,'databits',8,'stopbits',1,'parity','none');	
        
	
