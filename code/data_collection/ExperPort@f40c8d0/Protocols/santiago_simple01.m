% I think that this file provides an interface between RPBox and
% Solo by defining the actions of the protocol object.
% I wish someone had written a paragraph about it.
%
% Santiago Jaramillo - 2007.05.14

function [out] = santiago_simple01(varargin)

global exper

if nargin > 0 
    action = lower(varargin{1});
else
    action = lower(get(gcbo,'tag'));
end

out=1;
switch action
    case 'init',
        ModuleNeeds(mfilename, {'rpbox'});
        SetParam(mfilename,'priority','value',GetParam('rpbox','priority')+1);       
        InitParam(mfilename, 'object', 'value', ...
                  eval([mfilename 'obj(''' mfilename ''')']));
        
    case 'update',
        my_obj = GetParam(mfilename, 'object');
        update(my_obj);

    case 'close',
        if ExistParam(mfilename, 'object'),
            my_obj = GetParam(mfilename, 'object');
            close(my_obj);
        end;    
        SetParam('rpbox','protocols',1);
        return;
        
    case 'state35',
        my_obj = GetParam(mfilename, 'object');
        state35(my_obj);
        
   otherwise
        out = 0;
end;


%%%function [myname] = me
%%%    myname = lower(mfilename);
