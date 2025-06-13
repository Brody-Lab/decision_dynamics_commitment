function [x_coord, y_coord, ch, good_targets] = ExtractLED(box, x, y, color, valid_targets, varargin)
% function [x_coord, y_coord, ch, good_targets] = ExtractLED(box, x, y, color, valid_targets, varargin)
% 
% takes in the parameters extracted by ExtractFromTargets.m (provided by Neuralynx) and
% identifies the leds within the area specified by box
%
% 1) keep only the channels specified in the arguments
% 2) crops out points beyond the rectangle ROI
% 3) average targets of the same color which are within P pixels from each other
%
%
% Inputs:
%       x - an M by N matrix where M = the number of records and N = number of x coordinates per record.
%           this value represents the x coordinate of a given target.
%       y - an M by N matrix where M = the number of records and N = number of y coordinates per record.
%           this value represents the y coordinate of a given target.
%       color - an M by N by 7 matrix where M = the number of records and N = number of colors per record.
%           The 7 represents the 7 types of color information that is stored.
%           this value represents the color of a given target, or zero if that color is not present, or one if present.
%           color(:,:,1) = Raw Red
%           color(:,:,2) = Pure Red
%           color(:,:,3) = Raw Green
%           color(:,:,4) = Pure Green
%           color(:,:,5) = Raw Blue
%           color(:,:,6) = Pure Blue
%           color(:,:,7) = Luminance
%       valid_targets - a matrix containing the number of values for each N in the above variables.
%           this value represents the number of targets per record (which
%           varies from record to record).
%
% Varargin:
%       pix - threshold distance under which targets of the same channel are consolidated into
%           one, in pixels
%       channels - a 1 by 7 matrix where each element is 1 or 0,
%           designating if that color channel (see color) should be kept.
%           For example, channels = [0 0 0 1 0 1 0] means keep only the
%           pure green and pure blue channels, ignoring all others.
%       record_index - the color channels (out of 1:7) to look for 
%
%
% Outputs:
%       x_coord and y_coord are row vectors containing the coordinates of
%       the identified LEDs
%
%
%
% BWB, April 2008

pairs = { ...
    'pix'            10 ; ...
    'channels'       [4 6]; ... % blue and green channels
    'record_index'   []; ...
}; parseargs(varargin, pairs);

if isempty(record_index) && ~isempty(color),
    record_index = 1; % by default, process only the first record
elseif isempty(color),
    error('No targets!');
    return;
end;

if isreal(record_index),  % proces only the first record
    record_index = record_index(1);
end;

num_targets = valid_targets(record_index);

x_coord = zeros(1, num_targets);  % row vectors
y_coord = zeros(1, num_targets);
ch = zeros(1, num_targets);
for t = 1:num_targets,
    tcolor = color(record_index, t, 1:7);

    if sum(tcolor(channels)) > 0,  % if it's one of the channels we want
        x_coord(t) = x(record_index, t);
        y_coord(t) = y(record_index, t);
        ch(t)      = find(tcolor>0, 1);
    end;
end;

ins = isinside(x_coord, y_coord, box);

x_coord = nonzeros(ins .* x_coord);
y_coord = nonzeros(ins .* y_coord);
ch      = nonzeros(ins .* ch);

junk = [];
for couleur = 1:length(channels),
    guys = find(ch == channels(couleur));

    if ~isempty(guys),
        D = pdist([x_coord(guys) y_coord(guys)]);  % compute Euclidean dist.
        D = D < pix;  % find those distances smaller than pix
        D = squareform(D);
        
        for i = 1:rows(D)
            if ~ismember(guys(i), junk),
                for j = i+1:cols(D)
                    if D(i, j) > 0,  % if the two coords are closer than pix
                        t1 = guys(i);
                        t2 = guys(j);
                        x_coord(t1) = mean([x_coord(t1), x_coord(t2)]); % average
                        y_coord(t1) = mean([y_coord(t1), y_coord(t2)]);
                        junk = [junk t2]; % mark second coord for discard
                    end;
                end;
            end;
        end;
    end; % end if guys not empty
end;

junk = unique(junk);
keep = setdiff(1:length(x_coord), junk);
x_coord = x_coord(keep);
y_coord = y_coord(keep);
ch      = ch(keep);
good_targets = length(keep);