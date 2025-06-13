function varargout = AO(varargin)
% AO
% A module for analog output
%
% The hwtrigger input pin for AO on a National Instruments board is PFI6
%
%
% SL Macknik, 9/00
% ZF Mainen 10/00
% mw 101801 added hack to ao('close') to allow for multiple ao objects (e.g. that of sealtest) 


global exper

if nargin > 0
	action = lower(varargin{1});
else
	action = lower(get(gcbo,'tag'));
end

switch action
	
case 'init'
	
	% ao is called right before ai
	SetParam(me,'priority',2); 
	ModuleNeeds(me,{'ai'});

	fig = ModuleFigure(me,'visible','off');
	
	hs = 60;
	h = 5;
	vs = 20;
	n = 0;

	find_boards;

	InitParam(me,'SampleRate','ui','edit','value',8000,'pos',[h n*vs hs vs]); n=n+1;
	InitParam(me,'HwTrigger','ui','checkbox','pos',[h n*vs hs vs]); n = n+1;
	
	InitParam(me,'Send','ui','togglebutton','value',1,'pos',[h n*vs hs vs]);
	SetParamUI(me,'Send','string','Send','background',[0 1 0],'label','','pref',0);

	% reset
	uicontrol('parent',fig,'string','Reset','tag','reset','style','pushbutton',...
		'callback',[me ';'],'foregroundcolor',[.9 0 0],'pos',[h+hs n*vs hs vs]); n=n+1;
	
	% message box
	uicontrol('parent',fig,'tag','message','style','edit',...
		'enable','inact','horiz','left','pos',[h n*vs hs*2 vs]); n=n+1;
	
	set(fig,'pos',[5 234 128 n*vs],'visible','on');	
	
	

case 'slice'
	if 0
		if GetParam(me,'send')
			tot = round(exper.ao.daq.samplesavailable/1000);
			ot = round(exper.ao.daq.samplesoutput/1000);
			message(me,sprintf('Out %dk; left %dk',ot,tot));
		else
			message(me,'No output');
		end
	end
		
case 'trialready'
	if GetParam(me,'Send')
			% get rid of extra cued AO samples!
		if get(exper.ao.daq(1),'samplesavailable') > 0
			start(exper.ao.daq);
			stop(exper.ao.daq);
		end
		for n=1:length(exper.ao.daq)
			putdata(exper.ao.daq(n),exper.ao.data{n});
		end
		
		if 1
			cued = size(exper.ao.data{1},1)/1000;
			tot = get(exper.ao.daq(1),'samplesavailable')/1000;
		end
	end
	
case 'trialend'
	
case 'close'
    if ~isfield(exper.ao,'daq')
        return
    end
    for n=1:length(exper.ao.daq)
        for n=1:length(exper.ao.daq)
            %this hack prevents ao('close') from crashing if daqfind returns multiple ao objects
            %(which will happen if sealtest is running, since it has its own ao object!) mw 101801
            temp = daqfind('name',exper.ao.daq(n).name);
            if length(temp)==1
                dev(n) = daqfind('name',exper.ao.daq(n).name);
            elseif length(temp)==2 %if sealtest's ao object exists too
                dev{n}=temp{1};
            else error('hack didn''t work. mw 101801')
            end
            %        dev(n) = daqfind('name',exper.ao.daq(n).name);
        end
        
        %    dev(n) = daqfind('name',exper.ao.daq(n).name);
        %    end
        for n=1:length(dev)
            if strcmp(get(dev{n},'Running'),'On')
                stop(dev{n});
            end
            delete(dev{n});
        end
    end

%    ao = daqfind(
    exper.ao = rmfield( exper.ao, 'daq' );
	

% deal with UI callbacks

case 'ao_board_menu'
	name = get(gcbo,'user');
	if strcmp(name(1:5),'nidaq')
		adaptor = name(1:5);
		id = str2num(name(6));
	else
		adaptor = name(1:8);
		id = str2num(name(9));
	end
	
	if strcmp(get(gcbo,'checked'),'on')
		close_ao(adaptor,id);
	else
		open_ao(adaptor,id);
	end


case {'reset','putdata'}
	% a simple start/stop clears the cue
	if ~isvalid(exper.ao.daq)
        return
    end
    if strcmp(exper.ao.daq(1).running,'On')
		stop(exper.ao.daq);
	end
	reset_ao_data;

case 'hwtrigger'
	ao_pause;
	for n=1:length(exper.ao.daq)
		set_hwtrigger(exper.ao.daq(n));
	end

case 'slicerate'
	ao('samplerate')
	
case 'samplerate'
	if nargin >= 2
		SetParam(me, 'SampleRate', varargin{2});
	end	
	ao_pause;
	set(exper.ao.daq,'SampleRate',GetParam(me,'SampleRate'));
	SetParam(me,'SampleRate',exper.ao.daq(1).SampleRate);
	reset_ao_data;
	
case 'send'
	if nargin > 1
		SetParam(me,'send',varargin{2});
	end
	if GetParam(me,'send')
		SetParamUI(me,'send','background',[0 1 0]);
	else
		SetParamUI(me,'send','background',get(gcf,'color'));
	end
	
	
	
	
% implement external functions

case 'trigger'
	ao_start;
    
case 'pause'
    ao_pause;
	
case 'board_open'
	% ao('board_open',adaptor,id)
	% adaptor is 'nidaq' or 'winsound'
	board = open_ao(varargin{2},varargin{3});
	if board > 0
		nchan = length(exper.ao.daq(board).Channel);
	else
		nchan = 0;
	end
		
	varargout{1} = board;
	varargout{2} = nchan;
	

case 'board_close'
	% ao('board_close',adaptor,id)
	% adaptor is 'nidaq' or 'winsound'
	close_ao(varargin{2},varargin{3})

case 'channels'
	board = varargin{2};
	nchan = length(exper.ao.daq(board).Channel);
	varargout{1} = nchan;
	
case 'samples'
	varargout{1} = GetParam(me,'SampleRate')*GetParam('control','trialdur');
	
case 'putsample'
	% ao('putsample',data)
	% ao('putsample',board,data)
	% Immediately set AO channels to a specific voltage.
	% If more than one board is in use, the board number should be 
	% specified. Data must be a vector with same length as the
	% number of channels on the board
	if strcmp(exper.ao.daq(1).sending,'On')
		message(me,'Can''t putsample while sending','error');
	else
		if nargin > 2
			board = varargin{2};
			data = varargin{3};
		else
			if length(exper.ao.daq) == 1
				data = varargin{2};
				board = 1;
			else
				message(me,'Must specify board number');
				return
			end
		end
		nchan = length(exper.ao.daq(board).Channel);
		if length(data) == nchan
			putsample(exper.ao.daq(board),data)
%			message(me,sprintf('Putsamples board %d',board));
		else
			if nchan ~= 0
				message(me,sprintf('Need %d channels!',nchan));
			else
				message(me,sprintf('Board %d not initialized',board));
			end	
		end
	end
	
	
case 'setdata'
	% ao('setdata', board, data)

	if nargin > 2
		board = varargin{2};
		data = varargin{3};
	else
		if length(exper.ao.daq) == 1
			data = varargin{2};
			board = 1;
		else
			message(me,'Must specify board number');
			return
		end
	end
	
	aosize = GetParam(me,'SampleRate')*GetParam('control','trialdur');
	
 	if size(data,2) ~= length(exper.ao.daq(board).channel) | ...
		size(data,1) ~= aosize
		message(me,sprintf('Data size must be %d x %d',aosize,length(exper.ao.daq(board).channel)));
	else
		exper.ao.data{board} = data;
%		message(me,'Loaded data');
	end
	
case {'setchandata','addchandata'}
    % these fcns clear the current ao data
	%   ao('setchandata', channel, data)
	%   ao('setchandata', board, channel, data)
    % while these sum the new data and the existing data
    %   ao('addchandata', channel, data)
    %   ao('addchandata', board, channel, data)
	
	if nargin >= 4
		% User specified board.
		board = varargin{2};
		chan = varargin{3};
		data = varargin{4};
	elseif nargin >= 3
		% No board specified. Assume board 1.
		board = 1;
		chan = varargin{2};
		data = varargin{3};
	else
		message(me,'Incorrect use of setchandata.');
		return;
	end
	
	aosize = round(GetParam(me,'SampleRate')*GetParam('control','trialdur'));
	if size(data,1) > aosize
		message(me,sprintf('Data size must be <%d',aosize));
	else
        switch varargin{1} 
        case 'setchandata'
            exper.ao.data{board}(1:length(data),chan) = data;
        case 'addchandata'
            exper.ao.data{board}(1:length(data),chan) = data + ...
                exper.ao.data{board}(1:length(data),chan);
        otherwise
        end
   		message(me,sprintf('Loaded channel %d',chan));
	end        
	
otherwise	
	message(me,'Invalid function')
end



% begin local functions

function out = callback
	out = [lower(mfilename) ';'];

function out = me
	out = lower(mfilename); 


function ao_pause
global exper
	if isfield(exper.ao,'daq')
		if strcmp(exper.ao.daq(1).running,'On')
			stop(exper.ao.daq);
		end
	end


function ao_start
global exper	
	if ~GetParam(me,'send')
		return 
	end
	if strcmp(exper.ao.daq(1).running,'On')
		stop(exper.ao.daq);
		message(me,'Was still running!','error');
	end
	if exper.ao.daq(1).SamplesAvailable >= GetParam(me,'SampleRate')*GetParam('control','TrialDur')
		start(exper.ao.daq);
		if ~GetParam(me,'hwtrigger')
			if strcmp(exper.ao.daq(1).running,'On')
				trigger(exper.ao.daq);
				message(me,'Manually triggered');
			end
		end
		message(me,'');
	else
		message(me,sprintf('Too few (%d) samples cued',exper.ao.daq(1).SamplesAvailable));
	end
	% ai handles sending dio trigger
	% note trigger for AO on NI boards is PFI-6




function find_boards

fig = findobj('type','figure','tag','ao');
hf = uimenu(fig,'label','Board','tag','board');
delete(findobj('parent',hf));	% kill existing labels


%adaptors = {'nidaq','winsound'};
a=daqhwinfo;
adaptors = a.InstalledAdaptors;

for n=1:length(adaptors)
	b = daqhwinfo(adaptors{n});
	names = b.BoardNames;
	ids = b.InstalledBoardIds;
	for p=1:length(names)
				% this condition makes sure there is an analogoutput for this board
		if ~isempty(b.ObjectConstructorName{p,2})
			namestr = sprintf('%s%s-AO',adaptors{n},ids{p});
			label = sprintf('    %s (%s)',namestr,names{p});
			uimenu(hf,'tag','ao_board_menu','label',label,'user',namestr,'callback',callback);
		end
	end	
end

	

function close_ao(adaptor,id)
global exper

	boardname = sprintf('%s%d-AO',adaptor,id);
	ao = daqfind('name',boardname);
	
	if isempty(ao)
		message(me,'Board not open')
	end
		
	for n=1:length(ao)
		if strcmp(get(ao{n},'running'),'On')
			stop(ao{n});
		end
		k = length(exper.ao.daq);
		while k >= 1
			if strcmp(exper.ao.daq(k).name,boardname)
				if length(exper.ao.daq) > 1
					exper.ao.daq(k) = [];
				else
					exper.ao = rmfield(exper.ao,'daq');
				end
			end
			k=k-1;
		end
		
		delete(ao{n});
		message(me,sprintf('%s closed',boardname));
	end

	board_menu_labels;


	
function board = open_ao(adaptor,id)
global exper
	
	board = 0;
	boardname = sprintf('%s%d-AO',adaptor,id);
	if isfield(exper.ao,'daq')
		for n=1:length(exper.ao.daq)
			if strcmp(exper.ao.daq(n).Name,boardname)
				message(me,'Already initialized');
				board = n;
				return
			end
		end
	end
	
	if ~strcmp(adaptor,'nidaq') & ~strcmp(adaptor,'winsound')
		message(me,'nidaq and winsound are valid');
		return
	end
	boardinit = sprintf('analogoutput(''%s'',%d)',adaptor,id);
	ao = eval(boardinit); 

	ao.SampleRate = GetParam(me,'SampleRate');
	ao.TriggerFcn = {'ao_trig_handler'};
	
	switch adaptor
	case 'nidaq'
		h = daqhwinfo(ao);
		device = h.DeviceName;
		switch device
		case 'PCI-MIO-16E-4'
			ao.TransferMode = 'Interrupts';
			chan = 0:1;
		case 'PCI-6713'
			chan = 0:7;
		otherwise
			chan = 0:1;
		end
		for n=chan
			addchannel(ao,n,sprintf('Chan %d',n));
		end
		message(me,'nidaq');
		ok = 1;
	case 'winsound'
		for n=1:2
			addchannel(ao,n,sprintf('Chan %d',n));
		end
		message(me,'winsound');
	otherwise
		message(me,'no board!');
		return
	end
	
	if isfield(exper.ao,'daq')
		exper.ao.daq(end+1) = ao;
	else 
		exper.ao.daq = ao;
	end
	
	set_hwtrigger(ao);
	
	message(me,sprintf('%s%d initialized',ao.name));
	board_menu_labels;
	
	% erase data
	for n=1:length(exper.ao.daq)
		exper.ao.data{n} = [];
	end
	board = length(exper.ao.daq);	
	
%	reset_ao_data;


function board_menu_labels
global exper
	menuitems = findobj('tag','ao_board_menu');
	for n=1:length(menuitems)
		label = get(menuitems(n),'label');
		label(1:2) = '  ';
		set(menuitems(n),'checked','off','label',label);
	end
		
	if isfield(exper.ao,'daq')
		for n=1:length(exper.ao.daq)
			menuitem = findobj('tag','ao_board_menu','user',exper.ao.daq(n).name);
			label = get(menuitem,'label');
			label(1:2) = sprintf('%d:',n);
			set(menuitem,'checked','on','label',label);
		end
	end

	
function set_hwtrigger(board)
global exper

	%if its possible to set the Trigger to HwDigital, then do it
	inputs = propinfo(board, 'TriggerType');
	if isempty(find(strcmp(inputs.ConstraintValue, 'HwDigital')))
		SetParamUI(me,'hwtrigger','enable','off');
		SetParam(me,'hwtrigger','value',0,'range',[0 0]);
	else
		SetParamUI(me,'hwtrigger','enable','on');
		SetParam(me,'hwtrigger','range',[0 1]);
	end

	if max(GetParam(me,'hwtrigger','range')) & GetParam(me,'hwtrigger')
	
		%if its possible to set the Trigger to HwDigital, then do it
		board.TriggerType = 'HwDigital';
	else
		board.TriggerType = 'Manual';
	end

	message(me,sprintf('%s trigger',board.triggertype));

	


function reset_ao_data
global exper

	% get rid of extra cued AO samples!
	for n=1:length(exper.ao.daq)
        if exper.ao.daq(n).samplesavailable > 0
    		start(exper.ao.daq(n));
    		stop(exper.ao.daq(n));
    	end
    end
	
	
	for n=1:length(exper.ao.daq)
		nchan = length(exper.ao.daq(n).Channel);
		aosamp = ceil(GetParam('ao','SampleRate')*GetParam('control','trialdur'));
		if isempty(exper.ao.data{n}) | size(exper.ao.data{n},1) ~= aosamp
			exper.ao.data{n} = zeros(aosamp,nchan);
		end
		if GetParam(me,'Send')
			putdata(exper.ao.daq(n),exper.ao.data{n});
		end
		message(me,'');
	end
	
%	message(me,'Reset ao data');
%	message(me,'');


