function [] = lesion_polymarkreorder

% this script reorders the polymark_*.ai coordinates into rostrocaudal
% progression.
% it has only been written for ACxround2, and parameters are hard-coded.
% Shraddha, March 09.

% assumption : each roi is either present bilaterally or not at all.

tissue_name = 'ACx2';
roilist = {'S1','AuD','A1','AuV','Ect','Prh','TeA'};
histodir = ['..' filesep 'Histo' filesep tissue_name filesep 'polymark' filesep];


for roi=1:length(roilist)
    curroi=roilist{roi};
    newrostral = [histodir  'intermediate_file' filesep 'polygon_coords__' curroi '_NEWROSTRAL.mat'];
    newcaudal = [histodir  'intermediate_file' filesep 'polygon_coords__' curroi '_NEWCAUDAL.mat'];
    mainfile = [histodir  'intermediate_file' filesep 'polygon_coords__' curroi '.mat'];
    newfile = [histodir 'polygon_coords__' curroi '_reordered.mat'];

    newstruct = [curroi '__coordsNEW'];
    eval([newstruct '=[];']);

    % PIECE 1: put new rostral first
    if exist(newrostral, 'file')
        fprintf(1,'%s: Found rostral\n', roilist{roi});
        load(newrostral);
        % new rostral we know starts at 34 and goes to 45.
        for pos=1:12
            if isfield(eval([curroi '_coords']), ['L' num2str(pos+33)])
                eval([newstruct '.L' num2str(pos) '=' curroi '_coords.L' num2str(pos+33) ';']);
                eval([newstruct '.R' num2str(pos) '=' curroi '_coords.R' num2str(pos+33) ';']);
            end;
        end;
        eval(['clear ' curroi '_coords;']); % clear before moving to next set
    end;

    % PIECE 2: we know that existing data runs from 13 to 45 for ACx2
    % NOTE -- Numbering starts at 1, not 13!
    load(mainfile);
    pos=12;
    for k=1:33
        if isfield(eval([curroi '_coords']), ['L' num2str(k)])
            eval([newstruct '.L' num2str(pos+k) '=' curroi '_coords.L' num2str(k) ';']);
            eval([newstruct '.R' num2str(pos+k) '=' curroi '_coords.R' num2str(k) ';']);
        end;
    end;
    eval(['clear ' curroi '_coords;']); % clear before moving to next set

    % PIECE 3: end with caudal -- numbering starts at 46
    if exist(newcaudal,'file')
        fprintf(1,'%s: Found caudal\n', roilist{roi});
        load(newcaudal);
        for pos=46:47
            if isfield(eval([curroi '_coords']), ['L' num2str(pos)])
                eval([newstruct '.L' num2str(pos) '=' curroi '_coords.L' num2str(pos) ';']);
                eval([newstruct '.R' num2str(pos) '=' curroi '_coords.R' num2str(pos) ';']);
            end;
        end;
    end;
    eval(['clear ' curroi '_coords;']); % clear before moving to next set

    eval([curroi '_coords = ' newstruct ';']);
    2;

    save(newfile, [curroi '_coords']);

end;
