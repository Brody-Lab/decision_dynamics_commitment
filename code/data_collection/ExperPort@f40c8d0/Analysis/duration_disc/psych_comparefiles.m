function [] = psych_comparefiles(ratname)

oldbef = 'psych_before';
newbef='psych_beforeNEW';

global Solo_datadir;
if isempty(Solo_datadir), mystartup; end;
outdir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep ratname filesep ];

% load old
fname = [outdir oldbef '.mat'];
load(fname);

2;
% load new
fname = [outdir newbef '.mat'];
load(fname);
2;



