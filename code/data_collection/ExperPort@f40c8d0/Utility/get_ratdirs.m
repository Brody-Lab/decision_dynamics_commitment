function [dir_names] = get_ratdirs()

global Solo_datadir;
if isempty(Solo_datadir), mystartup; end;

datadir = [Solo_datadir filesep 'Data']; b = ls(datadir);
c = cellstr(b);
matches = regexp(c, '(\S+)', 'tokens'); matches = matches{1};

% get rat names
dir_names = cell(0,0); dctr= 1;
for k = 1:length(matches)
    m = matches{k}; m = m{1}; 
  %  fprintf(1, '%s\n', m);
    if exist([datadir filesep m], 'dir') && ~strcmp(m, 'CVS')
  %      fprintf(1, '\tIs Dir\n');
  dir_names{dctr} = m; dctr =  dctr + 1;
    end;
end;
