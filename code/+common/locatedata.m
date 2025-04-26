function folderpath = locatedata()
% Absolute path of the 'data' folder
    repositorypath = fileparts(fileparts(fileparts(mfilename('fullpath'))));
    folderpath = fullfile(repositorypath, 'data');
end