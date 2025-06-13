function [] = lesion_slice_coverage_sandbox

tissue_name = 'mPFC';
use_NX_knowledge = 0;


if strcmpi(tissue_name,'ACx')
ratset = {'Gimli', 'Aragorn', 'Gandalf', 'Lory', 'Bilbo', 'Boromir', 'Sauron', 'Legolas', 'Gryphon', 'Eaglet'};
roiset =  {'AuD','A1','AuV','TeA','Ect','Prh','S1'};
elseif strcmpi(tissue_name,'mPFC')
    ratset = {'Celeborn','Evenstar','Hudson','Moria','Nazgul','Shelob','Sherlock','Shadowfax'}; %'Treebeard','Watson','Wraith'};
    roiset = {'Cg','PrL','IL','MO','M2'};
end;

testrat = 'Celeborn';
curroi = 'MO';
startslice = 3;
endslice =6;
 
                out = lesion_slice_coverage(testrat,curroi, 'graphic',0, ...
                    'slices', startslice:endslice, ...
                    'graphic_gruntwork', 1, 'verbose_gruntwork',1, ...
                    'tissue_name', tissue_name,'valid_rois', roiset, 'use_NX_knowledge', 0, ...
                    'use_interpolated_coords', 1);
                
                2;

