% [out] = Template(varargin)
%
% This file Template.m, together with the directory @templateobj, is an
% example of how to write a protocol in the system as it exists on
% 9-Feb-06. The state of the system is currently still a hybrid of the old
% Exper and the new Solo/RTLinux system. (Nevertheless, it runs and can be
% used immediately.) The top-level file Template.m provides part of the
% interface between Exper and Solo/RTLinux.
%
% Copy and tweak this template to write your own protocol. This top-level
% file will probably need no modification. The protocol implemented is
% very simple and unsophisticated (sound localization): it is intended to
% be modified and built on by you.
%
% We will assume that your @templateobj directory contains the following
% methods (plus some others relevant to your protocol, of course):
%
%    templateobj.m, a constructor method, called once when the protocol
%                is opened.
%    update.m,   called repeatedly (every 350 ms or so) during a trial
%    state35.m,  called once at the end of each trial.
%    close.m     called when you are completely closing the protocol
%          (the expt is over).
%
% Given those methods, this top-level file, Template.m, will work for
% every protocol. There is no need to modify it at all (other than to
% replace 'template', of course, by some name of your choice.)
%

% CDB 9-Feb-06

function [out] = Template(varargin)

global exper

if nargin > 0 
    action = lower(varargin{1});
else
    action = lower(get(gcbo,'tag'));
end

out=1;  
switch action
    case 'init',
        ModuleNeeds(me, {'rpbox'});
        SetParam(me,'priority','value',GetParam('rpbox','priority')+1);       
        InitParam(me, 'object', 'value', ...
                  eval([lower(mfilename) 'obj(''' mfilename ''')']));
        
    case 'update',
        my_obj = GetParam(me, 'object');
        update(my_obj);

    case 'close',
        if ExistParam(me, 'object'),
            my_obj = GetParam(me, 'object');
            close(my_obj);
        end;    
        SetParam('rpbox','protocols',1);
        return;
        
    case 'state35',
        my_obj = GetParam(me, 'object');
        state35(my_obj);
        
   otherwise
        out = 0;
end;


function [myname] = me
    myname = lower(mfilename);
