function [] = fwrite_cell(p_cell, fstring, fname)
% Writes contents of given cell array to an Excel file. The cell should be
% 1-by-c in size, the first row of which is a header (see format below).
% Each subsequent row is a column array. 'fstring' is the format used to
% write each entry of this column array in the output file.
% 
% Arguments:
% p_cell is the cell to be written to the Excel file
% 'fstring' is the format string used to write each datapoint.
% outfile is the file in Solo_datadir/data/ to which to write the data.
%
% Sample p_cell
% p_cell{1} = char('Header1', 'Header2', 'Header3');
% p_cell{2} = [ 1 2 3 ];
% p_cell{3} = [ exp(1)  -1.000  76.34 ];
%
% Use: fwrite_cell(p_cell, '%2.3f', 'my_dummy_file.txt');
% Note header format (p_cell{1}).

rows = size(p_cell,2);
cols = length(p_cell{2});

% global Solo_datadir;
% fname = [Solo_datadir filesep 'data' filesep outfile];
fid = fopen(fname, 'w');

% print header
h_char = p_cell{1};
fmt_string = '';
for k = 1:cols-1, 
    fprintf(fid,'%s\t', h_char(k,:));   
    fmt_string=[fmt_string [fstring '\t']];    % each col of data is fstring 
end;

fprintf(fid,'%s\n', h_char(cols,:));
fmt_string = [fmt_string [fstring '\n']];

for r = 2:rows
    fprintf(fid,fmt_string,cell2mat(p_cell{r}));
end;


fclose(fid);



