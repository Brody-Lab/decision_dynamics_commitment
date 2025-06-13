% function [cell_array_out] = SetCalib(olf, comp, calibtable)
%
% Set the entire contents of the in-memory calibration table for a
% PIDFlow controller.  See GetCalib.
function [out] = SetCalib(olf, comp, calibtable)
    if (~isnumeric(calibtable) | size(calibtable,2) ~= 2),
        error('Please pass an Mx2 matrix of doubles for the calibration table!');
    end;
    lines = {};
    for i=1:size(calibtable,1),
        line = sprintf('%d %d\n', calibtable(i,1), calibtable(i,2));
        lines=vertcat(lines, line);
    end;
    lines = vertcat(lines, sprintf('\n'));
    out = DoUpdateCmd(olf, sprintf('SET CALIB %s', comp), lines);
    out = 1;