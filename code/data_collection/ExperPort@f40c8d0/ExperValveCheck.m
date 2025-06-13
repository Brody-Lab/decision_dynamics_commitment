% EXPER
% This is where it all begins.

global exper

daqreset;

ModuleInit('control');
if ~isempty(GetParam('control','user'))

        ModuleInit('ai');
        % need to add at least one channel to AI 
        AI('board_open','nidaq',1);
        AI('add_chan',6,'');

        ModuleInit('ao');
        ModuleInit('valvecheck');
        ModuleInit('sequence');
        ModuleInit('group');
        Control('restore_layout');
 

        setparam('control','trialdur',10);
        setparam('control','iti',15);
        setparam('control','advance',1);

        Control('reset');
        

else
    clear exper
end
