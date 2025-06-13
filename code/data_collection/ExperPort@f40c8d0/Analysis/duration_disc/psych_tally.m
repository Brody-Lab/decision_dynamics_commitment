function [] = psych_tally(ratlist, fname)

% prepare incase file needs to be loaded
global Solo_datadir;
if isempty(Solo_datadir), mystartup; end;
outdir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep]; 

if ~(strcmpi(fname,'psych_before') || strcmpi(fname,'psych_after'))
   error('fname should be one of ''psych_before'' and ''psych_after''');
end;

fprintf(1,'%s\n',repmat('-',1,50));
fprintf(1,'Tally for %s:\n', fname);
for r = 1:length(ratlist)
    ratname = ratlist{r};
    infile = [outdir ratname filesep fname];
    
    load(infile);
    fprintf(1,'%s=%i sessions\n', ratname, length(numtrials));
end;

fprintf(1,'%s\n',repmat('-',1,50));