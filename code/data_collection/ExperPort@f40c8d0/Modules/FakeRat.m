function out = FakeRat(varargin)
% FAKERATE
% 
% Send signals through AO to test
% RP2 as if there were a rat in the box


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
        
        SetParam(me,'priority','value',GetParam('rpbox','priority')+1);
        ModuleNeeds(me,{'ao'});
        
        hs = 60;
        h = 5;
        vs = 20;
        n = 0;
        
        InitParam(me,'lambda','ui','edit','value',1,'save',1,'pos',[h n*vs hs vs]); n=n+1;
        InitParam(me,'min','ui','edit','value',0.005,'save',1,'pos',[h n*vs hs vs]); n=n+1;
        InitParam(me,'showfig','ui','checkbox','value',1,'pos',[h n*vs hs vs]); n=n+1;
        InitParam(me,'on','ui','togglebutton','value',0,'pos',[h n*vs hs vs]); n=n+1;
        SetParamUI(me,'on','string','On','background',get(gcf,'color'),'label','','pref',0);
        InitParam(me,'times','save',1);
        InitParam(me,'pokes','save',1);
        InitParam(me,'AOData','value',0);
        InitParam(me,'LastPokeState','value',0);
        
        % message box
        uicontrol('parent',fig,'tag','message','style','edit',...
            'enable','inact','horiz','left','pos',[h n*vs hs*2.5 vs]); n=n+1;
        
        set(fig,'pos',[142 480-n*vs 160 n*vs],'visible','on');
        a=daqhwinfo(exper.ai.daq);
        if strcmp(a.DeviceName,'PCI-6014')
            set(exper.ai.daq,'Transfermode','Interrupts');
        end
        SetParam('ao','send',1);
        set_data;
        
    case 'slice'
        
    case 'trigger'
        message(me,'Ok');
        
        
    case 'trialend'
        SaveParamsTrial(me);
        fakerat('compare',GetParam('control','trial'));
        set_data;  
        
    case 'close'
        a=daqhwinfo(exper.ai.daq);
        if strcmp(a.DeviceName,'PCI-6014')
            set(exper.ai.daq,'Transfermode','SingleDMA');
        end    
        SetParam('ao','send',0);
        
    case 'reset'
        message(me,'Ok');
        set_data;  

        ClearParamTrials(me);
        
    case 'load'
        LoadParams(me);
        
        % handle UI parameter callbacks
        
    case {'lambda','min','on'}
        if ~GetParam('control','run')
            set_data;
        end
         
        
    case 'compare'
        if nargin < 2
            trial = GetParam('control','trial')-1;
        else
            trial = varargin{2};
        end
        
        compare_data(trial);    
        
    otherwise
        
end

% begin local functions

function out = me
out = lower(mfilename); 

function out = callback
out = [lower(mfilename) ';'];


function set_data
global exper

if GetParam(me,'On') == 0
    % need to clear ao
    return;
end

%samprate = 8000; % sample rate in Hz
samprate = GetParam('ao','samplerate');
L = ao('samples');

% mean rate in Hz
mu = GetParam(me,'lambda');
% number of events
N = 500;
intervals = exprnd(1/mu,1,N);

min_interval = GetParam(me,'min');
intervals(find(intervals < min_interval)) = min_interval;
% make sure 

times = cumsum(intervals);
times = times(find(times < L/samprate));

% make sure we end on an 'out'
% if mod(length(times),2) == 1
%     times = times(1:end-1);
% end

%try to set the state according to the last trial
trial = GetParam('control','trial');
state = GetParam(me,'LastPokeState');

y = zeros(round(L),1);
pokes = [];
last_ind = 1;
for i=1:length(times)
    ind = ceil(times(i)*samprate);
    y(last_ind:ind-1) = state;
    last_ind = ind;
    pokes(i)=state;
    state = 1-state;
end
y(last_ind:end) = state;


volts = 5;  % set output range
y = y*volts; 
ao('setdata',[y y]);

SetParam(me,'times',times);
SetParam(me,'pokes',pokes);
SetParam(me,'AOData',y);
SetParam(me,'LastPokeState',state);



% COMPARE DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function compare_data(trial)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
% the time at which the current trial began since the start of the
% experiment in seconds

if GetParam(me,'On') == 0
    return;
end

trialtime = etime(GetParamTrial('control','trialstart',trial),GetParam('control','start'));

my_times = GetParamTrial(me,'times',trial);
my_pokes = GetParamTrial(me,'pokes',trial);

rp2_field = GetParamTrial('rpbox','trial_events',trial);
for i=1:length(rp2_field)
    rp2_times(i) = rp2_field(i).time -trialtime;
    rp2_chan(i) = rp2_field(i).chan;
end

if isempty(rp2_field) | isempty(rp2_times) | isempty(my_times)
    message(me,'Problem: no data','error');
    return;
end

offset = rp2_times(1) - my_times(1);
rp2_times = (rp2_times-offset);     % note -- we are assuming some offset here


% find matches
eta = GetParam(me,'min')*.5;
k=1;
rp2_match_times = [];
rp2_err_times = [];
for i=1:length(my_times)
    match_ind = find(rp2_times < my_times(i)+eta & rp2_times > my_times(i)-eta);
    if length(match_ind) > 0
        rp2_match_times(i) = rp2_times(match_ind);
    else
        rp2_match_times(i) = NaN;
        rp2_err_times(k) = NaN;    % the answer here is ambiguous
        k = k+1;
    end
end

diff_times = my_times-rp2_match_times;

missed = length(rp2_err_times);
if missed > 0
    message(me,sprintf('Trial %d: missed %d/%d events',trial,missed,length(rp2_times)),'error');
else
    message(me,sprintf('Trial %d: Found %d matching events',trial,length(rp2_times)));
end

if GetParam(me,'ShowFig')
    figure(22); 
    if missed > 0
        plot(rp2_err_times,zeros(1,missed),'r*'); 
    end
    
    AOData=getparam(me,'AOData');
    time_base = (1:length(AOData))/GetParam('ao','samplerate');
    
    g = axis;
    axis([0 GetParam('control','trialdur') -1 2]); hold on;
    cla
    xlabel('Event times (s)');
    ylabel('Event');
    set(gca,'YTick',[0 1],'YTickLabel',{'Out','In'});
    mm = sqrt(mean(diff_times.^2))*1000;
    title(sprintf('Trial %d: Fakerat RMS time err: %3.3g ms',trial,mm));
    %plot(rp2_times,ones(1,length(rp2_times)),'x');  hold on;
    plot(my_times,mod(my_pokes+1,2),'bo');  
    plot(time_base,AOData/5,'b');  hold on;
    plot(rp2_times,mod(rp2_chan,2),'r+'); 
end