% Start a protocol for a particular animal
%
% Santiago Jaramillo - 2007.04.10
%
% NOTES: it cannot work as a function, because some variables need
% global scope.

%%% First run: 
%%%
%%% flush; newstartup; dispatcher('init');

[RootDir,CurrentDir]=fileparts(pwd);
if(~strcmp(CurrentDir,'ExperPort'))
    disp('You need to change to ExperPort directory.');
    return
end

if(strcmp(AnimalName,'saja017')|strcmp(AnimalName,'saja018')|...
   strcmp(AnimalName,'saja023')|strcmp(AnimalName,'saja024')|...
   strcmp(AnimalName,'saja027')|strcmp(AnimalName,'saja028')|...
   strcmp(AnimalName,'saja029')|strcmp(AnimalName,'saja030')|...
   strcmp(AnimalName,'saja031')|strcmp(AnimalName,'saja032')|...
   strcmp(AnimalName,'saja033')|strcmp(AnimalName,'saja034'))
   ProtocolName = 'saja_detection';
elseif(strcmp(AnimalName,'saja035')|strcmp(AnimalName,'saja036'))
    ProtocolName = 'saja_norush';
else
    ProtocolName = 'saja_detection';
end

Experimenter = 'santiago'; 

dispatcher('close_protocol'); dispatcher('set_protocol',ProtocolName);

ThisSPH=get_sphandle('owner', ProtocolName, 'name','experimenter');
ThisSPH{1}.value = Experimenter;

ThisSPH=get_sphandle('owner', ProtocolName, 'name','ratname');
ThisSPH{1}.value = AnimalName;

switch AnimalName
    case 'saja017'
        ThisSPH=get_sphandle('owner', ProtocolName, 'name','AutoCommandsMenu');
        ThisSPH{1}.value_callback = 'ChangeDelayByBlocks';
        ThisSPH=get_sphandle('owner', ProtocolName, 'name','PsychCurveMode');
        ThisSPH{1}.value_callback = 'on';
    case 'saja018'
        ThisSPH=get_sphandle('owner', ProtocolName, 'name','AutoCommandsMenu');
        ThisSPH{1}.value_callback = 'ChangeDelayByBlocks';
        ThisSPH=get_sphandle('owner', ProtocolName, 'name','PsychCurveMode');
        ThisSPH{1}.value_callback = 'on';
    case 'saja023'
        ThisSPH=get_sphandle('owner', ProtocolName, 'name','AutoCommandsMenu');
        ThisSPH{1}.value_callback = 'ChangeDelayByBlocks';
        ThisSPH=get_sphandle('owner', ProtocolName, 'name','PsychCurveMode');
        ThisSPH{1}.value_callback = 'on';
    case 'saja024'
        ThisSPH=get_sphandle('owner', ProtocolName, 'name','AutoCommandsMenu');
        ThisSPH{1}.value_callback = 'ChangeDelayByBlocks';
        ThisSPH=get_sphandle('owner', ProtocolName, 'name','PsychCurveMode');
        ThisSPH{1}.value_callback = 'on';
    case 'saja027'
        ThisSPH=get_sphandle('owner', ProtocolName, 'name','AutoCommandsMenu');
        ThisSPH{1}.value_callback = 'ChangeDelayByBlocks';
        ThisSPH=get_sphandle('owner', ProtocolName, 'name','PsychCurveMode');
        ThisSPH{1}.value_callback = 'on';
    case 'saja028'
        ThisSPH=get_sphandle('owner', ProtocolName, 'name','AutoCommandsMenu');
        ThisSPH{1}.value_callback = 'ChangeDelayByBlocks';
        ThisSPH=get_sphandle('owner', ProtocolName, 'name','PsychCurveMode');
        ThisSPH{1}.value_callback = 'on';
    case 'saja029'
        ThisSPH=get_sphandle('owner', ProtocolName, 'name','AutoCommandsMenu');
        ThisSPH{1}.value_callback = 'ChangeDelayByBlocks';
        ThisSPH=get_sphandle('owner', ProtocolName, 'name','PsychCurveMode');
        ThisSPH{1}.value_callback = 'on';
    case 'saja030'
        ThisSPH=get_sphandle('owner', ProtocolName, 'name','AutoCommandsMenu');
        ThisSPH{1}.value_callback = 'ChangeDelayByBlocks';
        ThisSPH=get_sphandle('owner', ProtocolName, 'name','PsychCurveMode');
        ThisSPH{1}.value_callback = 'on';
    case 'saja031'
        ThisSPH=get_sphandle('owner', ProtocolName, 'name','AutoCommandsMenu');
        ThisSPH{1}.value_callback = 'ChangeDelayByBlocks';
        ThisSPH=get_sphandle('owner', ProtocolName, 'name','PsychCurveMode');
        ThisSPH{1}.value_callback = 'on';
    case 'saja032'
        ThisSPH=get_sphandle('owner', ProtocolName, 'name','AutoCommandsMenu');
        ThisSPH{1}.value_callback = 'ChangeDelayByBlocks';
        ThisSPH=get_sphandle('owner', ProtocolName, 'name','PsychCurveMode');
        ThisSPH{1}.value_callback = 'on';
    case 'saja033'
        ThisSPH=get_sphandle('owner', ProtocolName, 'name','AutoCommandsMenu');
        ThisSPH{1}.value_callback = 'ChangeDelayByBlocks';
        ThisSPH=get_sphandle('owner', ProtocolName, 'name','PsychCurveMode');
        ThisSPH{1}.value_callback = 'on';
    case 'saja034'
        ThisSPH=get_sphandle('owner', ProtocolName, 'name','AutoCommandsMenu');
        ThisSPH{1}.value_callback = 'ChangeDelayByBlocks';
        ThisSPH=get_sphandle('owner', ProtocolName, 'name','PsychCurveMode');
        ThisSPH{1}.value_callback = 'on';
    otherwise
        % Do nothing        
end


if(strcmp(AnimalName,'test'))
ThisSPH=get_sphandle('owner', ProtocolName, 'name','WaterDeliverySPH');
ThisSPH{1}.value = 'direct';
ThisSPH=get_sphandle('owner', ProtocolName, 'name','RelevantVolume');
ThisSPH{1}.value = 0.001;
end


return

%%%%%%%%% OTHER OPTIONS %%%%%%%%%

        %ThisSPH=get_sphandle('owner', ProtocolName, 'name','TargetModIndex');
        %ThisSPH{1}.value_callback = 0.01;

        %ThisSPH=get_sphandle('owner', ProtocolName, 'name','AutoCommandsMenu');
        %ThisSPH{1}.value_callback = 'CueingByBlocks';

        %ThisSPH=get_sphandle('owner', ProtocolName, 'name','AdaptiveMode');
        %ThisSPH{1}.value_callback = 'on';
