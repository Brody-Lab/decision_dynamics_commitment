function [t d1 dlast] = session_tally(ratname, varargin)
% Gives number of sessions whose data is stored in "infile"
% Used to answer questions like , "How many sessions are buffered in the
% latest post-lesion psychometric file?"

pairs = { ...
    'infile', 'psych_before' ; ...
    'experimenter','Shraddha' ; ...
    };

parse_knownargs(varargin, pairs);

fprintf(1,'Loading %s for %s ...\n', infile, ratname);

global Solo_datadir;
if isempty(Solo_datadir), mystartup; end;
outdir = [Solo_datadir filesep 'Data' filesep experimenter filesep ratname filesep];
fname = [outdir infile '.mat'];

load(fname);

fprintf(1,'File covers sessions from %s to %s\n', dates{1}, dates{end});
t = length(numtrials);

d1 = dates{1};
dlast = dates{end};
