function [] = lesion_loaddata

ratlist = {'S029','S033','S038','S048'};
tissue_name='ACx3';
global Solo_datadir;
indir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Histo' filesep tissue_name filesep 'rat_coords' filesep];

for r=1:length(ratlist)
    ratname=ratlist{r};
    fname = [indir ratname '_coords.mat'];
    load(fname);


    tmp = 0;
    flist = fieldnames(lesion_coords);

    for f=1:length(flist)
        eval(['tmp.' flist{f} '_1=lesion_coords.' flist{f} ';']);
    end;

    lesion_coords=tmp;

    outdir=indir;
    outf=[outdir ratname '_coords2.mat'];
    save(outf, 'lesion_coords');

    clear lesion_coords;
end;


2;