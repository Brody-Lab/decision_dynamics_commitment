function  [] = LoadRealignedData(obj);

GetSoloFunctionArgs;
CurrentTrialPokesSubsection(value(mychild), 'set_realign');

load_soloparamvalues(RatName, 'child_protocol', mychild, 'realign', 1);

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
