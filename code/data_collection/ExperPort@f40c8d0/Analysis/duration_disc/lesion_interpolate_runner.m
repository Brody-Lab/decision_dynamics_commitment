function [] = lesion_interpolate_runner

tissue_name = 'mPFC';
setsize = 21;
ratset = {'Celeborn','Evenstar','Hudson','Moria','Nazgul','Shelob','Sherlock','Shadowfax','Treebeard','Watson','Wraith'};
swap2and3=0;
%ratset={'Evenstar'};

%ratset = {'Aragorn','Gimli', 'Lory', 'Bilbo', 'Boromir', 'Sauron', 'Legolas', 'Gryphon', 'Eaglet'};

for r = 1:length(ratset)
    ratname = ratset{r};
    fprintf(1,'%s...\n', ratname);
    lesion_interpolate(ratname,'averageshape_interp', ...
        'tissue_name', tissue_name, 'maxslices', setsize, 'swap2and3', swap2and3, 'graphic', 0);  
end;