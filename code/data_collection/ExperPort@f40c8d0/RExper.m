% REXPER
% Review exper

global exper

addpath(pwd);
addpath([pwd '\utility']);
addpath([pwd '\modules']);


ModuleInit('control','reinit');
if ExistParam('control','sequence') % this is an abitrary parameter just to check that control has been initialized
    ModuleInit('group');
    ModuleInit('sequence');
   % Control('modreload','orca');
    Control('modreload','opt');
    Control('modreload','group');
    Control('modreload','blob');
end


