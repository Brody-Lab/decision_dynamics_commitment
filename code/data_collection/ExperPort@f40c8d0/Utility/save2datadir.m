function [] = save2datadir(rat, fname, varargin)
% saves given variables to rat-specific data folder

savestring = '';

if nargin < 3
    error('Need atleast 3 arguments: the rat name, the filename, and data to be saved');
elseif mod(numel(varargin),2) > 0
    error('Need even number of args in varargin: name-value pairs');
else
    k = length(varargin);
    names = varargin(1:2:k-1); values = varargin(2:2:k);
    for i = 1:(k/2)
        eval([names{i} ' = values{i};']);
        if i > 1, savestring = [savestring ', '];end;
        savestring = [savestring '''' names{i} ''''];
    end;
end;

global Solo_datadir;
if isempty(Solo_datadir), mystartup; end;

rat_dir = [Solo_datadir filesep 'data' filesep rat filesep];
if ~exist(rat_dir, 'dir')
    error('Rat directory does not exist. Create it first');
end;

fname = [rat_dir fname '.mat'];

try   
    eval(['save(fname, ' savestring ');']);
catch
    error('Error while saving data. Data not saved.');
end;

