%actxcontrolWrapper.m   [out] = actxcontrolWrapper(varargin)
%
% Takes two possible actions, depending on the value of the global variable
% 'fake_rp_box':
%
%   - If fake_rp_box doesn't exist, is empty, or is 0, then calls
%          out = actxcontrol(args); 
%        with args being whatever was passed to it.
%
%   - If fake_rp_box ~= 0, then interprets the first three args as 
%        name, pos, handle, and ...
%
% fake_rp_box == 0 --> RM1 TDT boxes
% fake_rp_box == 1 --> First virtual state machine (running off timers)
% fake_rp_box == 2 --> RT Linux state machien
% fake_rp_box == 3 --> SoftSMMarkII virtual state machine (object, no timers)
% fake_rp_box == 4 --> softsm virtual state machine (old, no scheduled waves)
%

function [out] = actxcontrolWrapper(varargin)

global fake_rp_box;
global FakeActiveXObjects;

if length(varargin)<1, error('Need at least one argument'); end;

% If using RM1 boxes, this is just a direct gateway to actxcontrol.m
if isempty(fake_rp_box) | fake_rp_box == 0,
    argstr = []; for i=1:length(varargin)-1,
        argstr = [argstr 'varargin{' num2str(i) '}, '];
    end;
    argstr = [argstr 'varargin{' num2str(length(varargin)) '}'];
    out = eval(['actxcontrol(' argstr ');']);
    return;

% Using virtual machines that also use software sound
elseif ismember(fake_rp_box, [1 2 3 4]),
   if length(varargin) < 3, error('Need name, pos, handle as args'); end;
   name = varargin{1}; pos = varargin{2}; fighandle = varargin{3};
   if isempty(FakeActiveXObjects), 
      FakeActiveXObjects={'xhandle','name', 'pos', 'fighandle', 'rp_machine'};
   end;
   newhandle = num2str(size(FakeActiveXObjects,1));
   FakeActiveXObjects = ...
       [FakeActiveXObjects ; {newhandle name pos fighandle ''}];
   out = newhandle;
   return;

% Using RT Linux state machine with RM1 sound machine--
%
% 27-Sep-05:
% No longer used, RT Linux state machine now uses Calin's sound server
%
%
elseif fake_rp_box == 2, % First call creates empty virtual machine;
                         % second goes to physical RM1 sound machine
   if length(varargin) < 3, error('Need name, pos, handle as args'); end;
   name = varargin{1}; pos = varargin{2}; fighandle = varargin{3};
   if isempty(FakeActiveXObjects), 
      FakeActiveXObjects={'xhandle','name', 'pos', 'fighandle', 'rp_machine'};
      newhandle = num2str(size(FakeActiveXObjects,1));
      FakeActiveXObjects = ...
          [FakeActiveXObjects ; {newhandle name pos fighandle ''}];
   else
      newhandle = num2str(size(FakeActiveXObjects,1));
      acx = actxcontrol(name, pos, fighandle);
      FakeActiveXObjects = ...
          [FakeActiveXObjects ; {newhandle name pos fighandle acx}];
   end;
   out = newhandle;   
end;

