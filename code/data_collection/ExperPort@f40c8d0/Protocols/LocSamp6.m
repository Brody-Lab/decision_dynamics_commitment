function [out] = LocSamp6(varargin)

% - implement changing dot color as soon as we have an answer, not only at
% - the end of the trial...

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
