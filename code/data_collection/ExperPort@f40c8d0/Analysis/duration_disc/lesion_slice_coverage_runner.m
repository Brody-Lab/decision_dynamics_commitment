function [] = lesion_slice_coverage_runner(varargin)

% loops through rat set and list of rois, making a mega struct with
% coverage information per rat.
% Ideally you want the output of this file stored in a datafile so you can
% retrieve it for visualization purposes

% input/output file we deal with
tissue_name = 'ACx3';
use_NX_knowledge = 0;
use_interpol_coords = 0; % use coordinates made by running averageshape (lesion_interpolate_runner.m)

global Solo_datadir;
histodir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Histo' filesep tissue_name filesep];
% histodir=['..' filesep 'Histo' filesep tissue_name filesep];
outfile = [histodir 'lesion_coverage_calc_Hpc.mat'];

if strcmpi(tissue_name,'ACx')
    ratset = {'Gimli', 'Aragorn', 'Gandalf', 'Lory', 'Bilbo', 'Boromir', 'Sauron', 'Legolas', 'Gryphon', 'Eaglet'};
    roiset =  {'AuD','A1','AuV','TeA','Ect','Prh','S1'};
elseif strcmpi(tissue_name,'mPFC')
    ratset = {'Celeborn','Evenstar','Hudson','Moria','Nazgul','Shelob','Sherlock','Shadowfax','Treebeard','Watson','Wraith'};
    %ratset={'Evenstar'};
    roiset = {'Cg','PrL','IL','MO','M2'};
elseif strcmpi(tissue_name,'ACx2')
    ratset ={'S036','S039','S026','S028','S041','S025','S044','S045','S047','S050'};
    roiset =  {'AuD','A1','AuV','TeA','Ect','Prh','S1'};
elseif strcmpi(tissue_name,'ACx3')
    ratset ={'S033','S029','S038','S048'};
    roiset =  {'Hpc'}; %{'AuD','A1','AuV','TeA','Ect','Prh','S1','Hpc'};
end;
%roiset = {'AuV'};

if nargin > 0
    action = varargin{1};
else
    action = 'nothing';
end;

switch action
    case 'save_coverage'
        savestmt = 'save(outfile,';

        for r = 1:length(ratset)
            ratname = ratset{r};
            fprintf(1,'%s: ...\n', ratname);
            eval([ratname '_lesioncvg = [];']);

            for k = 1:length(roiset)
                curroi = roiset{k};
                %   try
                fprintf(1,'\t...%s\n', curroi);
                out = lesion_slice_coverage(ratname,curroi, 'graphic',0, ...
                    'tissue_name', tissue_name,'valid_rois', roiset, 'use_NX_knowledge', 0, ...
                    'use_interpolated_coords', use_interpol_coords);
                eval([ratname '_lesioncvg.' curroi ' = out;']);
                %         catch
                %             eval([ratname '_lesioncvg.' curroi ' = -1;']);
                %         end;
            end;

            savestmt = horzcat(savestmt, ['''' ratname '_lesioncvg''']);
            if r < length(ratset), savestmt = horzcat(savestmt, ','); end;
        end;
        savestmt = horzcat(savestmt, ');');

        eval(savestmt);


    case 'addon_lesionpts'
        load(outfile);
        for r = 1:length(ratset)
            ratname = ratset{r};
            fprintf(1,'%s: ...\n', ratname);

            curroi = roiset{1};
            %   try
            out = lesion_slice_coverage(ratname,curroi, 'graphic',0,...
                'tissue_name', tissue_name,'valid_rois', roiset, 'use_NX_knowledge', 0, ...
                'use_interpolated_coords', 0);
            eval([ratname '_lesioncvg.lesionpt__L  = out.lesionpt__L;']);
            eval([ratname '_lesioncvg.lesionpt__R  = out.lesionpt__R;']);
        end;

        save(outfile, ...
            'Aragorn_lesioncvg','Bilbo_lesioncvg','Boromir_lesioncvg','Eaglet_lesioncvg',...
            'Gimli_lesioncvg','Gandalf_lesioncvg','Gryphon_lesioncvg','Legolas_lesioncvg',...
            'Lory_lesioncvg', 'Sauron_lesioncvg');

    case 'nothing'
        fprintf(1,'Doing nothing. Call me with an action so I''m actually doing work!\n');

    otherwise
        error('Sorry, not implemented');
end;



2;
