function varargout = dio(varargin)
% dio
% A module for digital input and output
% 
% DIO('trigger')
% DIO('line',line,value)
% DIO('line',line,port,value)
% 	value is 0 or 1
%		
%
% ZF Mainen, CSHL, 10/00
% SL Macknik, CSHL, 9/00

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
	
	%set initial parameters 
	SetParam(me,'priority',1);
	ModuleNeeds(me,{'ai'});
	
	
	hs = 60;
	h = 5;
	vs = 20;
	n = 1;
	
	if ~ExistParam(me,'board')
		% if we haven't been initialized
		[boards boardinits] = find_boards;
		InitParam(me,'board','ui','menu','list',boards,'value',1);
		InitParam(me,'boardinit','list',boardinits);
	else
		InitParam(me,'Board','ui','menu');
	end
	SetParamUI(me,'Board','label','Board');
	InitParam(me,'Trigchan','value','c0','ui','edit','pos',[h 0 hs vs]);
	InitParam(me,'HwTrigger','value',0,'ui','checkbox','pos',[h n*vs+1 hs vs]); n=n+1;
	
	[lines ports] = init_dio(fig);
	
	% set up the trigger
	dio('trigchan');
	
	n = n+ports;
	
	
	% message box
	uicontrol('parent',fig,'tag','message','style','edit',...
		'enable','inact','horiz','left','pos',[h n*vs hs*2 vs]); n=n+1;
	
	message(me,sprintf('%s DIO initialized',GetParamList(me,'board')));

	set(fig,'pos',[5 188-n*vs 128 n*vs],'visible','on');
	
	
	
case 'slice'	
	%something is wrong with the code below...but I'm not sure what and I don't need it right now..sorry.SLM 9/00
	
	%find the dio lines that are set to 'IN'
%	innies  = daqfind('Direction', 'In');
%	if ~isempty(innies)
%		names   = innies{:}.LineName;
%		indeces = innies{:}.Index;
%		
%		signals = getvalue(exper.dio.dio);
%		
%		for n=1:length(innies)
%			SetParam(me, 'value', 1)
%			set(GetParam(me, names{indeces{n}}, 'h'), 'BackgroundColor', [0 0 signals(indeces{n})]);
%		end	
%	end
	
case 'trialready'
	
case 'trialend'
		
	
case 'close'
	if ~isfield(exper.dio,'dio')
        return
    end
    
        stop(exper.dio.dio);
	while(length(exper.dio.dio.Line))
		delete(exper.dio.dio.Line(1));
	end
	delete(exper.dio.dio);


	
% handle UI callbacks

case 'trigchan'
	
	
%	line = daqfind(exper.dio.dio,'linename',GetParam(me,'trigchan','value'));
	
	lineh = findobj('parent',findobj('type','figure','tag',me),'tag','line',...
		'string',GetParam(me,'trigchan','value'));
	
	if ~isempty(lineh)
		SetParam(me,'hwtrigger','lineh',lineh)
		SetParamUI(me,'hwtrigger','enable','on');
		message(me,'Trigger chan changed');
	else
		SetParamUI(me,'hwtrigger','enable','off');
		message(me,'Invalid trigger chan');
	end
	
	
case 'board'
	ModuleClose('dio');
	dio('init');


% line is both a callback and an external function
	
case 'line'
	% handle callback from the status panel or
	% called with syntax:
	%
	% dio('line',line,value)
	% dio('line',line,port,value)
	% 	value is 0 or 1
	
	if nargin <2 
		% called from the object
		val = get(gcbo,'Value');
		h = gcbo;
	else
		% called from a function
		line = varargin{2};
		if nargin < 4
			port = 1;
			val = varargin{3};
		else
			port = varargin{3};
			val = varargin{4};
		end
		% we have stored an array of handles to the button objects
		% which in turn contain a reference to the dio line in their
		% user field
		h = exper.dio.lineh(port,line+1);
	end
	
	%change the color of the button 
	if val
		set(h,'BackgroundColor',[0 1 0],'value',1);
	else
		set(h,'BackgroundColor',get(gcf,'color'),'value',0);
	end
	% set the line
	lineobj = get(h,'user');
	if length(lineobj) > 1
		for n=1:length(lineobj)
			putvalue(lineobj{n}, val);
		end
	else
		putvalue(lineobj, val);
	end
		
		
case 'hwtrigger'
	if get(gcbo,'value')
		dio('trigger');
	end
	
	
	
% handle external function calls

case 'reset'
	message(me,'');
	
case 'trigger'
	if ~ExistParam(me,'hwtrigger') return; end
    if GetParam(me,'hwtrigger') & GetParam(me,'open')
        lineh = getparam(me,'hwtrigger','lineh');
        line = get(lineh,'user');
        set(lineh,'background',[0 1 0]);
        putvalue(line,1);
        putvalue(line,0);
        set(lineh,'background',get(gcf,'color'));
    end
    

otherwise	
	
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 								begin local functions
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = me
out = lower(mfilename); 



function out = callback
out = [lower(mfilename) ';'];



function varargout = find_boards
%adaptors = {'nidaq'};
a=daqhwinfo;
adaptors = a.InstalledAdaptors;
boards = {''};
boardinits = {''};
q = 1;
for n=1:length(adaptors)
	b = daqhwinfo(adaptors{n});
	names = b.BoardNames;
	ids = b.InstalledBoardIds;

	for p=1:length(names)
        if strcmp(b.AdaptorName,'nidaq')
%   		if strcmp(names{p},'nidaq')
    		boards{q} = names{p};
    		boardinits{q} = sprintf('digitalio(''%s'',%s)',adaptors{n},ids{p});
    		q = q+1;
    	end	
    end
end
varargout{1} = boards;
varargout{2} = boardinits;


function [lines, ports] = init_dio(fig)
global exper

	board = GetParam(me,'board','value');
	
	SetParam(me,'boardinit',board);
	bo = GetParamList(me,'boardinit');
	if isempty(bo)
        ports  = 0;
        lines = 0;
        return
    end
    dio = eval(bo); %this initializes DIO by evaluating the string "dio = digitalio('nidaq', ...
	
	exper.dio.dio = dio;
	nidioinfo = daqhwinfo(dio);
	ports = length(nidioinfo.Port);
	lines = nidioinfo.TotalLines;
	
	n = 1+ports;
	vs = 20;
	count = 0;
	portnames = {'','a','b','c'};

	for l=1:ports % one row of line buttons for each port
		for m=1:(lines/ports) % # of lines per port
			port = portnames{l};

			name = sprintf('%s%d', port, m-1);
			line = addline(dio, count, 0, 'Out', name);
		
			% status panel
			h = uicontrol(fig,'string',name,'style','toggle','pos',[((m-1)*15)+5 (n*vs) 15 15], ...
				'value', 0, 'tag', 'line', 'user', line, 'callback', callback, ...
				'BackgroundColor', get(gcf,'color'));
			
			% save a set of handles to the toggles, which in turn
			% reference the lines
			exper.dio.lineh(l,m) = h;
		
			count = count+1;
		end
		n = n-1;
	end

