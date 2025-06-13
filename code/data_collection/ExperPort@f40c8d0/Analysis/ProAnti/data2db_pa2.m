function data2db

% start in SoloData/Data

exper={'Jeff','Carlos'};

for ex=1:numel(exper)

    cd(exper{ex});

    check_rats;

    cd ..
end




function check_rats

ddir=dir;

for dx=1:numel(ddir)

    if ddir(dx).name(1)=='.' || isequal(ddir(dx).name,'CVS')
        % display('skipping')
    elseif ddir(dx).isdir

        cd(ddir(dx).name)

        find_pa2_files

        cd ..
    end
end


function find_pa2_files

ddir=dir('data_@ProAnti2*');

for dx=1:numel(ddir)

    try
        add_PA2data_to_db(ddir(dx).name);
        fprintf(1,'added %s\n', ddir(dx).name);
        
    catch
        fprintf(2,'Fucked the pooch on %s\n', ddir(dx).name);
    end


end
