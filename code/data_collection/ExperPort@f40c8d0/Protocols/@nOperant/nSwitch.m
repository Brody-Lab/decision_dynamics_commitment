function [ ] = nSwitch(obj, action)

GetSoloFunctionArgs;

switch action,
    case 'init',
        
flush;
newstartup;
dispatcher('init')
dispatcher('set_protocol', 'nprotocol2')


        

end;        
