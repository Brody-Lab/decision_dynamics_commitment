function [] = lesion_histofile_readdata()
% reads output of polygon_coords_X.scpt which is Applescript-output in text
% format and converts it into Matlab structs

% Expects input in a five-column space-separated plaintext format:
% column 1: brain area abbreviation - Prh, AuD, AuV, A1, TeA, Ect, S1
% column 2: slice # in the extracted set of the rat brain atlas
% column 3: hemsiphere - L, R
% column 4: x-value of polygon vertex
% column 5:
% Prh 1 R 100.0322265625 243.935546875
% Prh 1 R 156.1611328125 252.322265625
% Prh 1 R 153.58056640625 220.064453125
% Prh 1 R 104.54833984375 200.064453125

%tissue_name ='ACx';
tissue_name = 'ACx2'; %%% NOTE: SLICE SWAP HAS BEEN COMMENTED OUT (JAN 15 09)
numcols = 5;

global Solo_datadir;
%histodir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Histo' filesep tissue_name filesep];
histodir = ['..' filesep 'Histo' filesep tissue_name filesep 'polymark' filesep];
% this is the file which has the output of the Applescript with area
% coordinates
infile = [histodir 'intermediate_file' filesep 'polygon_coords_NEWROSTRAL.txt'];

try
    fid = fopen(infile);
catch error('cannot open file');
end;

% read to eof

% file format
% each line has 5 values
% roi slicenum currhem x-value y-value
A = fscanf(fid, '%3s %d %c %15f %15f\n', [1 inf]);
fclose(fid);

currslice = 0;
currhem = 'X';
curr_ba = 'Y';

lesion_coords = 0;
curr_coords = 'blah'; % array that stores x/y values for a particular slice/hemisphere combination
xval = 'blah';

existing_structs = {}; % names of structs created for each brain area

k = 1;
while k < length(A)
    % if this is a 3-letter brain area name then position (3) + 1+ 1 = 5 
    % 5 should be an integer of either L (76) or R (82)
    puthem = A(k+4);
    if (rem(puthem,1) == 0) && (puthem == 76 || puthem == 82)
        br_area = char(A(k:k+2));
        slice = A(k+3);
        hem = char(A(k+4));
        xval = A(k+5);
        yval = A(k+6);
        nextk = k+7;
    else
        br_area = char(A(k:k+1));
        slice = A(k+2);
        hem = char(A(k+3));
        xval = A(k+4); yval = A(k+5);
        nextk = k+6;
    end;    
%     %% SLICE SWAP!
%     slicenum = str2double(num2str(slice));
%     if slicenum == 2, 
%         slice = '3'; 
%     elseif slicenum == 3, 
%         slice = '2'; 
%     end;
    
    if ~strcmpi(br_area,curr_ba) || (slice ~= currslice) || (hem ~= currhem) % encountered new combination
        % make a new struct for it if necessary
        tmp = [curr_ba '_coords'];
        if ~exist(tmp)
            eval([tmp ' = [];']);        
            existing_structs{end+1} = tmp;
        end;
        
        % store old entry.
        sl = num2str(currslice);
        eval([tmp '.' currhem sl ' = curr_coords;']);
        % make new array
        curr_coords = [];

        currslice = slice;
        currhem = hem;
        curr_ba = br_area;
    end;
    curr_coords = vertcat(curr_coords, [xval yval]);
    
    k = nextk;
end;

tmp = [curr_ba '_coords'];
% store the last array
sl = num2str(currslice);
eval([tmp '.' currhem sl ' = curr_coords;']);

% save data
%save(outfile, 'lesion_coords');


for k = 1:length(existing_structs)
  underscores = findstr(existing_structs{k}, '_');
  pfx = existing_structs{k}; pfx = pfx(1:underscores(1)-1);
  outfile = [histodir 'polygon_coords__' pfx '_NEWROSTRAL.mat'];
  
  save(outfile, existing_structs{k});
end;

2;



