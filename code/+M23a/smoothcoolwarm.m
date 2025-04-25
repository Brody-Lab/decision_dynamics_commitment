function C = smoothcoolwarm()
% Diverging (double-ended) color map with a smooth transition in the middle to prevent artifacts at
% the midpoint. This color map avoids dark colors to provide shading cues throughout its range.
%
% Obtained from https://www.kennethmoreland.com/color-advice/

C = readmatrix(fullfile(M23a.locateassets, 'smoothcoolwarm.csv'));