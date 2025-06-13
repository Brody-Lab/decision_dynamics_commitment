% EXPER
% This is where it all begins.

%clear exper
global exper


addpath(pwd);

addpath([pwd '\Protocols']);
addpath([pwd '\utility']);
addpath([pwd '\modules']);
addpath([pwd '\soundtools']);

daqreset;

ModuleInit('control');
SetParam('control','slicerate','value',4,'range',[0 5]);
SetParam('control','trialdur',10);
SetParam('control','iti',0);
SetParam('control','advance',1);

% ModuleInit('ai');
% ai('board_open','nidaq',1);
% set(exper.ai.daq,'InputType','NonReferencedSingleEnded')
% ai('samplerate',1000);
% 
% ai('add_chan',0,'nosepoke');
% % SetParam('ai','hwtrigger',1);AI('hwtrigger');
% SetParam('ai','save',0);
% AI('save');
% Explicitly set sampling rate.

% ModuleInit('dio');

ModuleInit('rpbox');
% ModuleInit('pathdisplay');
Control('restore_layout');
Control('reset');
% turn off control auto-save
set(findobj('tag','autosave'),'Checked','off');

% ModuleInit('ao');
% AO('board_open','nidaq',1);
% set(exper.ai.daq,'Transfermode','Interrupts')
% ModuleInit('fakerat');
% ModuleInit('operant');