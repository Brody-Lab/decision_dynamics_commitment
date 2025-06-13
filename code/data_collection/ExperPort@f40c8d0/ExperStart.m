% EXPER
% This is where it all begins.

global exper

addpath(pwd);
addpath([pwd '/Utility']);
addpath([pwd '/Modules']);

% daqreset;

ModuleInit('Control');
if ~isempty(GetParam('control','user'))
    if strcmp(GetParam('control','user'),'uchida_e')
        
        ModuleInit('ai');
        ModuleInit('valveflow');
        %     ModuleInit('opt');
        %     ModuleInit('blob');
            ModuleInit('group');
        %     ModuleInit('orca');
        %     ModuleInit('till');
        ModuleInit('sequence');
        % need to add one channel to AI even though it's not used
        AI('board_open','nidaq',1);
        AI('add_chan',1,'');
        Control('reset');
        Opt('slicerate');
        Control('restore_layout');
        
    else
        ModuleInit('ai');
        ModuleInit('valveflow');
        ModuleInit('opt');
        ModuleInit('blob');
        ModuleInit('group');
        ModuleInit('orca');
        ModuleInit('till');
        ModuleInit('sequence');
        % need to add one channel to AI even though it's not used
        AI('board_open','nidaq',1);
        AI('add_chan',1,'');
        Control('reset');
        Opt('slicerate');
        Control('restore_layout');
    end
else
    clear exper
end
