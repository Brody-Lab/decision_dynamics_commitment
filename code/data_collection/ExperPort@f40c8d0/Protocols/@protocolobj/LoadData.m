function [] = LoadData(obj);

% bug fix 101205 - calls child's version of methods
GetSoloFunctionArgs;

if strcmpi(class(value(mychild)),'duration_discobj') || strcmpi(class(value(mychild)),'dual_discobj')
	CurrentTrialPokesSubsection(value(mychild), 'clear_realign');
end;
rpbox('runstart_disable'); % <~> added for consistency with LoadSettings (not terribly important)
load_soloparamvalues(value(ratname), ... % <~> ratname -> value(ratname)
    'child_protocol', mychild, ...
    'experimenter', value(experimenter)); % <~> filenames & directories depend on experimenter name now
rpbox('runstart_enable'); % <~> added for consistency with LoadSettings (not terribly important)

SidesSection(value(mychild),        'set_future_sides');
SidesSection(value(mychild),        'update_plot');
VpdsSection(value(mychild),         'set_future_vpds');
VpdsSection(value(mychild),         'update_plot');
PokeMeasuresSection(value(mychild), 'update_plot');

ChordSection(value(mychild),        'update_prechord');
if isa(value(mychild),'duration_discobj')
    ChordSection(value(mychild),        'update_tone_schedule');
    ChordSection(value(mychild),         'update_tones');
end;
ChordSection(value(mychild),        'make');
