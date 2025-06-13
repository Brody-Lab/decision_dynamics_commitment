function varargout = ValveFlow(varargin)
% ValveFlow
% A basic utility for flow controllers and valves using analog out
% ZF Mainen 6/02
%
% Revisions
% 7-08-02 ZFM: Removed 'samplerate' parameter to avoid the possibility of
% conflicting with AO.samplerate
% 
% 1-30-03 ZFM: Added 'reset' function
%

global exper


out = lower(mfilename);
if nargin > 0
	action = lower(varargin{1});
else
	action = lower(get(gcbo,'tag'));
end

switch action
	
case {'init','reinit'}

	SetParam(me,'priority',8);      % note: priority must be lower than orca
    if strcmp(action,'init')
        ModuleNeeds(me,{'ao'});
    end

	fig = ModuleFigure(me,'visible','off');	 
	
	hs = 110;
	h = 5;
	vs = 20;
	n = 0;
	

	% a name for the current odor list, for purposes of saving/loading 
	% different sets
	
	InitParam(me,'Duration','ui','edit','value',10,'save',1,'pos',[h n*vs hs vs]); n=n+1;
	InitParam(me,'Delay','ui','edit','value',5,'save',1,'pos',[h n*vs hs vs]); n=n+1;

%    InitParam(me,'total_flow','ui','edit','value',1000,'pos',[h n*vs hs vs]); n=n+1;
	
	uicontrol(fig,'string','Update','tag','update','callback',[me ';'],'pos',[h n*vs hs vs]); n=n+1;
    
    InitParam(me,'calibration','ui','checkbox','value',0,'pos',[h n*vs hs vs]); n=n+1;
	InitParam(me,'odor_B_flow','board',1,'chan',2,'units_range',[0 100],'out_range',[0 5],'ui','edit','value',50,'save',1,'pos',[h n*vs hs vs]); n=n+1;
    InitParam(me,'odor_A_flow','board',1,'chan',1,'units_range',[0 100],'out_range',[0 5],'ui','edit','value',50,'save',1,'pos',[h n*vs hs vs]); n=n+1;
    InitParam(me,'total_flow','board',2,'chan',8,'units_range',[0 1000],'out_range',[0 5],'ui','edit','value',1000,'save',1,'pos',[h n*vs hs vs]); n=n+1;

    % chan allows an arbitrary mapping from value number to DA channel 
    % blank is a channel that is open when valves are nominally 'off'
    uicontrol(fig,'string','Valves on','tag','valves_on','style','togglebutton','callback',[me ';'],'pos',[h n*vs hs vs]); n=n+1;
    InitParam(me,'odor_A_valves','board',2,'chan',1:4,'blank',4,'ui','edit','value',1,'save',1,'pos',[h n*vs hs vs]); n=n+1;
    InitParam(me,'odor_B_valves','board',2,'chan',5:7,'blank',7,'ui','edit','value',5,'save',1,'pos',[h n*vs hs vs]); n=n+1;
    
    uicontrol('parent',fig,'string','Reset','tag','reset','style','pushbutton',...
		'callback',[me ';'],'foregroundcolor',[.9 0 0],'pos',[h n*vs hs vs]); n=n+1;
	   	
	% message box
	uicontrol('parent',fig,'tag','message','style','edit',...
		'enable','inact','horiz','left','pos',[h n*vs hs*2 vs]); n=n+1;
	
	set(fig,'pos',[142 746-n*vs hs+80 n*vs],'visible','on');
	
    if strcmp(action,'init')
        init_ao;
        [on_value,off_value] = setup_ao;
        putdata_ao(on_value,off_value);
    end
    putsample_ao(off_value);
	
case 'slice'
	
case 'trialready'	

case 'trialend'
	[on_value,off_value] = setup_ao;
    putdata_ao(on_value,off_value);
    putsample_ao(off_value);
    
    
case 'close'
      

	
% handle ui callbacks


case 'reset'
    
    if isfield(exper.ao,'daq')
        delete(exper.ao.daq);
        exper.ao = rmfield(exper.ao,'daq');
    end
    
    init_ao;
    [on_value,off_value] = setup_ao;
    putdata_ao(on_value,off_value);
 


case {'update','delay','duration','reset'}
    
    [on_value,off_value] = setup_ao;
    putsample_ao(off_value);
    putdata_ao(on_value,off_value);
    set(findobj(gcbo,'tag','valves_on'),'value',0,'background',get(gcbf,'color'));
    

case 'valves_on'
    [on_value,off_value] = setup_ao;
    if get(gcbo,'value')
        putsample_ao(on_value);
        set(gcbo,'background','green');
    else
        putsample_ao(off_value);
        set(gcbo,'background',get(gcbf,'color'));
    end

	
otherwise
	
end

% begin local functions

function out = me
	out = lower(mfilename);
    
    
function init_ao
	
    % Open the NIDAQ boards
    boards = { 'nidaq1-AO','nidaq2-AO'};
   
    for i=1:length(boards)
        [b{i},c{i}] = AO('board_open','nidaq',i);
    end
  
       

        
function [on_value,off_value] = setup_ao

    % Set up output vectors
    
    boards = { 'nidaq1-AO','nidaq2-AO'};
    
    for i=1:length(boards)
        b = daqfind('name',boards{i});
        nchan = length(get(b{1},'channel'));
        
        on_value{i} = zeros(nchan,1);
        off_value{i} = zeros(nchan,1);
    end

    % VALVES
    
    valves = {'odor_A_valves','odor_B_valves'};
    
    for i=1:length(valves)
        
        board = GetParam(me,valves{i},'board');
        chan = GetParam(me,valves{i},'chan');
        nchan = length(chan);
        
        % odor chan is the index of the channel(s) on during the stimulus
        odor_index = GetParam(me,valves{i},'value');
        if ischar(odor_index)
            odor_index = str2num(odor_index);
        end
        odor_chan = odor_index;
        
        on_value{board}(odor_chan) = 5;
        
        % blank chan is the index of the channel(s) on before and after the stimulus
        blank_index = GetParam(me,valves{i},'blank');
        blank_chan = blank_index;
        
        off_value{board}(blank_chan) = 5;  % 5 means 'on'
    end

    %FLOW CONTROLLERS 
    
    flow = {'odor_a_flow','odor_b_flow','total_flow'};
    
        for i = 1:length(flow)
            f(i) = GetParam(me,flow{i},'value');
        end
        
        % f(3) becomes the actual carrier flow 
        % which is the total_flow desired (f(3)) minus the odor flows (f(1) and f(2))
        f(3) = f(3) - (f(1) + f(2));
        
        % calibration
        if GetParam(me,'calibration');
            f = calib_flow(f);
        end
%         disp(f)
    
    for i=1:length(flow)
        board = GetParam(me,flow{i},'board');
        chan = GetParam(me,flow{i},'chan');
        out_range = GetParam(me,flow{i},'out_range');    
        units_range = GetParam(me,flow{i},'units_range');    
        v = f(i)*out_range/units_range;
        on_value{board}(chan) = v;
        off_value{board}(chan) = v;
    end
    
%     disp(off_value{3})
    
function putsample_ao(value)
       % send command to ao immediately

        boards = { 'nidaq1-AO','nidaq2-AO'};
        for i=1:length(boards)
            ao('putsample',i,value{i}');
        end

        
function putdata_ao(on_value,off_value)
    % Set up the vector data for the boards

    % First figure out the number of samples and the period when the
    % valves will be on
    
    sample_rate = GetParam('ao','samplerate');
    samples = GetParam('control','trialdur') * sample_rate;
    v0 = GetParam(me,'delay') * sample_rate;
    v1 = (GetParam(me,'delay')+GetParam(me,'duration')) *  sample_rate;

    boards = { 'nidaq1-AO','nidaq2-AO'};
  
    for i=1:length(boards)
        
        % load board for triggered output
        chan_vector = repmat(off_value{i}',samples,1);
        chan_vector(v0:v1,:) = repmat(on_value{i}',v1-v0+1,1);
        
        ao('setdata',i,chan_vector);
    end   
        
    ao('putdata');
    
    
function f = calib_flow(flows)

% function to calibrate flow controler

% parameters for calibration ('set flow' and 'actual flow') measured on 7/22/2002
set_flow_A = [0 0.5 1 2 4 8 10 15 20 40 60 80 90];
act_flow_A = [1.5 3.9 4.3 5.5 7.6 12.2 14.3 19.1 24.8 46.5 66.8 87.4 97.8];

set_flow_B = [0 1 2 4 8 10 20 40 60 80 90];
act_flow_B = [1.1 3.8 5.0 7.8 11.4 13.9 23.4 44.1 64.5 85.3 95.1];

set_flow_T = [0 10 20 40 80 100 200 400 600 800 900];
act_flow_T = [4 11 20 40 80 100 203 430 659 865 985];

% calibrated values 7/22/2002 at tetrode rig
% set_flow_A = [0 0.5 1 2 4 8 10 15 20 40 60 80 90];
% act_flow_A = [1.5 3.9 4.3 5.5 7.6 12.2 14.3 19.1 24.8 46.5 66.8 87.4 97.8];
% 
% set_flow_B = [0 1 2 4 8 10 20 40 60 80 90];
% act_flow_B = [1.1 3.8 5.0 7.8 11.4 13.9 23.4 44.1 64.5 85.3 95.1];
% 
% set_flow_T = [0 10 20 40 80 100 200 400 600 800 900];
% act_flow_T = [4 11 20 40 80 100 203 430 659 865 985];

for n = 1:length(flows)
    flow = flows(n);
    switch n
    case 1 
        set_flow = set_flow_A;
        act_flow = act_flow_A;
        r1 = find(set_flow <= 20);
        p1 = polyfit(set_flow(r1),act_flow(r1),3);
        
        r2 = find(set_flow > 10);
        p2 = polyfit(set_flow(r2),act_flow(r2),1);
        
%         figure
%         plot(set_flow, act_flow,'o'); hold on 
%         plot(0:10,polyval(p1,0:10))
%         plot(8:100,polyval(p2,8:100))
        
        if flow >= 8
            p = p2;
            p(end) = p(end) - flow;
            f(n) = roots(p);
        else p = p1;
            p(end) = p(end) - flow;
            ff = roots(p);
            f(n) = min(ff);
        end
        
    case 2
        set_flow = set_flow_B;
        act_flow = act_flow_B;
        r1 = find(set_flow <= 10);
        p1 = polyfit(set_flow(r1),act_flow(r1),3);
        
        r2 = find(set_flow > 10);
        p2 = polyfit(set_flow(r2),act_flow(r2),1);
        
        if flow >= 8
            p = p2;
            p(end) = p(end) - flow;
            f(n) = roots(p);
        else p = p1;
            p(end) = p(end) - flow;
            ff = roots(p);
            f(n) = min(ff);
        end
        
    case 3
        set_flow = set_flow_T;
        act_flow = act_flow_T;
        r1 = find(set_flow <= 100);
        p1 = polyfit(set_flow(r1),act_flow(r1),3);
        
        r2 = find(set_flow > 100);
        p2 = polyfit(set_flow(r2),act_flow(r2),1);
        
        if flow >= 80
            p = p2;
            p(end) = p(end) - flow;
            f(n) = roots(p);
        else p = p1;
            p(end) = p(end) - flow;
            ff = roots(p);
            f(n) = min(ff);
        end
    end
end