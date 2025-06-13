function [] = LoadSettings(obj);

% bug fix: 101205 - All child's methods are called for updati
GetSoloFunctionArgs;

rpbox('runstart_disable');
load_solouiparamvalues(value(ratname), ... % <~> ratname -> value(ratname)
    'child_protocol', mychild, ...
    'experimenter', value(experimenter)); % <~> filenames & directories depend on experimenter name now
rpbox('runstart_enable');

SidesSection(value(mychild), 'set_future_sides');
SidesSection(value(mychild), 'update_plot');
VpdsSection(value(mychild), 'set_future_vpds');
VpdsSection(value(mychild), 'update_plot');
ChordSection(value(mychild), 'update_prechord');
if isa(value(mychild),'duration_discobj')
    ChordSection(value(mychild), 'update_tone_schedule');
    ChordSection(value(mychild), 'update_tones');
end;
ChordSection(value(mychild), 'make');
