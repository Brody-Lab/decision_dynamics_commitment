function [] = lesion_readdata()
% reads rat coordinates (output of AppleScript) and converts to Matlab
% format

% These are the original ACx ibo-lesioned rats
%ratset = {'Gimli', 'Aragorn', 'Gandalf', 'Lory', 'Bilbo', 'Boromir', 'Sauron', 'Legolas', 'Gryphon', 'Eaglet'};

% These are original mPFC ibo-lesioned rats
%{'Celeborn','Evenstar','Hudson','Moria','Nazgul','Shelob','Sherlock','Shadowfax','Treebeard','Watson','Wraith'};

% These are round 2 ACx-lesioned rats
% this is the complete set
%ratset ={'S025','S026','S028','S036','S039','S041','S044','S045','S047','S050'};

% these are rats that had to be redone
% ratset={'S025','S050','S044','S028'};
ratset={'S029','S033','S038','S048'};

% Updates:
% 1. SLICE SWAP HAS BEEN COMMENTED OUT - 15 Jan 09
% 2. Multiple polygons in each hem supported; reading in 5 tokens (hemisphere is now "L2" instead of simply "L").  
% 3. ... 2 overridden to single poly per hem - 13 Nov 09

tissue_name ='ACx3'; 
numcols = 4;

global Solo_datadir;
indir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Histo' filesep tissue_name filesep 'rat_coords' filesep];
outdir=indir;
%histodir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Histo' filesep tissue_name filesep];

for r = 1:length(ratset)
    ratname =ratset{r};
    fprintf(1,'%s\n', ratname);

    % get rats' coordinates
   % indir = [histodir ratname filesep];

    infile = [indir 'source_files' filesep ratname '_coords.txt'];
    outfile = [outdir ratname '_coords.mat'];

    try
        fid = fopen(infile);
    catch error('cannot open file');
    end;
    
    if fid == -1
        error('cannot open file');
    end;

    % read to eof

    % file format
    % each line has 4 values
    % slicenum currhem x-value y-value
    A = fscanf(fid, '%d %c %15f %15f\n', [1 inf]);
    fclose(fid);    

    if mod(length(A),numcols) ~= 0
        error('A should contain multiples-of-%s datapoints', numcols);
    end;

    currslice = 0;
    currhem = 'X';
    currpolynum = 0;

    lesion_coords = [];
    curr_coords = ratname; % array that stores x/y values for a particular slice/hemisphere combination
    xval = ratname;

    for k = 1:numcols:length(A)
        c = A(k:k+(numcols-1));
        slice = c(1); hem = char(c(2)); 
        % Files for ACx3 don't have a polygon number, since it's just one
        % pre hem.
%         polynum = c(3);
        xval = c(3); yval = c(4);
        
%        %% SLICE SWAP!
%     slicenum = str2double(num2str(slice));
%     if slicenum == 2, 
%         slice = '3'; 
%     elseif slicenum == 3, 
%         slice = '2'; 
%     end;
    
        if (slice ~= currslice) || (hem ~= currhem)  %|| (polynum ~= currpolynum) % encountered new combination
            % store old entry.
            sl = num2str(currslice);
%             eval(['lesion_coords.' currhem num2str(sl) '_' num2str(currpolynum) ' = curr_coords;']);
str=['lesion_coords.' currhem num2str(sl) ' = curr_coords;'];
                        eval(str);
            % make new array
            curr_coords = [];

            currslice = slice;
            currhem = hem;
%             currpolynum = polynum;
        end;
        curr_coords = vertcat(curr_coords, [xval yval]);
    end;

    % store the last array
    sl = num2str(currslice);
    eval(['lesion_coords.' currhem num2str(sl) ' = curr_coords;']);

    % save data
    save(outfile, 'lesion_coords');
end;
