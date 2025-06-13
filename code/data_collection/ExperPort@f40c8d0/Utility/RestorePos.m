function RestorePos(user,module)
% Restore preferred position on screen for fig corresponding to module
global exper

    prefstr = sprintf('%s_pos',module);
    if ~ispref(user,prefstr)
        return
    end
    pos = getpref(user,prefstr);
    h = findobj('type','figure','tag',module,'parent',0);
    if ~isempty(h) & ishandle(h)
       set(h,'pos',pos);
   end
    
   