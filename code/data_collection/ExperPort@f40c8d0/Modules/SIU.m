function out = SIU(varargin)
% SIU
% 
% This module doesn't do much except let you manually enter setting for a
% stimulus isolation unit (SIU).
% 
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
	
	fig = ModuleFigure(me,'visible','off');	
	
	SetParam(me,'priority',7);

	hs = 60;
	h = 5;
	vs = 20;
	n = 0;
    InitParam(me,'amplitude','ui','edit','value',0,'save',1,'pos',[h n*vs hs vs]); n=n+1;
    InitParam(me,'mode','ui','togglebutton','value',1,'save',1,'pos',[h n*vs hs vs]); n=n+1;
    SetParamUI(me,'mode','string','current');
    
    
    % message box
    uicontrol('parent',fig,'tag','message','style','edit',...
        'enable','inact','horiz','left','pos',[h n*vs hs*2 vs]); n=n+1;
    
	set(fig,'pos',[142 480-n*vs 128 n*vs],'visible','on');

case 'slice'
	
case 'trialready'
    
case 'trialend'
   	SaveParamsTrial(me);
    
case 'close'
	
case 'load'
    LoadParams(me);
	
% handle UI parameter callbacks

case 'mode'
    if GetParam(me,'mode')
        SetParamUI(me,'mode','string','current');
    else
        SetParamUI(me,'mode','string','voltage');
    end
	
otherwise
	
end

% begin local functions

function out = me
	out = lower(mfilename); 
	
function out = callback
	out = [lower(mfilename) ';'];

    
