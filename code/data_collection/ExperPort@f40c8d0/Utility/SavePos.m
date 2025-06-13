function SavePos(user,module)
global exper

    h = findobj('type','figure','tag',module,'parent',0);
    pos = get(h,'position');
    prefstr = sprintf('%s_pos',module);
    SetPref(user,prefstr,pos);
    
    
    