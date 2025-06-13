function [] = LoadData(obj);

% bug fix 101205 - calls child's version of methods
GetSoloFunctionArgs;

load_soloparamvalues(RatName, 'child_protocol', mychild);

SidesSection(value(mychild),        'set_future_sides');
SidesSection(value(mychild),        'update_plot');
