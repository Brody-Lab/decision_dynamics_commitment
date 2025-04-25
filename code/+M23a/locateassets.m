function folderpath = locateassets()
% Absolute path of the 'assets' folder
    repositorypath = fileparts(fileparts(fileparts(mfilename('fullpath'))));
    folderpath = fullfile(repositorypath, 'assets');
end