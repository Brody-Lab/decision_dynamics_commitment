function [] = LoadSettings(obj);

% bug fix: 101205 - All child's methods are called for updating
GetSoloFunctionArgs;

load_solouiparamvalues(RatName, 'child_protocol', mychild);

SidesSection(value(mychild), 'set_future_sides');
SidesSection(value(mychild), 'update_plot');
