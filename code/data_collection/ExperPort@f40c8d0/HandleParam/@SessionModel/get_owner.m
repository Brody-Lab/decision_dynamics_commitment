function [param_owner] = get_owner(obj, varargin)
% Gets the class of the object that owns this instance of SessionModel

pairs = { ...
    'object', 0 ; ...
    };
parse_knownargs(varargin,pairs);
if object >0
    param_owner = obj.param_owner_obj;

else
        param_owner = obj.param_owner;
end;