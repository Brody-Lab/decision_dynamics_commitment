function [] = savegraphic(graphicname, foldername, varargin)
% Save a graphical item to be used as part of a manuscript figure
%
% ARGUMENTS
%
% 	graphicname
%       the name of the file to which the graphical item will be saved
%
%   foldername
%       the name of the folder
%
% OPTIONAL ARGUMENTS
%
%   extensions
%       a char row vector specifying the extensions of the saved
%   figure
%       the handle of the MATLAB figure
%
%   overwrite
%       a scalar logical whether to overwrite the existing figure
folderpath = fullfile(M23a.locateassets, foldername);
P = inputParser;
addParameter(P, 'extension', 'svg', @(x) ischar(x) && isrow(x))
addParameter(P, 'figure', gcf, @(x) validateattributes(x, {'handle'}, {}))
addParameter(P, 'overwrite', false, @(x) validateattributes(x, {'logical'}, {'scalar'}))
parse(P, varargin{:});
P = P.Results;
if ~exist(folderpath, 'dir')
    error('this folder does not exist: "%s"', folderpath)
end
graphicpath = fullfile(folderpath, [graphicname '.' P.extension]);
if exist(graphicpath, 'file')
    if P.overwrite
        delete(graphicpath)
        saveas(P.figure, graphicpath);
    else
        warning('\n%s.m: this file exists and not overwritten:"%s"\n', mfilename, graphicpath)
    end
else
    saveas(P.figure, graphicpath);
end