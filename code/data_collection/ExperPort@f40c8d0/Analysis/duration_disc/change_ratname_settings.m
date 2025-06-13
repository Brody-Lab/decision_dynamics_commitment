function [] = change_ratname_settings(newrat,date,varargin)

pairs = { ...
    'classical', 1 ; ... % are we loading a classical2afc file?
 };
parse_knownargs(varargin,pairs);

[status fname] = load_datafile(newrat,date,'classical',classical, 'ftype','Settings');

saved.SavingSection_ratname = newrat;

save(fname, 'saved','saved_autoset', 'fig_position');


2;