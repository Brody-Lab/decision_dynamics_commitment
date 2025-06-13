function out = bdata_connect()
% function out = BDATA_CONNECT()
%
% Modify user's path depending on system type to allow connections to bdata.
% Add correct mym version for your system to the path
%
% See also BDATA

this_path = fileparts(mfilename('fullpath'));
setenv('MYM_USE_32BIT_DIMS', 'true')

% Get correct mym path depending on your version:
if ismac
    mym_path = fullfile(this_path, 'mym_mac');
elseif ispc
    is_64_bit = contains(computer, '64');
    if is_64_bit
        mym_path = fullfile(this_path, 'win64_2019b');
    else
        mym_path = fullfile(this_path, 'mym_32bits');
    end
else
    mym_path = fullfile(this_path, 'mym_linux');
end

other_paths = dir(this_path);
dirFlags = [other_paths.isdir];
% Extract only those that are directories.
other_paths = other_paths(dirFlags); % A structure with extra info.
% Get only the folder names into a cell array.
other_paths = {other_paths(3:end).name}; % Start at 3 to skip . and ..

% Remove unnecessary mym directories from path
warning('off','MATLAB:rmpath:DirNotFound')
for i=1:length(other_paths)
    this_mym_path = fullfile(this_path,other_paths{i});
    rmpath(genpath(this_mym_path));
end
warning('on','MATLAB:rmpath:DirNotFound')

% Add the correct mym path 
addpath(genpath(mym_path));

% connect to DB
out = bdata('connect');

end
